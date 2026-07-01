#!/usr/bin/env perl
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
# Dessin avec une ligne en pointillés, seconde étape
# Drawing a dotted line, second step
#

use v5.10;
use strict;
use warnings;
use GD;
use MIME::Base64;

my $name = '02-dotted-line';
my $im   = GD::Image->newFromGd("$name.gd");

$im->line(10, 10, 100, 10, gdStyled);

open my $fh, '>', "$name.png"
    or die "opening PNG file: $!";
binmode $fh;
print $fh $im->png;
close $fh
    or die "closing PNG file: $!";


__END__

=encoding utf8

=head1 NAME

21-use-style.pl - draw a dotted line, second step

=head1 SYNOPSIS

  perl    20-add-style.pl
  perl    21-use-style.pl
  display 20-dotted-line.png

=head1 DESCRIPTION

This program reads a GD file and generates a PNG file showing a dotted
line.

=head1 PARAMETERS

None.

=head1 PREREQUISITE

Modules C<GD>.

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
