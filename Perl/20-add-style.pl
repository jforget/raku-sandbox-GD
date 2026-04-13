#/usr/bin/env perl
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
# Dessin avec une ligne en pointillés, première étape
# Drawing a dotted line, first step
#

use v5.10;
use strict;
use warnings;
use GD;

my $name   = '20-dotted-line';
unless (GD::supportsFileType("$name.gd", 1)) {
  die "Unable to test, suffix 'gd' not supported";
}
my $width  = 120;
my $height =  50;
my $im     = GD::Image->new($width, $height);
my $white  = $im->colorAllocate(255, 255, 255);
my $black  = $im->colorAllocate(  0,   0,   0);
my $red    = $im->colorAllocate(255,   0,   0);
my $blue   = $im->colorAllocate(  0,   0, 255);

$im->setStyle($red, $red, gdTransparent, gdTransparent);

open my $fh, '>', "$name.gd"
  or die "opening GD file: $!";
binmode $fh;
print $fh $im->gd;
close $fh
  or die "closing GD file: $!";

__END__

=encoding utf8

=head1 NAME

20-add-style.pl - draw a dotted line, first step

=head1 SYNOPSIS

  perl    20-add-style.pl
  perl    21-use-style.pl
  display 20-dotted-line.png

=head1 DESCRIPTION

This program generates a GD file  which will be used later to generate
a PNG file with a dotted line.

=head1 PARAMETERS

None.

=head1 PREREQUISITE

Module C<GD>

=head1 BUGS

This program (and its companion) are  based on the assumption that the
Perl module  C<GD> and the C  library C<libgd> support the  GD format.
Unfortunately, support for GD (and GD2) was dropped from version 2.3.2
of C<libgd>. Therefore, the program cannot run.

=head1 AUTHOR

Jean Forget <J2N-FORGET at orange dot fr>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2026 Jean Forget, all rights reserved

This program is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
