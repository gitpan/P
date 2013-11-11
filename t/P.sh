#!/bin/sh

unset PERL5OPT


mydir=`dirname "$0"`
fc=`echo "$mydir"|cut -c1`

if [ "${mydir}" = "" ] ; then
	mydir = "$PWD"
fi

dn=/dev/null
if [ ! -e /dev/null ]; then dn="NUL:" ; fi

myprog=`basename $0 ".sh"`

PATH="$mydir:$PATH"

PERL5LIB="$mydir/../blib/lib"

export PERL5LIB
export PATH

unset -v PERL5OPT

exec "$myprog.t" "@_"

