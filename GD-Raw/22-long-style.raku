#/usr/bin/env raku
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
# Dessiner une spirale avec un style très long
# Drawing a spiral with a huge style
#

use GD::Raw;
use NativeCall;

my $name   = '22-long-style';
my $size   = 150;
my $im     = gdImageCreate($size, $size);
LEAVE gdImageDestroy($im) if $im;
my $white  = gdImageColorAllocate($im, 255, 255, 255);
my $red    = gdImageColorAllocate($im, 255,   0,   0);
my $blue   = gdImageColorAllocate($im,   0,   0, 255);
my $grey   = gdImageColorAllocate($im, 240, 240, 240);
my $black  = gdImageColorAllocate($im,   0,   0,   0);

my @style = ();
for (0..255) -> $n {
  my Str $x = sprintf('%08b', $n);
  for (0..7) -> $pos {
    given substr($x, $pos, 1) {
      when '0' { push @style, $grey, $blue, $blue, $grey; }
      when '1' { push @style, $grey, $red , $red , $grey; }
    }
  }
  push @style, $black;
}
my @style-c := CArray[int32].new;
for @style.keys -> $i {
  @style-c[$i] = @style[$i];
}
gdImageSetStyle($im, @style-c, @style.elems);
say "size ", 0 + @style;

my Int $x  = ($size / 2).Int;
my Int $y  = $x;
my Int $vx = 1;
my Int $vy = 0;

my Int $l = 1;
while $l < $size {
  gdImageLine($im, $x, $y, $x + $vx × $l, $y + $vy × $l, gdStyled);
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

22-long-style.raku - draw basic lines

=head1 SYNOPSIS

  raku    22-long-style.raku
  display 22-long-style.png

=head1 DESCRIPTION

This  program  generates a  PNG  file  with  a  spiral using  a  style
containing many pixels.

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
