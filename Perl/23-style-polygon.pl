#!/usr/bin/env perl
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
# Dessiner une spirale avec un style très long
# Drawing a spiral with a huge style
#

use v5.10;
use strict;
use warnings;
use GD;

my $name   = '23-style-polygon';
my $size   = 150;
my $im     = GD::Image->new($size, $size);
my $white  = $im->colorAllocate(255, 255, 255);
my $red    = $im->colorAllocate(255,   0,   0);
my $blue   = $im->colorAllocate(  0,   0, 255);
my $grey   = $im->colorAllocate(240, 240, 240);
my $black  = $im->colorAllocate(  0,   0,   0);

my @style = ();
for my $n (0..256) {
  my $str = sprintf('%08b', $n);
  for my $pos (0..7) {
    my $digit = substr($str, $pos, 1);
    if ($digit eq '0') {
      push @style, $grey, $blue, $blue, $grey;
    }
    else {
      push @style, $grey, $red, $red, $grey;
    }
  }
  push @style, $black;
}
$im->setStyle(@style);
say "size ", 0 + @style;

my $poly = GD::Polygon->new;
my $x  = $size / 2;
my $y  = $x;
my $vx = 1;
my $vy = 0;
$poly->addPt($x, $y);

for (my $l = 1; $l < $size; $l += 2) {
  $x += $vx * $l;
  $y += $vy * $l;
  ($vx, $vy) = ($vy, -$vx);
  $poly->addPt($x, $y);
}
$im->unclosedPolygon($poly, gdStyled);

open my $fh, '>', "$name.png"
  or die "opening GD file: $!";
binmode $fh;
print $fh $im->png;
close $fh
  or die "closing GD file: $!";

__END__

=encoding utf8

=head1 NAME

23-style-polygon.pl - draw a spiral with a long style

=head1 SYNOPSIS

  perl    23-style-polygon.pl
  display 23-style-polygon.png

=head1 DESCRIPTION

This  program  generates a  PNG  file  with  a  spiral using  a  style
containing many pixels.

=head1 PARAMETERS

None.

=head1 PREREQUISITE

Module C<GD>

=head1 AUTHOR

Jean Forget <J2N-FORGET at orange dot fr>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2026 Jean Forget, all rights reserved

This program is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
