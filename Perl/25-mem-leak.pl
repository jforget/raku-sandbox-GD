#!/usr/bin/env perl
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
# Recherche de fuite mémoire dans le cas simple d'utilisation
# Looking for memory leaks in the simple use case
#

use v5.10;
use strict;
use warnings;
use GD;
use Memory::Process;

my $mem = Memory::Process->new();

for my $i (1..10) {
  for my $j (1..100) {
    my $size   = 150;
    my $im     = GD::Image->new($size, $size);
    my $white  = $im->colorAllocate(255, 255, 255);
    my $red    = $im->colorAllocate(255,   0,   0);
    my $blue   = $im->colorAllocate(  0,   0, 255);
    my $grey   = $im->colorAllocate(240, 240, 240);
    my $black  = $im->colorAllocate(  0,   0,   0);

    my @style = ();
    for my $n (0..255) {
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
    if ($j == 1) {
      $mem->record("iteration $i");
      print $mem->report . "\n";
    }
  }
}

__END__

=encoding utf8

=head1 NAME

25-mem-leak.pl - Looking for memory leaks when using styles with GD.pm

=head1 SYNOPSIS

  perl 25-mem-leak.pl

=head1 DESCRIPTION

This  program creates  several dummy  GD images  while monitoring  the
memory usage of the process.

The result  of the  program is  not reproductible.  You should  run it
several times and average out the results.

=head1 PARAMETERS

None.

=head1 PREREQUISITE

Module C<GD>

Module C<Memory::Process>

=head1 AUTHOR

Jean Forget <J2N-FORGET at orange dot fr>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2026 Jean Forget, all rights reserved

This program is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
