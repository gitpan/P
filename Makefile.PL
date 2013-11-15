

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'P',
    VERSION_FROM => 'lib/P.pm', # finds \$VERSION
    AUTHOR       => 'Linda Walsh (LAWALSH@cpan.org)',
    ABSTRACT     => 'safer+easier printf, sprintf & say all-in-1',
    PREREQ_PM    => {
										 'mem'	=> '0.3.2',
                    },
		TEST_REQUIRES=> {
                     'Test::Simple' => 0.44,
										 'mem'	=> '0.3.2',
									 },
		dist				=> { TAR=> 'ptar' , TARFLAGS=> "-cvf" },
		test				=> { TESTS => 't/*.env' }
);
