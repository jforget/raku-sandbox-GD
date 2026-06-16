#/usr/bin/env perl
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
# Fichier de test avec un rectangle
# Test file with a rectangle
#

use v5.10;
use strict;
use warnings;
use GD;
use MIME::Base64;

my $name   = '040-rectangle';
my $width  = 50;
my $height = 30;
my $im     = GD::Image->new($width, $height);
my $white  = $im->colorAllocate(255, 255, 255);
my $black  = $im->colorAllocate(  0,   0,   0);
$im->rectangle(10, 10, 30, 20, $black);

open my $fh, '>', "$name.png"
    or die "opening PNG file: $!";
binmode $fh;
print $fh $im->png;
close $fh
    or die "closing PNG file: $!";

my $png =  MIME::Base64::encode($im->png);
$png =~ s/\n\Z//;
open $fh, '>', "$name.html"
    or die "opening HTML file: $!";
print $fh <<"EOF";
<html>
<head><title>Rectangle</title></head>
<body>
<h1>Embedded PNG data</h1>
<img src='data:image/png;base64,$png'>
</body>
</html>
EOF
close $fh
    or die "closing HTML file: $!";

# Check that the off-by-one error does not exist in Perl
for my $y (9 .. 11, 18..21) {
  for my $x (8 .. 11, 28..32) {
    printf("(%2d, %2d) → %d\n", $x, $y, $im->getPixel($x, $y));
  }
}


__END__

=encoding utf8

=head1 NAME

040-rectangle.pl - draw a rectangle (for test purposes)

=head1 SYNOPSIS

  perl    040-rectangle.pl
  firefox 040-rectangle.html

=head1 DESCRIPTION

This  program  generates  an  HTML  file  with  a  picture  showing  a
rectangle.

=head1 PARAMETERS

None.

=head1 PREREQUISITE

Modules C<GD> and C<MIME::Base64>.

=head1 AUTHOR

Jean Forget <J2N-FORGET at orange dot fr>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2026 Jean Forget, all rights reserved

This program is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
