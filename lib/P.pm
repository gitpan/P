#!/usr/bin/perl  -w

{ package P;
	# next line needed for P.pm to be runnable & pass it's tests
	BEGIN{ $::INC{__PACKAGE__.".pm"} = __FILE__."#__LINE__"};
	use 5.8.0;
	use warnings;
	our $VERSION='1.0.15';


	# RCS $Revision: 1.30 $ -  $Date: 2012-03-15 21:01:06-08 $
	# 1.0.15  - remove 'my $_' usage; old perl compat probs; use local
  #           in once instance were needed local copy of $_
	# 1.0.14  - arg! misspelled Win nul: devname(fixed)
	# 1.0.13  - test case change only to better test print to STDERR
	# 1.0.12  - test case change: change of OBJ->print to print OBJ to
	#           try to get around problem on BSD5.12 in P.pm (worked!)
	#         - change embedded test case to not use util 'rev', but
	#           included perl script 'rev' in 't' directory...(for native win)
	# 1.0.11	- revert printing decimals using %d: dropped significant leading
	#           zero's;  Of NOTE: floating point output in objects is
	#           not default: we use ".2f"
	#         - left off space after comma in arrays(fixed)
	#         - rewrite of sections using given/when/default to not use
	#           them; try for 5.8 compat
	#         - call perl for invoking test vs. relying on #! invokation
	#         - pod updates mentioning 'ops'/depth
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

	my $given = [[ '$p =~ /^[-+]?\d+$/',				q{%s}			],
								[ '$ro',	 										q{%s}			],
								[ '1==length $p',							q{'%s'}		],
								[ '$p =~ /^[+-]?\d*\.\d*$/',	q{%.2f}		],
								[ 1, 													q{"%s"}		]	];
	sub Px { my $p = shift;
		my $lvl = scalar @_ ? $_[0] : 2;
		my $ro = scalar @_>1 ? $_[1]:0;
		return "(undef)" unless defined $p;
		my $ref = ref $p;
		if (!$ref || 1 >$lvl--) {
			sprintf &{sub(){eval $_->[0] && return $_->[1] for @$given }}, $p;
		} else { 
			my $pkg='';
			($pkg, $ref)=($1, $2) if 0<= (index $p,'=') && $p=~m{([\w:]+)=(\w+)}; 
			my %actions = ( 
				GLOB	=>	\&{sub(){'<*='.<$p>.'>'}},
				IO		=>	\&{sub(){ '<='.<$p>.'>'}},
				SCALAR=>	\&{sub(){ $pkg.'\\' . Px($$_, $lvl).' ' }},
				ARRAY	=>	\&{sub(){ $pkg."[". 
													(join ', ', map{ Px($_, $lvl) } @$p ) ."]" }},
				HASH	=>	\&{sub(){ $pkg.'{' . ( join ', ', @{[
											map { Px($_, $lvl, 1) .  '=>'. Px($p->{$_}, $lvl,0) } 
											keys %$p]} ) . '}' }},);
			if (my $act=$actions{$ref}) { &$act } 
			else { "$p" }
		}
	}

	use constant NBH => 0x83;
	my %dflts=(depth=>2, noquote=>1);

	sub P(@) {    # 'safen' to string or FH or STDOUT
		my $p = $_[0];
		my ($depth, $noquote) = ($dflts{depth}, $dflts{noquote});
    if (ref $p eq __PACKAGE__) {
			$c = shift; $p = $_[0];
			$depth = $c->{depth} if exists $c->{depth};
    }
    if (ref $p eq 'ARRAY') {  #expand first parm into list of parms
      $p = shift;
      @_=(@$p, @_);
      $p=$_[0];
		}
		my ($fh, $f, $explicit_out);
    my $rp=ref $p;
		if ($rp eq 'GLOB' || $rp eq 'IO') {
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
			$res =  sprintf $f,	map {local $_ = Px($_,$depth,$noquote) } @_ } 
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
		print $fh ($res . (!$ctx ? "\n" : "")  );
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
			} else { $p->{$_}=$args->{$_} } }
		$p }
1;}

{
	package main;
  use 5.8.0;
	use utf8;

	(caller 0)[0] || do {
    $_=do{ $/=undef, <main::DATA>};
		close main::DATA;
		our @globals;
		eval $_;
    die "self-test failed: $@" if $@;
		1;
	};
1;
}

############################################################################
#							Pod documentation						{{{1
#    use P;

=head1 NAME

=encoding utf-8


P, Pe                               Safer, friendlier sprintf/printf+say

=head1 VERSION

Version  "1.0.15"

=head1 SYNOPSIS


  P FILEHANDLE, FORMAT, LIST
  P FORMAT, LIST
  P @ARRAY
  $s=P @ARRAY; P $s;          # same output as "P @
  Pe                          # same as P, but output to  STDERR


L<P> is a combined printf, sprintf & say in 1 routine .  It was designed
to save on typing and undef checking when printing strings.  It saves on
in that you don't have constantly insert or move C<newline>s (C<\n>).  
If you change a string into a formatted string, insert P, as in:

  die "Wrong number of params";
             # to
  die P "Expecting 2 params, got %s", scalar @ARGV;


When printed as
strings (C<"%s">), undefs are automatically caught and "C<(undef)>" is
printed in place of C<Use of uninitialized value $x in xxx at -e line z.>
L<P> knows how to print simple references and does so automatically. Instead
of HASH=(0x235432), at the first two¹ levels, it will print the contents
of the hash: {none=>0, one=>1, two=>2}.  Meant for use in development and
as debug aid.  Made executable and run, it does a small self-demo/test.
Pod-documentation also builtin. 

¹-two was chosen so that the first level of the interior of an object
could be printed, as the first reference is to the object itself.

=head1 DESCRIPTION

While designed to speed up and simplify development, isn't limited to such.

It automatically handles newlines at the end of output, letting the user 
ignore an LF at the end of a line (present or not).  

The auto-newline feature at the end of a line can be supressed by adding
the Unicode control char "Don't break here" (0x83) at the end of a string,
but be warned, in normal ourput, lines are line buffered and the I/O
system  won't flush the output until it sees the end-of-line.

Blessed objects, by default,  are printed with a short label at the front.
This means the output is NOT, at this time, by default, valid perl
code.  Compactness takes precidence over language semantics.  Note that
these default when printing objects via C<"%s">.  Printing something other
than a reference will print (or format) the object the same way that
printf or sprintf would.

A difference between P and sprintf, paraphrasing and contrasting the
sprintf documentation: B<Like> C<printf>, P follows the perl design
philosophy and tries to I<"Do what you mean"> when you pass it array as your
first argument.  The array is NOT given scalar context and instead of
trying to use the size of the array as a format (which is almost never
useful), it will use the first element of the array as the format
specification by which to format the rest of the arguments.  This is the
same behavior of C<printf> and fixes a wart in the language.  It also,
can automatically be used as a replacement for "say", as it auto-appends
the needed LineFeed at the end of line.  It will NOT append a line
feed to the formatted output if it is assigned to a variable.

B<NOTE:> this has the, sometimes, surprising effect of silencing C<P> when
you might not expect it: if it is the last statement in a subroutine,
P will assume that you want to return the formatted string as the value
of the subroutine or function.  

=head1 Experimental Feature

While P is normally called procedurally, and not as an object, there are 
some rare cases where you would really like it to print just 1 level
deeper.  In such cases, to pass options to P, you need an object handle
to it's C<ops> routine to which you can pass a C<depth> parameter.

=head1 Example

Suppose you had an array of objects, and you wanted to see the contents
of the objects in the array.  Normally P would only print the first level
-- being the contents of the array:


  my %complex_probs = (                                
      questions =E<gt> [ "sqrt(-4)",  "(1-i)**2"     ],
      answers   =E<gt> [ {real => 0, i =>2 }, 
                     {real => 0, i => -2 } ] );
  P "my probs = %s", \%complex_probs;


Would normally produce:


  my probs = {questions=>["sqrt(-4)", "(1-i)**2"], answers=>["HASH(0x235efc0)", "HASH(0x235f098)"]} 


When you might want to see those hashes as they are short anyway.  To
do that you'd use the object and print with that, like this:


  my %complex_probs = (                                     
      questions => [ "sqrt(-4)",          "(1-i)**2"     ],
      answers   => [ {real => 0, i =>2 }, { real => 0, i => -2 } ] );
  my $p=P::->ops({depth=>3});                                
  $p->P("my array = %s", \%complex_probs);


Which produces:


  my array = {questions=["sqrt(-4)", "(1-i)**2"], answers=>[{i=>2, real=>0}, {i=>-2, real=>0}]}


B<Note:>  Don't confuse L<P::P> with a Pretty Printer or Data::Dumper.  I<Especially>, when printing references, it was designed as a debug aid.


=head1 MORE EXAMPLES


  P "Hello %s", "World";        # auto NL when to a FH
  P "Hello \x83"; P "World";    # \x83: suppress auto-NL to FH's 
  $s = P "%s", "Hello %s";      # not needed if printing to string 
  P $s, "World";                # still prints "Hello World" 

  @a = ("%s", "my string");     # using array, fmt as 1st arg 
  P @a;

  @a = ("Hello %s", "World");   # format in array[0]
  P @a;
  P @a;                         # prints 1st of @a elements (Hello %s)
  P 0 + @a;                     # prints #items in 'a'

  P "a=%s", \@a;                # prints contents of 'a': [1,2,3...]

  P STDERR, @a                  # use @a as args to a specific FH
                                # NOTE: "," after FH 
  Pe  "Output to STDERR"        # 'Shortcut' for P to STDERR

  # P Hash bucket usage + contents with hashes
  %H=(one=>1, two=>2, u=>undef);

  P "%H #items %s", 0+%H;       # Show number of  items in hash
  P "%H hash usage: %s", "".%H; # Shows used/total Hash bucket usage
  P "%H=%s", \%H;               # Show contents of hash:
    %H={u=>(undef), one=>1, two=>2}

  bless my $h=\%H, 'Hclass';    # Blessed objs... 
  P "Obj-h = %s", $h;        #     & content:
    Obj-h = Hclass{u=>(undef), one=>1, two=>2}


=head1 NOTES

Values given as args with a format statement, are
checked for B<undef> and have "C<(undef)>" substituted for undefined values.
If you print vars as in decimal or floating point, they'll likely show up 
as 0, which doesn't stand out as well as "C<(undef)>",

While usable in any code, it's use was designed to save typing, time
and work of undef checking, newline handling, and doing the right
thing with the given input.  It may not be suitable where speed is
important.

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
    if (/^\d+/ && $_<=$MAXCASES) {$tests{$_}=1}
		else {die P "%s: no such test case", $_}
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
	my $cmd = "echo -n \"(echo) ${\(+iter)}\" |perl t/rev";
  open $fh, "$cmd |" or 
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
	bless $hp={a=>1, b=>2, x=>'y'}, 'Pkg';
	P "%s", $hp;
};

# vim: ts=2 sw=2

