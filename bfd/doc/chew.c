/* chew
   Copyright (C) 1990-2024 Free Software Foundation, Inc.
   Contributed by steve chamberlain @cygnus

   This file is part of BFD, the Binary File Descriptor library.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston,
   MA 02110-1301, USA.  */

/* Yet another way of extracting documentation from source.
   No, I haven't finished it yet, but I hope you people like it better
   than the old way

   sac

   Basically, this is a sort of string forth, maybe we should call it
   struth?

   You define new words thus:
   : <newword> <oldwords> ;

   Variables are defined using:
   variable NAME

*/

/* Primitives provided by the program:

   Two stacks are provided, a string stack and an integer stack.

   Internal state variables:
	internal_wanted - indicates whether `-i' was passed
	internal_mode - user-settable

   Commands:
	push_text
	! - pop top of integer stack for address, pop next for value; store
	@ - treat value on integer stack as the address of an integer; push
		that integer on the integer stack after popping the "address"
	hello - print "hello\n" to stdout
	stdout - put stdout marker on TOS
	stderr - put stderr marker on TOS
	print - print TOS-1 on TOS (eg: "hello\n" stdout print)
	skip_past_newline
	catstr - fn icatstr
	copy_past_newline - append input, up to and including newline into TOS
	dup - fn other_dup
	drop - discard TOS
	idrop - ditto
	remchar - delete last character from TOS
	get_stuff_in_command
	do_fancy_stuff - translate <<foo>> to @code{foo} in TOS
	bulletize - if "o" lines found, prepend @itemize @bullet to TOS
		and @item to each "o" line; append @end itemize
	courierize - put @example around . and | lines, translate {* *} { }
	exit - fn chew_exit
	swap
	outputdots - strip out lines without leading dots
	maybecatstr - do catstr if internal_mode == internal_wanted, discard
		value in any case
	catstrif - do catstr if top of integer stack is nonzero
	translatecomments - turn {* and *} into comment delimiters
	kill_bogus_lines - get rid of extra newlines
	indent
	print_stack_level - print current stack depth to stderr
	strip_trailing_newlines - go ahead, guess...
	[quoted string] - push string onto string stack
	[word starting with digit] - push atol(str) onto integer stack

	internalmode - the internalmode variable (evaluates to address)

   A command must be all upper-case, and alone on a line.

   Foo.  */

#include <assert.h>
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <inttypes.h>

#define DEF_SIZE 5000
#define STACK 50

/* Here is a string type ...  */

typedef struct buffer
{
  char *ptr;
  unsigned long write_idx;
  unsigned long size;
} string_type;

/* Compiled programs consist of arrays of these.  */

typedef union
{
  void (*f) (void);
  struct dict_struct *e;
  char *s;
  intptr_t l;
} pcu;

typedef struct dict_struct
{
  char *word;
  struct dict_struct *next;
  pcu *code;
  int code_length;
  int code_end;
} dict_type;

int internal_wanted;
intptr_t *internal_mode;

int warning;

string_type stack[STACK];
string_type *tos;

unsigned int pos_idx = 0; /* Pos in input buffer */
string_type *buf_ptr; /* and the buffer */

intptr_t istack[STACK];
intptr_t *isp = &istack[0];

dict_type *root;

pcu *pc;

static void
die (char *msg)
{
  fprintf (stderr, "%s\n", msg);
  exit (1);
}

static void *
xmalloc (size_t size)
{
  void *newmem;

  if (size == 0)
    size = 1;
  newmem = malloc (size);
  if (!newmem)
    die ("out of memory");

  return newmem;
}

static void *
xrealloc (void *oldmem, size_t size)
{
  void *newmem;

  if (size == 0)
    size = 1;
  if (!oldmem)
    newmem = malloc (size);
  else
    newmem = realloc (oldmem, size);
  if (!newmem)
    die ("out of memory");

  return newmem;
}

static char *
xstrdup (const char *s)
{
  size_t len = strlen (s) + 1;
  char *ret = xmalloc (len);
  return memcpy (ret, s, len);
}

static void
init_string_with_size (string_type *buffer, unsigned int size)
{
  buffer->write_idx = 0;
  buffer->size = size;
  buffer->ptr = xmalloc (size);
}

static void
init_string (string_type *buffer)
{
  init_string_with_size (buffer, DEF_SIZE);
}

static void
write_buffer (string_type *buffer, FILE *f)
{
  if (buffer->write_idx != 0
      && fwrite (buffer->ptr, buffer->write_idx, 1, f) != 1)
    die ("cannot write output");
}

static void
delete_string (string_type *buffer)
{
  free (buffer->ptr);
  buffer->ptr = NULL;
}

static char *
addr (string_type *buffer, unsigned int idx)
{
  return buffer->ptr + idx;
}

static char
at (string_type *buffer, unsigned int pos)
{
  if (pos >= buffer->write_idx)
    return 0;
  return buffer->ptr[pos];
}

static void
catchar (string_type *buffer, int ch)
{
  if (buffer->write_idx == buffer->size)
    {
      buffer->size *= 2;
      buffer->ptr = xrealloc (buffer->ptr, buffer->size);
    }

  buffer->ptr[buffer->write_idx++] = ch;
}

static void
overwrite_string (string_type *dst, string_type *src)
{
  free (dst->ptr);
  dst->size = src->size;
  dst->write_idx = src->write_idx;
  dst->ptr = src->ptr;
}

static void
catbuf (string_type *buffer, char *buf, unsigned int len)
{
  if (buffer->write_idx + len >= buffer->size)
    {
      while (buffer->write_idx + len >= buffer->size)
	buffer->size *= 2;
      buffer->ptr = xrealloc (buffer->ptr, buffer->size);
    }
  memcpy (buffer->ptr + buffer->write_idx, buf, len);
  buffer->write_idx += len;
}

static void
cattext (string_type *buffer, char *string)
{
  catbuf (buffer, string, (unsigned int) strlen (string));
}

static void
catstr (string_type *dst, string_type *src)
{
  catbuf (dst, src->ptr, src->write_idx);
}

static unsigned int
skip_white_and_stars (string_type *src, unsigned int idx)
{
  char c;
  while ((c = at (src, idx)),
	 isspace ((unsigned char) c)
	 || (c == '*'
	     /* Don't skip past end-of-comment or star as first
		character on its line.  */
	     && at (src, idx +1) != '/'
	     && at (src, idx -1) != '\n'))
    idx++;
  return idx;
}

static unsigned int
skip_past_newline_1 (string_type *ptr, unsigned int idx)
{
  while (at (ptr, idx)
	 && at (ptr, idx) != '\n')
    idx++;
  if (at (ptr, idx) == '\n')
    return idx + 1;
  return idx;
}

static void
check_range (void)
{
  if (tos < stack)
    die ("underflow in string stack");
  if (tos >= stack + STACK)
    die ("overflow in string stack");
}

static void
icheck_range (void)
{
  if (isp < istack)
    die ("underflow in integer stack");
  if (isp >= istack + STACK)
    die ("overflow in integer stack");
}

static void
drop (void)
{
  tos--;
  check_range ();
  delete_string (tos + 1);
  pc++;
}

static void
idrop (void)
{
  isp--;
  icheck_range ();
  pc++;
}

static void
exec (dict_type *word)
{
  pc = word->code;
  while (pc->f)
    pc->f ();
}

static void
call (void)
{
  pcu *oldpc = pc;
  dict_type *e = pc[1].e;
  exec (e);
  pc = oldpc + 2;
}

static void
remchar (void)
{
  if (tos->write_idx)
    tos->write_idx--;
  pc++;
}

static void
strip_trailing_newlines (void)
{
  while (tos->write_idx > 0
	 && (isspace ((unsigned char) at (tos, tos->write_idx - 1))
	     || at (tos, tos->write_idx - 1) == '\n'))
    tos->write_idx--;
  pc++;
}

static void
push_number (void)
{
  isp++;
  icheck_range ();
  pc++;
  *isp = pc->l;
  pc++;
}

/* This is a wrapper for push_number just so we can correctly free the
   variable at the end.  */
static void
push_variable (void)
{
  push_number ();
}

static void
push_text (void)
{
  tos++;
  check_range ();
  init_string (tos);
  pc++;
  cattext (tos, pc->s);
  pc++;
}

/* This function removes everything not inside comments starting on
   the first char of the line from the  string, also when copying
   comments, removes blank space and leading *'s.
   Blank lines are turned into one blank line.  */

static void
remove_noncomments (string_type *src, string_type *dst)
{
  unsigned int idx = 0;

  while (at (src, idx))
    {
      /* Now see if we have a comment at the start of the line.  */
      if (at (src, idx) == '\n'
	  && at (src, idx + 1) == '/'
	  && at (src, idx + 2) == '*')
	{
	  idx += 3;

	  idx = skip_white_and_stars (src, idx);

	  /* Remove leading dot */
	  if (at (src, idx) == '.')
	    idx++;

	  /* Copy to the end of the line, or till the end of the
	     comment.  */
	  while (at (src, idx))
	    {
	      if (at (src, idx) == '\n')
		{
		  /* end of line, echo and scrape of leading blanks  */
		  if (at (src, idx + 1) == '\n')
		    catchar (dst, '\n');
		  catchar (dst, '\n');
		  idx++;
		  idx = skip_white_and_stars (src, idx);
		}
	      else if (at (src, idx) == '*' && at (src, idx + 1) == '/')
		{
		  idx += 2;
		  cattext (dst, "\nENDDD\n");
		  break;
		}
	      else
		{
		  catchar (dst, at (src, idx));
		  idx++;
		}
	    }
	}
      else
	idx++;
    }
}

static void
print_stack_level (void)
{
  fprintf (stderr, "current string stack depth = %ld, ",
	   (long) (tos - stack));
  fprintf (stderr, "current integer stack depth = %ld\n",
	   (long) (isp - istack));
  pc++;
}

/* turn {*
   and *} into comments */

static void
translatecomments (void)
{
  unsigned int idx = 0;
  string_type out;
  init_string (&out);

  while (at (tos, idx))
    {
      if (at (tos, idx) == '{' && at (tos, idx + 1) == '*')
	{
	  cattext (&out, "/*");
	  idx += 2;
	}
      else if (at (tos, idx) == '*' && at (tos, idx + 1) == '}')
	{
	  cattext (&out, "*/");
	  idx += 2;
	}
      else
	{
	  catchar (&out, at (tos, idx));
	  idx++;
	}
    }

  overwrite_string (tos, &out);

  pc++;
}

/* Wrap tos-1 as a C comment, indenting by tos.  */

static void
wrap_comment (void)
{
  string_type out;
  init_string (&out);

  catstr (&out, tos);
  cattext (&out, "/* ");
  for (unsigned int idx = 0; at (tos - 1, idx); idx++)
    {
      catchar (&out, at (tos - 1, idx));
      if (at (tos - 1, idx) == '\n' && at (tos - 1, idx + 1) != '\n')
	{
	  catstr (&out, tos);
	  cattext (&out, "   ");
	}
    }
  cattext (&out, "  */");

  overwrite_string (tos - 1, &out);
  drop ();
}

/* Mod tos so that only lines with leading dots remain */
static void
outputdots (void)
{
  unsigned int idx = 0;
  string_type out;
  init_string (&out);

  while (at (tos, idx))
    {
      /* Every iteration begins at the start of a line.  */
      if (at (tos, idx) == '.')
	{
	  char c;
	  int spaces;

	  idx++;
	  spaces = 0;
	  while ((c = at (tos, idx)) && c != '\n')
	    {
	      if (spaces >= 0)
		{
		  if (c == ' ')
		    {
		      spaces++;
		      idx++;
		      continue;
		    }
		  else
		    {
		      while (spaces >= 8)
			{
			  catchar (&out, '\t');
			  spaces -= 8;
			}
		      while (spaces-- > 0)
			catchar (&out, ' ');
		    }
		}
	      if (c == '{' && at (tos, idx + 1) == '*')
		{
		  cattext (&out, "/*");
		  idx += 2;
		}
	      else if (c == '*' && at (tos, idx + 1) == '}')
		{
		  cattext (&out, "*/");
		  idx += 2;
		}
	      else
		{
		  catchar (&out, c);
		  idx++;
		}
	    }
	  if (c == '\n')
	    idx++;
	  catchar (&out, '\n');
	}
      else
	{
	  idx = skip_past_newline_1 (tos, idx);
	}
    }

  overwrite_string (tos, &out);
  pc++;
}

/* Find lines starting with . and | and put example around them on tos */
static void
courierize (void)
{
  string_type out;
  unsigned int idx = 0;
  int command = 0;

  init_string (&out);

  while (at (tos, idx))
    {
      if (at (tos, idx) == '\n'
	  && (at (tos, idx +1 ) == '.'
	      || at (tos, idx + 1) == '|'))
	{
	  cattext (&out, "\n@example\n");
	  do
	    {
	      idx += 2;

	      while (at (tos, idx) && at (tos, idx) != '\n')
		{
		  if (command > 1)
		    {
		      /* We are inside {} parameters of some command;
			 Just pass through until matching brace.  */
		      if (at (tos, idx) == '{')
			++command;
		      else if (at (tos, idx) == '}')
			--command;
		    }
		  else if (command != 0)
		    {
		      if (at (tos, idx) == '{')
			++command;
		      else if (!islower ((unsigned char) at (tos, idx)))
			--command;
		    }
		  else if (at (tos, idx) == '@'
			   && islower ((unsigned char) at (tos, idx + 1)))
		    {
		      ++command;
		    }
		  else if (at (tos, idx) == '{' && at (tos, idx + 1) == '*')
		    {
		      cattext (&out, "/*");
		      idx += 2;
		      continue;
		    }
		  else if (at (tos, idx) == '*' && at (tos, idx + 1) == '}')
		    {
		      cattext (&out, "*/");
		      idx += 2;
		      continue;
		    }
		  else if (at (tos, idx) == '{'
			   || at (tos, idx) == '}')
		    {
		      catchar (&out, '@');
		    }

		  catchar (&out, at (tos, idx));
		  idx++;
		}
	      catchar (&out, '\n');
	    }
	  while (at (tos, idx) == '\n'
		 && ((at (tos, idx + 1) == '.')
		     || (at (tos, idx + 1) == '|')))
	    ;
	  cattext (&out, "@end example");
	}
      else
	{
	  catchar (&out, at (tos, idx));
	  idx++;
	}
    }

  overwrite_string (tos, &out);
  pc++;
}

/* Finds any lines starting with "o ", if there are any, then turns
   on @itemize @bullet, and @items each of them. Then ends with @end
   itemize, inplace at TOS*/

static void
bulletize (void)
{
  unsigned int idx = 0;
  int on = 0;
  string_type out;
  init_string (&out);

  while (at (tos, idx))
    {
      if (at (tos, idx) == '@'
	  && at (tos, idx + 1) == '*')
	{
	  cattext (&out, "*");
	  idx += 2;
	}
      else if (at (tos, idx) == '\n'
	       && at (tos, idx + 1) == 'o'
	       && isspace ((unsigned char) at (tos, idx + 2)))
	{
	  if (!on)
	    {
	      cattext (&out, "\n@itemize @bullet\n");
	      on = 1;

	    }
	  cattext (&out, "\n@item\n");
	  idx += 3;
	}
      else
	{
	  catchar (&out, at (tos, idx));
	  if (on && at (tos, idx) == '\n'
	      && at (tos, idx + 1) == '\n'
	      && at (tos, idx + 2) != 'o')
	    {
	      cattext (&out, "@end itemize");
	      on = 0;
	    }
	  idx++;

	}
    }
  if (on)
    {
      cattext (&out, "@end itemize\n");
    }

  delete_string (tos);
  *tos = out;
  pc++;
}

/* Turn <<foo>> into @code{foo} in place at TOS*/

static void
do_fancy_stuff (void)
{
  unsigned int idx = 0;
  string_type out;
  init_string (&out);
  while (at (tos, idx))
    {
      if (at (tos, idx) == '<'
	  && at (tos, idx + 1) == '<'
	  && !isspace ((unsigned char) at (tos, idx + 2)))
	{
	  /* This qualifies as a << startup.  */
	  idx += 2;
	  cattext (&out, "@code{");
	  while (at (tos, idx)
		 && at (tos, idx) != '>' )
	    {
	      catchar (&out, at (tos, idx));
	      idx++;

	    }
	  cattext (&out, "}");
	  idx += 2;
	}
      else
	{
	  catchar (&out, at (tos, idx));
	  idx++;
	}
    }
  delete_string (tos);
  *tos = out;
  pc++;

}

/* A command is all upper case,and alone on a line.  */

static int
iscommand (string_type *ptr, unsigned int idx)
{
  unsigned int len = 0;
  while (at (ptr, idx))
    {
      if (isupper ((unsigned char) at (ptr, idx))
	  || at (ptr, idx) == ' ' || at (ptr, idx) == '_')
	{
	  len++;
	  idx++;
	}
      else if (at (ptr, idx) == '\n')
	{
	  if (len > 3)
	    return 1;
	  return 0;
	}
      else
	return 0;
    }
  return 0;
}

static int
copy_past_newline (string_type *ptr, unsigned int idx, string_type *dst)
{
  int column = 0;

  while (at (ptr, idx) && at (ptr, idx) != '\n')
    {
      if (at (ptr, idx) == '\t')
	{
	  /* Expand tabs.  Neither makeinfo nor TeX can cope well with
	     them.  */
	  do
	    catchar (dst, ' ');
	  while (++column & 7);
	}
      else
	{
	  catchar (dst, at (ptr, idx));
	  column++;
	}
      idx++;

    }
  catchar (dst, at (ptr, idx));
  idx++;
  return idx;

}

static void
icopy_past_newline (void)
{
  tos++;
  check_range ();
  init_string (tos);
  pos_idx = copy_past_newline (buf_ptr, pos_idx, tos);
  pc++;
}

static void
kill_bogus_lines (void)
{
  int sl;

  int idx = 0;
  int c;
  int dot = 0;

  string_type out;
  init_string (&out);
  /* Drop leading nl.  */
  while (at (tos, idx) == '\n')
    {
      idx++;
    }
  c = idx;

  /* If the first char is a '.' prepend a newline so that it is
     recognized properly later.  */
  if (at (tos, idx) == '.')
    catchar (&out, '\n');

  /* Find the last char.  */
  while (at (tos, idx))
    {
      idx++;
    }

  /* Find the last non white before the nl.  */
  idx--;

  while (idx && isspace ((unsigned char) at (tos, idx)))
    idx--;
  idx++;

  /* Copy buffer upto last char, but blank lines before and after
     dots don't count.  */
  sl = 1;

  while (c < idx)
    {
      if (at (tos, c) == '\n'
	  && at (tos, c + 1) == '\n'
	  && at (tos, c + 2) == '.')
	{
	  /* Ignore two newlines before a dot.  */
	  c++;
	}
      else if (at (tos, c) == '.' && sl)
	{
	  /* remember that this line started with a dot.  */
	  dot = 2;
	}
      else if (at (tos, c) == '\n'
	       && at (tos, c + 1) == '\n'
	       && dot)
	{
	  c++;
	  /* Ignore two newlines when last line was dot.  */
	}

      catchar (&out, at (tos, c));
      if (at (tos, c) == '\n')
	{
	  sl = 1;

	  if (dot == 2)
	    dot = 1;
	  else
	    dot = 0;
	}
      else
	sl = 0;

      c++;

    }

  /* Append nl.  */
  catchar (&out, '\n');
  pc++;
  delete_string (tos);
  *tos = out;

}

static void
collapse_whitespace (void)
{
  int last_was_ws = 0;
  int idx;

  string_type out;
  init_string (&out);

  for (idx = 0; at (tos, idx) != 0; ++idx)
    {
      char c = at (tos, idx);
      if (isspace (c))
	{
	  if (!last_was_ws)
	    {
	      catchar (&out, ' ');
	      last_was_ws = 1;
	    }
	}
      else
	{
	  catchar (&out, c);
	  last_was_ws = 0;
	}
    }

  pc++;
  delete_string (tos);
  *tos = out;
}

/* indent
   Take the string at the top of the stack, do some prettying.  */

static void
indent (void)
{
  string_type out;
  int tab = 0;
  int idx = 0;
  int ol = 0;
  init_string (&out);
  while (at (tos, idx))
    {
      switch (at (tos, idx))
	{
	case '\n':
	  catchar (&out, '\n');
	  idx++;
	  if (tab && at (tos, idx))
	    {
	      int i;
	      for (i = 0; i < tab - 1; i += 2)
		catchar (&out, '\t');
	      if (i < tab)
		cattext (&out, "    ");
	    }
	  ol = 0;
	  break;
	case '(':
	  if (ol == 0)
	    {
	      int i;
	      for (i = 1; i < tab - 1; i += 2)
		catchar (&out, '\t');
	      if (i < tab)
		cattext (&out, "    ");
	      cattext (&out, "   ");
	    }
	  tab++;
	  idx++;
	  catchar (&out, '(');
	  ol = 1;
	  break;
	case ')':
	  tab--;
	  catchar (&out, ')');
	  idx++;
	  ol = 1;
	  break;
	default:
	  catchar (&out, at (tos, idx));
	  ol = 1;
	  idx++;
	  break;
	}
    }

  pc++;
  delete_string (tos);
  *tos = out;

}

static void
get_stuff_in_command (void)
{
  tos++;
  check_range ();
  init_string (tos);

  while (at (buf_ptr, pos_idx))
    {
      if (iscommand (buf_ptr, pos_idx))
	break;
      pos_idx = copy_past_newline (buf_ptr, pos_idx, tos);
    }
  pc++;
}

static void
swap (void)
{
  string_type t;

  t = tos[0];
  tos[0] = tos[-1];
  tos[-1] = t;
  pc++;
}

static void
other_dup (void)
{
  tos++;
  check_range ();
  init_string (tos);
  catstr (tos, tos - 1);
  pc++;
}

static void
icatstr (void)
{
  tos--;
  check_range ();
  catstr (tos, tos + 1);
  delete_string (tos + 1);
  pc++;
}

static void
skip_past_newline (void)
{
  pos_idx = skip_past_newline_1 (buf_ptr, pos_idx);
  pc++;
}

static void
maybecatstr (void)
{
  if (internal_wanted == *internal_mode)
    {
      catstr (tos - 1, tos);
    }
  delete_string (tos);
  tos--;
  check_range ();
  pc++;
}

static void
catstrif (void)
{
  int cond = isp[0];
  isp--;
  icheck_range ();
  if (cond)
    catstr (tos - 1, tos);
  delete_string (tos);
  tos--;
  check_range ();
  pc++;
}

static char *
nextword (char *string, char **word)
{
  char *word_start;
  int idx;
  char *dst;
  char *src;

  int length = 0;

  while (isspace ((unsigned char) *string) || *string == '-')
    {
      if (*string == '-')
	{
	  while (*string && *string != '\n')
	    string++;

	}
      else
	{
	  string++;
	}
    }
  if (!*string)
    {
      *word = NULL;
      return NULL;
    }

  word_start = string;
  if (*string == '"')
    {
      do
	{
	  string++;
	  length++;
	  if (*string == '\\')
	    {
	      string += 2;
	      length += 2;
	    }
	}
      while (*string != '"');
    }
  else
    {
      while (!isspace ((unsigned char) *string))
	{
	  string++;
	  length++;

	}
    }

  *word = xmalloc (length + 1);

  dst = *word;
  src = word_start;

  for (idx = 0; idx < length; idx++)
    {
      if (src[idx] == '\\')
	switch (src[idx + 1])
	  {
	  case 'n':
	    *dst++ = '\n';
	    idx++;
	    break;
	  case '"':
	  case '\\':
	    *dst++ = src[idx + 1];
	    idx++;
	    break;
	  default:
	    *dst++ = '\\';
	    break;
	  }
      else
	*dst++ = src[idx];
    }
  *dst++ = 0;

  if (*string)
    return string + 1;
  else
    return NULL;
}

static dict_type *
lookup_word (char *word)
{
  dict_type *ptr = root;
  while (ptr)
    {
      if (strcmp (ptr->word, word) == 0)
	return ptr;
      ptr = ptr->next;
    }
  if (warning)
    fprintf (stderr, "Can't find %s\n", word);
  return NULL;
}

static void
free_words (void)
{
  dict_type *ptr = root;

  while (ptr)
    {
      dict_type *next;

      free (ptr->word);
      if (ptr->code)
	{
	  int i;
	  for (i = 0; i < ptr->code_end - 1; i ++)
	    if (ptr->code[i].f == push_text
		&& ptr->code[i + 1].s)
	      {
		free (ptr->code[i + 1].s - 1);
		++i;
	      }
	    else if (ptr->code[i].f == push_variable)
	      {
		free ((void *) ptr->code[i + 1].l);
		++i;
	      }
	  free (ptr->code);
	}
      next = ptr->next;
      free (ptr);
      ptr = next;
    }
}

static void
perform (void)
{
  tos = stack;

  while (at (buf_ptr, pos_idx))
    {
      /* It's worth looking through the command list.  */
      if (iscommand (buf_ptr, pos_idx))
	{
	  char *next;
	  dict_type *word;

	  (void) nextword (addr (buf_ptr, pos_idx), &next);

	  word = lookup_word (next);

	  if (word)
	    {
	      exec (word);
	    }
	  else
	    {
	      if (warning)
		fprintf (stderr, "warning, %s is not recognised\n", next);
	      pos_idx = skip_past_newline_1 (buf_ptr, pos_idx);
	    }
	  free (next);
	}
      else
	pos_idx = skip_past_newline_1 (buf_ptr, pos_idx);
    }
}

static dict_type *
newentry (char *word)
{
  dict_type *new_d = xmalloc (sizeof (*new_d));
  new_d->word = word;
  new_d->next = root;
  root = new_d;
  new_d->code = xmalloc (sizeof (*new_d->code));
  new_d->code_length = 1;
  new_d->code_end = 0;
  return new_d;
}

static unsigned int
add_to_definition (dict_type *entry, pcu word)
{
  if (entry->code_end == entry->code_length)
    {
      entry->code_length += 2;
      entry->code = xrealloc (entry->code,
			      entry->code_length * sizeof (*entry->code));
    }
  entry->code[entry->code_end] = word;

  return entry->code_end++;
}

static void
add_intrinsic (char *name, void (*func) (void))
{
  dict_type *new_d = newentry (xstrdup (name));
  pcu p = { func };
  add_to_definition (new_d, p);
  p.f = 0;
  add_to_definition (new_d, p);
}

static void
add_variable (char *name, intptr_t *loc)
{
  dict_type *new_d = newentry (name);
  pcu p = { push_variable };
  add_to_definition (new_d, p);
  p.l = (intptr_t) loc;
  add_to_definition (new_d, p);
  p.f = 0;
  add_to_definition (new_d, p);
}

static void
add_intrinsic_variable (const char *name, intptr_t *loc)
{
  add_variable (xstrdup (name), loc);
}

static void
compile (char *string)
{
  /* Add words to the dictionary.  */
  char *word;

  string = nextword (string, &word);
  while (string && *string && word[0])
    {
      if (word[0] == ':')
	{
	  dict_type *ptr;
	  pcu p;

	  /* Compile a word and add to dictionary.  */
	  free (word);
	  string = nextword (string, &word);
	  if (!string)
	    continue;
	  ptr = newentry (word);
	  string = nextword (string, &word);
	  if (!string)
	    {
	      free (ptr->code);
	      free (ptr);
	      continue;
	    }
	  
	  while (word[0] != ';')
	    {
	      switch (word[0])
		{
		case '"':
		  /* got a string, embed magic push string
		     function */
		  p.f = push_text;
		  add_to_definition (ptr, p);
		  p.s = word + 1;
		  add_to_definition (ptr, p);
		  break;
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
		  /* Got a number, embedd the magic push number
		     function */
		  p.f = push_number;
		  add_to_definition (ptr, p);
		  p.l = atol (word);
		  add_to_definition (ptr, p);
		  free (word);
		  break;
		default:
		  p.f = call;
		  add_to_definition (ptr, p);
		  p.e = lookup_word (word);
		  add_to_definition (ptr, p);
		  free (word);
		}

	      string = nextword (string, &word);
	    }
	  p.f = 0;
	  add_to_definition (ptr, p);
	  free (word);
	  string = nextword (string, &word);
	}
      else if (strcmp (word, "variable") == 0)
	{
	  free (word);
	  string = nextword (string, &word);
	  if (!string)
	    continue;
	  intptr_t *loc = xmalloc (sizeof (intptr_t));
	  *loc = 0;
	  add_variable (word, loc);
	  string = nextword (string, &word);
	}
      else
	{
	  fprintf (stderr, "syntax error at %s\n", string - 1);
	}
    }
  free (word);
}

static void
bang (void)
{
  *(intptr_t *) ((isp[0])) = isp[-1];
  isp -= 2;
  icheck_range ();
  pc++;
}

static void
atsign (void)
{
  isp[0] = *(intptr_t *) (isp[0]);
  pc++;
}

static void
hello (void)
{
  printf ("hello\n");
  pc++;
}

static void
stdout_ (void)
{
  isp++;
  icheck_range ();
  *isp = 1;
  pc++;
}

static void
stderr_ (void)
{
  isp++;
  icheck_range ();
  *isp = 2;
  pc++;
}

static void
print (void)
{
  if (*isp == 1)
    write_buffer (tos, stdout);
  else if (*isp == 2)
    write_buffer (tos, stderr);
  else
    fprintf (stderr, "print: illegal print destination `%" PRIdPTR "'\n", *isp);
  isp--;
  tos--;
  icheck_range ();
  check_range ();
  pc++;
}

static void
read_in (string_type *str, FILE *file)
{
  char buff[10000];
  unsigned int r;
  do
    {
      r = fread (buff, 1, sizeof (buff), file);
      catbuf (str, buff, r);
    }
  while (r);
  buff[0] = 0;

  catbuf (str, buff, 1);
}

static void
usage (void)
{
  fprintf (stderr, "usage: -[d|i|g] <file >file\n");
  exit (33);
}

/* There is no reliable way to declare exit.  Sometimes it returns
   int, and sometimes it returns void.  Sometimes it changes between
   OS releases.  Trying to get it declared correctly in the hosts file
   is a pointless waste of time.  */

static void
chew_exit (void)
{
  exit (0);
}

int
main (int ac, char *av[])
{
  unsigned int i;
  string_type buffer;
  string_type pptr;

  init_string (&buffer);
  init_string (&pptr);
  init_string (stack + 0);
  tos = stack + 1;
  buf_ptr = &pptr;

  add_intrinsic ("push_text", push_text);
  add_intrinsic ("!", bang);
  add_intrinsic ("@", atsign);
  add_intrinsic ("hello", hello);
  add_intrinsic ("stdout", stdout_);
  add_intrinsic ("stderr", stderr_);
  add_intrinsic ("print", print);
  add_intrinsic ("skip_past_newline", skip_past_newline);
  add_intrinsic ("catstr", icatstr);
  add_intrinsic ("copy_past_newline", icopy_past_newline);
  add_intrinsic ("dup", other_dup);
  add_intrinsic ("drop", drop);
  add_intrinsic ("idrop", idrop);
  add_intrinsic ("remchar", remchar);
  add_intrinsic ("get_stuff_in_command", get_stuff_in_command);
  add_intrinsic ("do_fancy_stuff", do_fancy_stuff);
  add_intrinsic ("bulletize", bulletize);
  add_intrinsic ("courierize", courierize);
  /* If the following line gives an error, exit() is not declared in the
     ../hosts/foo.h file for this host.  Fix it there, not here!  */
  /* No, don't fix it anywhere; see comment on chew_exit--Ian Taylor.  */
  add_intrinsic ("exit", chew_exit);
  add_intrinsic ("swap", swap);
  add_intrinsic ("outputdots", outputdots);
  add_intrinsic ("maybecatstr", maybecatstr);
  add_intrinsic ("catstrif", catstrif);
  add_intrinsic ("translatecomments", translatecomments);
  add_intrinsic ("wrap_comment", wrap_comment);
  add_intrinsic ("kill_bogus_lines", kill_bogus_lines);
  add_intrinsic ("indent", indent);
  add_intrinsic ("print_stack_level", print_stack_level);
  add_intrinsic ("strip_trailing_newlines", strip_trailing_newlines);
  add_intrinsic ("collapse_whitespace", collapse_whitespace);

  internal_mode = xmalloc (sizeof (intptr_t));
  *internal_mode = 0;
  add_intrinsic_variable ("internalmode", internal_mode);

  /* Put a nl at the start.  */
  catchar (&buffer, '\n');

  read_in (&buffer, stdin);
  remove_noncomments (&buffer, buf_ptr);
  for (i = 1; i < (unsigned int) ac; i++)
    {
      if (av[i][0] == '-')
	{
	  if (av[i][1] == 'f')
	    {
	      string_type b;
	      FILE *f;
	      init_string (&b);

	      f = fopen (av[i + 1], "r");
	      if (!f)
		{
		  fprintf (stderr, "Can't open the input file %s\n",
			   av[i + 1]);
		  return 33;
		}

	      read_in (&b, f);
	      compile (b.ptr);
	      perform ();
	      delete_string (&b);
	    }
	  else if (av[i][1] == 'i')
	    {
	      internal_wanted = 1;
	    }
	  else if (av[i][1] == 'w')
	    {
	      warning = 1;
	    }
	  else
	    usage ();
	}
    }
  write_buffer (stack + 0, stdout);
  free_words ();
  delete_string (&pptr);
  delete_string (&buffer);
  if (tos != stack)
    {
      fprintf (stderr, "finishing with current stack level %ld\n",
	       (long) (tos - stack));
      return 1;
    }
  return 0;
}
