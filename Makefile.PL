

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'P',
    VERSION_FROM => 'lib/P.pm', # finds \$VERSION
    AUTHOR       => 'Linda Walsh (perl-diddler@tlinx.org)',
    ABSTRACT     => 'printf, sprintf & say all-in-1; safer & easier!',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                    },
);
