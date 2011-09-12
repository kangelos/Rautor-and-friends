# -*- Cperl -*-
#-----------------------------------------------------------------------
# Copyright (C) 1999-2000 Julian Fondren
#-- A module implementing a simple encryption

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
# USA
#-----------------------------------------------------------------------
package  rot13;
use strict;
use vars '$VERSION';
$VERSION = 'v0.6';


#=======================================================================
# Public Methods
#----------------------------------------------------------------------- 
#-- construct the object
sub new {
  my ($proto, @data) = @_;
  my $class = ref ($proto) || $proto;
  my $self  = \@data || [];
  bless ($self, $class);
  return $self;
}


#----------------------------------------------------------------------- 
#-- dereference and return the object
sub peek {
  my $self = shift;

  return @$self;
}


#----------------------------------------------------------------------- 
#-- define the object
sub charge {
  my $self = shift;

  return @$self = @_;
}


#-----------------------------------------------------------------------
#-- rotate every ASCII letter $degree times in every element of the
#-- object.
sub rot13 {
  my $self = shift;
  my $degree = (@_ > 0) ? shift : 13;

  if (($degree % 26) == 13) {
    # This is a rot13, which doesn't require a complex formula.
    my @rot13;
    foreach my $str ($self->peek ()) {
      $str =~ tr/a-zA-Z/n-za-mN-ZA-M/;
      push (@rot13, $str);
    }
    return @rot13;
  }
  elsif (($degree % 26) == 0) {
    # What is anything changed zero times?  Right.
    return $self->peek ();
  }
  else {
    my ($c, @rot13);
  line: foreach my $str (@rot13 = $self->peek ()) {
    char: foreach my $i (0 .. (length ($str) - 1)) {
        if (substr ($str, $i, 1) =~ /[a-zA-Z]/) {
          $c = substr ($str, $i, 1);
          substr ($str, $i, 1,
                  (($c eq lc $c)
                   ? chr ((((ord ($c) - ord ('a')) + $degree) % 26)
                          + ord ('a'))
                   : chr ((((ord ($c) - ord ('A')) + $degree) % 26)
                          + ord ('A'))));
        }
      } # char
    } # line
    return @rot13;
  }
}


1;
__END__

=head1 NAME

Crypt::rot13 v0.6 - a simple, reversible encryption

=head1 SYNOPSIS

  use Crypt::rot13;

  my $rot13 = new Crypt::rot13;
  $rot13->charge ("The quick brown fox jumped over the lazy dog.");
  print $rot13->rot13 (), "\n";
  print $rot13->rot13 (245.333), "\n";
  print $rot13->peek (), "\n";

  open (F, "/etc/passwd") or die "$!";
  $rot13->charge (<F>);
  close (F) or die "$!";
  print $rot13->rot13 (-13);

  while (<STDIN>) {
    $rot13->charge ($_);
    print $rot13->rot13 ();
  }

  $rot13->charge ('a' .. 'z');
  foreach (0 .. 26) {
    print $rot13->rot13 ($_), "\n";
  }

=head1 DESCRIPTION

rot13 is a simple encryption in which ASCII letters are rotated 13
places (see below).  This module provides an array object with methods
to encrypt its string elements by rotating ASCII letters n places down
the alphabet.

Think of it this way: all of the letters of the alphabet are arranged
in a circle like the numbers of a clock.  Also like a clock, you have
a hand pointing at one of the letters: a.  Crypt::rot13 turns the
hand clockwise n times through 'b', 'c', 'd', etc, and back again to
'a', 26 turns later.

Crypt::rot13 turns this hand for every letter of every string it
contains a given number of times, the default of which is 13, or
exactly half the number of letters in the alphabet.

=head1 PUBLIC METHODS

=over 4

=item * Crypt::rot13->new (@arguments)

This creates a Crypt::rot13 object, which is a blessed array
reference.  Any arguments given to C<new> define the array, which is
defaultly empty.

=item * Crypt::rot13->charge (@arguments)

Any arguments given to C<charge> define the array.  If no arguments are
passed, the Crypt::rot13 array will be empty.  The arguments can be
non-strings; see the following example.

  my $rot13 = Crypt::rot13->new ({'foo' => 'bar'}, 111);
  print $rot13->peek (), "\n", $rot13->rot13 (), "\n";

=item * Crypt::rot13->peek ()

This dereferences and returns the Crypt::rot13 object.

=back

(In case you are wondering, the strange method names of C<peek> and
C<charge> are derived from my original conception of Crypt::rot13 as a
magical device.)

=over 4  

=item * Crypt;:rot13->rot13 ($degree)

Rotates ASCII alphabetical characters of each element of the array
degree times and returns the changed array without altering the
Crypt::rot13 object.  The degree can be negative and a fractional part
is ignored (to be precise, C<chr> and C<%> ignore it).

Degrees effectively equal to 13 are optimized to a C<tr///>.
Degrees effectively equal to 0 are optimized into a C<peek>.  

A degree I<$d> is "effectively equal" to 13 if C<$d % 26 == 13>.
  

=back

=head1 LICENSE

Copyright (C) 1999-2000 Julian Fondren

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
USA

=head1 BUGS

The algorithm of C<rot13> isn't very easy to understand.

=head1 AUTHOR

Julian Fondren

=head1 SEE ALSO

perl(1) rot13(1)

