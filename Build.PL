use strict;
use warnings;

use Carp;
use lib 'inc';
use MyBuilder;

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
                            'Config::AutoConf'      => '0.20',
                            'ExtUtils::PkgConfig'   => '1.12',
                            'Module::Build'         => '0.36',
                            'ExtUtils::Mkbootstrap' => '0',
                            'ExtUtils::CBuilder' => '0.280205',
                           },
   build_requires       => {
                            'Config::AutoConf'      => '0.20',
                            'Test::Warn' => '0',
                            'ExtUtils::CBuilder' => '0.280205',
                           },
   requires             => {
                            'Try::Tiny' => '0',
                            'Carp' => '0',
                            'Scalar::Util' => '0',
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


