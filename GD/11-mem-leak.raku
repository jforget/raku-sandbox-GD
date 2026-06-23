#/usr/bin/env raku
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
# Recherche de fuite mémoire dans un cas évolué d'utilisation de GD::Raw
# Looking for memory leaks in an advanced use case of GD::Raw
#

use GD;
use Linux::Proc::Statm;

my $width  = 200;
my $height = 200;

my $resident1;
for 1..10 -> $i {
  for 1..300 -> $j {
    my $im     = GD::Image.new($width, $height);
    #LEAVE $im.destroy if $im;
    my $white  = $im.colorAllocate(red => 255, green => 255, blue => 255);
    my $black  = $im.colorAllocate(red =>   0, green =>   0, blue =>   0);
    my $red    = $im.colorAllocate(red => 255, green =>   0, blue =>   0);
    my $blue   = $im.colorAllocate(red =>   0, green =>   0, blue => 255);
    $im.destroy if $im;

    $im     = GD::Image.new($width, $height);
    #LEAVE $im.destroy if $im;
    $white  = $im.colorAllocate(red => 255, green => 255, blue => 255);
    $black  = $im.colorAllocate(red =>   0, green =>   0, blue =>   0);
    $red    = $im.colorAllocate(red => 255, green =>   0, blue =>   0);
    $blue   = $im.colorAllocate(red =>   0, green =>   0, blue => 255);

    if $j == 1 {
      say get-statm.raku;
      if $i == 1 {
        $resident1 = get-statm<resident>;
      }
    }
    $im.destroy if $im;
  }
}
my $resident2 = get-statm<resident>;
say $resident2 - $resident1;

=begin POD

=head1 NAME

11-mem-leak.raku - Looking for memory leaks

=head1 SYNOPSIS

  raku 11-mem-leak.raku

=head1 DESCRIPTION

This  program creates  several dummy  GD images  while monitoring  the
memory usage of the process.

The result  of the  program is  not reproductible.  You should  run it
several times and average out the results.

By  reactivating the  commented-out  C<LEAVE> lines,  you can  trigger
segmentation faults. FOR  TESTS ONLY, DO NOT TRY THIS  ON A PRODUCTION
SERVER.

By  commenting out  the C<$im.destroy>  lines, you  can create  memory
leaks. FOR TESTS ONLY, DO NOT TRY THIS ON A PRODUCTION SERVER.

=head1 PARAMETERS

None.

=head1 PREREQUISITE

Raku module C<GD>.

Raku module C<Linux::Proc::Statm>

=head1 AUTHOR

Jean Forget <J2N-FORGET at orange dot fr>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2026 Jean Forget, all rights reserved

This program is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end POD
