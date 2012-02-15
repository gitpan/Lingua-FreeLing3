use strict;
use warnings;

use Carp;
use lib 'inc';
use MyBuilder;

use File::Which;
use File::Spec;
use Cwd 'abs_path';

my $builder = MyBuilder->new
  (
   module_name          => 'Lingua::FreeLing3',
   license              => 'perl',
   dist_author          => [ 'Alberto Simões <ambs@cpan.org>' ],
   needs_compiler       => 1,
   recursive_test_files => 1,
   configure_requires   => {
                            'ExtUtils::PkgConfig'   => '1.12',
                            'Module::Build'         => '0.36',
                            'ExtUtils::Mkbootstrap' => '0',
                            'File::Which'           => '0'
                           },
   build_requires       => {
                            'Test::Warn' => '0',
                           },
   requires             => {
                            'Try::Tiny' => '0',
                            'Carp' => '0',
                           },
   add_to_cleanup       => [
                            'FreeLing.o',
                            'pm_to_blib',
                            qw'*~ */*~ */*/*~ */*/*/*~ */*/*/*/*~'
                           ],
  );

$builder->detect_freeling();
printf STDERR "Configuring for FreeLing version %s\n", $builder->notes('fl_version');

$builder->create_build_script;

