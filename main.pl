#!/usr/bin/env perl

use strict;
use warnings;

use Bot::Game;
use Data::Dumper;

# prevent output buffering
$|++;

sub say($) { print "@_\n"; }

sub main {
  my $game = Bot::Game->new();

  while (my $line = <STDIN>) {
    my @input = split " ", $line;
    my $cmd   = $input[0];

    if ($cmd eq 'settings' and $input[1] eq 'your_botid') {
      my $id = $input[2];

      $game->bot_id($id);
      $game->enemy_id(1 - $id);

    }

    if ($cmd eq 'update' and $input[2] eq 'field') {
      $game->parse_field($input[3]);
    }

    if ($cmd eq 'action') {
      # strategy: always move closer to the enemy in attempt
      # to put him into jail or cut biggest part of the field
      my $direction = $game->get_direction_to_enemy();
      say $direction;

    }
  }
};


&main();
