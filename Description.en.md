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
one in French, the  other one in English). If I leave  a project for a
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
in all modules.

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
format, yet I only need PNG). Generating  the blob and storing it in a
file exists in all modules.

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

The [documentation](https://metacpan.org/pod/GD#Drawing-Commands)
for the Perl module mentions  a deprecated command named `dashedLine`.
I will not bother with this function, I will deal only with `setStyle`
and `gdStyled`.

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
gives no  additional information. Both files  include stale hyperlinks
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

On the other  hand, the philosophy of `GD::Raw` is  to stay very close
to the API of the C functions. So the
[documentation of the C library](https://libgd.github.io/pages/about.html)
should bring enough information for the Raku module.

Other
-----

As is mentioned a few paragraphs below, we need the
[_native call_ manpage](https://docs.raku.org/language/nativecall)
for Raku.

A commonly  used method  which appeared  a few  years ago  consists in
opening  an  AI  session,  asking   the  AI  to  search  the  existing
documentation  and  to   summarise  it,  and  even   to  generate  the
corresponding  lines of  code.  I do  not use  this  method. I  prefer
reading on my own the existing documentation and understanding it.

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

Off-The-Shelf Raku Module `GD::Raw:ver<0.4>`
--------------------------------------------

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

MODULE IMPROVEMENTS
===================

Improved Raku Module `GD::Raw:ver<0.5>`
---------------------------------------

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
`$cy` instead of `$mx` and `$my` as specified in the
[C manpage](https://libgd.github.io/manuals/2.3.3/files/gd-c.html#gdImageEllipse).
Just to be sure, I checked on the
[documentation of function calls](https://raku-knowledge-base.podlite.org/doc/language/nativecall#Passing-and-returning-values).

### Memory Management

When I learnt Perl after coding  C programs, one of the features which
impressed me most  was that I no longer had  to bother about balancing
`malloc` calls with `free` calls. See an
[article from Joel Spolsky](https://www.joelonsoftware.com/2004/06/13/how-microsoft-lost-the-api-war/),
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

For the memory size, the programs  use a reference value which will be
compared with the  final value. This reference value  is not extracted
at the  beginning of the program,  but after the first  image has been
built, because at this point, the  buffers required by the Raku module
and by the C library has already been allocated.

### Use of Git and Github

One first thing is sure, I must fork the
[community repository](https://github.com/raku-community-modules/GD-Raw)
into  a  [personal repo](https://github.com/jforget/GD-Raw),  work  on
this personal  repo and send  back the  updates to the  community repo
through
[pull requests](https://github.com/raku-community-modules/GD-Raw/pulls).

Beyond that, it is more fuzzy.  Should I work in branch `main`? Should
I create a second branch for  developments? A single new branch or one
per   new   feature?   At   first,    I   created   a   branch   named
`circles-rectangles` and  I planned to  create other branches  for the
other features.  When the first  feature was developped and  tested, I
created a
[first pull request](https://github.com/raku-community-modules/GD-Raw/pull/2)
from this branch.

Then I changed my mind and I opted to use the same `dev` branch for
all new features. I renamed the current
[branch from my personal repo](https://github.com/jforget/GD-Raw/branches)
from  `circles-rectangles` to  `dev` and  I was  astonished that  this
action triggered an  automatic close of the pull  request created just
before. So I created
[a new PR nearly identical to the prior one](https://github.com/raku-community-modules/GD-Raw/pull/3).

Because  of  a  slight  problem,  the  pull  request  was  not  merged
immediately into the community repo. During this time, I
[wrote some documentation](https://github.com/raku-community-modules/GD-Raw/pull/3/changes/a91e977e0d7dfb64d06c2be7da9b4a81f5c7137b).
And I was again astonished that the open PR would inherit this commit.
There are  things in  Git and  Github that I  do not  understand quite
well.

Improved Raku Module `GD::Raw:ver<0.6>`
---------------------------------------

### Loading PNG Data Without Any File

While the outlines of rectangles and  ellipses was a milk run, loading
PNG data  into a Raku  blob is much trickier  and I had  to frequently
search and read the documentation.

First, when I wrote example scripts such as
[00-basic-lines.raku](https://github.com/jforget/raku-sandbox-GD/blob/d0c0438c6d8cb18b7c5f5df2ee580a49bebf4ca9/GD-Raw/00-basic-lines.raku)
with a commented-out  example of loading PNG data into a Raku blob, I
thought that
[function `gdImagePngPtr`](https://libgd.github.io/manuals/2.3.3/files/gd_png-c.html#gdImagePngPtr),
was working the same way as
[`gdImagePng`](https://libgd.github.io/manuals/2.3.3/files/gd_png-c.html#gdImagePng)
by only replacing the pointer to  a filehandle with the pointer to the
binary data.

```
my $png-data;
gdImagePngPtr($im, pointer to $png-data);
my $src = MIME::Base64.encode($png-data);
print "<img src='data:image/png;base64,$src'/>";
```

Actually,  while  function  `gdImagePng` returns  absolutely  nothing,
function `gdImagePngPtr`  theoretically returns two values:  a pointer
to the binary data and the size (in bytes) of these binary data. As is
the usage in C, one of these  is the return value of the function, the
other is  transmitted by way of  a pointer. So the  actual programming
template is:

```
my $size;
my $png-data = gdImagePngPtr($im, pointer to $size);
my $src = MIME::Base64.encode($png-data);
print "<img src='data:image/png;base64,$src'/>";
```

Parameter `$size` was a simple matter. In the
[documentation for C library calls](https://raku-knowledge-base.podlite.org/doc/language/nativecall#Basic-use-of-pointers),
I  read that  the function  signature  must define  this parameter  as
`int32 is rw`. No need to use references (in the Raku meaning).

Parameter `$png-data` is  a little more convoluted.  Actually, we must
use a pointer `$ptr` as printed in
[this paragraph](https://raku-knowledge-base.podlite.org/doc/language/nativecall#Basic-use-of-pointers)
and then retrieve the contents as suggested in
[that paragraph](https://docs.raku.org/language/nativecall#Buffers_and_blobs),
which requires the module
[`NativeHelpers::Blob`](https://github.com/salortiz/NativeHelpers-Blob).

In the end, the template is:

```
use GD::Raw;
use MIME::Base64;
use NativeHelpers::Blob;

[...]

my int32 $size;
my $ptr       = gdImagePngPtr($im, $size);
my $png-data  = blob-from-pointer($ptr, elems => $size, type => Blob[int8]);
my $mime-data = MIME::Base64.encode($png-data);
print "<img src='data:image/png;base64,$mime-data'/>";
gdFree($ptr);
```

Beware, there is an
[error](https://github.com/salortiz/NativeHelpers-Blob/issues)
in  distribution `NativeHelpers::Blob`  version  0.1.12.  You need  to
install it with `zef` parameter `--force-test`.

As fas as I am concerned, only  the PNG format is useful. Yet, since I
have  managed to  add function  `gdImagePngPtr`, I  might as  well add
other  functions `gdImageXXXPtr`,  provided  I  understand them.  That
means that I have not added
[`gdImageGd2Ptr`](https://libgd.github.io/manuals/2.3.3/files/gd_gd2-c.html#gdImageGd2Ptr)
because I  do not understand what  parameters `cs` and `fmt`  are for.
Similarly, I have added neither
[`gdImageHeifPtr`](https://libgd.github.io/manuals/2.3.3/files/gd_heif-c.html#gdImageHeifPtr)
nor [`gdImageHeifPtrEx`](https://libgd.github.io/manuals/2.3.3/files/gd_heif-c.html#gdImageHeifPtrEx)
because I do  not understand what the parameters  `codec` and `chroma`
represent.

The test values have been generated by Perl script
`Perl/mk-test-ptr.pl`. Since on my computer, library `libgd` gives
error messages when generating formats GD, TIFF and WebP, these
formats are not tested in program `xt/gdimagepngptr.rakutest`.

### Trying to Store a Style into File `foo.gd`

Another aim of version 0.6 is  using styles when drawing lines and the
like. Before  modifying the Raku module,  I have a few  experiments to
run.

The idea is to check whether a  first program can create an image with
a style and  store this image into  a file `foo.gd` and then whether a
second program can read this file and draw a line with this style. See
programs `20-add-style.pl` and `21-use-style.pl` in directory `Perl`.

I could not run the experiment. While the
[documentation for `GD`](https://metacpan.org/pod/GD#Image-Data-Output-Methods)
states that an image object has methods named
[`gd`](https://metacpan.org/pod/GD#$gddata-=-$image-%3Egd)
and [`gd2`](https://metacpan.org/pod/GD#$gd2data-=-$image-%3Egd2),
the [documentation for `GD::Image`](https://metacpan.org/pod/GD::Image),
state that  formats "Gd" and "Gd2"  are not supported. Coming  back to
the `GD` documentation, the comments for methods
[`newFromGd`](https://metacpan.org/pod/GD#$image-=-GD::Image-%3EnewFromGd($file)),
[`newFromGdData`](https://metacpan.org/pod/GD#$image-=-GD::Image-%3EnewFromGdData($data)),
[`newFromGd2`](https://metacpan.org/pod/GD#$image-=-GD::Image-%3EnewFromGd2($file))
and [`newFromGd2Data`](https://metacpan.org/pod/GD#$image-=-GD::Image-%3EnewFromGd2Data($data))
tell me that formats GD and GD2 have been dropped from version 2.3.2 of `libgd`.

Now, let us read the
[documentation](https://libgd.github.io/manuals/2.3.3/files/preamble-txt.html)
of version 2.3.3 of C library `libgd`. This documentation contains a
[page](https://libgd.github.io/manuals/2.3.3/files/gd_gd-c.html)
for format GD and
[another](https://libgd.github.io/manuals/2.3.3/files/gd_gd2-c.html)
for format GD2. Both pages say that the format

> has to be regarded as being obsolete, and should only be used for development and testing purposes.

Very good, I  currently develop and test the Raku  module for `libgd`.
What a pity I cannot use Perl to develop and test the Raku module!

### Stress test, using a very long style

Usually, styles contain very few pixels,  because all we want to do is
drawing  dotted lines  and dashed  lines. Yet,  we can  wonder whether
there is an implicit threshold and what happens if we go beyond.

To shoehorn a very long line into  an image, I opt to display a spiral
line. Not  a rounded one, but  an angular spiral, built  from straight
segments with  increasing lengths.  The style is  based on  the binary
representation of  numbers from 0 to  255. Each "0" digit  is shown as
two blue pixels, each "1" digit is shown as two red pixels. Two binary
digits are separated by two light  grey pixels. Two numbers (from 0 to
255) are  separated by  a few grey  pixels plus a  black one.  With 33
pixels per number, that gives a huge style with 8481 pixels.

The  result is  fine, with  a small  misleading particularity.  When I
request that a line is drawn from  right to left, it is actually drawn
left to  right. Same problem with  vertical lines bottom to  top. This
peculiarity shows both for a  spiral drawn with several `line` methods
(`22-long-style.pl`) and a spiral drawn using a single open polygon
(`23-style-polygon.pl`).

A variant, `24-rainbow.pl`,  creates a "true color" image,  that is an
image with possibly more than 256  colours. In this program, the style
contains 765 colors.

### Implementing Styles

A  style is  an array  of colours.  Each colour  is implemented  as an
0-to-255 numeric index when dealing with a palette-type image, or as a
integer  encoding the  RGB triplet  when dealing  with a  "True Color"
image. But the array is not a plain Raku array. According to
[the documentation](https://docs.raku.org/language/nativecall#Arrays),
we  must instantiate  a  `CArray[int32]`  object and  bind  it to  the
variable name with "`:=`" instead of "`=`".

The pseudo-colours  `gdStyled` and `gdTransparent` are  defined in the
same area  of file `gd.c`  as symbol  `gdAntiAliased`. So in  the Raku
module, I define them in the same place as `gdAntiAliased`.

Program  `25-mem-leak.raku` is  the combination  of `10-mem-leak.raku`
and `22-long-style.raku`. Its purpose is  finding if the use of styles
generate memory  leaks. The results  seem to  show that there  is some
leaking  of  memory. On  the  other  hand,  when  I disable  the  line
`gdImageSetStyle` with  a hashmark, or  even when I disable  this line
and  the  lines building  the  `CArray`  value,  the memory  usage  is
displayed with similar values. I think  the increase of used memory is
mainly the result of building the Raku array `@style`, not the C array
`@style-c`.

This supposition  is confirmed with program  `26-mem-leak.raku`, which
builds  the Raku  array `@style`  before the  double loop,  while this
double loop contains  only the building of the C  array `@style-c` and
the call to  `gdImageSetStyle`. The memory usage  still increases, but
much slower. I  suppose that this is the normal  operation of the Raku
interpreter, this is not the symptom of a memory leak.

If we do  a further experiment by removing the  building of `@style-c`
from the double loop, the memory  usage still increases, but very very
slowly, a few bytes at a time.

Improved Raku Module `GD::Raw:ver<0.7>`
---------------------------------------

### Character Strings

My needs when drawing graphs are very  small. I only have to write the
codes identifying the vertices of the graph. These are codes, not full
designations.  Therefore,  they  are  strings of  7-bit  ASCII  chars,
without  any  diacritics. The  only  advanced  functionality would  be
displaying  a  string  vertically  for  the  map  scale,  with  method
`stringUp`. Up to now, I did  not use this functionality because I did
not  read   the  full  `GD.pm`  documentation   until  recently.  When
overhauling   the  graph   drawing   program  to   use  `GD::Raw`   or
`GD.rakumod`, I will use this method.

For  the character  font,  I  chose the  easiest  and  fastest way,  I
selected   an  internal   font  among   `gdGiantFont`,  `gdLargeFont`,
`gdMediumBoldFont`, `gdSmallFont` and `gdTinyFont`  and I did not look
beyond.

I  have  used the  `string`  method  with  only 7-bit  ASCII  strings.
Actually,  this method  uses a  8-bit  encoding, ISO-8859-2.  So if  I
invoke method `string` with a UTF-8  string containing "é", I will not
get the usual _mojibake_ "Ã©", but the new _mojibake_ "ĂŠ".

In the
[recap](http://paris.mongueurs.net/meetings/2004/0211.html)
of a  Paris.pm meeting, I  added two pictures generated  with `GD.pm`,
including a few  legends such as "Étudiantes  diplômées". Actually, at
first,  I invoked  the `string`  method with  a diacritic-less  label,
"Etudiantes  diplomees" and  then  I drew  acute  accents with  method
`line`. And  I gave  up drawing  the circumflex  accents. In  a second
time, I invoked method `stringFT`, described below.

We can use other character fonts with method `string`. As written in the
[`GD.pm` documentation](https://metacpan.org/pod/GD#Character-and-String-Drawing),
you can  take a  `xxx.bdf` font, convert  it with  utility `bdf2gd.pl`
into `xxx.fnt` and  use it in a  GD picture. For the  module writer or
mainainer, this requires coding a
[`gdFont` structure](https://libgd.github.io/manuals/2.3.3/files/gd-h.html#gdFontPtr).
I will not use this in Raku  modules `GD` and `GD::Raw`. Or maybe in a
remote future version, do not hold your breath.

The  `libgd` documentation  allows us  to use  strings with  a 16-char
encoding. See functions
[`gdImageString16`](https://libgd.github.io/manuals/2.3.3/files/gd-c.html#gdImageString16)
and [`gdImageStringUp16`](https://libgd.github.io/manuals/2.3.3/files/gd-c.html#gdImageStringUp16).
These functions were not ported  to the Perl module `GD.pm`. Moreover,
the `libgd` website does not provide examples of character fonts using
a  16-char encoding.  Experimenting with  this functionality  would be
time consuming  for a small benefit.  I will not take  these functions
into account in the Raku modules `GD` and `GD::Raw`.

Note that in the `GD.pm` documentation the conversion utility is named
`bdf2gd.pl`,  but in  the directory  `/usr/bin` on  my computer  it is
named    `bdf2gdfont`,    generated    at   installation    time    by
`bdf2gdfont_pl.PL`. And the
[`bdf_scripts` subdirectory](https://github.com/lstein/Perl-GD/tree/master/bdf_scripts)
of the [Github repository](https://github.com/lstein/Perl-GD/tree/master)
contains a older and simpler version `bdftogd`.

According to the `libgd` documentation, a further step is using
[_Free Type_ fonts](https://libgd.github.io/manuals/2.3.3/files/gdft-c.html)
with functions
[`gdImageStringFT`](https://libgd.github.io/manuals/2.3.3/files/gdft-c.html#gdImageStringFT)
and [`gdImageStringFTEx`](https://libgd.github.io/manuals/2.3.3/files/gdft-c.html#gdImageStringFTEx).
The `GD.pm` documentation mentions using
[_True Type_ fonts](https://metacpan.org/pod/GD#Character-and-String-Drawing)
with method `stringFT`. I suppose that "True Type" and "Free Type" are
the same, or  at least compatible. If  implementing this functionality
is simple, I  will implement this in Raku modules  `GD` and `GD::Raw`.
If the implementation  requires extensive work (defining  a new class,
describing a  C structure  in Raku),  I will leave  the hot  potato to
another person.

Yet, this  functionality requires  a system font,  stored in  a system
directory. Therefore,  I will not  provide a test  `t/xxx.rakutest` or
even a  test `xt/xxx.rakutest`, because I  cannot be sure that  on the
Unix machines of the next contributors, there will be a directory with
the same  name as  on my computer  and storing the  same files  as the
directory  on my  machine. And  if a  contributor works  on a  Windows
computer...

The [`GD.pm` documentation](https://metacpan.org/pod/GD)
mentions a
[`stringFTCircle` method](https://metacpan.org/pod/GD#$result-=-$image-%3EstringFTCircle($cx,$cy,$radius,$textRadius,$fillPortion,$font,$points,$top,$bottom,$fgcolor)).
The [`libgd` documentation](https://libgd.github.io/manuals/2.3.3/files/gdft-c.html)
does  not   describe  a  similar   function.  And  anyway,   the  Perl
documentation states that the method does not work. I will ignore this
in the Raku  modules. There is a  test in the `Perl`  directory of the
sandbox and you can see by yourselves the result.

### Character Strings in Hindsight

For the internal fonts such as `gdGiantFont`, the
[Perl module `GD.pm`](https://metacpan.org/pod/GD#Character-and-String-Drawing)
requires a `GD::Font` object. I have looked for `GD::Font` in the Perl
source files  for `GD` and I  have not found the  declaration for this
class. Maybe this class is defined only in the
[XS file](https://github.com/lstein/Perl-GD/blob/master/GD.xs).
The problem is that I do not know how XS works... As for the
[`libgd` documentation](https://libgd.github.io/manuals/2.3.3/files/gd-c.html#gdImageString),
it seems to say that I have to use a
[`gdFontPtr` pointer](https://libgd.github.io/manuals/2.3.3/files/gd-h.html#gdFontPtr)
and a `gdFont`  struct. Instead of declaring this C  structure, I used
an `OpaquePointer`.

The
[`NativeCall` documentation](https://docs.raku.org/language/nativecall#Passing_and_returning_values),
shows that  when a function receives  a string parameter or  returns a
string result,  we can specify the  encoding of this string.  The only
example given  is `is  encoded('utf8')`. I have  tried to  use another
encoding scheme with  `is encoded('iso-8859-2')` but it  fails. I have
tried variants  (with or without  dashes) and  it still fails.  So the
string is declared without any encoding.

Porting function
[`gdImageStringFT`](https://libgd.github.io/manuals/2.3.3/files/gdft-c.html#gdImageStringFT),
without providing a  test file is not advisable. The  first problem is
that the  function is not  tested. The  second problem is  that casual
module users will not benefit of  a script showing how the function is
called. Above,  I have written  that I would  not write a  test script
because  the TTF  fonts I  would  use might  not be  installed on  the
machines of the next contributors. Fortunately, I found a solution. In
addition  to  the expected  PNG  file,  the test  subdirectory  should
contain the TTF font  used for the test. The new problem  is to find a
TTF font  with a  compatible license.  New solution: I  do not  use an
existing font, I create  a new one and I choose  the proper license. I
installed
[Font Forge](https://fontforge.org/en-US/)
and I created a font from  scratch. I took a quick-and-dirty approach,
without bothering with aesthetics. Starting from
[Morse code](https://morsecode.world/international/translator.html),
I created  glyphs built from  dots and  dashes (vertical dashes  for a
manageable length).  The dots  are oval rather  than circular  and the
radii vary from one dot to  the next, the dashes have differing widths
and heights.  Glyphs are defined  only for the  space and the  7 chars
from `"Hello world"`.  My aim was creating a font  file which would be
useful for the tests, nothing more.

When I read the
[documentation](https://libgd.github.io/manuals/2.3.3/files/gdft-c.html#gdImageStringFT)
for C function `gdImageStringFT`, I read the following:

```
char * gdImageStringFT (        gdImagePtr  im,
                                int        *brect,
                                int         fg,
                        const   char       *fontlist,
                                double      ptsize,
                                double      angle,
                                int         x,
                                int         y,
                        const   char       *string  )
```

> `brect` The  bounding rectangle  as array of  8 integers  where each
> pair  represents the  x- and  y-coordinate  of a  point. The  points
> specify  the lower  left, lower  right, upper  right and  upper left
> corner.

Then, when I read the
[documentation](https://metacpan.org/pod/GD#@bounds-=-$image-%3EstringFT($fgcolor,$fontname,$ptsize,$angle,$x,$y,$string))
for the corresponding method within the Perl module, I read the following:

```
@bounds = $image->stringFT($fgcolor,$fontname,$ptsize,$angle,$x,$y,$string)
```

What about the missing parameter `brect`? Let us take a look at
[source file `GD.xs`](https://github.com/lstein/Perl-GD/blob/master/GD.xs).
Except     for     calling     functions     `gdImageStringFT`     and
`gdImageStringFTEx`, the only place in which `brect` is used is within
this chunk of code:

```
        if (err) {
          errormsg = perl_get_sv("@",0);
          if (errormsg != NULL)
            sv_setpv(errormsg,err);
          XSRETURN_EMPTY;
        } else {
          EXTEND(sp,8);
          for (i=0; i<8; i++) {
            mPUSHi(brect[i]);
          }
        }
```

I am  no expert  at XS, but  I may  guess what this  chunk of  code is
about. These  lines fill  the values that  the Perl  method `stringFt`
returns to the  calling Perl program. Therefore, the  `brect` array is
not a call parameter  to `gdImageStringFT` or `gdImageStringFTEx`, but
a pointer to values returned by these functions. When casually reading
the documentation of the C functions and the Perl method, you may miss
this piece of information.

Actually, I  could have read a  little more carefully the  Perl module
and I could have noticed the beginning of the line

```
@bounds = ...
```

As explained in the
[native call documentation](https://docs.raku.org/language/nativecall#Arrays),
we must allocate enough room for  8 integers. So the `brect` parameter
should be declared with

```
my @brect := CArray[int32].new;
@brect[7] = 0; # to allocate room for 8 integers
```

For the built-in  tests of function `gdImageStringFT`, I  wrote a Perl
script in  this repository, names, `mk-test-ttf.pl`,  which builds the
expected PNG file. When running `xt/gdimagestringft.rakutest`, several
pixels are different  between the expected file and  the actual image.
Yet, if you take  a look at both files, using  your Mk.1 eyeballs, you
see that the  files are very similar.  I have decided to  use the file
generated by the Raku test script as the expected file.

Here are the functions which have not been implemented:

* `gdImageChar` and  `gdImageCharUp`, because you can  obtain the same
  results with `gdImageString` and `gdImageStringUp`.

* `gdImageString16` and `gdImageStringUp16`, because I have no example
  of a font file with  a 16-bit encoding and because `gdImageStringFT`
  gives you access to all Unicode characters instead of just 65536.

* `gdImageStringFTEx` because the Raku module requires the description
  of a `gdFTStringExtra`  data structure and I punt this  issue to the
  next module contributor.

AUTHOR
======

Jean Forget / J2N-FORGET at orange dot fr

COPYRIGHT AND LICENSE
=====================

Copyright (c) 2026 Jean Forget, all rights reserved

The programs and  fonts are published under the  Artistic License 2.0.
See the text in LICENSE-ARTISTIC-2.0.

The various texts  of this repository are licensed under  the terms of
Creative Commons, with attribution and share-alike (CC-BY-SA).

