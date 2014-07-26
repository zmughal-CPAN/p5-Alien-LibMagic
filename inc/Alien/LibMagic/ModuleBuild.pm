package Alien::LibMagic::ModuleBuild;

use strict;
use warnings;

use parent 'Alien::Base::ModuleBuild';
use if $^O eq 'MSWin32', 'Alien::MSYS' => qw(msys);
use Archive::Extract;
use File::Copy;
use File::Spec;

sub alien_do_commands {
	my ($self, $phase) = @_;
	my $dir = $self->config_data( 'working_directory' );

	if( $^O eq 'MSWin32' ) {
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

		msys {
			$self->SUPER::alien_do_commands($phase);
		};
	} else {
		$self->SUPER::alien_do_commands($phase);
	}
}

1;
