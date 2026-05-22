#/usr/bin/env perl
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
# Génération d'un fichier de tests pour les fonctions gdImageString et gdImageStringUp
# Generating a test for functions gdImageString and gdImageStringUp
#

use v5.10;
use strict;
use warnings;
use GD;

my $name   = 'gdimagetext';
my $width  = 100;
my $height = 100;
my $im     = GD::Image->new($width, $height);
my $white  = $im->colorAllocate(255, 255, 255);
my $red    = $im->colorAllocate(255,   0,   0);
my $blue   = $im->colorAllocate(  0,   0, 255);

$im->string(gdGiantFont, 0, 80, "Horizontal", $red);
$im->stringUp(gdLargeFont, 0, 70, "Vertical", $blue);

open my $fh, '>', "$name.png"
    or die "opening PNG file: $!";
binmode $fh;
print $fh $im->png;
close $fh
    or die "closing PNG file: $!";


__END__

=encoding utf8

=head1 NAME

mk-test-text.pl - Create a test file for functions C<gdImageString> and C<gdImageStringUp>.

=head1 SYNOPSIS

  perl    mk-test-text.pl
  display gdimagetext.png

=head1 DESCRIPTION

This program  generates a PNG  file with a  few labels, which  will be
used in the tests of Raku module C<GD::Raw>.

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
