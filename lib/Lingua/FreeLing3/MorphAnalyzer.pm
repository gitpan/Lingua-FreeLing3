package Lingua::FreeLing3::MorphAnalyzer;

use warnings;
use strict;

use 5.010;
use Carp;
use Lingua::FreeLing3;
use File::Spec::Functions 'catfile';
use Lingua::FreeLing3::Bindings;

our $VERSION = "0.01";

=encoding UTF-8

=head1 NAME

Lingua::FreeLing3::MorphAnalyzer - Interface to FreeLing3 Morphological Analyzer

=head1 SYNOPSIS

   use Lingua::FreeLing3::MorphAnalyzer;

   my $morph = Lingua::FreeLing3::MorphAnalyzer->new("es",
    AffixAnalysis         => 1, AffixFile       => 'afixos.dat',
    QuantitiesDetection   => 0, QuantitiesFile  => "",
    MultiwordsDetection   => 1, LocutionsFile => 'locucions.dat',
    NumbersDetection      => 1,
    PunctuationDetection => 1, PunctuationFile => '../common/punct.dat',
    DatesDetection        => 1,
    DictionarySearch      => 1, DictionaryFile  => 'dicc.src',
    ProbabilityAssignment => 1, ProbabilityFile => 'probabilitats.dat',
    OrthographicCorrection => 1, CorrectorFile => 'corrector/corrector.dat',
    NERecognition => 'NER_BASIC', NPdataFile => 'np.dat',
  );

  $sentence = $morph->analyze($sentence);

=head1 DESCRIPTION

Interface to the FreeLing3 Morphological Analyzer library.

=head2 C<new>

Object constructor. One argument is required: the languge code
(C<Lingua::FreeLing3> will search for the data file) or the full or
relative path to the data file. It also receives a lot of options that
are explained below.

Returns the morphological analyzer object for that language, or undef
in case of failure.

=over 4

=item C<AffixAnalysis> (boolean)

=item C<MultiwordsDetection> (boolean)

=item C<NumbersDetection> (boolean)

=item C<PunctuationDetection> (boolean)

=item C<DatesDetection> (boolean)

=item C<QuantitiesDetection> (boolean)

=item C<DictionarySearch> (boolean)

=item C<ProbabilityAssignment> (boolean)

=item C<NERecognition> (option)

NER_BASIC / NER_BIO / NER_NONE

=item C<Decimal> (string)

=item C<Thousand> (string)

=item C<LocutionsFile> (file)

=item C<InverseDict> (boolean)

=item C<RetokContractions> (boolean)

=item C<QuantitiesFile> (file)

=item C<AffixFile> (file)

=item C<ProbabilityFile> (file)

=item C<DictionaryFile> (file)

=item C<NPdataFile> (file)

=item C<PunctuationFile> (file)

=item C<ProbabilityThreshold> (real)

=item C<UserMap> (boolean)

=item C<OrthographicCorrection> (boolean)

=item C<CorrectorFile> (file)

=item C<UserMapFile> (file)

=back

=cut

my %maco_valid_option = (
                         UserMap                => 'BOOLEAN',
                         UserMapFile            => 'FILE',
                         RetokContractions      => 'BOOLEAN',
                         InverseDict            => 'BOOLEAN',
                         AffixAnalysis          => 'BOOLEAN',
                         MultiwordsDetection    => 'BOOLEAN',
                         NumbersDetection       => 'BOOLEAN',
                         OrthographicCorrection => 'BOOLEAN',
                         PunctuationDetection   => 'BOOLEAN',
                         DatesDetection         => 'BOOLEAN',
                         QuantitiesDetection    => 'BOOLEAN',
                         DictionarySearch       => 'BOOLEAN',
                         ProbabilityAssignment  => 'BOOLEAN',
                         NERecognition          => { 'NER_BASIC' => 0,
                                                     'NER_BIO'   => 1,
                                                     'NER_NONE'  => 2 },
                         Decimal                => 'STRING',
                         Thousand               => 'STRING',
                         LocutionsFile          => 'FILE',
                         QuantitiesFile         => 'FILE',
                         AffixFile              => 'FILE',
                         ProbabilityFile        => 'FILE',
                         DictionaryFile         => 'FILE',
                         NPdataFile             => 'FILE',
                         PunctuationFile        => 'FILE',
                         CorrectorFile          => 'FILE',
                         ProbabilityThreshold   => 'REAL',
                        );

sub _check_option {
    my ($self, $value, $type) = @_;

    given ($type) {
        when ("BOOLEAN") {
            return $value ? 1 : 0;
        }
        when ("REAL") {
            return $value =~ /(\d+(?:\.\d+))?/ ? $1 : undef;
        }
        when ("STRING") {
            $value =~ s/(?<!\\)"/\\"/g;
            return '"'.$value.'"';
        }
        when ("FILE") {
            $value    || return undef;
            -f $value && return '"'.$value.'"';

            my $ofile = catfile($self->{prefix} => $value);
            -f $ofile && return '"'.$ofile.'"';

            return undef;
        }
        when (qr/NER/) {
            return $type->{$value} // undef;
        }
        default {
            return undef;
        }
    }
}

sub new {
    my ($class, $lang, %maco_op) = @_;

    # It might make sense to make this language-dependent
    my %default_ops = (
                       UserMap                => 0,
                       UserMapFile            => undef,
                       AffixAnalysis          => 1,
                       AffixFile              => 'afixos.dat',
                       QuantitiesDetection    => 0,
                       QuantitiesFile         => undef,
                       MultiwordsDetection    => 1,
                       LocutionsFile          => 'locucions.dat',
                       NumbersDetection       => 1,
                       PunctuationDetection   => 1,
                       PunctuationFile        => '../common/punct.dat',
                       DatesDetection         => 1,
                       DictionarySearch       => 1,
                       DictionaryFile         => 'dicc.src',
                       ProbabilityAssignment  => 1,
                       ProbabilityFile        => 'probabilitats.dat',
                       NERecognition          => 'NER_BASIC',
                       NPdataFile             => 'np.dat',
                       OrthographicCorrection => 1,
                       CorrectorFile          => 'corrector/corrector.dat',
                      );

    my @keys = keys %{{ %maco_op, %default_ops }}; # as BingOS called it, hash shaving

    my $dir;
    if ($lang =~ /^[a-z][a-z]$/i) {
        $dir = Lingua::FreeLing3::_search_language_dir($lang);
    }

    my $self = bless {
                      prefix => $dir,
                      maco_options => Lingua::FreeLing3::Bindings::maco_options->new($lang),
                     } => $class;

    my @to_deactivate = ();
    for my $op (@keys) {
        if ($maco_valid_option{$op}) {
            my $option = exists($maco_op{$op}) ? $maco_op{$op} : $default_ops{$op};
            if (defined($option = $self->_check_option($option, $maco_valid_option{$op}))) {
                eval "\$self->{maco_options}->swig_${op}_set($option);";
            } else {
                push @to_deactivate, $op if $op =~ /File$/;

                exists($maco_op{$op}) and carp "Option $op with invalid value: '$maco_op{$op}'.";
            }
        } else {
            carp "Option '$op' not recognized for MorphAnalyzer object."
        }
    }

    my %map = (AffixFile       => 'AffixAnalysis',
               QuantitiesFile  => 'QuantitiesDetection',
               LocutionsFile   => 'MultiwordsDetection',
               PunctuationFile => 'PunctuationDetection',
               DictionaryFile  => 'DictionarySearch',
               CorrectorFile   => 'OrthographicCorrection',
               ProbabilityFile => 'ProbabilityAssignment',
               NTPdataFile     => 'NERecognition'         );

    for my $op (@to_deactivate) {
        my $target = $map{$op};
        next unless $target && ($maco_op{$target} || $default_ops{$target});

        if ($target eq "NERecognition") {
            eval "\$self->{maco_options}->swig_${target}_set(2);"; # NER_NONE
        } else {
            eval "\$self->{maco_options}->swig_${target}_set(0);";
        }
    }

    $self->{maco} = Lingua::FreeLing3::Bindings::maco->new($self->{maco_options});
    return $self;
}

=head2 C<analyze>

=cut

sub analyze {
    my ($self, $sentences, %opts) = @_;

    unless (Lingua::FreeLing3::_is_sentence_list($sentences)) {
        carp "Error: analyze argument should be a list of sentences";
        return undef;
    }

    $sentences = $self->{maco}->analyze($sentences);

    for my $s (@$sentences) {
        $s = Lingua::FreeLing3::Sentence->_new_from_binding($s);
    }

    return $sentences;

}



### TODO: maco_options
#
# *set_active_modules = *Lingua::FreeLing3::Bindingsc::maco_options_set_active_modules;
# *set_nummerical_points = *Lingua::FreeLing3::Bindingsc::maco_options_set_nummerical_points;
# *set_data_files = *Lingua::FreeLing3::Bindingsc::maco_options_set_data_files;
# *set_threshold = *Lingua::FreeLing3::Bindingsc::maco_options_set_threshold;
#
###


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

