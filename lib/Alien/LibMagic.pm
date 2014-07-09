package Alien::LibMagic;

use strict;
use warnings;

use parent 'Alien::Base';

sub Inline {
	return unless $_[-1] eq 'C'; # Inline's error message is good
	my $self = __PACKAGE__->new;
	+{
		LIBS => $self->libs,
		INC => $self->cflags,
		AUTO_INCLUDE => '#include "magic.h"',
	};
}

1;

__END__
# ABSTRACT: Alien package for the libmagic library

=pod

=head1 Inline support

This module supports L<Inline's with functionality|Inline/"Playing 'with' Others">.

=head1 SEE ALSO

L<file(1)>, L<file command|http://darwinsys.com/file/>, L<File::LibMagic>
