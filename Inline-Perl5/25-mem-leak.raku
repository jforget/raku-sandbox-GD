#!/usr/bin/env raku
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
# Recherche de fuite mémoire dans le cas simple d'utilisation
# Looking for memory leaks in the simple use case
#

use GD:from<Perl5>;
use Linux::Proc::Statm;

my $resident1;
for 1..10 -> $i {
  for 1..100 -> $j {
    my $size   = 150;
    my $im     = GD::Image.new($size, $size);
    my $white  = $im.colorAllocate(255, 255, 255);
    my $red    = $im.colorAllocate(255,   0,   0);
    my $blue   = $im.colorAllocate(  0,   0, 255);
    my $grey   = $im.colorAllocate(240, 240, 240);
    my $black  = $im.colorAllocate(  0,   0,   0);

    my @style = ();
    for (0..255) -> $n {
      my $str = sprintf('%08b', $n);
      for (0..7) -> $pos {
        given substr($str, $pos, 1) {
          when '0' { push @style, $grey, $blue, $blue, $grey; }
          when '1' { push @style, $grey, $red , $red , $grey; }
        }
      }
      push @style, $black;
    }
    $im.setStyle(|@style);
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

25-mem-leak.raku - Looking for memory leaks when using styles with Inline::Perl5 and GD.pm

=head1 SYNOPSIS

  raku 25-mem-leak.raku

=head1 DESCRIPTION

This  program creates  several dummy  GD images  while monitoring  the
memory usage of the process.

The result  of the  program is  not reproductible.  You should  run it
several times and average out the results. BUT YOU SHOULD NOT RUN THIS
PROGRAM ON A PRODUCTION SERVER.

=head1 PARAMETERS

None.

=head1 PREREQUISITE

Raku modules C<Inline::Perl5> and C<Linux::Proc::Statm>

Perl module C<GD>.

=head1 AUTHOR

Jean Forget <J2N-FORGET at orange dot fr>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2026 Jean Forget, all rights reserved

This program is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end POD
