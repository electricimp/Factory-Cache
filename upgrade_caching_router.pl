#!/usr/bin/perl

use warnings;
use strict;

use Expect;

$Expect::Log_Stdout = 1;

my $usage = "Usage: $0 [-test]\n";
my $min_args = 0;
my $max_args = 1;  #less than 0 disables 

if((@ARGV < $min_args) ||
         (0 <= $max_args && $max_args < @ARGV) ||
         (0 < @ARGV && ($ARGV[0] =~ /--?h/))){
                print $usage;
                exit;
}

my $test = 0;
if(0 < @ARGV){
	if($ARGV[0] =~ /-t/){
		$test = 1;
	}else{
		die "Unrecognized option: ".$ARGV[0];
	}
}

my @ip_addrs  = ("192.168.31.1", "192.168.1.1");
my @passwords = ("upgrades", "admin");
my $e;


$e = login();
command($e,"cd /jffs");
command($e,"rm -rf ./*");
if($test){
	command($e,"wget -q -O - http://demo.electricimp.com/cachingrouter/jffs-test.tgz | tar xzv");
}else{
	command($e,"wget -q -O - http://demo.electricimp.com/cachingrouter/jffs.tgz | tar xzv");
}
command($e,"reboot");
$e->soft_close();

wait_for_reboot();

#$e = login();
#$e->interact();


#$e->interact();


sub login{
	my $pw_pntr = 0;

	my $ip_found = 0;
	
	my $e;

	foreach my $ip (@ip_addrs){
		$e =  Expect->spawn("telnet ".$ip);
	
	 	$e->expect(5,
	 			[qr/wrt/i, sub{$ip_found = 1;}],
	 		 	[timeout  =>  sub{print "Telnet timed out.\n"; } ],
				[eof      =>  sub{print "Telnet reached EOF.\n"; } ],
		);

	 	if($ip_found){
	 		 	$e->expect(5,
 					[qr/login:\s*$/i,    sub{ my $fh = shift;
											$fh->send("root\n");
											exp_continue;
											}
					],
					[qr/password:\s*$/i, sub{ 
												my $fh = shift;
												if( $pw_pntr >= scalar @passwords){ die "Password Failed.\n"; }
												print $passwords[$pw_pntr]."\n";
												$fh->send($passwords[$pw_pntr]."\n");
												$pw_pntr++;
												exp_continue;
											}
					],
					[qr/root\@DD-WRT/i],
					[timeout =>  sub { die "Telnet Login timed out waiting for prompt.\n"; }],
					[eof     =>  sub { die "Telnet reached EOF.\n"; } ],
			 	);
			return $e;			 	
		}
	}


}

sub command{
	my $exp = shift;
	my $cmd = shift;
	chomp($cmd);
	$cmd .= "\n";

	$exp->send($cmd);
	$exp->expect(15,
 				[qr/root\@DD-WRT/], #Wait for prompt then exit
 				[qr/./, sub{ exp_continue; }],
				[timeout =>  sub { return "ERROR: Command timed out.\n"; } ],
	);

	return undef;
}

sub wait_for_reboot{
	my $sleep = 100;
	while($sleep-- > 0){
		print "Time Remaining: ".$sleep."             \r";
		sleep(1);
	}




}

