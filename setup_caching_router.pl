#!/usr/bin/perl

use warnings;
use strict;

use Expect;
use IO::Select;

$Expect::Log_Stdout = 1;
select STDOUT; $| = 1;  # make unbuffered

my $s = IO::Select->new();
$s->add(\*STDIN);

my @ip_addrs  = ("192.168.1.1", "192.168.31.1");
my @passwords = ("admin", "upgrades");

my $new_ip   = "192.168.31.1";
my $new_pswd = "upgrades";

doFirmwareUpdate();

do303030();

my $e =  login();

command($e,"setuserpasswd root upgrades");
command($e,"setpasswd root upgrades");
command($e,"nvram set cron_enable=0");
command($e,"nvram set dhcp_lease=30");
command($e,"nvram set dhcp_start=5");
command($e,"nvram set dhcp_num=200");
command($e,"nvram set dnsmasq_options=address=/upgrades.electricimp.com/".$new_ip);
command($e,"nvram set http_lanport=81");
command($e,"nvram set httpd_enable=1");
command($e,"nvram set https_enable=1");
command($e,"nvram set is_default=0");
command($e,"nvram set lan_gateway=".$new_ip);
command($e,"nvram set lan_ipaddr=".$new_ip);
command($e,"nvram set local_dns=1");
command($e,"nvram set nas_enable=0");
command($e,"nvram set resetbutton_enable=0 ");
command($e,"nvram set sshd_enable=1");
command($e,"nvram set time_zone=+00");
command($e,"nvram set wl0_auth_mode=none");
command($e,"nvram set wl0_authmode=open");
command($e,"nvram set wl0_channel=0 ");
command($e,"nvram set wl0_ssid=cache ");
command($e,"nvram set wl0_wchannel=0");
command($e,"nvram set wl_channel=0");
command($e,"nvram set wl_ssid=cache");
command($e,"nvram set jffs_mounted=1");
command($e,"nvram set enable_jffs2=1");
command($e,"nvram set sys_enable_jffs2=1");
command($e,"nvram set clean_jffs2=1");
command($e,"nvram set sys_clean_jffs2=1");
command($e,"nvram commit");
command($e,"reboot");
$e->soft_close();

wait_for_reboot();

$e = login();
command($e,"cd /jffs");
command($e,"rm -rf ./*");
command($e,"wget -q -O - http://demo.electricimp.com/cachingrouter/jffs.tgz | tar xzv");
command($e,"reboot");
$e->soft_close();

wait_for_reboot();

print "Caching Update Router Setup Complete.\n";

`open http://$new_ip`;
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

	die "Can not connect to router.\n";
}

sub command{
	my $exp = shift;
	my $cmd = shift;
	chomp($cmd);
	$cmd .= "\n";

	$exp->send($cmd);
	$exp->expect(10,
 				[qr/root\@DD-WRT/], #Wait for prompt then exit
 				[qr/./, sub{ exp_continue_timeout; }],
				[timeout =>  sub { return "ERROR: Command timed out.\n"; } ],
	);

	return undef;
}

sub countDown{
	my $time = shift;
	while($time-- > 0){
		if( $s->can_read(1) ){
			print "Skipping...               ";
			$time = 0;
			readline(*STDIN);
		}else{
			print "\rTime Remaining: ".$time."  ";
		}

	}
	print "\n\n";
}


sub wait_for_reboot{
	print "Waiting for reboot.\n";
	countDown(100);
}

sub doFirmwareUpdate{
	print "Type Enter to open http://admin:admin\@192.168.1.1/Upgrade.asp.  Then navigate to the Firmware Update page by clicking through all the dialog boxes.\n";
	print "Upload the file found at: ftp://ftp.dd-wrt.com/others/eko/BrainSlayer-V24-preSP2/2012/06-08-12-r19342/broadcom_K26/dd-wrt.v24-19342_NEWD-2_K2.6_big-nv64k.bin\n";
	print "Once the progress bar reaches 100%, close the page and return to the terminal.\n";
	readline(*STDIN);
	`open http://admin:admin\@192.168.1.1/Upgrade.asp`;
	
	#Wait for them to return to the terminal
	print "Once you have completed the firmware upload type Enter.\n";
	readline(*STDIN);
	
	print "Waiting for update to complete.\n";
	countDown(60);
}

sub do303030{
	print "Press and hold router Reset button, then type Enter.\n";
	readline(*STDIN);
	countDown(30);

	print "Continue holding Reset button and unplug router power, then type Enter.\n";
	readline(*STDIN);
	countDown(30);	

	print "Continue holding Reset button and reconnect router power, then type Enter.\n";
	readline(*STDIN);
	countDown(30);

	print "Release the Reset button, then type Enter.\n";
	readline(*STDIN);
	countDown(30);

	print "Unplug router power, then type Enter\n";
	readline(*STDIN);
	countDown(3);

	print "Reconnect router power, then type Enter.\n";
	readline(*STDIN);
	countDown(100);

}

