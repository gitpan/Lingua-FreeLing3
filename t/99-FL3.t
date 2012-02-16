#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 16;

use FL3 'pt';
ok 1 => 'Loaded ok';

my $text = <<EOT;
A Assembleia Constituinte afirma a decisão do povo português de
defender a independência nacional, de garantir os direitos
fundamentais dos cidadãos, de estabelecer os princípios basilares da
democracia, de assegurar o primado do Estado de Direito democrático e
de abrir caminho para uma sociedade socialista, no respeito da vontade
do povo português, tendo em vista a construção de um país mais livre,
mais justo e mais fraterno.
EOT

isa_ok splitter()  => 'Lingua::FreeLing3::Splitter';
isa_ok tokenizer() => 'Lingua::FreeLing3::Tokenizer';

ok ((splitter('en') eq splitter('en')) => "cache works");

my $words = tokenizer->tokenize($text);
ok $words => 'Tokenizer did something';
isa_ok $words, 'ARRAY' => 'Tokenizer result';
isa_ok $words->[0], 'Lingua::FreeLing3::Word' => 'Tokenizers result first element';

my $sentences = splitter->split($words);
ok $sentences => 'Splitter returns something';
isa_ok $sentences, 'ARRAY' => 'Spliter result';
isa_ok $sentences->[0], 'Lingua::FreeLing3::Sentence' => 'Spliters result first element';

my $more_text = <<EOT;
О ранних годах жизни Амундсена известно немногое. Детство его прошло в
лесах, окружавших родительскую усадьбу, в компании братьев и соседских
детей (доходившей до 40 человек), в которой Руаль был самым
младшим. Братья Амундсен охотно участвовали в драках; Руаля в то время
описывали как «высокомерного мальчика», которого легко было
разозлить. Одним из его товарищей по играм был будущий исследователь
Антарктики Карстен Борхгревинк.
EOT

my $more_words = tokenizer('ru')->tokenize($more_text);
ok $more_words => 'Tokenizer(ru) did something';
isa_ok $more_words, 'ARRAY' => 'Tokenizer(ru) result';
isa_ok $more_words->[0], 'Lingua::FreeLing3::Word' => 'Tokenizer(ru) result first element';

my $more_sentences = splitter('ru')->split($more_words);
ok $more_sentences => 'Splitter(ru) returns something';
isa_ok $more_sentences, 'ARRAY' => 'Spliter(ru) result';
isa_ok $more_sentences->[0], 'Lingua::FreeLing3::Sentence' => 'Spliter(ru) result first element';
