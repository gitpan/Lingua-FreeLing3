package Lingua::FreeLing3::EAGLES;

use warnings;
use strict;

use parent 'Exporter';

our @EXPORT = 'eagles';

my @ptlang = (
             );

my %langs = (
             pt => \@ptlang,
            );


sub eagles {
    my ($lang, $tag) = @_;


}



1;

=encoding UTF-8

=head1 NAME

Lingua::FreeLing3::EAGLES - Interface to parse EAGLES tagsets from FL3

=head1 SYNOPSIS

  use Lingua::FreeLing3::EAGLES;

=head1 DESCRIPTION

=head2 NOTE: THIS MODULE IS NOT YET FUNCTIONAL

EAGLES-like tagets are easy to define, and most of them are kind of
easy to read by humans. However, there is not a clear algorithm to
parse all EAGLES tagsets, as the rules are too permissive.

This module defines an interface to easily obtain feature structures
from EAGLES tags.

=head2 Tagset Feature Structure

The homogeneous feature structure includes obligatorily a category
(C<<cat>> key). All other features might or not be present, depending
on the chosen language, and the supplied tag.

=head3 Categories

Categories (C<<cat>> key) are:

=over 4

=item C<noun>

a common noun.

=item C<name>

a proper noun.

=back

=head1 METHODS

This module exports only one method.

=head2 C<eagles>

The method used to extract details from an EAGLES tag.

=head1 SEE ALSO

perl(1)

=head1 AUTHOR

Alberto Manuel Brandão Simões, E<lt>ambs@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Alberto Manuel Brandão Simões

=cut
