# -*- cperl -*-

use warnings;
use strict;

use Test::More tests => 3;
use Lingua::FreeLing3::Document;

my $doc = Lingua::FreeLing3::Document->new();

ok     $doc => 'Document is defined';
isa_ok $doc => 'Lingua::FreeLing3::Document';
isa_ok $doc => 'Lingua::FreeLing3::Bindings::document';
