#/usr/bin/env perl
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
# Dessiner une spirale arc-en-ciel avec un style très long
# Drawing a rainbow spiral with a huge style
#

use v5.10;
use strict;
use warnings;
use GD;

my $name   = '24-rainbow';
my $size   = 150;
my $im     = GD::Image->newTrueColor($size, $size);
my $white  = $im->colorAllocate(255, 255, 255);
$im->fill(0, 0, $white);

my @style = ();
for my $n (0..254) {
  push @style, $im->colorAllocate(255 - $n, $n, 0);
}
for my $n (0..254) {
  push @style, $im->colorAllocate(0, 255 - $n, $n);
}
for my $n (0..254) {
  push @style, $im->colorAllocate($n, 0, 255 - $n);
}
$im->setStyle(@style);
say "size ", 0 + @style;

my $x  = $size / 2;
my $y  = $x;
my $vx = 1;
my $vy = 0;

for (my $l = 1; $l < $size; $l += 2) {
  $im->line($x, $y, $x + $vx * $l, $y + $vy * $l, gdStyled);
  $x += $vx * $l;
  $y += $vy * $l;
  ($vx, $vy) = ($vy, -$vx);
}

open my $fh, '>', "$name.png"
  or die "opening GD file: $!";
binmode $fh;
print $fh $im->png;
close $fh
  or die "closing GD file: $!";

__END__

=encoding utf8

=head1 NAME

24-rainbow.pl - draw a spiral with a long style

=head1 SYNOPSIS

  perl    24-rainbow.pl
  display 24-rainbow.png

=head1 DESCRIPTION

This  program  generates a  PNG  file  with  a  spiral using  a  style
containing many different colours.

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
