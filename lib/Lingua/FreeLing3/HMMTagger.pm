package Lingua::FreeLing3::HMMTagger;

use warnings;
use strict;

use Carp;
use Lingua::FreeLing3;
use File::Spec::Functions 'catfile';
use Lingua::FreeLing3::Bindings;
use Lingua::FreeLing3::Sentence;

use parent -norequire, 'Lingua::FreeLing3::Bindings::hmm_tagger';

our $VERSION = "0.02";


=encoding UTF-8

=head1 NAME

Lingua::FreeLing3::HMMTagger - Interface to FreeLing3 HMMTagger

=head1 SYNOPSIS

   use Lingua::FreeLing3::HMMTagger;

   my $pt_tagger = Lingua::FreeLing3::HMMTagger->new("pt");

   # alternativelly
   my $pt_tagger = Lingua::FreeLing3::HMMTagger->new(
                   "/path/to/tagger.dat", LanguageCode => 'pt');

   $taggedListOfSentences = $pt_tagger->analyze($listOfSentences);

=head1 DESCRIPTION

Interface to the FreeLing3 hmm tagger library.

=head2 C<new>

Object constructor. One argument is required: the languge code
(C<Lingua::FreeLing3> will search for the tagger data file) or the full
or relative path to the tagger data file.

Returns the tagger object for that language, or undef in case of
failure.

It understands the following options:

=over 4

=item C<LanguageCode> (string)

If you use the language code when telling where the data file is (as
the first argument to the new constructor), you can safely ignore this
option.

If you supply a relative or absolute path to the data file, please use
this option with the two code language name.

The language code is used to determine if the language uses an EAGLES
tagset, and to properly shorten the PoS tags in that case.

=item C<Retokenize> (boolean)

States whether words that carry retokenization information (e.g. set
by the dictionary or affix handling modules) must be retokenized (that
is, splitted in two or more words) after the tagging.

=item C<AmbiguityResolution> (option)

States whether and when the tagger must select only one analysis in
case of ambiguity. Possible values are: FORCE_NONE: no selection
forced, words ambiguous after the tagger, remain
ambiguous. FORCE_TAGGER: force selection immediately after tagging,
and before retokenization. FORCE_RETOK: force selection after
retokenization.

=back

=cut

sub new {
    my ($class, $lang, %ops) = @_;

    my $language;
    if ($lang =~ /^[a-z][a-z]$/i) {
        $language = lc($lang);
        my $dir = Lingua::FreeLing3::_search_language_dir($lang);
        $lang = catfile($dir, "tagger.dat") if $dir;
    }

    unless (-f $lang) {
        carp "Cannot find hmm_tagger data file. Tried [$lang]\n";
        return undef;
    }

    $language ||= lc($ops{LanguageCode});
    die "Could not guess a language code!" unless $language;

    my $retok = Lingua::FreeLing3::_validate_bool($ops{Retokenize} => 0); # bool
    my $amb   = Lingua::FreeLing3::_validate_option($ops{AmbiguityResolution},
                                                    {
                                                     FORCE_NONE   => 0,
                                                     FORCE_TAGGER => 1,
                                                     FORCE_RETOK  => 2,
                                                    }, 'FORCE_NONE');

    my $self = $class->SUPER::new($language, $lang, $retok, $amb);
    return bless $self => $class
}


=head2 C<tag>

Alias to C<analyze>

=cut

sub tag { &analyze }

=head2 C<analyze>

Receives a list of sentences, and returns that same list of sentences
after tagging process. Basically, selected the most probable
(accordingly with the tagger model) analysis for each word.

=cut

sub analyze {
    my ($self, $sentences, %opts) = @_;

    unless (Lingua::FreeLing3::_is_sentence_list($sentences)) {
        carp "Error: analyze argument isn't a list of sentences";
        return undef;
    }

    $sentences = $self->SUPER::analyze($sentences);

    for my $s (@$sentences) {
        $s = Lingua::FreeLing3::Sentence->_new_from_binding($s);
    }
    return $sentences;
}


1;

__END__

=head1 SEE ALSO

Lingua::FreeLing3 (3), freeling, perl(1)

=head1 AUTHOR

Alberto Manuel Brandão Simões, E<lt>ambs@cpan.orgE<gt>

Jorge Cunha Mendes E<lt>jorgecunhamendes@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Projecto Natura

=cut
