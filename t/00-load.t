#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'MooseX::AttrInflate' );
}

diag( "Testing MooseX::AttrInflate $MooseX::AttrInflate::VERSION, Perl $], $^X" );
