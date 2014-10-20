# -*- cperl -*-

use warnings;
use strict;

use Test::More tests => 16;
use Lingua::FreeLing3::Word;

my $word1 = Lingua::FreeLing3::Word->new();

ok     $word1 => 'Word object is defined for empty new';
isa_ok $word1 => 'Lingua::FreeLing3::Word';
isa_ok $word1 => 'Lingua::FreeLing3::Bindings::word';

is     $word1->form, "" => "Empty word as no form";
# XXX - ok     $word1->in_dict  => "Words are on a dictionary by default";

$word1->form("gato");
is     $word1->form, "gato" => "Setter works";


my $word2 = Lingua::FreeLing3::Word->new("cavalo");

ok     $word2 => 'Word object is defined for specific word';
isa_ok $word2 => 'Lingua::FreeLing3::Word';
isa_ok $word2 => 'Lingua::FreeLing3::Bindings::word';

is $word2->form, "cavalo" => 'Word has form';
# XXX - ok $word2->in_dict        => "Words are on a dictionary by default";

my $hash = $word2->as_hash;
is $hash->{form}   => "cavalo", "As hash.form";
is $hash->{lemma}  => ""      , "As hash.lemma";
is $hash->{tag}    => ""      , "As hash.tag";

is $hash->{lemma}  => $word2->lemma,  'Lemma accessor';
is $hash->{tag}    => $word2->tag,    'Tag accessor';
is $hash->{form}   => $word2->form,   'Form accessor';

is_deeply $word2->analysis => [], 'Basic word has no analysis';
