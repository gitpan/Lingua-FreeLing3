# -*- cperl -*-

use warnings;
use strict;

use Test::More tests => 8;
use Lingua::FreeLing3::Paragraph;
use Lingua::FreeLing3::Sentence;

my $paragraph = Lingua::FreeLing3::Paragraph->new();

ok $paragraph => 'Paragraph is defined';
isa_ok $paragraph => 'Lingua::FreeLing3::Paragraph';
isa_ok $paragraph => 'Lingua::FreeLing3::Bindings::paragraph';
is $paragraph->size => 0, 'Paragraph is empty';

my $sentence = Lingua::FreeLing3::Sentence->new();
$paragraph->push($sentence);
is $paragraph->size => 1, 'Paragraph has one sentence';

my $s = $paragraph->get(0);
isa_ok $s => 'Lingua::FreeLing3::Sentence';

my $ns = Lingua::FreeLing3::Sentence->new();
$paragraph->push($ns);

my @x = $paragraph->sentences();
isa_ok $_ => 'Lingua::FreeLing3::Sentence' for @x;






