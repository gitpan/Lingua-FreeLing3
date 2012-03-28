package Lingua::FreeLing3::Tokenizer;

use warnings;
use strict;

use Carp;
use Lingua::FreeLing3;
use File::Spec::Functions 'catfile';
use Lingua::FreeLing3::Bindings;
use Lingua::FreeLing3::Word;
use parent -norequire, 'Lingua::FreeLing3::Bindings::tokenizer';


our $VERSION = "0.01";

=encoding UTF-8

=head1 NAME

Lingua::FreeLing3::Tokenizer - Interface to FreeLing3 Tokenizer

=head1 SYNOPSIS

   use Lingua::FreeLing3::Tokenizer;

   my $pt_tok = Lingua::FreeLing3::Tokenizer->new("pt");

   # compute list of Lingua::FreeLing3::Word
   my $list_of_words = $pt_tok->tokenize("texto e mais texto.");

   # compute list of strings (words)
   my $list_of_words = $pt_tok->tokenize("texto e mais texto.",
                                         to_text => 1);

=head1 DESCRIPTION

Interface to the FreeLing3 tokenizer library.

=head2 C<new>

Object constructor. One argument is required: the languge code
(C<Lingua::FreeLing3> will search for the tokenization data file) or
the full or relative path to the tokenization data file.

Returns the tokenizer object for that language, or undef in case of
failure.

=cut

sub new {
    my ($class, $lang) = @_;

    if ($lang =~ /^[a-z][a-z]$/i) {
        my $dir = Lingua::FreeLing3::_search_language_dir($lang);
        $lang = catfile($dir, "tokenizer.dat") if $dir;
    }

    unless (-f $lang) {
        carp "Cannot find tokenizer data file. Tried [$lang]\n";
        return undef;
    }
    return bless $class->SUPER::new($lang), $class #amen
}


=head2 C<tokenize>

This is the only available method for the tokenizer object. It
receives a string and tokenizes the text, returning a reference to a
list of words.

Without any further configuration option, it will return a reference
to a list of L<Lingua::FreeLing3::Word>. The option C<to_text> can be
set, and it will return a reference to a list of strings.

=cut

sub tokenize {
    my ($self, $string, %opts) = @_;

    return undef unless $string;

    my $result = $self->SUPER::tokenize($string);

    for my $w (@$result) {
        if ($opts{to_text}) {
            $w = $w->get_form;
            utf8::decode($w);
        } else {
            $w = Lingua::FreeLing3::Word->_new_from_binding($w);
        }
    }
    return $result;
}

1;

__END__

=head1 SEE ALSO

Lingua::FreeLing3(3) for the documentation table of contents. The
freeling library for extra information, or perl(1) itself.

=head1 AUTHOR

Alberto Manuel Brandão Simões, E<lt>ambs@cpan.orgE<gt>

Jorge Cunha Mendes E<lt>jorgecunhamendes@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Projecto Natura

=cut
