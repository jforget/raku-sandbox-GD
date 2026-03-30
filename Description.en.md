-*- encoding: utf-8; indent-tabs-mode: nil -*-

PURPOSE
=======

When I first wrote
[my programs about graphs and Hamiltonian paths](https://github.com/jforget/raku-Hamilton2/blob/master/doc/Hamilton.en.md),
I had to choose a module to draw pictures. At this time,
[the Raku module `GD`](https://github.com/raku-community-modules/GD)
was missing some features and I did not know about
[module `GD::Raw`](https://raku.land/zef:raku-community-modules/GD::Raw).
So I chose to install
[`Inline::Perl5`](https://raku.land/cpan:NINE/Inline::Perl5)
with Perl's
[`GD`](https://metacpan.org/pod/GD).

But  now, I  want  to use  a  native  Raku module,  that  is, `GD`  or
`GD::Raw`. This  repository contains  my notes about  installing these
modules, finding documentation and maybe even adding features to these
modules. It also contains the various programs (Perl and Raku) I wrote
to prepare and run my exploratory tests.

Usually,  in the  projects I  publish  on Github,  I add  a text  file
documenting the  installation process  (actually two files,  the first
one in French,  the other one in  English). If I quit a  project for a
few months and get  back to it after that, I  have no problems reading
the  code I  wrote a  few  months ago,  but I  have more  difficulties
remembering  all  the  actions  I   had  to  do  when  installing  and
configuring the software. If I happen to add a few features to `GD` or
`GD::Raw`,  which are  Raku Community  Modules, I  am not  entitled to
write  my   memories  in  a   documentation  file  published   in  the
distribution's Github repo. Instead of that, I write the documentation
file (this  very file) in  a sandbox repo  and I publish  this sandbox
repo on Github.

MY NEEDS
========

Image Creation
--------------

This task allocates a data structure representing a blank image, so we
can after that add graphical  elements. Of course, this already exists
in both modules.

```
# Perl
my $im = GD::Image->new($width, $height);

# Inline::Perl5 + GD
my $image = GD::Image.new($width, $height);

# GD
my $image = GD::Image.new($width, $height);

# GD::Raw
my $im = gdImageCreate($width, $height) or die;
LEAVE gdImageDestroy($im) if $im;
```

Colours
-------

```
# Perl
my $white = $im->colorAllocate(255, 255, 255);
my $black = $im->colorAllocate(  0,   0,   0);
my $red   = $im->colorAllocate(255,   0,   0);
my $blue  = $im->colorAllocate(  0,   0, 255);

# Inline::Perl5 + GD
my $white = $image.colorAllocate(255, 255, 255);
my $black = $image.colorAllocate(  0,   0,   0);

# GD
my $black = $image.colorAllocate(
     red   => 0,
     green => 0,
     blue  => 0);
my $white = $image.colorAllocate(
     red   => 255,
     green => 255,
     blue  => 255);
my $red   = $image.colorAllocate("#ff0000");
my $green = $image.colorAllocate("#00ff00");
my $blue  = $image.colorAllocate(0x0000ff);

# GD::Raw
my $white = gdImageColorAllocate($im, 0xff, 0xff, 0xff);
my $black = gdImageColorAllocate($im, 0, 0, 0);
```

`GD`: I found the code example in file `README.md`.

Image Generation
----------------

Once all  the required  examples have  been added  to the  picture, we
generate the blob  encoding the picture with the PNG  format (or other
format, yet I only nee PNG). This exists in both modules.

On the other  hand, I do not need  to create a PNG file.  I insert the
PNG blob inside an HTML `<img>` tag, with a `MIME::Base64` encoding.

```
# Perl
binmode $fh;
print $fh $im->png;
[...]
my $src = MIME::Base64::encode($im->png);
print "<img src='data:image/png;base64,$src'/>";

# Inline::Perl5 + GD
"test.png".IO.spurt($image.png);
[...]
my $src = MIME::Base64.encode($image.png);
print "<img src='data:image/png;base64,$src'/>";

# GD
my $png_fh = $image.open("test.png", "wb");
$image.output($png_fh, GD_PNG);
$png_fh.close;

# GD::Raw
my $fh = fopen($path, "wb");
return 0 unless $fh;
gdImagePng($img, $fh);
fclose($fh) if $fh;
```

`GD`: I found the code example in file `README.md`.

`GD::Raw`: I found the code examples in files
`t/01-create-and-load.rakutest` and `xt/gdtest.rakumod`.

Neither in `GD` nor in `GD::Raw` have  I found how I can store the PNG
blob in a program variable instead of inside a file.

Basic Lines
-----------

We just draw a line from one point to another.

```
# Perl
$im->line($x_from, $y_from, $x_to, $y_to, $color);

# Inline::Perl5 + GD
$img.line($x-from, $y-from, $x-to , $y-to , $color);

# GD
$image.line(
     start => ($x-from, $y-from),
     end   => ($x-to  , $y-to),
     color => $color);

# GD::Raw
gdImageLine($im, $x-from, $y-from, $x-to, $y-to, $color);
```

Thick Lines and Thin Lines
--------------------------

We draw lines with varying thicknesses (and colours).

```
# Perl
$im->setThickness($thickness);
$im->line($x_from, $y_from, $x_to, $y_to, $color);

# Inline::Perl5 + GD
$img.setThickness($thickness);
$img.line($x-from, $y-from, $x-to , $y-to , $color);

# GD

# GD::Raw
gdImageSetThickness($im, $thickness);
gdImageLine($im, $x-from, $y-from, $x-to, $y-to, $color);
```

For `GD::Raw`, read file
[fichier `bug00191.rakutest`](https://github.com/raku-community-modules/GD-Raw/blob/main/xt/bug00191.rakutest)

For `GD`,  I have grepped  string `"thick"` in  a clone of  the Github
repo and I have found nothing.

Dotted and Dashed Lines
-----------------------

This task draws a dotted or dashed lite from a point to another.

```
# Perl
$im->setStyle($color, $color, gdTransparent, gdTransparent);
$im->line($x_from, $y_from, $x_to, $y_to, gdStyled);

# Inline::Perl5 + GD
$img.setStyle($color, $color, gdTransparent, gdTransparent);
$img.line($x-from, $y-from, $x-to , $y-to , gdStyled);

# GD

# GD::Raw
```

For both `GD` and `GD::Raw`, grepping `"styled"` in repos
cloned from Github gives to results.

Circles and Squares
-------------------

We draw circles and squares, either filled or outline.


```
# Perl
$im->filledEllipse  (10, 20,  20, 20, $white);
$im->ellipse        (10, 20,  20, 20, $blue);
$im->filledRectangle(30, 10,  50, 30, $white);
$im->rectangle      (30, 10,  50, 30, $blue);
$im->filledEllipse  (70, 20,  20, 20, $red);
$im->filledRectangle(90, 10, 110, 30, $red);

# Inline::Perl5 + GD
$img.filledEllipse(  10, 20,  20, 20, $white);
$img.ellipse(        10, 20,  20, 20, $blue);
$img.filledRectangle(30, 10,  50, 30, $white);
$img.rectangle(      30, 10,  50, 30, $blue);
$img.filledEllipse(  70, 20,  20, 20, $red);
$img.filledRectangle(90, 10, 110, 30, $red);

# GD
$image.rectangle(
    location => (10, 10),
    size     => (100, 100),
    fill     => True,
    color    => $red);
$image.ellipse(
    center => (100, 100),
    axes   => (60, 80),   # width and height
    fill   => False,
    color  => $blue);

# GD::Raw
gdImageFilledEllipse($im, 50,50, 70, 90, 0x50FFFFFF);
gdImageFilledRectangle($im, 0,0, 299,299, 0xFFFFFF);
```

In  the  `Inline::Perl5`  examples,  you   will  note  that  the  left
parentheses are not aligned as in  the Perl examples. This is required
by the syntax of Raku. Too bad.

The examples for `GD` are extracted from
[`examples/gd.p6`](https://github.com/raku-community-modules/GD/blob/master/examples/gd.p6).

The examples for `GD::Raw` are extracted from
[`xt/bug00010.rakutest`](https://github.com/raku-community-modules/GD-Raw/blob/main/xt/bug00010.rakutest)
and [`xt/bug00079.rakutest`](https://github.com/raku-community-modules/GD-Raw/blob/main/xt/bug00079.rakutest).
Some other examples can be found in
directory `xt`, but  there is no need  to list them all.  On the other
hand, I found no examples without qualifier "filled".

Text
----

`libgd` allows you to print labels with a font provided by the library
or with a system font such as "Times New Roman" or "Helvetica". I have
no artistic needs, no I will stick with the internal fonts.

```
# Perl
$im->string(gdSmallFont     ,   5, 15, '01', $black);
$im->string(gdMediumBoldFont,  35, 15, '02', $black);
$im->string(gdLargeFont     , 153, 13, '03', $black);

# Inline::Perl5 + GD
$img.string(gdSmallFont,        5, 15, '01', $black);
$img.string(gdMediumBoldFont,  35, 15, '02', $black);
$img.string(gdLargeFont,      153, 13, '03', $black);

# GD

# GD::Raw
```

You may  have noticed that in  the Perl example, the  commas following
the font names are vertically  aligned and that in the `Inline::Perl5`
example, they are  not. This is a requirement of  the Raku syntax. Too
bad.

I have  grepped the  keyword `string`  in the clones  of the  `GD` and
`GD::Raw`  repositories  and I  have  found  nothing. Same  thing  for
substring `Font`.

DOCUMENTATION
=============

C Library
---------

The  C library  was written  by Thomas  Boutell. Yet,  his website  no
longer contains the documentation for `libgd`. According to the
[terse webpage about GD](http://www.boutell.com/gd/),
the documentation is hosted on
[another website](http://www.libgd.org/)
but requests to this website end with a timeout.

The [Github repository](https://github.com/libgd/libgd/tree/master)
seems to  give very little  documentation too. It is  implemented with
some "Natural  Docs" format which I  know nothing about. If  I want to
read raw documentation files, there is
[only one documentation file](https://github.com/libgd/libgd/blob/500995e4d4b7a730f7c7cc25213710becf414ce8/docs/naturaldocs/preamble.txt)
which gives very few bits of documentation.

Fortunately and eventually, I found
[a website providing the documentation](https://libgd.github.io/pages/about.html)
for library `libgd`.

Raku Module `GD`
----------------

The [Github repository](https://github.com/raku-community-modules/GD)
includes a rather interesting
[README file](https://github.com/raku-community-modules/GD/blob/master/README.md).
On the other hand, the
[documentation file proper](https://github.com/raku-community-modules/GD/blob/master/lib/GD.pod)
gives no additional information.  Both files includes stale hyperlinks
to some previous C library documentation. These links should lead to
[a new repository](https://bitbucket.org/libgd/gd-libgd/src/master/).

Raku Module `GD::Raw`
---------------------

The [Github repo](https://github.com/raku-community-modules/GD-Raw/tree/main)
contains a very short
[README file](https://github.com/raku-community-modules/GD-Raw/blob/main/README.md).
To know how such and such functions  can be called, you have to browse
the developper's tests directory, `xt`. For example, I had to read
[file `bug00191.rakutest`](https://github.com/raku-community-modules/GD-Raw/blob/main/xt/bug00191.rakutest)
in order to know how to choose the line thickness.

On the other  hand, the philosophy of `GD::Raw` is  to stay wery close
to the API of the C functions. So the
[documentation of the C library](https://libgd.github.io/pages/about.html)
should bring enough information for the Raku module.

INSTALLATION
============

When testing the installation and set-up of some software I am not yet
accustomed to, I usually use a  virtual machine. I create snapshots at
crucial moments, so if anything goes wrong, I can roll back easily.

Usually, I begin with a virtual machine freshly installed from
an ISO image, to which I add useful software:

* curl

* my favorite source editor (5 letters, starts with "E", but not `edlin`)

* gcc

* g++

* gitk (which implies git)

* make

For Raku  modules `GD`  and `GD::Raw`,  I add  `rakudo` and  `zef`. At
first I did not intend to install library `libgd`. But in distribution
Devuan 6, `libgd`  version 2.3.3 is installed by default  from the ISO
image. Maybe some othet distributions do things differently.

Off-The-Shelf Raku Module `GD:ver<0.0.2>`
-----------------------------------------

The module is installed with just `zef install GD`, because by default
`libgd3` is already installed on  this distribution. As I have already
written when listing my needs, several features are missing:

* generating a PNG blob without storing it in a file,

* choosing the line thickness,

* defining a dotted style or a dashed style for lines,

* adding labels.

Off-The-Shelf Raku Module `GD::Raw:ver<0.0.4>`
----------------------------------------------

The module is installed with just `zef install GD`, because by default
`libgd3` is already installed on  this distribution. As I have already
written when listing my needs, several features are missing:

* function [`gdImagePngPtr`](https://libgd.github.io/manuals/2.3.0/files/gd_png-c.html#gdImagePngPtr)
allowing the programmer to load the  PNG blob into a program variable,
which will be used to write an `<img>` HTML tag,

* function [`gdImageSetStyle`](https://libgd.github.io/manuals/2.3.0/files/gd-c.html#gdImageSetStyle)
and pseudo colour `gdStyled` allowing  to draw dotned lines and dashed

* functions [`gdImageEllipse`](https://libgd.github.io/manuals/2.3.0/files/gd-c.html#gdImageEllipse)
and [`gdImageRectangle`](https://libgd.github.io/manuals/2.3.0/files/gd-c.html#gdImageRectangle)
to draw the outlines of ellipses and rectangles without filling them,

* function [`gdImageString`](https://libgd.github.io/manuals/2.3.0/files/gd-c.html#gdImageString)
and values
[`gdTinyFont`](https://libgd.github.io/manuals/2.3.3/files/gdfontt-c.html),
[`gdSmallFont`](https://libgd.github.io/manuals/2.3.3/files/gdfonts-c.html),
[`gdMediumFontBold`](https://libgd.github.io/manuals/2.3.3/files/gdfontmb-c.html),
[`gdLargeFont`](https://libgd.github.io/manuals/2.3.3/files/gdfontl-c.html)
and [`gdGiantFont`](https://libgd.github.io/manuals/2.3.3/files/gdfontg-c.html)
to print labels inside the images.

Improved Raku Module `GD::Raw:ver<0.0.5>`
-----------------------------------------

The obvious first step is cloning or
[forking](https://github.com/jforget/GD-Raw)
the module's
[Github repository](https://github.com/raku-community-modules/GD-Raw).
We also need to keep an eye on the
[_native call_ manpage](https://docs.raku.org/language/nativecall)
and the
[C implementation manpage](https://libgd.github.io/manuals/2.3.3/files/preamble-txt.html).

### Rectangle Outlines and Ellipse Outlines

For this first feature, the update was very easy. The signature of
[`gdImageEllipse`](https://libgd.github.io/manuals/2.3.3/files/gd-c.html#gdImageEllipse)
is the same as the signature of
[`gdImageFilledEllipse`](https://libgd.github.io/manuals/2.3.3/files/gd-c.html#gdImageFilledEllipse),
so you only need to copy-paste the few lines involved. Same thing for
[`gdImageRectangle`](https://libgd.github.io/manuals/2.3.3/files/gd-c.html#gdImageRectangle)
with respect to
[`gdImageFilledRectangle`](https://libgd.github.io/manuals/2.3.3/files/gd-c.html#gdImageFilledRectangle).
This is why the coordinates for the ellipse center are named `$cx` and
`$cy` instead of  `$mx` and `$my` as specified in  the C manpage. Just
to be sure, I checked on the
[documentation of function calls](https://raku-knowledge-base.podlite.org/doc/language/nativecall#Passing-and-returning-values).

### Memory Management

When I learnt Perl after coding  C programs, one of the features which
impressed me most  was that I no longer had  to bother about balancing
`malloc` calls with `free` calls. See an
[article from Joel Sposlky](https://www.joelonsoftware.com/2004/06/13/how-microsoft-lost-the-api-war/),
especially the paragraph  starting with "A lot of us  thought" and the
following sidebar. This is still the case with most Raku programs, but
this is not the case with programs using `GD::Raw`.

When I listed my needs and  when I did some preliminary exploration, I
copied the line

```
LEAVE gdImageDestroy($im) if $im;
```

because I intuitively  thought that it dealt with memory  leaks, but I
did not activate my analytical brain and I did not dig further. Now, I
reconsider  the  subject  and  I  think  the  full  answer  is  not  a
straightforward and intuitive one. This code chunk will be adequate in
95% of  the cases (guesstimate), but  it will fail with  the remaining
5%.

In the following explanations, I posit that there are two memory banks
to store data,  one for Raku values, the other  for GD values. Experts
and gurus  will say that the  real situation is more  complicated than
that, but I consider that this simplified description is pedagogically
adequate.

Suppose we create two graphical files with the program below:

```
{
  my $im = gdImageCreate($width, $height) or die;    # (a)
  LEAVE gdImageDestroy($im) if $im;                  # (b)
  my $white = gdImageColorAllocate($im, 0xff, 0xff, 0xff);
  my $red   = gdImageColorAllocate($im, 0xff, 0   , 0);
  gdImageFilledEllipse($im, $cx, $cy, $r, $r, $red);
  my $fh = fopen("red-button.png", "wb");
  return 0 unless $fh;
  gdImagePng($img, $fh);
  flose($fh) if $fh;

  $im = gdImageCreate($width, $height) or die;       # (c)
  LEAVE gdImageDestroy($im) if $im;                  # (d)
  $white    = gdImageColorAllocate($im, 0xff, 0xff, 0xff);
  my $green = gdImageColorAllocate($im, 0   , 0xff, 0);
  gdImageFilledEllipse($im, $cx, $cy, $r, $r, $green);
  $fh = fopen("green-button.png", "wb");
  return 0 unless $fh;
  gdImagePng($img, $fh);
  flose($fh) if $fh;
} # (e)
```

You may notice  that variables `$im`, `$white` and  `$fh` are declared
in the first half and reused in the second half.

Line (a) allocates a first value  in the Raku memory bank for variable
`$im` and a second  value in the GD memory bank  for _n_ pixels. There
is also a test to ensure  the allocations went right. The value stored
in `$im`  will be automatically  deallocated upon reaching the  end of
the lexical scope in line (e).

Line (b)'s theoretical role is to ensure that when reaching the end of
scope in  line (e), the  function `gdImageDestroy` will be  called and
will deallocate the GD memory storing the pixels. And there is a check
to ensure that this call is relevant.

Why "theoretical"? Because  meanwhile, line (c) acts  like an elephant
in  a porcelain  store. On  one side  (Raku memory  bank), it  cleanly
deallocates the existing  `$im` value and immediately  allocates a new
`$im` value. On the other side  (GD memory bank), it allocates some GD
memory for the green button's  pixels _without deallocating the memory
for  the  red  button's  pixels_.  The Raku  memory  bank  is  managed
properly, but there is a memory leak in the GD bank.

And  line   (d)?  Just  like   line  (b),   it  prepares  a   call  to
`gdImageDestroy` when  reaching the end  of the lexical scope  in line
(e). With a test for relevancy, of course.

When reaching  line (e),  there are two  calls to  `gdImageDestroy` to
deallocate the GD memory storing the green button's pixels and none to
deallocate the red button's pixels. In the best case, we have a memory
leak, in the worst case we have something nasty such as a segmentation
fault.

To check these guesses, I wrote two test programs based on the example
above. To monitor the usage of memory, there are two Raku modules:

* [`Linux::Proc::Statm`](https://raku.land/github:Skarsnik/Linux::Proc::Statm)
which uses a process ID parameter,

* [`System::Stats::MEMUsage`](https://raku.land/github:ramiroencinas/System::Stats::MEMUsage)
with no parameter.

I guess that  the second module gives the total  amount of memory used
on the  host machine, while  the first one  gives the amout  of memory
allocated to a single process. So I use `Linux::Proc::Statm`.

As written, the programs  `10-mem-leak.raku` and `11-mem-leak.raku` do
not leak  memory and do  not crash.  By commenting-out some  lines and
un-commenting some  others, you will  be able to reproduce  the memory
leak or the  segmentation fault. But _do not try  this on a production
server!_

AUTHOR
======

Jean Forget / J2N-FORGET at orange dot fr

COPYRIGHT AND LICENSE
=====================

Copyright (c) 2026 Jean Forget, all rights reserved

The programs  are published  under the Artistic  License 2.0.  See the
text in LICENSE-ARTISTIC-2.0.

The various texts  of this repository are licensed under  the terms of
Creative Commons, with attribution and share-alike (CC-BY-SA).

