#!/bin/sh

# nanomips_abi_version.sh - Check for ABIVERSION mismatch

# Copyright (C) 2024 Free Software Foundation, Inc.
# Written by Faraz Shahbazker <faraz.shahbazker@mediatek.com>

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

# Output ABI version for matching inputs
check nanomips_abi_version_0.stdout "ABI Version:[\ ]*0"
check nanomips_abi_version_1.stdout "ABI Version:[\ ]*1"

# Output ABI version error for mis-matched inputs
check nanomips_abi_version_01.stderr "nanomips_foo_abi_0.o: ABI version 0 is not compatible with ABI version 1 output"
check nanomips_abi_version_10.stderr "nanomips_bar_abi_0.o: ABI version 0 is not compatible with ABI version 1 output"

# Output ABI version is 1 when allowing mis-matched inputs
check nanomips_no_abi_mismatch_01.stdout "ABI Version:[\ ]*1"
check nanomips_no_abi_mismatch_01.stdout "ABI Version:[\ ]*1"

exit 0
