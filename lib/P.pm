#!/usr/bin/perl  -w

{ package P;
	# next line needed for P.pm to be runnable & pass it's tests
	BEGIN{ $::INC{__PACKAGE__.".pm"} = __FILE__."#__LINE__"};
	use 5.10.0;
	use warnings;
	our $VERSION='1.0.10';
	# RCS $Revision: 1.21 $ -  $Date: 2013-03-01 18:59:51-08 $
	# 1.0.10	- remove Carp::Always from test (wasn't needed and caused it
	#           to fail on most test systems)
	#           add OO-oriented way to set internal P ops (to be documented)
	#         - fixed bug in logic trimming recursion depth on objects
	# 1.0.9 	- Add Px - recursive object print in squished form;
	#       		Default to using Px for normal print
	# 1.0.8 	- fix when ref to IO -- wasn't dereferenced properly
	#       	- upgrade of self-test/demo to allow specifying which test
	#       	  to run from cmd line; test numbers are taken from
	#       	  the displayed examples when run w/no arguments
	#       	B:still doesn't run cleanly under test harness may need to
	#       	  change cases for that (Fixed)
	#       	- POD update to current code 
	# 1.0.7 	- (2013-1-9) add support for printing blessed objects
	#       	- pod corrections
	#       	- strip added LF from 'rev' example with tr (looks wrong)
	# 1.0.6 	- add manual check for LF at end (chomp doesn't always work)
	# 1.0.5 	- if don't recognize ref type, print var
	# 1.0.4 	- added support for printing contents of arrays and hashes.
	# 					(tnx 2 MidLifeXis@prlmnks 4 brain reset)
	# 1.0.3 	- add Pea
	# 1.0.2 	- found 0x83 = "no break here" -- use that for NL suppress
	# 				- added support for easy inclusion in other files 
	# 					(not just as lib);
	# 				- add ISA and EXPORT to 'mem' so they are available @ BEGIN time
	#
	# 1.0.1 	- add 0xa0 (non breaking space) to suppress NL
	our (@ISA, @EXPORT);
	BEGIN {@EXPORT=qw(P Pa Pe Pae), @ISA=qw(Exporter) };
	use Exporter;

	sub Px { my $p = shift;
		my $lvl = scalar @_ ? $_[0] : 2;
		#$lvl or return '…';
		my $ro = $_[1] if scalar @_>1;
		return "(undef)" unless defined $p;
		my $ref = ref $p;
		if (!$ref || 1 >$lvl--) {
			sprintf do { given ($p) { "%d"			when /^[-+]?\d+$/; 
																"%s"			when defined $ro; 
																"'%s'"		when 1==length $_;
																"%.2f"		when /^[-+]?\d*\.\d*$/; 
																default { "\"%s\""}; 					}},		$p;
		} else { 
			my $pkg='';
			if ( 0<= (index $p,'=') && $p=~m{([\w:]+)=(\w+)}) { 
				$pkg=$1.":", $ref=$2 }
			given($ref) {
				when (/^GLOB$/)		{ '<*='.<$p>.'>' }
				when (/^IO$/)			{ '<='.<$p>.'>'}
				when ('ARRAY') { 
				when ('SCALAR') { $pkg.'\\' . Px($$_, $lvl).' ' } 
				$pkg . "[". (join ',', map { Px($_, $lvl) } @$p ) ."]" }
				when ('HASH') { $pkg.'{' . ( join ', ', @{[
					map { Px($_, $lvl, 1) .  '=>'. Px($p->{$_}, $lvl) } 
					keys %$p]} ) . '}' }
				default { "$p" }
			}
		}
	}

	use constant NBH => 0x83;
	my %dflts=(depth=>2, noquote=>1);

	sub P(@) {    # 'safen' to string or FH or STDOUT
		my ($_, $p);
		my ($depth, $noquote) = ($dflts{depth}, $dflts{noquote});
		do{ @_=@$_[0] } if ref $_[0] eq 'ARRAY';
		if (ref $_[0] eq __PACKAGE__) {
			$p=shift;
			$depth=$p->{depth} if exists $p->{depth};
		}
		my ($fh, $f, $explicit_out);
		if (ref $_[0] eq 'GLOB') {
			($fh, $explicit_out) = (shift, 1);
		} else { $fh =\*STDOUT }
		my ($fc, $fmt, @flds, $res)=(1, $_[0]);
#		if ($fmt) {
#			if ((index $fmt, '%')>-1) {
#				@flds=split /(?<!%)%(?!%)/, $fmt;
#				$fc=scalar @flds;
#			}
#		}
		if ($fc) {
			$f=shift;
			no warnings;
			$res =  sprintf $f,	map {my $_ = Px($_,$depth,$noquote) } @_ } 
		else { $res=Px(@_)}
		chomp $res;
		my $ctx = defined wantarray;
    {use bytes; #pretend we know what we are doing... ;-)
		if ((ord substr $res,-1) eq NBH) {                 #"NO_BREAK_HERE"
      my $w=0; $w=1 if (ord substr $res, -2,1) eq 0xC2; #UTF-8 encoded?
			$res=substr $res,0,-($w+1)+length $res ;
			$ctx=1;
		}};
		if (!$fh && !$ctx) {	#internal consistancy check
			$fh = \*STDERR and P $fh 
	 						"Invalid File Handle presented for output, using STDERR:";
			$explicit_out=1;
		} else { return $res if (!$explicit_out and $ctx) }
		$fh->print ($res . (!$ctx ? "\n" : "")  );
	};
	sub Pa(@) {goto &P};
	sub Pe($;@) {
		return unless scalar @_;
		unshift @_, \*STDERR;
		goto &P 
	};
	sub Pea(@) {goto &Pe};
	sub Pae(@) {goto &Pe};


	sub ops($) {
		my $p = shift; my $c=ref $p || $p;
		bless $p = {}, $c unless ref $p;
		my $args = $_[0];
		$p->{$_}=$dflts{$_} for keys %dflts;
		die "ops takes a hash to pass arguments" unless ref $args eq 'HASH';
		foreach (keys %$args) {
			unless (exists $p->{$_}) {
				warn P "Unknown key \"%s\" passed to ops",$_;
			} else {
				$p->{$_}=$args->{$_};
			}
		}
		$p
	}


1;}
{
	package main;
  use 5.10.0;
	use utf8;

	(caller 0)[0] || do {
    $_=do{ $/=undef, <main::DATA>};
		close main::DATA;
		eval $_;
    die "self-test failed: $@" if $@;
		1;
	};
1;
}

############################################################################
#{{{1
#    use P;

=head1 NAME

P, Pe, Pa, Pae                       Safer, General Format + Print sub

=head1 VERSION

Version  "1.0.10"

=head1 SYNOPSIS

=over 

=item
S<P <FILEHANDLE, FORMAT, LIST|FORMAT, LIST|LIST> >

=item
S<Pa @ARRAY>

=item
S<Pe, Pae (same as P and Pa but ouput defaults to STDERR)>

=back

Combined printf, sprintf & say in 1 routine (almost).  Can safely handle
*args* to formmatted strings that are 'undef' & will print '(undef)' in
place of the output.  It knows how to print simple references and does so
automatically rather than HASH=(0x235432), at the 1st level, it
will print the contents of the hash: {none=>0, one=>1, two=>2}.  Meant
for use in development and as debug aid.  Made executable and run, 
it does a small self-demo/test. Pod-documentation also builtin.

=head1 DESCRIPTION

While designed to speed up and simplify development, isn't limited to such.

It tries to auto-handle adding Newlines at the end of a line, substrating
or adding LF's at the end depending on the circumstance.  When you print
vars via a string format, "undef" is handled 'in-line', with (undef)
being printed in fields (though it is likely to retrn a 0 for numeric
formats at this time.

The auto-newline feature at the end of a line can be supressed by adding
the Unicode control char "Don't break here" (0x83) at the end of a string.

Any items printed as strings that are undef -- will print '(undef)'.

=head1 EXAMPLES

=over 4

=item  
S<P "Hello %s", "World";        # auto NL when to a FH>

=item
S<>

=item 
S<P "Hello \x83"; P "World";    # \x83: suppress auto-NL to FH's >

=item
S<>

=item
S<$s = P "%s", "Hello %s";      # not needed if printing to string >

=item
S<P $s, "World";                # still prints "Hello World" >

=item
S<>

=item 
S<@a = ("%s", "my string");     # using array, fmt as 1st arg >

=item 
S<Pa @a;                        # use 'Pa' have @a as args to 'P'>

=item 
S<@a = ("Hello %s", "World");   # format in array[0]>

=item 
S<Pa @a;                        # use @a as args for P>

=item 
S<P @a;                         # prints first of @a elements (Hello %s)>

=item
S<>

=item
S<P 0 + @a;                     # prints #items in 'a'>

=item
S<P "a=%s", \@a;                # prints contents of 'a': [1,2,3...]>

=item
S<>

=item 
S<P STDERR, @a                  # use @a as args to a specific FH>

=item	
S<                              # NOTE: "," after FH L</*STC>>

=item 
S<Pe  "Output to STDERR"        # 'Shortcut' for P to STDERR>

=item
S<>

=item
S<# P Hash bucket usage + contents with hashes>

=item
S<>

=over 1

=item
S<%H=(one=E<gt>1, two=E<gt>2, u=E<gt>undef);>

=back

=item
S<>

=item
S<P "%H #items %s", 0+%H;       # - Show number of  items in hash>

=item
S<P "%H hash usage: %s", "".%H; # - Shows used/total Hash bucket usage>

=item
S<P "%H=%s", \%H;               # show contents of hash {x=>E<gt>S<y, ...}>

=item
S<P "*this=%s", $this;          # show blessed objs. + top-lvl content>

=back

=head1 NOTES

Note, values given as args to a formatted print statement, are
checked for undef and substitute "(undef)" for undefined values.
If you print vars as numbers, this can have the side effect of causing
runtime format errors, so best to print as strings to see 'undef'.
S<>
While usable in any code, it's use was designed to save typing, time
and work of undef checking, newline handling, and doing the right
thing with given input.  It may not be suitable where speed is
important.
S<>
S<>
=cut
#}}}1

__DATA__
# line ' .__LINE__ . ' "' ' __FILE__ . "\"\n" . '
foreach (qw{STDERR STDOUT}) {select *$_; $|=1};
use strict; use warnings;
use P;
my %tests;
my $MAXCASES=11;
{ my $i=1;
  foreach (@ARGV) {
    $tests{$_}=1 when /^\d+/ && $_<=$MAXCASES;
    default {die P "%s: no such test case", $_}
  }
}
exists $tests{7} and $tests{6}=1;

my $format="#%-2d %-25s: ";
{
  my $case=0;
  sub newcase() {++$case}
  sub caseno() {$case};
  sub iter(){"Hello Perl ${\(0+&caseno)}"}
}

sub case ($) {
  &newcase;
  if (!@ARGV || $tests{&caseno}) {
	  $_=P (\*STDOUT, $format,  &caseno, "(".$_[0].")");
    1
  } else {
    0;
  }
}


case "ret from func" &&
  P &iter;                         			# case 1: return from func


case "w/string" &&
  P "${\(+iter())}";                   	# case 2 w/string

case "passed array" && do {
  my @msg = ("%s", &iter ); 
  Pa @msg;                           		# case 3 (hack around perlbug)
};

case "w/fmt+string" &&
  P "%s",iter;                       		# case 4

case "to STDERR" &&
  P \*STDERR, iter;                  		# case 5 #needs redirection to see

our $str;

case "to strng embedded in #7" && do {	# case 6 to string; prints in case 7
	$str = P "%s",iter; 
  P "";
};

case "prev string" &&										# case 7 - print embedded P output
  P "prev str=\"%s\" (no LF) && ${\(+iter())}", $str;

case "p thru '/.../rev' fr/FH" && do {	# case 8 - P 'pipe'
  my $fh;
  open $fh, "echo -n \"(echo) ${\(+iter)}\" |rev |tr -d \"\n\" |" or 
    die p(\*STDERR, "Problem opening 'rev' util ($!),".
                     " got PATH?(skipping)\n\n", 1); 
    P \*STDOUT, "%s", $fh;
};


case "P && array ref"  && do {
  my @ar=qw(one two three 4 5 6);
  P "%s",\@ar;													# case 9 - array expansion
};

my %hash=(a=>'apple', b=>'bread', c=>'cherry');
case "P HASH ref" &&										# case 10 - hash expansion
  P "%s", \%hash;

case "P Pkg ref" && do									# case 11 - blessed object
{	my $hp;
	bless $hp={a=>1, b=>2}, 'Pkg';
	P "%s", $hp;
};

# vim: ts=2 sw=2

