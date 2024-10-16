#!/bin/sh

# nanomips_justsymbols_script.sh - Check --just-symbols with symbol
# script

# Copyright (C) 2024 Free Software Foundation, Inc.
# Written by Andrija Jovanovic <ot_andrija.jovanovic@mediatek.com>

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
    pattern0=$2

    found=`grep "$pattern0" $file`
    if test -z "$found"; then
      echo "pattern \"$pattern0\" not found in file $file."
      exit 1
    fi
}

check nanomips_justsymbols_script.stdout "00000004     0 NOTYPE  GLOBAL DEFAULT  ABS loop"
check nanomips_justsymbols_script.stdout "00000003     0 NOTYPE  GLOBAL DEFAULT  ABS c"
check nanomips_justsymbols_script.stdout "00000002     0 NOTYPE  GLOBAL DEFAULT  ABS b"
check nanomips_justsymbols_script.stdout "00000001     0 NOTYPE  GLOBAL DEFAULT  ABS a"

check nanomips_justsymbols_script_1.stderr "justsymbols_script_obj_sup.o: multiple definition of 'fun'"
check nanomips_justsymbols_script_1.stderr "just symbols script: previous definition here"
check nanomips_justsymbols_script_2.stderr "just symbols script: multiple definition of 'fun'"
check nanomips_justsymbols_script_2.stderr "justsymbols_script_obj_sup.o: previous definition here"

check nanomips_no_justsymbols_script.stdout "00000005     0 NOTYPE  GLOBAL DEFAULT  ABS fun"
