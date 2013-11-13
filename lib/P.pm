#!/usr/bin/perl  -w

{ package P;
	# next line needed for P.pm to be runnable & pass it's tests
	BEGIN{ $::INC{__PACKAGE__.".pm"} = __FILE__."#__LINE__"};

	use warnings;
	our $VERSION='1.1.11';
	use utf8;
# vim=:SetNumberAndWidth

	# RCS $Revision: 1.41 $ -  $Date: 2013-11-12 14:17:12-08 $
	# 1.1.11	- May have found another test bug.... trying fix for some fails
	# 1.1.10	- Another internal format error bug (unreported), but caught
	# 					in testing.
	# 1.1.9		- Try to fix paths for test
	# 1.1.8		- use ptar to generate Archive::tar compat archives
	# 1.1.7		- Fix Makefile.PL
	# 1.1.6		- Use t/P.env for premodifying  ENV
	# 					Document effect of printing to a FH & recording return val;
	# 1.1.5		- Distribution change: use --format=v7 on tar to produce tarball
	# 					(rt#90165)
	# 				- Use shell script to preset env for test since 
	# 				  Test::More doesn't set ENV 
	# 1.1.4		- Quick patch to enable use of state w/CORE::state
	# 1.1.3		- [#$@%&!!!]
	# 1.1.2		- Second try for test in P.t to get prereq's right
	# 1.1.1   - Fix rest of (rt#89050)
	# 1.1.0		- Fixed Internal bug#001, below & embedded \n@end of int. str
	# 					(rt#89064)
	# 1.0.32	- Fix double nest test case @{[\*STDERR, ["fmt:%s", "string"]]}
	# 					(rt#89056)
	# 					only use sprintf's numeric formats (e.g. %d, %f...) on
	# 					numbers supported by sprintf (for now only arabic numerals).
	# 					Otherwise print as string. (rt#89063)
	# 					its numeric formats (ex "%d", "%f"...)
	# 1.0.31	- Fix check for previously printed items to apply only to
	# 				- the current output statement;
	# 1.0.30  - Fix LF suppression -- instead of suppressing EOL, suppressed
	# 					all output in the case where no FD was specified (code was
	# 					confused in deciding whether or not to suppress output and 
	# 					return it as a string. (rt#89058)
	# 				- Add missing quote in Synopsis (rt#89047)
	# 				- Change NAME section to reference module following CPAN
	# 				  standard to re-list name of module instead of functions
	# 				  (rt#89046)
	# 				- Fix L<> in POD that referenced "module" P::P instead of name, "P"
	# 				  (forms bad link in HTML) (rt#89051)
	# 				- Since ($;@) prototypes cause more problems than (@), clean p
	# 				  proto's to use '@'; impliciation->remove array variations
	# 				  (rt@89052, #89055) (rt#89058)
	# 				- fix outdated and inconsistent doc examples regarding old protos
	#						(rt#89056)(rt#89058)
	#						Had broken P's object oriented flag passing in adding 
	#						the 'seen' function (to prevent recursive outptut.  Fixed this
	#						while testing that main::DATA is properly closed (rt#89057,#89067)
	#					- Internal Bug #001
	#							#our @a = ("Hello %s", "World");
	#							#P(\*STDERR, \@a);       
	#							#		prints-> ARRAY(0x1003b40)
	# 1.0.29	- Convert to using 'There does not exist' sign (∄), U+2204
	# 					instead of (undef);  use  '🔁 ' for recursion/repeat;
	# 					U+1F500
	# 1.0.28	- When doing explicit out (FH specified), be sure to end
	# 					with newln. 
	# 1.0.27  - DEFAULT change - don't do implicit IO reads (change via 
	# 						impicit_io option)
	#           - not usually needed in debugging or most output;
	#           could cause problems
	#           reading data from a file and causing desychronization problems; 
	# 1.0.26	- detect recursive data structs and don't expand them
	# 1.0.25	- Add expansion for 'REF'; 
	# 				- WIP: Trying to incorporate enumeration of duplicate adjacent 
	# 					data: Work In Progress: status: disabled
	# 1.0.24	- limit default max string expanded to 140 chars (maybe want to
	# 					do this only in brace expansions?)  Method to change in OOO
	# 					not documented at this time. NOTE: limiting output by default
	# 					is not a great idea.
	# 1.0.23	- When printing contents of a hash, print non-refs before 
	# 					refs, and print each subset in alpha sorted order
  # 1.0.22  - Switch to {…} instead of HASH(0x12356892) or 
	# 										[…] for arrays
  # 1.0.21  - Doc change: added example of use in "die".
	# 1.0.20	- Rewrite of testcase 5 in self-execution; no external progs
	#           anymore: use fork and print from P in perl child, then
	#           print from FH in parent, including uses of \x83 to
	#           inhibit extra LF's;
	# 1.0.19  - Regretting fancy thru 'rev' P direct from FH test case (a bit)
	#           **seems** like some people don't have "." in path for test 
	#           cases, so running "t/prog" doesn't work, trying "./t/prog"
  #           (1 fail on a Win32 base on a x64 system...so tempted
	#           to just ignore it...) >;^); guess will up this for now
	#           and think about that test case some more...
	#           I'm so gonna rewrite that case! (see xtodox below)
	# 1.0.18  - convert top format-case statement to load-time compile
	#           and see if that helps BSD errors;
	#         - change test case w/array to use P & not old Pa-form
	#         - change test case to print to STDERR to use Pe
	#         - fix bug in decrement of $lvl in conditional (decrement must
	#           be in first part of conditional)
	#         - xtodox fix adaptation of 'rev' test case to work w/o 
	#           separate file(done)
	# 1.0.17  - another try at fixing pod decoding on metacpan
	# 1.0.16  - pod '=encoding' move to before '=head' 
	#           (ref:https://github.com/CPAN-API/metacpan-web/issues/800 )
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
	{ no warnings "once";
		*IO::Handle::P = P::P; *IO::Handle::Pe = P::P }
	our ($types_available, @TYPES);
		
	##NOTE: the types-code is here from yet-to-be published helper mod
	#       include minimal necessary bits to make things work
	#
	BEGIN {@EXPORT=qw(P Pe), @ISA=qw(Exporter); 

			eval {require  Types; Types->import()};
	 $types_available=!$@;

		use mem(@TYPES=qw(ARRAY CODE GLOB HASH IO REF SCALAR));
		eval '# line ' . __LINE__ .' '. __FILE__ .' 
			
		sub _isatype($$) {
			my ($var, $type) = @_;
			ref $var && (1+index($var, $type)) ? 1 : 0;
		}';
		$@ && die "_isatype eval(2): $@";
		unless ($types_available) {
			eval '# line ' . __LINE__ .' '. __FILE__ .'
							sub ' . $_ . ' (;*) {	
								return @_ ? _isatype($_[0], '.$_.') : '.$_.' } ' for @TYPES;
		}
	}

	use Exporter;
	our %dflts;
	use mem(%dflts=(implicit_io=>0, depth=>3, noquote=>1, maxstring=>undef));

	BEGIN {
		use constant EXPERIMENTAL=>0;	

	if (EXPERIMENTAL) {				#{{{
		sub rm_adjacent {
			my $c = 1;
			($a, $c) = @$a if ref $a;
			$b //= "∄";
			if ($a ne $b) { $c > 1 ? "$a × $c" : $a , $b } 
			else { (undef, [$a, ++$c]) }
		}
		sub reduce(&@) {
			my (@final, $i) =((), 0);
			my ($f, $ar)=@_;
			for (my $i=0; $i <  $#$ar; ++$i ) {
				($a, $b) = ($ar->[$i], $ar->[$i+1]);
				my @r = &$f;
				push @final, $r[0] if $r[0];
				$ar->[$i+1] = $r[1];
			}
			@final;
		}
	} 
	}															#}}}

	use constant {UTF8lead => 0xc2, NoBrHr => 0x83, BkSlsh => 0x5c};

	sub Px { my $p=shift; my $v = shift;
		if (ref $v) {
			if ($p->{__P_seen}{$v}) { return "*🔁 :".$v."*" }
			else {$p->{__P_seen}{$v}=1}
		}
		my $lvl = scalar @_ ? $_[0] : 2;
		my $ro = scalar @_>1 ? $_[1]:0;
		return "∄" unless defined $v;
		my $ref = ref $v;
		if (1 > $lvl-- || !$ref) {
			my $fmt;			# prototypes are documentary (rt#89053)
			my $given = [	sub ($$) { $_[0] =~ /^[-+]?[0-9]+\.?\z/			&& q{%s}	},
										sub ($$) { $_[1] 														&& qq{%s}},
										sub ($$) { 1==length($_[0]) 								&& q{'%s'}},
										sub ($$) { $_[0] =~ 
											/^(?:[+-]?(?:\.[0-9]+)
												|(?:[0-9]+\.[0-9]+))\z/x  &&  q{%.2f}},
										sub ($$) { substr($_[0],0,4) eq HASH				&& q({…})},
										sub ($$) { substr($_[0],0,5) eq ARRAY				&& q([…])},
										#	sub ($$) { $mxstr && length ($_[0])>$mxstr 
										#						&& qq("%.${mxstr}s")},
										sub ($$) { 1																&& q{"%s"}} ];

			do { $fmt = $_->($v, $ro) and last } for @$given;
			return sprintf $fmt, $v;
		} else { 
			my $pkg = '';
			($pkg, $ref) = ($1, $2) if 0 <= (index $v,'=') && $v=~m{([\w:]+)=(\w+)}; 
			local * nonrefs_b4_refs ;
			* nonrefs_b4_refs = sub {
				ref $v->{$a} cmp ref $v->{$b}  || $a cmp $b 
			};

			local ($IO_glob, $NIO_glob, $IO_io, $NIO_io) = (
						sub(){'<*'.<$v>.'>'}, sub(){'<*='.$p->Px($v, $lvl-1).'>'},
						sub(){'<='.<$v>.'>'}, sub(){'<|'.$p->Px($v, $lvl-1).'|>'},
					);

			my %actions = ( 
				GLOB	=>	$p->{implicit_io}? $IO_glob:$NIO_glob,
				IO		=>	$p->{implicit_io}? $IO_io:$NIO_io,
				REF		=>	sub(){ "\\" . $p->Px($$_, $lvl-1) . ' '},
				SCALAR=>	sub(){ $pkg.'\\' . $p->Px($$_, $lvl).' ' },
				ARRAY	=>	sub(){ $pkg."[". 
												(join ', ', 
#	not working: why?			#reduce \&rm_adjacent, (commented out)
												map{ $p->Px($_, $lvl) } @$v ) ."]" },
				HASH	=>	sub(){ $pkg.'{' . ( join ', ', @{[
										map {$p->Px($_, $lvl, 1) . '=>'. $p->Px($v->{$_}, $lvl,0)} 
										sort  nonrefs_b4_refs keys %$v]} ) . '}' },);
			if (my $act=$actions{$ref}) { &$act } 
			else { return "$v" }
		}
	}

	BEGIN{ if (0) {		# unused
		sub hex_str($) {
			my ($offset, @ar) = (0,split //, shift);
			printf "%02x%s", ord ($ar[$offset]), 
												++$offset%8 ? " ":"\n"  while $offset < @ar;
			print "\n" unless $offset%8;
		}
	}}

	sub P(@) {    # 'safen' to string or FH or STDOUT
		my $p=ref $_[0] eq 'P' ? shift: bless {};
		$p->{__P_seen}={} unless ref $p->{__P_seen};

		local * unsee_ret  = sub ($) { 
			delete $p->{__P_seen} if exists $p->{__P_seen}; 
			$_[0] };

		my $v = $_[0];
    my $rv = ref $v;
		my ($depth, $noquote) = ($dflts{depth}, $dflts{noquote});
    if (HASH eq $rv) {
			my $params = $v; $v = shift; $rv = ref $v;
			$depth = $params->{depth} if exists $params->{depth};
    }
    if (ARRAY eq $rv ) { $v = shift;
      @_=(@$v, @_); $v=$_[0]; $rv = ref $v }

		my ($fh, $f, $explicit_out);
		if ($rv eq GLOB || $rv eq IO) {
			($fh, $explicit_out) = (shift, 1);
			$v = $_[0]; $rv = ref $v;
		} else { $fh =\*STDOUT }
    
		if (ARRAY eq $rv ) { $v = shift;
      @_=(@$v, @_); $v=$_[0]; $rv = ref $v }
    
		my ($fc, $fmt, @flds, $res)=(1, $_[0]);
		if ($fc) { $f = shift; no warnings;
			$res =  sprintf $f,	map {local $_ = $p->Px($_,$depth,$noquote) } @_ } 
		else { $res = $p->Px(@_)}

		chomp $res;

		my ($nl, $ctx) = ("\n", defined wantarray ? 1 : 0);

		($res, $nl, $ctx) = (substr($res, 0, -1 + length $res), "", 2) if
					ord(substr $res,-1) == NoBrHr;									#"NO_BREAK_HERE"

		if (!$fh && !$ctx) {	#internal consistancy check
			($fh = \*STDERR) and 
				P $fh "Invalid File Handle presented for output, using STDERR";
			($explicit_out, $nl) = (1, "\n") }

		else { return unsee_ret($res) if (!$explicit_out and $ctx==1) }

		print $fh ($res . (!$ctx && (!$\ || $\ ne "\n") ? "\n" : "")  );
		unsee_ret($res);
	};

	sub Pe(@) {
		my $p = shift if ref $_[0];
		return '' unless @_;
		unshift @_, \*STDERR;
		unshift @_, $p if ref $p;
		goto &P 
	}



	sub ops($) {
		my $p = shift; my $c=ref $p || $p;
		bless $p = {}, $c unless ref $p;
		my $args = $_[0];
		$p->{$_}=$dflts{$_} for sort keys %dflts;
		die "ops takes a hash to pass arguments" unless HASH $args;
		foreach (sort keys %$args) {
			if (exists $p->{$_}) { $p->{$_}=$args->{$_} } 
			else { 
				warn  "Unknown key \"$_\" passed to ops";} 
		}
		$p }
1;}		#value 1 placed at as w/most of my end-of-packages (rt#89054)

{
	package main;
	use utf8;

	unless ((caller 0)[0]) {
		binmode P::DATA, ":utf8";
		binmode *STDOUT, ":utf8";
		binmode *STDERR, ":utf8";
    $_=do{ $/=undef, <P::DATA>};
		close P::DATA;
		our @globals;
		eval $_;
    die "self-test failed: $@" if $@;
		1;
	} else {
		close P::DATA;
	}
1;
}

############################################################################
#							Pod documentation						{{{1
#    use P;

=encoding utf-8

=head1 NAME

P  -   Safer, friendlier printf/print/sprintf + say

=head1 VERSION

Version  "1.1.11"

=head1 SYNOPSIS


  P FILEHANDLE, FORMAT, LIST
  P FORMAT, LIST
  P @ARRAY
  $s=P @ARRAY; P $s;          # same output as "P @ARRAY" 
  Pe                          # same as P, but output to  STDERR


C<P> is a combined printf, sprintf & say in 1 routine.  It was designed
to save on typing and undef checking when printing strings.  It saves on
in that you don't have constantly insert or move C<newline>s (C<\n>).  
If you change a string into a formatted string, insert P, as in:

  die "Wrong number of params";
             # to
  die P "Expecting 2 params, got %s", scalar @ARGV;


When printed as
strings (C<"%s">), undefs are automatically caught and "E<0x2204>", (U+2204 - 
meaning "I<There does not exist>") is
printed in place of "C<Use of uninitialized value $x in xxx at -e line z.>"

By default C<P>, prints the content of references (instead HASH 
(or ARRAY)=(0x12345678), three levels deep.  Deeper nesting is replaced
by the unicode ellipsis character (U+2026).

=head1 DESCRIPTION

While designed for development use, it is useful in many more situations, as 
tries to "do the right thing" based on context.  It can usually be used
as a drop-in replacement the perl functions C<print>, C<printf>, C<sprintf>,
and, C<say>.  

P tries to smartly handle newlines at the end of the line -- adding them 
or subtracting them based on if they are going to a file handle or to another
variable.

The newline handling at the end of a line can be supressed by adding
the Unicode control char "Don't break here" (0x83) at the end of a string
or by assigning the return value B<and> having a file handle as the first
argument.  Ex: C<my $fmt = P STDOUT, "no LF added=> ";>.

Blessed objects, by default,  are printed with the Class name in front of the
reference.   Note that these substitutions are performed only with 
references printed through a string (C<"%s">) format -- features designed
to give useful output in development or debug situations.

One minor difference between C<P> and C<sprintf>': P takes the same
list format as C<printf>.  P does not implement the sprintf's design flaw
in forcing an array argument into scalar context, which is described in
the perl documentation as something that is almost never useful.

B<NOTE:> A side effect of P being a contextual replacement for sprintf,
is if it is used as the last line of a subroutine.  By default, this
won't print it's arguments to STDOUT, but acts as sprintf in returning
the formatted string to the caller.

=head1 Experimental Features

While P is normally called procedurally, and not as an object, there are 
some rare cases where you would really like it to print "just 1 level
deeper".  To do that, you need to get a pointer to P's C<options>. 

To get that pointer, call P::->ops({key=>value}) to set C<P>'s options and
save the return value.  Use that as a class-pointer to call P.  See
following example.

=head1 Example

Suppose you had an array of objects, and you wanted to see the contents
of the objects in the array.  Normally P would only print the first two levels:


  my %complex_probs = (                                
      questions =E<gt> [ "sqrt(-4)",  "(1-i)**2"     ],
      answers   =E<gt> [ {real => 0, i =>2 }, 
                     {real => 0, i => -2 } ] );
	my $prob_ref = \%complex_problems;
  P "my probs = %s", [$prob_ref];


Would normally produce:

  my probs = [{answers=>[{…}, {…}], questions=>["sqrt(-4)", "(1-i)**2"]}]


When you might want to see those hashes as they are short anyway.  To
do that you'd use the object and print with that, like this:


  my %complex_probs = (                                     
      questions => [ "sqrt(-4)",          "(1-i)**2"     ],
      answers   => [ {real => 0, i =>2 }, { real => 0, i => -2 } ] );
  my $p=P::->ops({depth=>4});                                
  $p->P("my array = %s", \%complex_probs);


Which produces:
  
  my probs = [{answers=>[{i=>2, real=>0}, {i=>-2, real=>0}],  # extra "\n" 
	             questions=>["sqrt(-4)", "(1-i)**2"]}]

B<Note:>  Don't confuse C<P> with a Pretty Printer or Data::Dumper.  I<Especially>, when printing references, it was designed as a debug aid.



=head1 Summary of possible OO args to "ops"

=over 4

depth=>3;          Allows setting depth of nested structure printing.  NOTE: regardless of depth, recursive structures in the same call to C<P>, will not expand but be displayed in some abbreviated form (in flux).

implicit_io=>0;    in printing references, references to globs and i/O handles do not have their contents printed.  If this is wanted, one would call C<ops> with this set to true.

noquote=>1;        in printing items in hashes or arrays, data that are read only or do not need quoting don't have quoting (contrast to Data::Dumper, where it can be turned off or on, but not turned on, only when needed).

maxstring=>undef;      Allows specifying a maximum length of any single datum when expanded from an indirection expansion.

=back


=head1 Example 2: Not worrying about "undefs"

Looking at some old code of mine, I found this:

  print sprintf STDERR,
    "Error: in parsing (%s), proto=%s, host=%s, page=%s\n",
    $_[0] // "null", $proto // "null", $host // "null",
    $path // "null";
  die "Exiting due to error."

Too many words and effort in upgrading a die message! Now it looks like:

  die P "Error: in parsing (%s), proto=%s, host=%s, page=%s",
          $_[0], $proto, $host, $path;

It's not just about formatting or replacing sprintf -- but automatically
giving you sanity in places like error messages and debug output when
the variables you are printing may be 'undef' -- which would abort the
output entirely!



=head1 MORE EXAMPLES


  P "Hello %s", "World";            # auto NL when to a FH
  P "Hello \x83"; P "World";        # \x83: suppress auto-NL to FH's 
  $s = P "%s", "Hello %s";          # not needed if printing to string 
  P $s, "World";                    # still prints "Hello World" 

  @a = ("Hello %s", "World");       # using array, fmt as 1st arg 
  P @a;                             # print "Hello World"
  P 0 + @a;                         # prints #items in '@a': 2

  P "a=%s", \@a;                    # prints contents of 'a': [1,2,3...]

  P STDERR @a                       # use @a as args to a specific FH
                                    # Uses indirect method calls when invoked
                                    # like "print FH ARGS"
                                    #
  Pe  "Output to STDERR"            # 'Shortcut' for P to STDERR

  # P Hash bucket usage + contents with hashes:
  %H=(one=>1, two=>2, u=>undef);

  P "%H hash usage: %s", "".%H;     # Shows used/total Hash bucket usage
  P "%H=%s", \%H;                   # Show contents of hash:
    %H={u=>(undef), one=>1, two=>2}

  bless my $h=\%H, 'Hclass';        # Blessed objs... 
  P "Obj-h = %s", $h;               #   & content:
    Obj-h = Hclass{u=>(undef), one=>1, two=>2}


=head1 NOTES

Values given as args with a format statement, are
checked for B<undef> and have "E<0x2204>" substituted for undefined values.
If you print vars as in decimal or floating point, they'll likely show up 
as 0, which doesn't stand out as well.

Sometimes the perl parser gets confused about what args belong to P and
which do not.  Using parens (i.e. C<P("Hello World")>) can help in those
cases.

Usable in any code, P was was designed to save typing, time
and work of undef checking, newline handling, peeking at data 
structures in small spaces during development.  It tries to do
the "right thing" with the given input. It may not be 
suitable where speed is paramount.

=cut
#}}}1

package P;
__DATA__
# line ' .__LINE__ . ' "' ' __FILE__ . "\"\n" . '
use utf8;
use open IN => q(:utf8);
use open OUT => q(:utf8);
foreach (qw{STDERR STDOUT}) {select *$_; $|=1};
use strict; use warnings; 
use P;
my %tests;
my $MAXCASES=13;
{ my $i=1;
  foreach (@ARGV) {
    if (/^\d+/ && $_<=$MAXCASES) {$tests{$_}=1}
		else {die P "%s: no such test case", $_}
  }
}
exists $tests{7} and $tests{6}=1;

my $format="#%-2d %-25s: ";
{	#mini-package
  my $case=0;
  sub newcase() {++$case}
  sub caseno() {$case};
  sub iter(){"Hello Perl ${\(0+&caseno)}"}
}

sub case ($) {
  &newcase;
  if (!@ARGV || $tests{&caseno}) {
	  P ("$format\x83",  &caseno, "(".$_[0].")");
    1
  } else {
    0;
  }
}


case "ret from func" &&
  P iter;                         			# case 1: return from func


case "w/string" &&
  P "${\(+iter())}";                   	# case 2 w/string

case "passed array" && do {
  my @msg = ("%s", &iter ); 
  P  @msg;                              # case 3 -- being passed Array
};

case "w/fmt+string" &&
  P "%s",iter;                       		# case 4

case "to STDERR" &&
  Pe iter;                           		# case 5 #needs redirection to see

our $str;

case "to strng embedded in #7" && do {	# case 6 to string; prints in case 7
	$str = P "%s",iter; 
  P "";
};

sub timed_read($$) {
	my ($fh, $timeout)= @_;
	my $result;
	eval {
		local $SIG{ALRM} = sub {die P "timeout"};
		alarm $timeout;
		$result=<$fh>; 
		alarm 0;
	};
	return $result unless $@;
	die P "unexpected error in read: $@" unless $@ eq "timeout";
	$result="timeout";
}

sub rev{ 1 >= length $_[0] ?	$_[0] : 
							substr( $_[0], -1) .  rev(substr $_[0], 0, -1) } 

case "prev string" &&										# case 7 - print embedded P output
  P "prev str=\"%s\" (no LF) && ${\(+iter())}", $str;

case "P && array ref"  && do {
  my @ar=qw(one two three 4 5 6);
  P "%s",\@ar;													# case 8 - array expansion
};

my %hash=(a=>'apple', b=>'bread', c=>'cherry');
case "P HASH ref" &&										# case 9 - hash expansion
  P "%s", \%hash;

case "P Pkg ref" && do									# case 10 - blessed object
{	my $hp;
	bless $hp={a=>1, b=>2, x=>'y'}, 'Pkg';
	P "%s", $hp;
};

case "P \@{[FH,[\"fmt:%s\",…]]}" && do	# case 11 - embed (FH,[fmt,parms])
{																				# (rt#89056)
	P @{[\*STDOUT, ["fmt:%s", &iter]]};
};

case "truncate embedded float" && do		# case 12 - embedded float
{	my $pi=4*atan2(1,1);
	P "norm=%s, embed=%s", $pi, {pi=>$pi};
};

case "test mixed digit string" && do		# case 13 - embed foreign digits
{	use utf8;my $p="3.ⅰⅳⅰⅴⅸ";
	P "embed roman pi = %s", [$p];
};
# vim: ts=2 sw=2

