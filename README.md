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

AUTHOR
======

Jean Forget <J2N-FORGET at orange dot fr>

COPYRIGHT AND LICENSE
=====================

Copyright (c) 2026 Jean Forget, all rights reserved

The programs  are published  under the Artistic  License 2.0.  See the
text in LICENSE-ARTISTIC-2.0.

The various texts  of this repository are licensed under  the terms of
Creative Commons, with attribution and share-alike (CC-BY-SA).

