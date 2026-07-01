#!/usr/bin/env raku
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
# Recherche de fuite mémoire dans le cas simple d'utilisation
# Looking for memory leaks in the simple use case
#

use GD;
use Linux::Proc::Statm;

my $width  = 200;
my $height = 200;

my $resident1;
my $im     = GD::Image.new($width, $height);
LEAVE $im.destroy if $im;
my $white  = $im.colorAllocate(red => 255, green => 255, blue => 255);
my $black  = $im.colorAllocate(red =>   0, green =>   0, blue =>   0);
my $red    = $im.colorAllocate(red => 255, green =>   0, blue =>   0);
my $green  = $im.colorAllocate(red =>   0, green => 255, blue =>   0);
my $blue   = $im.colorAllocate(red =>   0, green =>   0, blue => 255);
my $grey   = $im.colorAllocate(red => 240, green => 240, blue => 240);

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

for 1..10 -> $i {
  for 1..100 -> $j {
    $im.set-style(@style);

    if $j == 1 {
      say get-statm.raku;
      if $i == 1 {
        $resident1 = get-statm<resident>;
      }
    }
  }
}
my $resident2 = get-statm<resident>;
say $resident2 - $resident1;

=begin POD

=head1 NAME

26-mem-leak.raku - Looking for memory leaks when using styles with GD::Raw

=head1 SYNOPSIS

  raku 26-mem-leak.raku

=head1 DESCRIPTION

This program creates  a dummy GD image and repeatedly  chooses a style
while monitoring the memory usage of the process.

The result  of the  program is  not reproductible.  You should  run it
several times and average out the results.

By commenting out the C<LEAVE> line, you can create a memory leak. FOR
TESTS ONLY, DO NOT TRY THIS ON A PRODUCTION SERVER.

=head1 PARAMETERS

None.

=head1 PREREQUISITE

Raku module C<GD::Raw>.

Raku module C<Linux::Proc::Statm>

=head1 AUTHOR

Jean Forget <J2N-FORGET at orange dot fr>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2026 Jean Forget, all rights reserved

This program is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end POD
