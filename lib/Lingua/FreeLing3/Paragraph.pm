package Lingua::FreeLing3::Paragraph;

use Lingua::FreeLing3::Bindings;
use parent -norequire, 'Lingua::FreeLing3::Bindings::paragraph';

use Carp;
use warnings;
use strict;

our $VERSION = "0.01";

=encoding UTF-8

=head1 NAME

Lingua::FreeLing3::Paragraph - Interface to FreeLing3 Paragraph object

=head1 SYNOPSIS

   use Lingua::FreeLing3::Paragraph;

=head1 DESCRIPTION

This module is a wrapper to the FreeLing3 Paragraph object.

=head2 CONSTRUCTOR

=over 4

=item C<new>

The constructor returns a new Paragraph object: a list of sentences

=cut


# *size = *Lingua::FreeLing3::Bindingsc::ListSentence_size;
# *empty = *Lingua::FreeLing3::Bindingsc::ListSentence_empty;
# *clear = *Lingua::FreeLing3::Bindingsc::ListSentence_clear;
# *push = *Lingua::FreeLing3::Bindingsc::ListSentence_push;

sub new {
    my $class = shift;
    my $self = $class->SUPER::new();
    return bless $self => $class #amen
}

=item C<push>

=cut

sub push {
    my ($self, $sentence) = @_;
    carp "Can't push non-sentence object" unless ref($sentence) eq "Lingua::FreeLing3::Sentence";

    $self->SUPER::push($sentence);
}

=item C<get>

Gets a sentence from a paragraph. Note that this method is extremely
slow, given that FreeLing paragraph is implemented as a
list. Therefore, retrieving the nth element of the list does n
iterations on a linked list.

=cut

sub get {
    my ($class, $n) = @_;
    my $out = $class->SUPER::get($n);
    return Lingua::FreeLing3::Sentence->_new_from_binding($out);
}

=item C<sentences>

Returns an array of sentences from a paragraph.

=cut

sub sentences {
    my ($class) = @_;
    my $out = $class->SUPER::elements();
    return map { Lingua::FreeLing3::Sentence->_new_from_binding($_) } @$out;
}


=pod

=back

=cut

1;

__END__

=head1 SEE ALSO

Lingua::FreeLing3(3) for the documentation table of contents. The
freeling library for extra information, or perl(1) itself.

=head1 AUTHOR

Alberto Manuel Brandão Simões, E<lt>ambs@cpan.orgE<gt>

Jorge Cunha Mendes E<lt>jorgecunhamendes@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011-2012 by Projecto Natura

=cut


