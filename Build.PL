use strict;
use warnings;

use Carp;
use lib 'inc';
use MyBuilder;

use File::Spec;
use File::Copy;
use Cwd 'abs_path';
use File::Spec::Functions qw.catdir catfile.;

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
                            'File::Copy'            => '0',
                            'Module::Build'         => '0.36',
                            'ExtUtils::Mkbootstrap' => '0',
                            'ExtUtils::CBuilder'    => '0.280205',
                           },
   build_requires       => {
                            'File::Copy'          => '0',
                            'Config::AutoConf'    => '0.20',
                            'Test::Warn'          => '0',
                            'ExtUtils::CBuilder'  => '0.280205',
                           },
   requires             => {
                            'Try::Tiny'    => '0',
                            'Carp'         => '0',
                            'Scalar::Util' => '0',
                           },
   add_to_cleanup       => [
                            'FreeLing.o',
                            'pm_to_blib',
                            qw'*~ */*~ */*/*~ */*/*/*~ */*/*/*/*~'
                           ],
  );

$builder->detect_freeling();

my $version = $builder->notes('fl_version');
my ($major, $minor) = ($builder->notes('fl_major'), $builder->notes('fl_minor'));
printf STDERR "Configuring for FreeLing version ${version} [$major.$minor]\n";

die "Versions prior to 3 not supported" if $major != 3;
die "Minor version not supported"   unless $minor == 0 || $minor == 1;

my @prefix = ('lib','Lingua','FreeLing3');
copy catfile("swig","Bindings-$major.$minor.pm") => catfile(@prefix, "Bindings.pm");
copy catfile("swig","freeling-$major.$minor.cxx") => catfile("swig", "FreeLing_wrap.cxx");

$builder->create_build_script;


