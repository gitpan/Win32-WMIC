#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Win32::WMIC' );
}

diag( "Testing Win32::WMIC $Win32::WMIC::VERSION, Perl $], $^X" );
