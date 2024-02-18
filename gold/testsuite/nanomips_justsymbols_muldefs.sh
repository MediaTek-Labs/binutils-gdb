#!/bin/sh

# nanomips_justsymbols_muldefs.sh - Test that the --just-symbols
# allow multiple definitions except when used with -z nobfd-compat-muldefs.

# Copyright (C) 2024 Free Software Foundation, Inc.
# Written by Dragan Mladjenovic <Dragan.Mladjenovic@syrmia.com>.

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

check nanomips_justsymbols_muldefs.stdout "no error"
check nanomips_justsymbols_nobfd_compat_muldefs.stderr "multiple definition of '__start'"

exit 0
