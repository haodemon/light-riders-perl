#!/usr/bin/env perl

package Bot::Game;

use strict;
use warnings;

use Bot::Point;

our $VERSION = '0.01';

use Moose;

has 'field'     => (is => 'rw', isa => 'ArrayRef');

has [ 'bot_id', 'enemy_id' ] => (is => 'rw', isa => 'Str');
has [ 'pos', 'enemy_pos'   ] => (is => 'rw', isa => 'Bot::Point');


sub parse_field {
  my ($self, $data) = @_;

  my $field;
  my ($x, $y) = (0, 0);

  for my $value (split m/,/, $data) {
    $field->[$x][$y] = $value;

    $self->pos(
      Bot::Point->new(x => $x, y => $y)
    ) if $value eq $self->bot_id;

    $self->enemy_pos(
      Bot::Point->new(x => $x, y => $y)
    ) if $value eq $self->enemy_id;

    # new row
    if (++$x == 16) {
      $x = 0;
      ++$y;
    }
  }

  $self->field($field);
}

sub get_allowed_directions {
  my ($self, $opts) = @_;

  my $pos = $opts->{pos} // $self->pos;
  my ($x, $y) = ($pos->x, $pos->y);

  my $directions = {
    right => Bot::Point->new(x => $x + 1, y => $y),
    left  => Bot::Point->new(x => $x - 1, y => $y),
    up    => Bot::Point->new(x => $x, y => $y - 1),
    down  => Bot::Point->new(x => $x, y => $y + 1),
  };

  while (my ($k, $p) = each %$directions) {
    my $coord = $self->field->[$p->x][$p->y];

    delete $directions->{$k}
      if not $p->is_allowed() or $coord ne '.';
  }

  return $directions;
}

# returns direction to get closer to enemy
sub get_direction_to_enemy {
  my $self = shift;

  my $direction;
  my $min_distance = ~0;

  my $directions = $self->get_allowed_directions();

  while (my ($k, $v) = each %$directions) {
    my $distance = $v->calculate_distance($self->enemy_pos);

    # we do not want to get into trouble in the long run thus filter
    # directions which lead us into a corridor
    my $future_moves = $self->get_allowed_directions({ pos => $v });
    next if scalar keys %$future_moves < 1;

    if ($min_distance > $distance) {
      $min_distance = $distance;
      $direction    = $k;
    }
  }

  return $direction;
}

1;
