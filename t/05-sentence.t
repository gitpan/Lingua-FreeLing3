# -*- cperl -*-

use warnings;
use strict;

use Test::More tests => 5;
use Lingua::FreeLing3::Sentence;

my $sentence = Lingua::FreeLing3::Sentence->new();

ok $sentence => "Sentence is defined";
isa_ok $sentence => 'Lingua::FreeLing3::Sentence';
isa_ok $sentence => 'Lingua::FreeLing3::Bindings::sentence';
ok !$sentence->is_parsed => "By default a tree is not parsed";
ok !$sentence->is_dep_parsed => "By default a tree is not dependency parsed";
