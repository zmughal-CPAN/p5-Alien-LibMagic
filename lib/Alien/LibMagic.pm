package Alien::LibMagic;

use strict;
use warnings;

use Path::Tiny;
use parent 'Alien::Base';

sub cflags {
	my ($self) = @_;
	my $top_include = File::Spec->catfile( File::Spec->rel2abs($self->dist_dir), qw(include) );
	return "-I$top_include";
}

sub libs {
	my ($self) = @_;
	my $top_lib = File::Spec->catfile( File::Spec->rel2abs($self->dist_dir), qw(lib) );
	my $la_file = path( File::Spec->catfile( $top_lib, 'libmagic.la' ) );
	my ($deps) = $la_file->slurp_utf8 =~ /^dependency_libs=' (.*)'$/m;
	return "-L$top_lib -lmagic $deps";
}

sub Inline {
	my ($self, $lang) = @_;

	if( $lang eq 'C' ) {
		my $params = Alien::Base::Inline(@_);
		$params->{MYEXTLIB} .= ' ' .
			join( " ",
				map { File::Spec->catfile(
					File::Spec->rel2abs($self->dist_dir),
					'lib',  $_ ) }
				qw(libmagic.a)
			);
		# Use static linking instead of dynamic linking on macOS.
		if( $^O eq 'darwin' ) {
			$params->{LIBS} =~ s/-lmagic//g;
		}
		return $params;
	}
}

sub inline_auto_include {
	return  [ 'magic.h' ];
}

1;

__END__
# ABSTRACT: Alien package for the libmagic library

=pod

=head1 Inline support

This module supports L<Inline's with functionality|Inline/"Playing 'with' Others">.

=head1 SEE ALSO

L<file(1)>, L<file command|http://darwinsys.com/file/>, L<File::LibMagic>
