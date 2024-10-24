#!/bin/sh

# nanomips_eh_frame_start_end_syms.sh -- test generation of start/end eh_frame
# section symbols.

# Copyright (C) 2024 Free Software Foundation, Inc.
# Written by Andrija Jovanovic <andrija.jovanovic@htecgroup.com>.

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


check nanomips_eh_frame_start_end_syms_1.stdout ".eh_frame         PROGBITS        00001000 001000 000028"
# Global hidden symbols may be demoted to local symbols, that's why that is
# not checked
check nanomips_eh_frame_start_end_syms_1.stdout "00001000     0 NOTYPE [A-Z ]* HIDDEN [0-9 ]* __eh_frame_start"
check nanomips_eh_frame_start_end_syms_1.stdout "00001028     0 NOTYPE [A-Z ]* HIDDEN [0-9 ]* __eh_frame_end"

check nanomips_eh_frame_start_end_syms_2.stdout ".eh_frame         PROGBITS        00001000 001000 000028"
check nanomips_eh_frame_start_end_syms_2.stdout ".eh_frame_hdr     PROGBITS        00002000 002000 000014"
check nanomips_eh_frame_start_end_syms_2.stdout "00001000     0 NOTYPE [A-Z ]* HIDDEN [0-9 ]* __eh_frame_start"
check nanomips_eh_frame_start_end_syms_2.stdout "00001028     0 NOTYPE [A-Z ]* HIDDEN [0-9 ]* __eh_frame_end"
check nanomips_eh_frame_start_end_syms_2.stdout "00002000     0 NOTYPE [A-Z ]* HIDDEN [0-9 ]* __eh_frame_hdr_start"
check nanomips_eh_frame_start_end_syms_2.stdout "00002014     0 NOTYPE [A-Z ]* HIDDEN [0-9 ]* __eh_frame_hdr_end"
