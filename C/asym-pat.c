/* -*- encoding: utf-8; indent-tabs-mode: nil -*- */

#include "gd.h"
#include <stdio.h>

int main() {
  gdImagePtr im;

  FILE *pngout;

  int white;
  int black;
  int blue;
  int cyan;
  int green;
  int yellow;
  int red;

  im = gdImageCreate(101, 101);

  white  = gdImageColorAllocate(im, 255, 255, 255);
  black  = gdImageColorAllocate(im,   0,   0,   0);
  blue   = gdImageColorAllocate(im,   0,   0, 255);
  cyan   = gdImageColorAllocate(im,   0, 255, 255);
  green  = gdImageColorAllocate(im,   0, 255,   0);
  yellow = gdImageColorAllocate(im, 223, 150,  23); /* yellow-ish, actually */
  red    = gdImageColorAllocate(im, 255,   0,   0);

  int style[] = { blue                                 , gdTransparent
                , cyan  , cyan                         , gdTransparent, gdTransparent
                , green , green , green                , gdTransparent, gdTransparent, gdTransparent
                , yellow, yellow, yellow, yellow       , gdTransparent, gdTransparent, gdTransparent, gdTransparent
                , red   , red   , red   , red   , red  , gdTransparent, gdTransparent, gdTransparent, gdTransparent, gdTransparent
                };
  gdImageSetStyle(im, style, sizeof style / sizeof(int));

  gdImageLine(im, 10, 5, 90, 5, gdStyled);
  gdImageLine(im, 85, 3, 90, 5, black);
  gdImageLine(im, 85, 7, 90, 5, black);

  gdImageLine(im, 95, 10, 95, 90, gdStyled);
  gdImageLine(im, 93, 85, 95, 90, black);
  gdImageLine(im, 97, 85, 95, 90, black);

  gdImageLine(im, 90, 95, 10, 95, gdStyled);
  gdImageLine(im, 15, 93, 10, 95, black);
  gdImageLine(im, 15, 97, 10, 95, black);

  gdImageLine(im,  5, 90,  5, 10, gdStyled);
  gdImageLine(im,  3, 15,  5, 10, black);
  gdImageLine(im,  7, 15,  5, 10, black);

  pngout = fopen("asym-pat.png", "wb");
  gdImagePng(im, pngout);
  fclose(pngout);

  /* Destroy the image in memory. */
  gdImageDestroy(im);
  printf("Version %s\n", gdVersionString());
}
