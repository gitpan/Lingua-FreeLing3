package FL3;

use warnings;
use strict;

use Lingua::FreeLing3;
use Lingua::FreeLing3::Tokenizer;
use Lingua::FreeLing3::Splitter;

use parent 'Exporter';
our @EXPORT = (qw{&splitter &tokenizer});

our $VERSION = '0.01';

our $selected_language = undef;
our $tools_cache = {};

=head1 NAME

FL3 - A shortcut module for Lingua::FreeLing3.

=head1 SYNOPSIS

  use FL3 'en';

  splitter->split($text);

  splitter('pt')->split($texto);

=head1 DESCRIPTION

=cut


=head2 C<splitter>

Creates a new Splitter object.

=cut

sub splitter {
    my $l = $_[0] || $selected_language;

    return undef unless $l;

    unless (exists($tools_cache->{$l}{splitter})) {
        $tools_cache->{$l}{splitter} = Lingua::FreeLing3::Splitter->new($l);
    }
    return $tools_cache->{$l}{splitter}
}

=head2 C<tokenizer>

Creates a new Tokenizer object.

=cut

sub tokenizer {
    my $l = $_[0] || $selected_language;

    return undef unless $l;

    unless (exists($tools_cache->{$l}{tokenizer})) {
        $tools_cache->{$l}{tokenizer} = Lingua::FreeLing3::Tokenizer->new($l);
    }
    return $tools_cache->{$l}{tokenizer}
}

sub import {
    my $self = shift;
    my $lang = shift;
    $selected_language = $lang if $lang;

    $self->export_to_level(1, undef, @EXPORT);
}

=head1 SEE ALSO

Lingua::FreeLing3(3)

=head1 AUTHOR

Alberto Simões, E<lt>ambs@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Alberto Simões

=cut

1;

