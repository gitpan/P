#!/usr/bin/perl

# vim=:SetNumberAndWidth

## Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl P.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

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
	push @answers, [8, qr{^\s*\[.*three.*4.*\]\s*$} ];
	push @answers, [9, qr{^\s*\{.*a.?=>.apple.*\}$} ];
	push @answers, [10, qr{Pkg.*\{.*=>.*\}} ];
	push @answers, [11, qr{fmt:Hello Perl}];
	push @answers, [12, qr(norm=3\.14159.*embed.*3.14)];
	push @answers, [13, qr{embed.*ⅴⅸ.*$}];

	#	3 setup tests, all answers have two parts except for 1 (#6)
	
	$num_tests=3+2*@answers-2;

}

use Test::More tests => $num_tests+2;
#BEGIN {
#my $builder = Test::More->builder;
#binmode $builder->output,         ":utf8";
#binmode $builder->failure_output, ":utf8";
#binmode $builder->todo_output,    ":utf8";
#}


BEGIN { use_ok('mem') || BAIL_OUT("missing pre-req mem");};

BEGIN { use_ok('P') || BAIL_OUT("missing module to test");};

BEGIN { ok(!defined $ENV{PERL5OPT} || $ENV{PERL5OPT} !~ /utf8/, "check for utf8 in ENV (causes probs)") ||
				BAIL_OUT("\nincompat utf8 set in PERL5OPT");}

my $match_case_n_name=qr{^.(\d+)\s*\(([^\)]+)\)[^:]*:};
my $match_testout=qr{\s*(.*)$};
my $match_expr=qr{^.(\d+)\s*\(([^\)]+)\)[^:]*:\s*(.*)$};
my $weak_match_expr=qr{^(?:.(\d+)\s*)?\(?([^\)]*)\)?[^:]*:?\s*(.*)$};

ok( -e $tp , "P.pm exist?");
chmod( 0755, $tp); 
#ok( -x $tp , "P.pm executable?");		#3

sub get_case($;$) {
	my $case = shift;
	my $cmd = @_? "$^X $tp $case ".$_[0]."|" : "$^X $tp $case |";
	open(my $fh, $cmd) || return undef;
	my $out;
	{ local $/=undef;
		$out = <$fh>;
	}
	chomp $out;
	$out;
}

sub sv($) { defined $_[0] ? $_[0] : "(undef)" }

my $caseno=0;
for my $matchp (@answers) {
	my ($rcase, $name, $rstr);
	my $re = $matchp->[1];
	++$caseno;
	if ($caseno == 5) {	# see if output was on STDERR
		my $null;
		my $dev;
		open($null, ">", $dev="/dev/null") or
			open($null, ">", $dev="NUL:") or 
			die "Cannot open /dev/null nor NUL:";
		close ($null);
		my $resp = get_case($matchp->[0],"2>$dev");
		$resp =~ m{$weak_match_expr};
		($rcase,$name, $rstr) = ($1,$2,$3);
		$resp = get_case($matchp->[0],"2>&1 >$dev");
		$resp =~ m{$weak_match_expr};
		$rstr = $2;
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
		&saveSTD_n_redirect_err if $caseno==5;
		my $resp = get_case($matchp->[0]);
		$resp =~ m{$match_expr};
		($rcase,$name, $rstr) = ($1,$2,$3);
		&restoreSTDs if $caseno==5;
	}
	ok($rcase && $caseno == $rcase, "received testcase $caseno");
	if (length($re)) {
		ok($rstr =~ m{$re}, $name) || 
			diag( sprintf "Regex \"%s\" did not match string \"%s\" in case \"%s\".", 
				sv($re), sv($rstr), sv($name) );
	}
}






