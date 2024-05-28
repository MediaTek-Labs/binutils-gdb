#!/bin/sh

# nanomips_balc_trampoline.sh - Test that generating
# balc trampolines is valid (converting several balcs
# into 16 bit balcs while one becomes a trampoline
# - balc[16], bc[16], bc[32] that the others jump to)

# Copyright (C) 2023 Free Software Foundation, Inc.
# Written by Andrija Jovanovic <andrija.jovanovic@syrmia.com>.

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

check nanomips_balc_trampoline.stdout "3912 "
check nanomips_balc_trampoline.stdout "3910 "
check nanomips_balc_trampoline.stdout "3812 "
check nanomips_balc_trampoline.stdout "3810 "
check nanomips_balc_trampoline.stdout "380e "
check nanomips_balc_trampoline.stdout "380c "
check nanomips_balc_trampoline.stdout "380a "
check nanomips_balc_trampoline.stdout "60a3 fffe "
check nanomips_balc_trampoline.stdout "001f "
check nanomips_balc_trampoline.stdout "3802 "
check nanomips_balc_trampoline.stdout "1804 "
check nanomips_balc_trampoline.stdout "2800 0fe8 "
check nanomips_balc_trampoline.stdout "3803 "
check nanomips_balc_trampoline.stdout "3801 "


check nanomips_balc_trampoline.stdout "3808 "
check nanomips_balc_trampoline.stdout "3806 "
check nanomips_balc_trampoline.stdout "3804 "
check nanomips_balc_trampoline.stdout "2bff fbfd "


check nanomips_balc_trampoline.stdout "3814 "
check nanomips_balc_trampoline.stdout "3812 "

check nanomips_balc_trampoline.stdout "1808 "