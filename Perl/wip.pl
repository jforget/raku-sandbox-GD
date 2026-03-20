#/usr/bin/env perl
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
# Annonce "travail en cours"
# Warning "work in progress"
#

use v5.10;
use strict;
use warnings;
use GD;

my $name   = 'wip';
my $width  = 230;
my $height =  50;
my $im     = GD::Image->new($width, $height);
my $white  = $im->colorAllocate(255, 255, 255);
my $black  = $im->colorAllocate(  0,   0,   0);
my $red    = $im->colorAllocate(255,   0,   0);
my $blue   = $im->colorAllocate(  0,   0, 255);

$im->setThickness(5);
my $triangle = GD::Polygon->new;
$triangle->addPt(15, 12);
$triangle->addPt( 0, 39);
$triangle->addPt(30, 39);
$im->openPolygon($triangle, $red);
$triangle = GD::Polygon->new;
$triangle->addPt(205, 12);
$triangle->addPt(190, 39);
$triangle->addPt(220, 39);
$im->openPolygon($triangle, $red);
$im->string(gdGiantFont, 35, 10, 'Work in progress', $black);
$im->string(gdGiantFont, 35, 30, 'Travail en cours', $black);

open my $fh, '>', "$name.png"
    or die "opening PNG file: $!";
binmode $fh;
print $fh $im->png;
close $fh
    or die "closing PNG file: $!";

__END__

=encoding utf8

=head1 NAME

wip.pl - create a PNG file warning "work in progress"

=head1 SYNOPSIS

  perl    wip.pl
  display wip.png

=head1 DESCRIPTION

This program  generates a PNG  file with  a picture showing  a warning
"work in progress".

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
