#/usr/bin/env raku
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
# Dessiner une spirale avec un style très long
# Drawing a spiral with a huge style
#

use GD;

my $name   = '22-long-style';
my $size   = 150;
my $im     = GD::Image.new($size, $size);
my $white  = $im.colorAllocate( red => 255, green => 255, blue => 255);
my $red    = $im.colorAllocate( red => 255, green =>   0, blue =>   0);
my $blue   = $im.colorAllocate( red =>   0, green =>   0, blue => 255);
my $grey   = $im.colorAllocate( red => 240, green => 240, blue => 240);
my $black  = $im.colorAllocate( red =>   0, green =>   0, blue =>   0);

my @style = ();
for 0..256 -> $n {
  my $str = sprintf('%08b', $n);
  for (0..7) -> $pos {
    my $digit = $str.substr($pos, 1);
    if $digit eq '0' {
      push @style, $grey, $blue, $blue, $grey;
    }
    else {
      push @style, $grey, $red, $red, $grey;
    }
  }
  push @style, $black;
}
$im.set-style(@style);
say "size ", @style.elems;

my $x  = ($size / 2).Int;
my $y  = $x;
my $vx = 1;
my $vy = 0;

loop (my $l = 1; $l < $size - 1; $l += 2) {
  $im.line(start => ($x, $y), end => ($x + $vx * $l, $y + $vy * $l), color => GD-styled);
  $x += $vx × $l;
  $y += $vy × $l;
  ($vx, $vy) = ($vy, -$vx);
}

my $png_fh = $im.open("$name.png", "wb");
$im.output($png_fh, GD_PNG);
$png_fh.close;

$im.destroy;

=begin POD

=encoding utf8

=head1 NAME

22-long-style.raku - draw a spiral with a long style

=head1 SYNOPSIS

  raku    22-long-style.raku
  display 22-long-style.png

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

=end POD
