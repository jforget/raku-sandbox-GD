#!/usr/bin/env perl
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
# Génération d'un fichier de tests pour la fonctions gdImageStringFT
# Generating a test for function gdImageStringFT
#

use v5.10;
use strict;
use warnings;
use GD;

my $name   = 'gdimagetextft';
my $width  = 500;
my $height =  50;
my $im     = GD::Image->new($width, $height);
my $white  = $im->colorAllocate(255, 255, 255);
my $black  = $im->colorAllocate(  0,   0,   0);
my $fontpath = "./testing-gd-raw.ttf";
my $fontsize = 30;

# a negative colour parameter means that anti-aliasing is disabled
$im->stringFT(- $black, $fontpath, $fontsize, 0, 10, 40, "Hello world");

open my $fh, '>', "$name.png"
    or die "opening PNG file: $!";
binmode $fh;
print $fh $im->png;
close $fh
    or die "closing PNG file: $!";


__END__

=encoding utf8

=head1 NAME

mk-test-ttf.pl - Create a test file for function C<gdImageStringFT>.

=head1 SYNOPSIS

  perl    mk-test-ttf.pl
  display gdimagetextft.png

=head1 DESCRIPTION

This program  generates a  PNG file  with a labels  using a  true type
font. This file is used in the tests of Raku module C<GD::Raw>.

=head1 PARAMETERS

None.

=head1 PREREQUISITE

Module C<GD>.

=head1 AUTHOR

Jean Forget <J2N-FORGET at orange dot fr>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2026 Jean Forget, all rights reserved

This program is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
