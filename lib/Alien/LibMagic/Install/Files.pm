package Alien::LibMagic::Install::Files;

# allows other packages to use ExtUtils::Depends like so:
#   use ExtUtils::Depends;
#   my $p = new ExtUtils::Depends MyMod, Alien::LibMagic;
# and their code will have all LibMagic available at C level

use strict;
use warnings;

use Alien::LibMagic qw(Inline);
BEGIN { *Inline = *Alien::LibMagic::Inline }
sub deps { () }
