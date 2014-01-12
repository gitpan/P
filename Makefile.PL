

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'P',
    VERSION_FROM => 'lib/P.pm', # finds \$VERSION
    AUTHOR       => 'Linda Walsh (LAWALSH@cpan.org)',
    ABSTRACT     => 'safer+easier [s]print[f], & say all-in-1',
    BUILD_REQUIRES=> { 'ExtUtils::MakeMaker' => '6.82', },
    PREREQ_PM    => {
										 'mem'			=> '0.4.5', 		'Types::Core' => '0.1.3',
										 'Xporter'	=>	'0.0.9',
                    },
		TEST_REQUIRES=> {
                     'Test::Simple' => 0.44,		'Types::Core' => '0.1.3',
										 'mem'	=> '0.4.3',					'Xporter'			=> '0.0.9',
									 },
		dist				=> { TAR=> 'ptar' , TARFLAGS=> "-cvf" },
		test				=> { TESTS => 't/*.env' }
);
