#!/usr/bin/perl
use 5.10.0;
## Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl P.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;


#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

our $num_tests;
our @answers;
our $sample_strlen;
our $tp;

BEGIN{
	$tp="lib/P.pm";

	$sample_strlen=length "Hello Perl 0";

	$_=1;
	push (@answers, [$_, qr{Hello\sPerl\s$_}]) for 1 .. 5;
	push @answers, [6, ""];
	push @answers, [7, qr{Hello Perl \d.*Perl 7}];
	push @answers, [8, qr{[8eHloPr\s]{$sample_strlen}} ];
	push @answers, [9, qr{^\s*\[.*three.*4.*\]\s*$} ];
	push @answers, [10, qr{^\s*\{.*a.?=>.apple.*\}$} ];
	push @answers, [11, qr{Pkg.*\{.*=>.*\}} ];

	#	3 setup tests, all answers have two parts except for 1 (#6)
	
	$num_tests=3+2*@answers-1;
}

use Test::More tests => $num_tests;

BEGIN { use_ok('P') };

my $match_case_n_name=qr{^.(\d+)\s*\(([^\)]+)\)[^:]*:};
my $match_testout=qr{\s*(.*)$};
my $match_expr=qr{^.(\d+)\s*\(([^\)]+)\)[^:]*:\s*(.*)$};

ok( -e $tp , "P.pm exist?");
chmod( 0755, $tp); 
ok( -x $tp , "P.pm executable?");		#3

sub get_case($;$) {
	my $case = shift;
	my $cmd = @_? "$tp $case ".$_[0] : "$tp $case |";
	open(my $fh, $cmd) || return undef;
	my $out;
	{ local $/=undef;
		$out = <$fh>;
	}
	chomp $out;
	$out;
}

my $caseno=0;
for my $matchp (@answers) {
	my ($rcase, $name, $rstr);
	my $re = $matchp->[1];
	if (++$caseno == 5) {
		my $part1=`$tp 5 2>stderr.out.txt`; chomp $part1;
		$part1 =~ m{$match_case_n_name};
		($rcase, $name) = ($1, $2);
		$rstr=`cat stderr.out.txt`;chomp $rstr;
		unlink "stderr.out.txt";
	} elsif ($caseno == 6) {
		my $resp = get_case($matchp->[0]);
		$resp =~ m{$match_expr};
		($rcase,$name, $rstr) = ($1,$2,$3);
		ok($caseno == $rcase, "received testcase $caseno");
		next;
	} elsif ($caseno == 7) { 
		get_case($matchp->[0]-1);
		my $resp = get_case($matchp->[0]);
		my @lns=split /\n/, $resp;
		$resp = $lns[1];
		$resp =~ m{$match_expr};
		($rcase,$name, $rstr) = ($1,$2,$3);
	} else {
		my $resp = get_case($matchp->[0]);
		$resp =~ m{$match_expr};
		($rcase,$name, $rstr) = ($1,$2,$3);
	}
	ok($caseno == $rcase, "received testcase $caseno");
	if (length($re)) {ok($rstr =~ m{$re}, $name)}
}






