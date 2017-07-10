#!/usr/bin/env perl

package Bot::Point;

use strict;
use warnings;

our $VERSION = '0.01';

use Moose;

has ['x', 'y'] => (is => 'rw', isa => 'Maybe[Int]');

# field is 16x16
has 'max'    => (is => 'ro', default => 15);
has 'min'    => (is => 'ro', default => 0);


sub is_allowed {
  my $self = shift;

  return 1 if
    ($self->x <= $self->max and $self->x >= $self->min)
      and
    ($self->y <= $self->max and $self->y >= $self->min);

  return 0;
}

# distance formula http://mste.illinois.edu/dildine/js/distance.html
sub calculate_distance {
  my ($self, $point) = @_;

  return ($self->x - $point->x) ** 2 + ($self->y - $point->y) ** 2;
}

1;
