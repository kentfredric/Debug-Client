#!/usr/bin/perl

use strictures 1;

# Turn on $OUTPUT_AUTOFLUSH
local $| = 1;

use Test::More;
use Test::Deep;
plan( tests => 3 );


#Top
use t::lib::Debugger;

start_script('t/eg/14-y_zero.pl');
my $debugger;
$debugger = start_debugger();
$debugger->get;
$debugger->set_breakpoint( 't/eg/14-y_zero.pl', '14' );
$debugger->run;


#Body
my $out;
my @out;
foreach ( 1 .. 3 ) {
	$debugger->run();

	my @out;
	@out = $debugger->get_y_zero();
	cmp_deeply( \@out, ["\$line = $_"], "y (0) \$line = $_" ) or diag( $debugger->buffer );

}


#Tail
$debugger->quit;
done_testing();

1;

__END__
