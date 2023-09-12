#!/bin/sh

# nanomips_function_call.sh -- test nanoMIPS function call transformations.

# Copyright (C) 2018 Free Software Foundation, Inc.
# Written by Vladimir Radosavljevic <vladimir.radosavljevic@mips.com>.

# This file is part of gold.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston,
# MA 02110-1301, USA.

check()
{
    file=$1
    pattern=$2
    
    found=`grep "$pattern" $file`
    if test -z "$found"; then
	echo "pattern \"$pattern\" not found in file $file."
	exit 1
    fi
}

# Test li[48] transformation into lapc[48].
check nanomips_fix_hw110880.stdout " 1000000:	6083 23fa 	lapc\[48\]	a0.*"

# Test li[48] transformation into aluipc, ori.
check nanomips_fix_hw110880.stdout " 1000006:	e0a1 2a22 	aluipc	a1,.*"
check nanomips_fix_hw110880.stdout " 100000a:	80a5 0500 	ori	a1,a1,.*"

# Test li[48] not being transformed
check nanomips_fix_hw110880.stdout " 100000e:	60c0 0000 	li\[48\]	a2,.*"

# Test addiu[48] transformation into lapc[48], addu.
check nanomips_fix_hw110880.stdout " 1000014:	6023 23e6 	lapc\[48\]	at,.*"
check nanomips_fix_hw110880.stdout " 100001a:	2027 3950 	addu\[32\]	a3,a3,at"

# Test addiu[48] transformation into aluipc, ori, addu.
check nanomips_fix_hw110880.stdout " 100001e:	e021 2a22 	aluipc	at,.*"
check nanomips_fix_hw110880.stdout " 1000022:	8021 0500 	ori	at,at,.*"
check nanomips_fix_hw110880.stdout " 1000026:	2028 4150 	addu\[32\]	a4,a4,at"

# Test addiu[48] not being transformed
check nanomips_fix_hw110880.stdout " 100002a:	6121 0000 	addiu\[48\]	a5,a5,.*"

# Test lapc[48] not being transformed
check nanomips_fix_hw110880.stdout " 1000030:	6183 23ca 	lapc\[48\]	t0,.*"

# Test lapc[48] transformation into aluipc, ori.
check nanomips_fix_hw110880.stdout " 1000036:	e1a1 2a22 	aluipc	t1,.*"
check nanomips_fix_hw110880.stdout " 100003a:	81ad 0500 	ori	t1,t1,.*"

# Test swpc[48] not being transformed
check nanomips_fix_hw110880.stdout " 100003e:	61cf 23bc 	swpc\[48\]	t2,.*"

# Test swpc[48] transformation into aluipc, sw.
check nanomips_fix_hw110880.stdout " 1000044:	e021 2a22 	aluipc	at,.*"
check nanomips_fix_hw110880.stdout " 1000048:	85e1 9500 	sw\[u12\]	t3,.*(at)"

exit 0
