#!/bin/sh

# nanomips_balc_relax.sh - Test that the 32-bit balc
# instructions are relaxed to their 16-bit variants.

# Copyright (C) 2023 Free Software Foundation, Inc.
# Written by Aleksandar Rikalo <aleksandar.rikalo@syrmia.com>.

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

check nanomips_balc_relax.stdout "380c "
check nanomips_balc_relax.stdout "380a "
check nanomips_balc_relax.stdout "3808 "
check nanomips_balc_relax.stdout "3806 "
check nanomips_balc_relax.stdout "3804 "
check nanomips_balc_relax.stdout "3802 "
check nanomips_balc_relax.stdout "1804 "
check nanomips_balc_relax.stdout "3813 "
check nanomips_balc_relax.stdout "3811 "
check nanomips_balc_relax.stdout "380f "
check nanomips_balc_relax.stdout "380d "
check nanomips_balc_relax.stdout "380b "
check nanomips_balc_relax.stdout "3809 "
