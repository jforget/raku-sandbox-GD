-*- encoding: utf-8; indent-tabs-mode: nil -*-

BUT
===

Lorsque j'ai écris la première version de
[mes programmes sur les graphes et les chemins hamiltoniens](https://github.com/jforget/raku-Hamilton2/blob/master/doc/Hamilton.fr.md),
il a  fallu que je  choisisse un module  pour dessiner des  schémas. À
cette époque, le
[module Raku `GD`](https://github.com/raku-community-modules/GD)
présentait des lacunes par rapport à mes besoins et je ne connaissais pas le
[module `GD::Raw`](https://raku.land/zef:raku-community-modules/GD::Raw).
J'ai donc décidé d'installer
[`Inline::Perl5`](https://raku.land/cpan:NINE/Inline::Perl5)
avec le module Perl
[`GD`](https://metacpan.org/pod/GD).

Maintenant, je souhaite utiliser un  module Raku natif, soit `GD` soit
`GD::Raw`.  Ce  dépôt  rassemble  mes  notes  pour  expliquer  comment
installer ces modules,  où trouver de la  documentation, voire comment
ajouter des  fonctionnalités supplémentaires. Le dépôt  contient aussi
les  programmes Perl  et les  programmes Raku  que j'ai  utilisés pour
préparer mes tests et les exécuter.

Assez  souvent, dans  les  projets hébergés  sur  Github, j'ajoute  un
fichier de  documentation expliquant  la procédure  d'installation. En
effet, si je  reviens sur le sujet après quelques  mois, je n'ai aucun
mal à comprendre ce le code que j'ai écrit, mais j'ai beaucoup plus de
mal  à  retrouver toutes  les  actions  effectuées pour  installer  et
paramétrer le logiciel. Si je suis amené à ajouter des fonctionnalités
dans le  module `GD`  ou dans  `GD::Raw`, qui sont  des modules  de la
communauté Raku, je ne pourrai pas  raconter ma vie dans un fichier de
documentation  ajouté au  dépôt Github.  Au lieu  de cela,  j'écris le
fichier de  documentation (le présent  fichier), je l'ajoute  au dépôt
« bac à sable » et je publie le dépôt « bac à sable » sur Github.

BESOINS
=======

Création d'image
----------------

Allouer la structure de données permettant de travailler sur une image
vide au début, en ajoutant au fur et à mesure des éléments graphiques.
Cela existe forcément dans les deux modules.

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

Couleurs
--------

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

`GD` : exemple de code trouvé dans le fichier `README.md`.

Génération d'image
------------------

Une fois  que l'on  a ajouté  tous les  éléments graphiques,  créer la
chaîne binaire encodant cette image dans le format PNG, éventuellement
dans d'autres formats. J'ai besoin  juste du format PNG. Heureusement,
cela existe dans les deux modules.

D'un autre  côté, je n'ai  pas besoin  d'écrire la chaîne  binaire PNG
dans un  fichier, je  l'insère dans  une balise  HTML `<img>`  avec un
encodage `MIME::Base64`.

```
# Perl
binmode $fh;
print $fh $im->png;
[...]
src => "data:image/png;base64," . MIME::Base64::encode($im->png()));

# Inline::Perl5 + GD
src => "data:image/png;base64," ~ MIME::Base64.encode($image.png()));

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

`GD` : exemple de code trouvé dans le fichier `README.md`.

`GD::Raw` :  exemples trouvés dans  `t/01-create-and-load.rakutest` et
`xt/gdtest.rakumod`.

Je  n'ai pas  vu dans  `GD` ni  dans `GD::Raw`  comment récupérer  les
données PNG sans passer par un fichier.

Traits basiques
---------------

Tirer un trait en couleur d'un point à un autre.

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

Traits épais et traits fins
---------------------------

Tirer  un trait  en  couleur d'un  point à  un  autre, en  choisissant
l'épaisseur.

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

Pour `GD::Raw`, voir le
[fichier `bug00191.rakutest`](https://github.com/raku-community-modules/GD-Raw/blob/main/xt/bug00191.rakutest)

Pour `GD`,  la recherche  par `grep`  de la  chaîne `"thick"`  dans un
clone du dépôt Github ne donne aucun résultat.

Pointillés
----------

Tirer un trait pointillé ou tireté d'un point à un autre.

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

Pour `GD` comme  pour `GD::Raw`, la recherche par `grep`  de la chaîne
`"styled"` dans les clones des dépôts Github ne donne aucun résultat.

Cercles et carrés
-----------------

Dessiner des cercles et des carrés, soit vides, soit emplis.


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

Les  exemples de  `GD` proviennent  de `examples/gd.p6`.  Je n'ai  pas
trouvé d'exemple  avec le  qualificatif _filled_. Il  existe toutefois
deux fonctions `gdImageFilledRectangle` et `gdImageFilledEllipse`.

Les exemples de `GD::Raw`  proviennent de `xt/bug00010.rakutest` et de
`xt/bug00079.rakutest`. Il  y en a  d'autres dans le  répertoire `xt`,
inutile de tous les lister. En  revanche, je n'ai trouvé aucun exemple
omettant le qualificatif _filled_.

Texte
-----

`libgd`  permet  d'afficher du  texte  avec  une  fonte interne  à  la
bibliothèque ou  avec une fonte  système comme « Times New  Roman » ou
« Helvetica ». N'ayant pas de gros besoins artistiques, je me contente
de la fonte interne.

```
# Perl
$im->string(gdSmallFont     ,   5, 15, '01', $black);
$im->string(gdMediumBoldFont,  35, 15, '02', $black);
$im->string(gdLargeFont     , 153, 13, '03', $black);

# Inline::Perl5 + GD
$img.string(gdSmallFont     ,   5, 15, '01', $black);
$img.string(gdMediumBoldFont,  35, 15, '02', $black);
$img.string(gdLargeFont     , 153, 13, '03', $black);

# GD

# GD::Raw
```

J'ai cherché la chaîne `string` avec `grep` dans les clones des dépôts
`GD` et `GD::Raw`, je n'ai rien trouvé. Idem pour la chaîne `Font`.

DOCUMENTATION
=============

Bibliothèque C
--------------

La bibliothèque C a été écrite  par Thomas Boutell. Cela dit, son site
web ne comporte plus de documentation pour sa bibliothèque. D'après la
[page laconique consacrée à GD](http://www.boutell.com/gd/),
la documentation se trouve sur
[un autre site](http://www.libgd.org/)
mais ce site n'a pas l'air de répondre aux requêtes.

Le [dépôt Github](https://github.com/libgd/libgd/tree/master)
n'a  pas l'air  non plus  de  contenir beaucoup  de documentation.  Il
repose sur  un format "Natural  Docs" que je  ne connais pas.  Quant à
lire  dans le  texte source  les  fichiers de  documentation, je  n'ai
trouvé qu'un
[qu'un seul fichier de documentation](https://github.com/libgd/libgd/blob/500995e4d4b7a730f7c7cc25213710becf414ce8/docs/naturaldocs/preamble.txt)
qui ne résout pas tout.

Heureusement, j'ai fini par trouver
[un site dédié à la documentation](https://libgd.github.io/pages/about.html)
de la bibliothèque GD.

Module Raku `GD`
----------------

Le [dépôt Github](https://github.com/raku-community-modules/GD)
comporte un
[fichier README](https://github.com/raku-community-modules/GD/blob/master/README.md)
assez intéressant. En revanche, le
[fichier de documentation](https://github.com/raku-community-modules/GD/blob/master/lib/GD.pod)
n'apporte rien de plus. D'autre part, ces deux fichiers comportent des
liens  vers  la bibliothèque  C,  mais  ces  liens sont  périmés,  ils
devraient pointer vers
[un nouveau dépôt](https://bitbucket.org/libgd/gd-libgd/src/master/).

Module Raku `GD::Raw`
---------------------

Le [dépôt Github](https://github.com/raku-community-modules/GD-Raw/tree/main)
comporte un
[fichier README](https://github.com/raku-community-modules/GD-Raw/blob/main/README.md)
très bref. Pour savoir comment coder  telle ou telle fonction, il faut
piocher dans le répertoire `xt` des tests du développeur. Par exemple,
c'est dans le
fichier `bug00191.rakutest`](https://github.com/raku-community-modules/GD-Raw/blob/main/xt/bug00191.rakutest)
que j'ai vu que l'on pouvait choisir l'épaisseur des traits.

D'un  autre côté,  la philosophie  de `GD::Raw`  étant de  rester très
proche de l'API C, la
[documentation de la bibliothèque C](https://libgd.github.io/pages/about.html)
pourra suffire pour ce module Raku.

INSTALLATION
============

Pour tester l'installation et la configuration de tel ou tel logiciel,
j'ai  l'habitude  d'utiliser  une  machine virtuelle.  En  prenant  un
instantané  avant de  commencer le  test,  cela permet  de revenir  en
arrière facilement.

Dans  le  cas  général,  je  commence  avec  une  machine  fraîchement
installée à partir de l'image  ISO d'installation, à laquelle j'ajoute
quelques logiciels indispensables :

* curl

* emacs

* gcc

* g++

* gitk (installe implicitement git)

* make

Pour le  cas des modules  Raku `GD`  et `GD::Raw`, j'installe  en plus
Raku, zef et  un clone du présent dépôt. Notamment,  je n'installe pas
`libgd`  avant de  prendre  l'instantané. Je  l'installe  après et  je
mentionne  cette installation  dans  la  procédure. L'installation  du
présent dépôt permet d'avoir immédiatement des programmes de test.

AUTEUR
======

Jean Forget <J2N-FORGET at orange dot fr>

COPYRIGHT ET LICENCE
====================

Copyright (c) 2026 Jean Forget, tous droits réservés.

Les programmes sont diffusés avec la licence **Artistic License 2.0**.
Voir le texte (en anglais) dans `LICENSE`.

Les divers textes  et images de ce dépôt sont  publiés avec la licence
Creative Commons : Attribution - Partage dans les Mêmes Conditions (CC
BY-SA ).

