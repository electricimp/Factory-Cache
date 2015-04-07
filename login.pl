#!/usr/bin/perl

use warnings;
use strict;

use Expect;

$Expect::Log_Stdout = 1;

my @ip_addrs  = ("192.168.31.1", "192.168.1.1");
my @passwords = ("upgrades","admin");

my $new_ip   = "192.168.31.1";
my $new_pswd = "upgrades";

my $e =  login();
$e->interact();


sub login{
	my $pw_pntr = 0;

	my $ip_found = 0;
	
	my $e;

	foreach my $ip (@ip_addrs){
		$e =  Expect->spawn("telnet ".$ip);
	
	 	$e->expect(3,
	 			[qr/DD-WRT/i, sub{$ip_found = 1;}],
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


