#/usr/bin/env raku
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
# Dessiner une spirale arc-en-ciel avec un style très long
# Drawing a rainbow spiral with a huge style
#

use GD::Raw;

my $name   = '24-rainbow';
my $size   = 150;
my $im     = gdImageCreateTrueColor($size, $size);
LEAVE gdImageDestroy($im) if $im;
my $white  = gdImageColorAllocate($im, 255, 255, 255);
my $red    = gdImageColorAllocate($im, 255,   0,   0);
gdImageFilledRectangle($im, 0, 0, $size - 1, $size - 1, $white);

my @style = ();
for (0..254) -> $n {
  push @style, gdImageColorAllocate($im, 255 - $n, $n, 0);
}
for (0..254) -> $n {
  push @style, gdImageColorAllocate($im, 0, 255 - $n, $n);
}
for (0..254) -> $n {
  push @style, gdImageColorAllocate($im, $n, 0, 255 - $n);
}
###$im->setStyle(@style);
say "size ", 0 + @style;

my Int $x  = ($size / 2).Int;
my Int $y  = $x;
my Int $vx = 1;
my Int $vy = 0;

my Int $l = 1;
while $l < $size {
  gdImageLine($im, $x, $y, $x + $vx × $l, $y + $vy × $l, $red);
  $x += $vx × $l;
  $y += $vy × $l;
  ($vx, $vy) = ($vy, -$vx);
  $l += 2;
}

my $fh = fopen("$name.png", "wb");
return 0 unless $fh;
gdImagePng($im, $fh);
fclose($fh) if $fh;


=begin POD

=head1 NAME

24-rainbow.raku - draw basic lines

=head1 SYNOPSIS

  raku    24-rainbow.raku
  display 24-rainbow.png

=head1 DESCRIPTION

This  program  generates a  PNG  file  with  a  spiral using  a  style
containing many different colours.

=head1 PARAMETERS

None.

=head1 PREREQUISITE

Raku module C<GD::Raw>.

=head1 AUTHOR

Jean Forget <J2N-FORGET at orange dot fr>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2026 Jean Forget, all rights reserved

This program is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end POD
