package Alien::LibMagic::ModuleBuild;

use strict;
use warnings;

use parent 'Alien::Base::ModuleBuild';
use Archive::Extract;
use File::Copy;
use File::Spec;
use Module::Load;

sub alien_do_commands {
	my ($self, $phase) = @_;
	my $dir = $self->config_data( 'working_directory' );

	if( $^O eq 'MSWin32' ) {
		load 'Alien::MSYS';
		$self->alien_build_commands([
			map {
				my $c = $_;
				$c =~ s/^%pconfigure/sh %pconfigure/;
				$c
			} @{$self->alien_build_commands}
		]);
		my $extract_to = $phase eq 'build'
			? $dir
			: $self->alien_library_destination;

		my @files = glob File::Spec->catfile( $dir, '..', 'inc', 'mingw-libgnurx*.tar.gz' );
		for my $archive_file (@files) {
			my $e = Archive::Extract->new( archive => $archive_file );
			$e->extract( to => $extract_to );
		}

		if( $phase eq 'build' ) {
			# copy libregex files into shared dir
			for my $file ( [qw(include regex.h)],
					[qw(lib libgnurx.dll.a)],
					[qw(lib libregex.a)] ) {
				copy( File::Spec->catfile( $dir, @$file ), 'src' );
			}
		} elsif( $phase eq 'install' ) {

		}

		Alien::MSYS::msys( sub  {
			$self->SUPER::alien_do_commands($phase);
		} );
	} else {
		$self->SUPER::alien_do_commands($phase);
	}
}

1;
