package Alien::LibMagic::ModuleBuild;

use strict;
use warnings;

use parent 'Alien::Base::ModuleBuild';
use Archive::Extract;
use File::Copy;
use File::Spec;
use Module::Load;
# NOTE
# win32 build process
# extract inc\mingw-libgnurx-2.5.1-src.tar.gz
# patch --binary < inc\patch\mingw-libgnurx-2.5.1
# cd mingw-libgnurx-2.5.1; sh .\configure; make
# cd file-5*\
#set CPPFLAGS=-I$abs_dir/_alien/mingw-libgnurx-2.5.1
#set LDFLAGS=-L$abs_dir/_alien/mingw-libgnurx-2.5.1
#set PATH=%PATH%;$abs_dir/_alien/mingw-libgnurx-2.5.1
#sh .\configure
#make
sub alien_do_commands {
	my ($self, $phase) = @_;
	my $dir = $self->config_data( 'working_directory' );

	if( $^O eq 'MSWin32' ) {
		load 'Alien::MSYS';
		my $lib = File::Spec->catfile( $dir, 'lib');
		my $include = File::Spec->catfile($dir, 'include');
		$ENV{PATH} = "$ENV{PATH};$lib";
		$ENV{CPPFLAGS} = "$ENV{CPPFLAGS} -I$include";
		use DDP; p $ENV{PATH};
		use DDP; p $ENV{CPPFLAGS};
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

		my @files = glob File::Spec->catfile( $dir, '..', '..', 'inc', 'mingw-libgnurx*.tar.gz' );
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
