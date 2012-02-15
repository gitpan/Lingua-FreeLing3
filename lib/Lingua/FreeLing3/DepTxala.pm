package Lingua::FreeLing3::DepTxala;

use warnings;
use strict;

use Carp;
use Lingua::FreeLing3;
use File::Spec::Functions 'catfile';
use Lingua::FreeLing3::Bindings;
use Lingua::FreeLing3::Sentence;
use Lingua::FreeLing3::ChartParser;

use parent -norequire, 'Lingua::FreeLing3::Bindings::dep_txala';

our $VERSION = "0.01";


=encoding UTF-8

=head1 NAME

Lingua::FreeLing3::DepTxala - Interface to FreeLing3 DetTxala

=head1 SYNOPSIS

   use Lingua::FreeLing3::DepTxala;

   my $pt_parser = Lingua::FreeLing3::DepTxala->new("pt");

   $taggedListOfSentences = $pt_parser->analyze($listOfSentences);

=head1 DESCRIPTION

Interface to the FreeLing3 txala parser library.

=head2 C<new>

Object constructor. One argument is required: the languge code
(C<Lingua::FreeLing3> will search for the parser and the txala data
files) or the full or relative path to the dependencies file together
with the full or relative path to the chart parser data file.

=cut

sub new {
    my ($class, $lang, $chartParser) = @_;

    my $dep_txala_file;
    if ($lang =~ /^[a-z]{2}$/i) {
        # lets guess everything
        my $dir = Lingua::FreeLing3::_search_language_dir(lc $lang);
        if ($dir) {
            $dep_txala_file = catfile($dir, "dep", "dependences.dat");
        }
    } else {
        $dep_txala_file = $lang;
    }

    unless (-f $dep_txala_file) {
        carp "Cannot find txala data file. Tried [$dep_txala_file]\n";
        return undef;
    }

    unless (ref($chartParser) && $chartParser->isa('Lingua::FreeLing3::Bindings::chart_parser')) {
        carp "Supplied chart parser is not a chart parser\n";
        return undef;
    }

    my $self = Lingua::FreeLing3::Bindings::dep_txala->new($dep_txala_file,
                                                           $chartParser->start_symbol);
    return bless $self => $class #amen
}


=head2 C<analyze>

Receives a list of sentences, and returns that same list of sentences
after tagging process, enriching each sentence with a parse tree.

=cut

sub analyze {
    my ($self, $sentences) = @_;

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

Copyright (C) 2011-2012 by Projecto Natura

=cut
