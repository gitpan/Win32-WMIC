use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Win32::WMIC',
    AUTHOR              => 'Al Newkirk <awncorp@cpan.org>',
    VERSION_FROM        => 'lib/Win32/WMIC.pm',
    ABSTRACT_FROM       => 'lib/Win32/WMIC.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'DBIx::Simple'  => 0,
        'SQL::Abstract' => 0,
        'DBD::AnyData'  => 0,
        'Test::More'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Win32-WMIC-*' },
);
