package t::lib::Debugger;

use strictures 1;

# Turn on $OUTPUT_AUTOFLUSH
local $| = 1;


use File::Temp qw(tempdir);

require Exporter;
use base 'Exporter';
our @EXPORT = qw(start_script start_debugger slurp rc_file);

my $host = 'localhost';
my $port = 24642 + int rand(1000);

sub start_script {
	my ($file) = @_;

	my $dir = tempdir( CLEANUP => 0 );
	my $path = $dir;
	if ( $^O =~ /Win32/i ) {
		require Win32;
		$path = Win32::GetLongPathName($path);
		local $ENV{PERLDB_OPTS} = "RemotePort=$host:$port";
		sleep 1;

		system( 1, qq($^X -d $file > "$path/out" 2> "$path/err") );

	} else {

		my $pid = fork();
		die if not defined $pid;

		if ( not $pid ) {
			local $ENV{PERLDB_OPTS} = "RemotePort=$host:$port";
			sleep 1;

			exec qq($^X -d $file > "$path/out" 2> "$path/err");
			exit 0;
		}
	}

	return ($dir);
}

sub start_debugger {
	require Debug::Client;
	my $debugger = Debug::Client->new( host => $host, port => $port, );	
	# $debugger->listener;
	return $debugger;
}

sub slurp {
	my ($file) = @_;

	open my $fh, '<', $file or die "Could not open '$file' $!";
	local $/ = undef;
	return <$fh>;
}

# the debugger loads custom settings from
# a .perldb file. If the user has it, some
# test outputs might go boo boo.
sub rc_file {
	require File::HomeDir;
	require File::Spec;
	return -e File::Spec->catfile(
		File::HomeDir->my_home,
		'.perldb'
	);
}

1;
