-*- encoding: utf-8; indent-tabs-mode: nil -*-

BUT
===

Lorsque j'ai écrit la première version de
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
mal à  comprendre le code que  j'ai écrit, mais j'ai  beaucoup plus de
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
Cela existe forcément dans tous les modules.

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
cela existe dans tous les modules.

D'un autre  côté, je n'ai  pas besoin  d'écrire la chaîne  binaire PNG
dans un  fichier, je  l'insère dans  une balise  HTML `<img>`  avec un
encodage `MIME::Base64`.

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

La [documentation](https://metacpan.org/pod/GD#Drawing-Commands)
mentionne  une commande  `dashedLine`, tout  en précisant  qu'elle est
obsolète.  Je   ne  m'occuperai  donc   pas  de  cette   fonction,  je
m'intéresserai uniquement à `setStyle` et `gdStyled`.

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

Vous  noterez dans  les exemples  de `Inline::Perl5`,  les parenthèses
ouvrantes ne sont pas alignées comme en Perl. C'est la syntaxe de Raku
qui veut cela. Dommage.

Les exemples de `GD` proviennent de
[`examples/gd.p6`](https://github.com/raku-community-modules/GD/blob/master/examples/gd.p6).

Les exemples de `GD::Raw` proviennent de
[`xt/bug00010.rakutest`](https://github.com/raku-community-modules/GD-Raw/blob/main/xt/bug00010.rakutest)
et de [`xt/bug00079.rakutest`](https://github.com/raku-community-modules/GD-Raw/blob/main/xt/bug00079.rakutest).
Il y en a d'autres dans le répertoire `xt`,
inutile de tous les lister. En  revanche, je n'ai trouvé aucun exemple
omettant le qualificatif _filled_.

Texte
-----

`libgd`  permet  d'afficher du  texte  avec  une  fonte interne  à  la
bibliothèque ou  avec une fonte  système comme « Times New  Roman » ou
« Helvetica ». N'ayant pas de gros besoins artistiques, je me contente
des fontes internes.

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

Vous noterez  dans les exemples  de `Inline::Perl5`, les  virgules qui
suivent le nom de la police ne  sont pas alignées comme en Perl. C'est
la syntaxe de Raku qui veut cela. Dommage.

J'ai cherché la chaîne `string` avec `grep` dans les clones des dépôts
`GD` et `GD::Raw`, je n'ai rien trouvé. Idem pour la chaîne `Font`.

Lecture d'une image existante
-----------------------------

Outre mon
[projet sur les graphes et les chemins hamiltoniens](https://github.com/jforget/raku-Hamilton2/blob/master/doc/Hamilton.fr.md),
j'ai utilisé GD pour un
[projet de reconnaissance de caractères](https://github.com/jforget/Perl-fixed-width-char-human-recognition/blob/master/description/description.md).
Le projet n'est plus actif, mais j'y pense quand même.

Dans ce projet,  certaines images sont générées,  mais d'autres images
sont analysées.  Il faut  donc charger  un objet  image à  partir d'un
fichier PNG ou d'un blob PNG.

```
# Perl
my $image = GD::Image->newFromPng($fichier);
[...]
my $im_cel = GD::Image->newFromPngData(decode_base64($cel->{data}));

# Inline::Perl5 + GD
my $image = GD::Image.newFromPng($fichier);
[...]
my $im_cel = GD::Image.newFromPngData(MIME::Base64.decode($cel<data>));

# GD

# GD::Raw
my $fh = fopen("my-image.png", "rb");
my $img = gdImageCreateFromPng($fh);
```

Exemples Perl tirés du
[programme `calibrage`](https://github.com/jforget/Perl-fixed-width-char-human-recognition/blob/master/calibrage)
et du [programme `appli.pl`](https://github.com/jforget/Perl-fixed-width-char-human-recognition/blob/master/appli/appli.pl)
du projet de reconnaissance de caractères.

Exemples `Inline::Perl5`  reconstitués à partir des  exemples Perl, je
ne les ai pas testés.

Exemple `GD::Raw` tiré de la documentation POD du module. Je n'ai rien
trouvé pour la création à partir d'un blob.

Pour `GD`, je n'ai rien trouvé.

Traitement pixel par pixel
--------------------------

Pour  ce projet  de  reconnaissance de  caractères,  il faut  analyser
certaines images  pixel par  pixel et connaître  la couleur  de chaque
pixel.

```
# Perl
my $index  = $image->getPixel($l1, $c1);

# Inline::Perl5 + GD
my $index  = $image.getPixel($l1, $c1);

# GD

# GD::Raw
my int32 $p = gdImageGetPixel($im, $x, $y);

```

Exemple Perl tiré du
[projet de reconnaissance de caractères](https://github.com/jforget/Perl-fixed-width-char-human-recognition/blob/master/calibrage).

Exemple `GD::Raw` tiré de
[`xt/gdimagepixelate.rakutest`](https://github.com/raku-community-modules/GD-Raw/blob/main/xt/gdimagepixelate.rakutest).

Pour `GD`, je n'ai rien trouvé.

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
[fichier `bug00191.rakutest`](https://github.com/raku-community-modules/GD-Raw/blob/main/xt/bug00191.rakutest)
que j'ai vu que l'on pouvait choisir l'épaisseur des traits.

D'un  autre côté,  la philosophie  de `GD::Raw`  étant de  rester très
proche de l'API C, la
[documentation de la bibliothèque C](https://libgd.github.io/pages/about.html)
pourra suffire pour ce module Raku.

Autre
-----

Comme cela sera rappelé dans quelques paragraphes, il faut disposer de la
[documentation _native call_](https://docs.raku.org/language/nativecall)
pour Raku.

Une méthode en vogue depuis quelques  années consiste à demander à une
intelligence  artificielle de  faire  les  recherches documentaires  à
notre place  et de nous expliquer  tout cela. Voire, d'écrire  à notre
place les lignes de code  nécessaires. Je n'utilise pas cette méthode,
je préfère lire et comprendre par moi-même la documentation.


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

* mon éditeur de source préféré (5 lettres, commence avec un « E », mais ce n'est pas `edlin`)

* gcc

* g++

* gitk (installe implicitement git)

* make

Pour le  cas des modules  Raku `GD`  et `GD::Raw`, j'installe  en plus
Raku, zef et  un clone du présent dépôt. Il  était dans mes intentions
de ne pas installer la bibliothèque  `libgd`. Or il se trouve que dans
la distribution Devuan version 6, `libgd3` version 2.3.3 est installée
par défaut. Peut-être n'est-ce pas le cas dans d'autres distributions.

Module Raku `GD:ver<0.0.2>` sur étagère
---------------------------------------

Un  simple `zef  install GD`  suffit, vraisemblablement  parce que  la
bilbiothèque `libgd3` est installée par  défaut. Conformément à ce que
j'ai   écrit  dans   le   recensement  des   besoins,  de   nombreuses
fonctionnalités manquent :

* génération des données PNG sans passer par un fichier,

* choix de l'épaisseur des traits

* définition d'un style pointillé ou avec des tirets,

* insertion de chaînes de caractères.

Module `GD::Raw:ver<0.4>` sur étagère
-------------------------------------

Un simple `zef install GD::Raw` suffit, vraisemblablement parce que la
bilbiothèque `libgd3` est installée par  défaut. Conformément à ce que
j'ai   écrit  dans   le   recensement  des   besoins,  de   nombreuses
fonctionnalités manquent :

* la fonction [`gdImagePngPtr`](https://libgd.github.io/manuals/2.3.0/files/gd_png-c.html#gdImagePngPtr)
permettant de récupérer les données PNG  pour les mettre en ligne
dans une balise HTML `<img>`,

* la fonction [`gdImageSetStyle`](https://libgd.github.io/manuals/2.3.0/files/gd-c.html#gdImageSetStyle)
et la  pseudo couleur `gdStyled`  permettant de définir des  lignes en
pointillés ou en tirets,

* les fonctions [`gdImageEllipse`](https://libgd.github.io/manuals/2.3.0/files/gd-c.html#gdImageEllipse)
et [`gdImageRectangle`](https://libgd.github.io/manuals/2.3.0/files/gd-c.html#gdImageRectangle)
permettant de dessiner  des contours d'ellipses et  de rectangles sans
remplir l'intérieur,

* la fonction [`gdImageString`](https://libgd.github.io/manuals/2.3.0/files/gd-c.html#gdImageString)
et les valeurs
[`gdTinyFont`](https://libgd.github.io/manuals/2.3.3/files/gdfontt-c.html),
[`gdSmallFont`](https://libgd.github.io/manuals/2.3.3/files/gdfonts-c.html),
[`gdMediumFontBold`](https://libgd.github.io/manuals/2.3.3/files/gdfontmb-c.html),
[`gdLargeFont`](https://libgd.github.io/manuals/2.3.3/files/gdfontl-c.html)
et [`gdGiantFont`](https://libgd.github.io/manuals/2.3.3/files/gdfontg-c.html)
permettant d'afficher des chaînes de caractères dans les dessins.

AMÉLIORATIONS DES MODULES
=========================

Module `GD::Raw:ver<0.5>` amélioré
----------------------------------

Il faut, bien entendu, cloner ou
[forker](https://github.com/jforget/GD-Raw)
le [dépôt Github](https://github.com/raku-community-modules/GD-Raw)
du module. Il faut également avoir à portée de main la
[documentation _native call_](https://docs.raku.org/language/nativecall)
et la
[documentation de l'implémentation C de GD](https://libgd.github.io/manuals/2.3.3/files/preamble-txt.html).

### Rectangles creux et ellipses creuses

Pour cette première fonctionnalité, c'est très facile. La signature de
[`gdImageEllipse`](https://libgd.github.io/manuals/2.3.3/files/gd-c.html#gdImageEllipse)
est identique à celle de
[`gdImageFilledEllipse`](https://libgd.github.io/manuals/2.3.3/files/gd-c.html#gdImageFilledEllipse),
il suffit donc d'un copier-coller. Idem pour
[`gdImageRectangle`](https://libgd.github.io/manuals/2.3.3/files/gd-c.html#gdImageRectangle)
vis-à-vis de
[`gdImageFilledRectangle`](https://libgd.github.io/manuals/2.3.3/files/gd-c.html#gdImageFilledRectangle).
C'est pour  cela que  les coordonnées du  centre s'appellent  `$cx` et
`$cy` et  non pas `$mx`  et `$my` comme  dans la
[spécification  de GD](https://libgd.github.io/manuals/2.3.3/files/gd-c.html#gdImageEllipse).
Par acquit de conscience, j'ai quand même jeté un coup d'œil à la
[documentation des appels de fonction](https://raku-knowledge-base.podlite.org/doc/language/nativecall#Passing-and-returning-values).

### Gestion de la mémoire

Lorsque j'ai découvert Perl en venant  de la programmation C, l'un des
points qui m'ont séduit était qu'il  n'y avait plus besoin de se faire
des nœuds au cerveau pour équilibrer les `malloc` et les `free`. Cf un
[article de Joel Spolsky](https://www.joelonsoftware.com/2004/06/13/how-microsoft-lost-the-api-war/)
(cherchez la  chaîne de caractères « A  lot of us thought »,  lisez le
paragraphe  correspondant  et  la  note  marginale  qui  suit).  C'est
toujours vrai avec la plupart des  programmes Raku, mais ce n'est plus
tout-à-fait vrai avec les programmes utilisant `GD::Raw`.

Lorsque j'ai recensé mes besoins  et que j'ai effectué une exploration
rapide de l'existant, j'ai recopié la ligne

```
LEAVE gdImageDestroy($im) if $im;
```

parce que  mon intuition me  disait que  c'était sans doute  une ligne
pour éviter les  fuites de mémoire. En revenant sur  le sujet avec mon
cerveau analytique,  je m'aperçois  qu'il faut  nuancer l'explication.
Cette ligne est adéquate dans  95% des cas (statistique pifométrique),
mais elle ne permettra pas de  résoudre les 5% restants.

Dans  l'explication qui  suit, je  suppose qu'il  existe deux  espaces
mémoire pour stocker  les données, un espace pour les  données Raku et
un  autre pour  les  données GD.  Les experts  et  les gourous  diront
peut-être que c'est une simplification abusive de la situation réelle,
mais d'un  point de vue  pédagogique, nous nous contenterons  de cette
description.

Supposons  que l'on  veuille créer  deux fichiers  graphiques avec  le
programme suivant :

```
{
  my $im = gdImageCreate($width, $height) or die;    # (a)
  LEAVE gdImageDestroy($im) if $im;                  # (b)
  my $white = gdImageColorAllocate($im, 0xff, 0xff, 0xff);
  my $red   = gdImageColorAllocate($im, 0xff, 0, 0);
  gdImageFilledEllipse($im, $cx, $cy, $r, $r, $red);
  my $fh = fopen("red-button.png", "wb");
  return 0 unless $fh;
  gdImagePng($img, $fh);
  flose($fh) if $fh;

  $im = gdImageCreate($width, $height) or die;       # (c)
  LEAVE gdImageDestroy($im) if $im;                  # (d)
  $white    = gdImageColorAllocate($im, 0xff, 0xff, 0xff);
  my $green = gdImageColorAllocate($im, 0, 0xff, 0);
  gdImageFilledEllipse($im, $cx, $cy, $r, $r, $green);
  $fh = fopen("green-button.png", "wb");
  return 0 unless $fh;
  gdImagePng($img, $fh);
  flose($fh) if $fh;
} # (e)
```

Vous pouvez remarquer que les  variables `$im`, `$white` et `$fh` sont
réutilisées dans la deuxième moitié.

La ligne (a)  a pour effet d'allouer une variable  `$im` dans l'espace
Raku  et  d'allouer  suffisamment  de mémoire  pour  _n_  pixels  dans
l'espace GD.  En outre, un test  pour vérifier que les  allocations se
sont bien  passées. La variable `$im`  sera automatiquement désallouée
au moment où elle quittera sa portée lexicale en (e).

La ligne (b)  a pour effet, théoriquement, de prévoir  que juste avant
la ligne  (e), il faudra  appeler la fonction  `gdImageDestroy` (après
avoir testé que ce soit nécessaire) pour désallouer la mémoire allouée
aux _n_ pixels dans l'espace mémoire de GD.

Pourquoi « théoriquement » ?  Parce que la ligne (c)  se conduit comme
un chien dans  un jeu de quilles. Dans l'espace  mémoire de Raku, elle
désalloue proprement la  valeur allouée à `$im`  pour immédiatement en
allouer une nouvelle.  Et dans l'espace mémoire de GD,  elle alloue de
la mémoire pour  les pixels du gros bouton vert  _sans avoir désalloué
la  mémoire des  pixels du  gros bouton  rouge_. La  mémoire Raku  est
correctement gérée, mais il y a une fuite de mémoire du côté de GD.

Et la ligne  (d) ? Comme la  ligne (b), elle est là  pour mémoriser le
fait  qu'il faut  lancer `gdImageDestroy`  au moment  où le  programme
abordera la ligne (e). Avec un test, bien entendu.

Au  passage  à   la  ligne  (e),  nous  aurons  donc   deux  appels  à
`gdImageDestroy` pour  désallouer l'espace  mémoire GD du  gros bouton
vert  et aucun  pour désallouer  l'espace  mémoire GD  du gros  bouton
rouge. Donc  dans le meilleur des  cas nous aurons juste  une fuite de
mémoire,  dans le  pire  des  cas nous  aurons  un  plantage du  genre
« _erreur de segmentation_ ».

Pour  vérifier mes  suppositions, j'ai  écrit des  programmes de  test
s'inspirant  des   scripts  présentés   ci-dessus.  Pour   évaluer  la
consommation de mémoire, il existe deux modules Raku :

* [`Linux::Proc::Statm`](https://raku.land/github:Skarsnik/Linux::Proc::Statm)
qui prend en paramètre un numéro de processus Linux,

* [`System::Stats::MEMUsage`](https://raku.land/github:ramiroencinas/System::Stats::MEMUsage)
qui ne prévoit pas de paramètre d'appel.

Je suppose  que le  deuxième module donne  la consommation  de mémoire
pour la machine  hôte dans sa totalité, alors que  le premier donne la
mémoire allouée  à un seul processus.  C'est donc `Linux::Proc::Statm`
qui répond à mes besoins.

Tels  qu'ils   sont  écrits,  les  programmes   `10-mem-leak-raku`  et
`11-mem-leak-raku` ne provoquent pas de  plantage ni de fuite mémoire.
Si  vous  masquez  certaines  lignes par  une  marque  de  commentaire
(dièse),  ou si  vous en  activez d'autres  en enlevant  la marque  de
commentaire, vous  pourrez reproduire  les problèmes. Mais  _ne faites
pas cela sur un serveur de production !_

L'état  de  référence de  la  mémoire  n'est  pas déterminé  avant  de
construire  la première  image, mais  après la  construction de  cette
première  image,  une fois  que  la  partie Raku  et  la  partie C  du
programme ont alloué leurs tampons respectifs.

### Utilisation de Git et Github

Un point acquis,  c'est qu'il faut _forker_ le
[dépôt  standard](https://github.com/raku-community-modules/GD-Raw)
vers un
[dépôt personnel](https://github.com/jforget/GD-Raw),
travailler sur son dépôt personnel et transmettre les modifications au
dépôt standard via une
[_pull request_](https://github.com/raku-community-modules/GD-Raw/pulls).

Ensuite, c'est  un peu plus  flou. Faut-il travailler dans  la branche
`main`  ?  Ou  bien  faut-il   créer  une  nouvelle  branche  pour  le
développement ? Ou  une branche pour chaque  fonctionnalité ajoutée ou
modifiée ?  J'ai commencé  par créer une  branche `circles-rectangles`
avec  l'idée  de  créer  ultérieurement  d'autres  branches  pour  les
fonctionnalités suivantes. Et j'ai créé une
[première _pull request_](https://github.com/raku-community-modules/GD-Raw/pull/2)
à partir de cette branche.

Puis j'ai changé d'avis et je me  suis dit que ce serait mieux d'avoir
une seule branche  `dev` pour les nouveautés. J'ai  renommé la
[branche de mon dépôt personnel](https://github.com/jforget/GD-Raw/branches)
en `dev` et, à ma surprise, cela a fermé automatiquement la PR que
j'avais créée juste avant. J'ai donc créé
[une nouvelle PR quasiment identique à la précédente](https://github.com/raku-community-modules/GD-Raw/pull/3).

En  raison   d'un  léger  problème,   la  PR  n'a  pas   été  intégrée
immédiatement dans  le dépôt  communautaire, il s'est  écoulé quelques
jours. Pendant ces quelques jours, j'ai
[ajouté un peu de documentation](https://github.com/raku-community-modules/GD-Raw/pull/3/changes/a91e977e0d7dfb64d06c2be7da9b4a81f5c7137b).
Et à ma surprise, la PR ouverte a hérité de cette modification. Il y a
des choses que je ne comprends pas dans le fonctionnement de Git et de
Github.

Lors de  mon travail sur `GD::Raw`,  je n'ai pas noté  les commandes à
passer pour  initialiser l'environnement de développement.  Je me suis
rattrapé lors de mon travail sur `GD`. Voir le
[paragraphe correspondant](https://github.com/jforget/raku-sandbox-GD/blob/master/Description.fr.md#utilisation-de-git-et-github-bis).

Module `GD::Raw:ver<0.6>` amélioré
----------------------------------

### Données PNG sans passer par un fichier

Alors que  les rectangles  creux et les  ellipses creuses  étaient une
promenade  de santé,  le  chargement  des données  en  mémoire est  un
problème   plus  ardu,   nécessitant   le  recours   continuel  à   la
documentation.

Tout d'abord, lorsque j'ai écrit les scripts d'exemple comme
[00-basic-lines.raku](https://github.com/jforget/raku-sandbox-GD/blob/d0c0438c6d8cb18b7c5f5df2ee580a49bebf4ca9/GD-Raw/00-basic-lines.raku)
avec en commentaires la récupération des données PNG, je croyais que la
[fonction `gdImagePngPtr`](https://libgd.github.io/manuals/2.3.3/files/gd_png-c.html#gdImagePngPtr),
s'utilisait comme
[`gdImagePng`](https://libgd.github.io/manuals/2.3.3/files/gd_png-c.html#gdImagePng)
en remplaçant le pointeur vers le _filehandle_ par un pointeur sur des
données binaires.

```
my $png-data;
gdImagePngPtr($im, pointeur vers $png-data);
my $src = MIME::Base64.encode($png-data);
print "<img src='data:image/png;base64,$src'/>";
```

En fait,  la fonction `gdImagePng`  ne renvoie absolument  rien, alors
que la fonction `gdImagePngPtr` renvoie, en théorie, deux valeurs : un
pointeur  sur les  données binaires  et la  taille de  ces données  en
octets. Conformément aux usages de  programmation en C, l'une des deux
valeurs est transmise dans la valeur de retour de la fonction, l'autre
est transmise par l'intermédiaire d'un pointeur sur une variable.

Le principe est donc :

```
my $size;
my $png-data = gdImagePngPtr($im, pointeur sur $size);
my $src = MIME::Base64.encode($png-data);
print "<img src='data:image/png;base64,$src'/>";
```

Le cas du paramètre `$size` est facile à régler. Dans la
[documentation des appels de bibliothèques C](https://raku-knowledge-base.podlite.org/doc/language/nativecall#Basic-use-of-pointers),
il est marqué qu'il faut définir ce paramètre comme `int32 is rw` dans
la signature de  la fonction. Pas besoin de recourir  à des références
(au sens Raku).

Le cas de `$png-data` est plus compliqué. Il faut en fait passer par un
pointeur `$ptr` comme indiqué dans
[ce paragraphe](https://raku-knowledge-base.podlite.org/doc/language/nativecall#Basic-use-of-pointers)
puis récupérer le contenu comme suggéré dans
[cet autre paragraphe](https://docs.raku.org/language/nativecall#Buffers_and_blobs),
ce qui nécessite le module
[`NativeHelpers::Blob`](https://github.com/salortiz/NativeHelpers-Blob).

Le principe est donc finalement :

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

Attention, il y a une
[erreur](https://github.com/salortiz/NativeHelpers-Blob/issues)
dans  la distribution  `NativeHelpers::Blob` version  0.1.12. Il  faut
utiliser le paramètre `--force-test` lors de l'installation par `zef`.

Personnellement, je n'ai  besoin que du format PNG.  Mais puisque j'ai
réussi  à  ajouter la  fonction  `gdImagePngPtr`,  autant ajouter  les
autres fonctions `gdImageXXXPtr`,  dans la mesure où cela  ne pose pas
de problème. Je n'ai toutefois par implémenté
[`gdImageGd2Ptr`](https://libgd.github.io/manuals/2.3.3/files/gd_gd2-c.html#gdImageGd2Ptr)
car je  ne comprends  pas en  quoi consistent  les paramètres  `cs` et
`fmt`. De même, je n'ai pas implémenté
[`gdImageHeifPtr`](https://libgd.github.io/manuals/2.3.3/files/gd_heif-c.html#gdImageHeifPtr)
ni [`gdImageHeifPtrEx`](https://libgd.github.io/manuals/2.3.3/files/gd_heif-c.html#gdImageHeifPtrEx)
car je ne comprend pas à  quoi correspondent les paramètres `codec` et
`chroma`.

Les tests  ont été générés  par le script  Perl `Perl/mk-test-ptr.pl`.
Comme  la bibliothèque  `libgd` de  ma  machine a  des problèmes  pour
générer les formats  GD, TIFF et WebP, ces formats  ne sont pas testés
dans le programme `xt/gdimagepngptr.rakutest`.

### Essai de mémorisation du style dans un fichier `toto.gd`

Un autre but de la version 0.6 est d'ajouter la notion de style de trait.
Avant de commencer à coder cela dans le module Raku, j'ai quelques
expériences à réaliser sur ce sujet.

L'idée est de tester si un premier programme peut créer une image avec
un style de trait, stocker cette image dans un fichier `toto.gd` et si
un second programme peut lire ce  fichier `toto.gd` et tracer un trait
utilisant ce style.  D'où les deux scripts  de tests `20-add-style.pl`
et `21-use-style.pl` dans le répertoire `Perl`.

L'expérience n'a pas pu avoir lieu. Alors que la
[documentation de `GD`](https://metacpan.org/pod/GD#Image-Data-Output-Methods)
indique qu'un objet image dispose des méthodes
[`gd`](https://metacpan.org/pod/GD#$gddata-=-$image-%3Egd)
et [`gd2`](https://metacpan.org/pod/GD#$gd2data-=-$image-%3Egd2),
la [documentation de `GD::Image`](https://metacpan.org/pod/GD::Image)
indique que les formats "Gd" et "Gd2" ne sont pas supportés.
En revenant à la documentation de `GD`, les commentaires des méthodes
[`newFromGd`](https://metacpan.org/pod/GD#$image-=-GD::Image-%3EnewFromGd($file)),
[`newFromGdData`](https://metacpan.org/pod/GD#$image-=-GD::Image-%3EnewFromGdData($data)),
[`newFromGd2`](https://metacpan.org/pod/GD#$image-=-GD::Image-%3EnewFromGd2($file))
et [`newFromGd2Data`](https://metacpan.org/pod/GD#$image-=-GD::Image-%3EnewFromGd2Data($data))
indiquent que les formats GD et GD2 ont été abandonnés avec la version 2.3.2 de `libgd`.

D'un autre côté, si l'on consulte la
[documentation](https://libgd.github.io/manuals/2.3.3/files/preamble-txt.html)
de la version 2.3.3 de la bibliothèque, on trouve bien une
[page](https://libgd.github.io/manuals/2.3.3/files/gd_gd-c.html)
pour le format GD et une
[autre](https://libgd.github.io/manuals/2.3.3/files/gd_gd2-c.html)
pour le  format GD2.  Dans chacune,  il est marqué  que le  format est
obsolète et  qu'il ne doit être  utilisé que pour du  développement et
des tests. Ça tombe  bien, c'est justement ce que je  suis en train de
faire.  Dommage   alors  que  Perl   ne  permette  pas  de   faire  du
développement et des tests !

### Test de capacité, avec un style très long

La plupart  du temps, on utilise  des styles très courts,  pour tracer
des pointillés  ou des  tirets. On  peut se  demander s'il  existe une
limite implicite  et ce  qui arrive  si l'on  utilise des  styles très
longs.

Pour caser une ligne très longue dans une image, j'ai eu recours à une
spirale. Pas  une spirale courbe,  comme d'habitude, mais  une spirale
anguleuse, construite avec  des segments de droite  dont les longueurs
croissent. Le style est basé sur la représentation binaire des nombres
de 0  à 255.  Chaque chiffre  « 0  »  apparaît sous  la forme  de deux
pixels  bleus, chaque  chiffre « 1 »  apparaît sous  la forme  de deux
pixels  rouges.  La  séparation   entre  deux  chiffres  binaires  est
constituée de deux pixels gris clair. La séparation entre deux nombres
(de 0 à 255)  contient un pixel noir. Avec 33  pixels par nombre, cela
donne un style gigantesque de 8481 pixels.

Le  résultat est  satisfaisant,  avec  une particularité  surprenante.
Lorsque le programme Perl trace une  ligne de droite à gauche, on peut
constater qu'en réalité  la bibliothèque `libgd` la trace  de gauche à
droite. C'est  la même chose  pour les lignes  tracées de bas  en haut
selon le  programme Perl,  mais tracées  de haut  en bas  par `libgd`.
Cette particularité se  manifeste aussi bien lorsque  l'on utilise des
méthodes  `line`  pour  tracer  la  spirale  (`22-long-style.pl`)  que
lorsque  l'on  crée  un  polygone  ouvert  pour  dessiner  la  spirale
(`23-style-polygon.pl`).

Une dernière variante, `24-rainbow.pl`, génère une image _True Color_,
c'est-à-dire une image contenant potentiellement plus de 256 couleurs.
Dans cet exemple, le style contient 765 couleurs.

### L'implémentation des styles

Un style  est un tableau  de couleurs. Chaque couleur  est représentée
par un indice  de 0 à 255 (cas  des images de type palette)  ou par un
entier encodant le triplet RGB (cas  des images de type _True Color_).
Mais le tableau n'est pas un tableau Raku ordinaire. Selon
[la documentation](https://docs.raku.org/language/nativecall#Arrays),
il faut  créer un  objet `CArray[int32]` et  l'associer à  la variable
avec « `:=` » et non pas « `=` ».

Quant  aux  pseudo-couleurs  `gdStyled` et  `gdTransparent`,  dans  la
version C  elles sont définies  avec le symbole  `gdAntiAliased`. Donc
dans la version Raku, je les définis au même endroit que ce symbole.

Le programme `25-mem-leak.raku` est  un amalgame de `10-mem-leak.raku`
et  de  `22-long-style.raku`. Son  but  est  d'évaluer les  pertes  de
mémoire lorsque l'on utilise des styles. Force est de constater que la
mémoire  est moins  bien  gérée  dans ce  nouveau  programme que  dans
`10-mem-leak.raku`.   Cela  dit,   lorsque   je   masque  l'appel   de
`gdImageSetStyle` avec un dièse, ou  lorsque je masque cet appel ainsi
que  la   construction  du  `CArray`,  j'obtiens   le  même  résultat.
L'augmentation  progressive  de  la  mémoire utilisée  est  donc  due,
vraisemblablement à la construction du tableau Raku `@style`, pas à la
construction du tableau C `@style-c`.

Cette supposition est confirmée  avec le programme `26-mem-leak.raku`,
qui construit le  tableau Raku `@style` en dehors de  la double boucle
et  qui conserve  à  l'intérieur  de la  double  boucle uniquement  la
construction  du   tableau  C  `@style-c`  et   son  utilisation  dans
`gdImageSetStyle`. La  quantité de  mémoire utilisée  augmente encore,
mais de  façon beaucoup  plus modérée.  Je suppose  donc que  c'est le
fonctionnement  normal de  l'interpréteur  `raku` et  pas le  symptôme
d'une fuite de mémoire.

Si l'on extrait la construction de `@style-c` de la double boucle pour
la placer juste avant, la consommation de mémoire augmente encore plus
lentement, quelques octets à chaque affichage.

Module `GD::Raw:ver<0.7>` amélioré
----------------------------------

### Chaînes de caractères

Mes besoins  pour dessiner  des graphes sont  très réduits.  Il s'agit
uniquement d'afficher  les codes  des sommets du  graphe. Ce  sont des
codes, même pas des  libellés. Donc de l'ASCII à 7  bits, même pas des
caractères accentués. La seule  fonctionnalité avancée que j'aurais pu
utiliser est l'affichage vertical  (méthode `stringUp`) pour l'échelle
de la  carte. Je n'y ai  pas pensé à  l'époque. Lors de la  refonte du
module Raku de dessin, j'y penserai.

Pour la police de caractères, j'ai  fait au plus simple, j'ai pris les
fontes  internes,  `gdGiantFont`,  `gdLargeFont`,  `gdMediumBoldFont`,
`gdSmallFont` et `gdTinyFont` et je n'ai pas cherché plus loin.

Si j'ai considéré que je pouvais utiliser de l'ASCII 7-bits, il s'agit
réellement d'un encodage à 8 bits,  ISO-8859-2. Donc si je transmets à
la méthode  `string` une chaîne  UTF-8 contenant un « é »,  je n'aurai
pas le _mojibake_ habituel « Ã© », mais « ĂŠ ».

Dans un vieux
[compte-rendu](http://paris.mongueurs.net/meetings/2004/0211.html)
de réunion des Mongueurs de Paris, j'ai inséré deux graphiques générés
avec  `GD.pm`  et  comportant  des légendes  telles  que  « Étudiantes
diplômées ».  En réalité,  j'ai  appelé la  méthode  `string` avec  la
légende sans  accent, « Etudiantes  diplomees », puis j'ai  ajouté les
accents aigus avec la méthode `line`.  J'ai eu la flemme d'ajouter les
accents  circonflexes sur  les  « o ». Dans  un  deuxième temps,  j'ai
appelé la méthode `stringFT` présentée ci-dessous.

Il est possible d'utiliser d'autres fontes. Ainsi qu'il est marqué dans la
[documentation de `GD.pm`](https://metacpan.org/pod/GD#Character-and-String-Drawing),
vous   pouvez  prendre   une  fonte   `xxx.bdf`,  la   convertir  avec
l'utilitaire `bdf2gd.pl`  en `xxx.fnt` et l'utiliser  pour écrire dans
un dessin  GD. Pour le  développeur et  le mainteneur du  module, cela
requiert la définition d'une classe représentant la
[structure `gdFont`](https://libgd.github.io/manuals/2.3.3/files/gd-h.html#gdFontPtr).
Dans un  premier temps, je n'en  tiendrai pas compte pour  les modules
Raku `GD` et `GD::Raw`.

Nous  pouvons remarquer  que  dans la  documentation  de `GD.pm`,  cet
utilitaire  de conversion  s'appelle  `bdf2gd.pl`, tandis  que sur  ma
machine, le répertoire `/usr/bin` contient un utilitaire `bdf2gdfont`,
généré   par  l'utilitaire   de  configuration   `bdf2gdfont_pl.PL`  à
l'installation de `GD.pm`. Et par-dessus tout cela, le
[sous-répertoire `bdf_scripts`](https://github.com/lstein/Perl-GD/tree/master/bdf_scripts)
du [dépôt Github](https://github.com/lstein/Perl-GD/tree/master)
contient une version plus ancienne et plus simple appelée `bdftogd`.

La documentation de `libgd` prévoit des chaînes où les caractères sont
encodés sur 16 bits. Voir les fonctions
[`gdImageString16`](https://libgd.github.io/manuals/2.3.3/files/gd-c.html#gdImageString16)
et [`gdImageStringUp16`](https://libgd.github.io/manuals/2.3.3/files/gd-c.html#gdImageStringUp16).
Ces fonctions n'ont pas été reprises dans le module Perl `GD.pm` et le
site  de `libgd`  ne propose  pas de  telles fontes.  Expérimenter ces
fonctions  me prendrait  trop de  temps  pour un  bénéfice minime.  Je
laisse  donc  tomber ces  fonctions  dans  les  modules Raku  `GD`  et
`GD::Raw`.

Pour   aller  plus   loin,   la  documentation   de  `libgd`   prévoit
l'utilisation de
[fontes _Free Type_](https://libgd.github.io/manuals/2.3.3/files/gdft-c.html)
avec les fonctions
[`gdImageStringFT`](https://libgd.github.io/manuals/2.3.3/files/gdft-c.html#gdImageStringFT)
et [`gdImageStringFTEx`](https://libgd.github.io/manuals/2.3.3/files/gdft-c.html#gdImageStringFTEx).
La documentation de `GD.pm` prévoit quant à elle l'utilisation de
[fontes _True Type_](https://metacpan.org/pod/GD#Character-and-String-Drawing)
avec la méthode `stringFT`. Je suppose  qu'il s'agit de la même chose.
Si la mise en œuvre de cette fonctionnalité est simple, je l'ajouterai
aux  modules Raku  `GD`  et  `GD::Raw`. Si  cette  mise  en œuvre  est
compliquée  (ajout d'une  nouvelle classe,  description en  Raku d'une
structure  C),  alors  je  laisse  la  patate  chaude  à  un  éventuel
volontaire.

Toutefois,  comme cette  fonctionnalité nécessite  l'utilisation d'une
fonte système, provenant  d'un répertoire système, il n'y  aura pas de
test  `t/xxx.rakutest` ni  même `xt/xxx.rakutest`.  En effet,  rien ne
m'assure que  sur les  machines Unix  des prochains  contributeurs, le
même  répertoire existe  et contient  les  mêmes fichiers  que sur  ma
machine  personnelle.  Quant  aux contributeurs  travaillant  sur  une
machine Windows...

La [documentation de `GD.pm`](https://metacpan.org/pod/GD)
mentionne une
[méthode `stringFTCircle`](https://metacpan.org/pod/GD#$result-=-$image-%3EstringFTCircle($cx,$cy,$radius,$textRadius,$fillPortion,$font,$points,$top,$bottom,$fgcolor)).
La [documentation de `libgd`](https://libgd.github.io/manuals/2.3.3/files/gdft-c.html)
ne  décrit  pas  de  fonction  similaire.  Et  de  toutes  façons,  la
documentation Perl  précise que  la fonction C  ne fonctionne  pas. Je
fais l'impasse sur  cette fonction dans les modules Raku.  Le test est
fait dans  le dossier  `Perl` du bac  à sable et  vous pouvez  voir le
résultat par vous-mêmes.

### Après l'ajout des chaînes de caractères

Pour les fontes internes `gdGiantFont` et similaires, le
[module Perl `GD.pm`](https://metacpan.org/pod/GD#Character-and-String-Drawing)
indique  qu'il  faut  utiliser  un  objet  de  classe  `GD::Font`.  En
cherchant  dans les  fichiers  sources  Perl, je  n'ai  pas trouvé  la
définition de cette classe. Peut-être est-elle définie uniquement dans
[le fichier XS](https://github.com/lstein/Perl-GD/blob/master/GD.xs),
mais  encore faudrait-il  que  je comprenne  comment fonctionne  XS...
Quant à regarder dans la
[documentation de `libgd`](https://libgd.github.io/manuals/2.3.3/files/gd-c.html#gdImageString),
je constate qu'il faut passer par un
[pointeur `gdFontPtr`](https://libgd.github.io/manuals/2.3.3/files/gd-h.html#gdFontPtr)
pointant  vers une  structure `gdFont`.  J'ai  utilisé à  la place  un
`OpaquePointer`, sans décrire la structure sous-jacente.

Dans la
[documentation de `NativeCall`](https://docs.raku.org/language/nativecall#Passing_and_returning_values),
il est marqué que l'on peut préciser l'encodage d'une chaîne transmise
en paramètre à une fonction ainsi que pour une chaîne renvoyée par une
fonction. Le seul encodage donné  en exemple est `is encoded('utf8')`.
J'ai essayé  de spécifier un encodage  `is encoded('iso-8859-2')` pour
les  chaînes en  paramètres de  `gdImageString` et  `gdImageStringUp`,
mais cela ne  fonctionne pas. J'ai essayé quelques  variantes (avec ou
sans tirets),  je n'ai pas plus  réussi. Le paramètre chaîne  est donc
déclaré sans encodage.

Omettre les tests de
[`gdImageStringFT`](https://libgd.github.io/manuals/2.3.3/files/gdft-c.html#gdImageStringFT),
est malvenu.  Parce que la fonction  n'est pas testée, bien  sûr, mais
aussi parce les utilisateurs du module ne disposeront pas d'un exemple
concret d'utilisation de  cette fonction. J'ai écrit plus  haut que je
n'écrirais pas de  script de test car je n'avais  aucune certitude sur
les  fichiers   TTF  disponibles   sur  les  machines   des  prochains
contributeurs.  Heureusement,  j'ai trouvé  la  solution.  En plus  du
fichier PNG  attendu, le répertoire  de test doit contenir  un fichier
TTF contenant  la fonte à  utiliser. Nouveau problème, où  trouver une
fonte  TTF que  je puisse  dupliquer et  diffuser sans  enfreindre les
conditions  d'utilisation  ? Solution  :  ne  pas utiliser  une  fonte
existante, mais en créer une à partir de rien. J'ai donc installé
[Font Forge](https://fontforge.org/en-US/)
et j'ai créé une  fonte de toutes pièces. J'ai fait  au plus vite sans
me soucier d'esthétique. En m'inspirant du
[code Morse](https://www.dcode.fr/code-morse),
j'ai  pu créer  des glyphes  contenant uniquement  des points  (ovales
plutôt  que circulaires)  et des  traits (verticaux  pour un  problème
d'encombrement). Les dimensions  des divers traits et  points et leurs
emplacements  respectifs  ne sont  pas  harmonisés.  Les glyphes  sont
définis  uniquement  pour l'espace  et  les  7  lettres de  la  chaîne
« `Hello world` ».

Quand je consulte la
[documentation](https://libgd.github.io/manuals/2.3.3/files/gdft-c.html#gdImageStringFT)
de la fonction C `gdImageStringFT`, je lis ceci :

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

Traduction

> `brect`  le  rectangle délimitant  la  chaîne,  sous la  forme  d'un
> tableau  de   8  entiers;  Chaque  paire   d'entiers  représente  la
> coordonnée  x puis  la coordonnée  y d'un  sommet du  rectangle. Ces
> sommets  sont,  dans l'ordre,  le  coin  inférieur gauche,  le  coin
> inférieur  droit,  le coin  supérieur  droit  et le  coin  supérieur
> gauche.

Et quand je lis la
[documentation](https://metacpan.org/pod/GD#@bounds-=-$image-%3EstringFT($fgcolor,$fontname,$ptsize,$angle,$x,$y,$string))
de la méthode correspondante dans le module Perl, je lis :

```
@bounds = $image->stringFT($fgcolor,$fontname,$ptsize,$angle,$x,$y,$string)
```

Où est passé le paramètre `brect` ? Jetons maintenant un coup d'œil au
[fichier source `GD.xs`](https://github.com/lstein/Perl-GD/blob/master/GD.xs).
Hormis  l'appel de  la fonction  `gdImageStringFT` et  de la  fonction
`gdImageStringFTEX`, la seule fois où la variable `brect` est utilisée
se situe dans ce pavé de code :

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

Je ne suis pas un expert en langage  XS, mais je devine ce dont il est
question. Il s'agit  d'alimenter les valeurs renvoyées  par la méthode
`stringFT` au programme  Perl appelant. Donc le  tableau `brect` n'est
pas un paramètre  d'appel de `gdImageStringFT`, mais  le pointeur vers
des valeurs renvoyées  par cette fonction. Il est  possible de manquer
cette interprétation avec une lecture  rapide de la documentation C et
de la documentation Perl.

En  fait,  j'aurais pu  lire  plus  attentivement  le module  Perl  et
remarquer le début de la ligne d'appel :

```
@bounds = ...
```

Ainsi qu'il est expliqué dans la
[documentation de native call](https://docs.raku.org/language/nativecall#Arrays),
il faut allouer de la place  pour 8 entiers. Le paramètre `brect` sera
donc déclaré ainsi :

```
my @brect := CArray[int32].new;
@brect[7] = 0; # to allocate room for 8 integers
```

Également, la gestion des erreurs  est essentielle. Il est tout-à-fait
possible que l'utilisateur fasse une faute  de frappe en tapant le nom
ou le  répertoire de la  fonte qu'il demande.  Dans ce cas,  le module
doit lui transmettre l'erreur détectée par `libgd`.

Pour tester la  fonction `gdImageStringFT`, j'ai écrit  un script Perl
`mk-test-ttf.pl` pour construire  le fichier PNG attendu.  Or, le test
`xt/gdimagestringft.rakutest` détecte de nombreux pixels de différence
entre le fichier attendu et  l'image obtenue. Or lorsque l'on consulte
les fichiers  graphiques, on constate qu'ils  se ressemblent beaucoup.
Dans un  premier temps j'ai utilisé  le fichier obtenu avec  le script
Raku  en  tant que  fichier  attendu.  Dans  un deuxième  temps,  j'ai
découvert que l'on pouvait désactiver l'anti-aliasing en attribuant un
signe "moins" au  numéro de couleur. J'ai  désactivé l'anti-aliasing à
la fois dans `mk-test-ttf.pl` et dans `xt/gdimagestringft.rakutest` et
cela   fonctionne   bien   en   utilisant  le   fichier   généré   par
`mk-test-ttf.pl`.

Ces précautions n'ont pas été suffisantes pour faire passer la
[_pull request_](https://github.com/raku-community-modules/GD-Raw/pull/6).
du  4 juin.  En raison  de minimes  différences de  positionnement des
caractères, certains  pixels sont blancs  dans une version  du fichier
graphique et noirs dans l'autre version. J'ai donc adapté le script de
test `gdimagestringft.rakutest` pour admettre  qu'un pixel à la limite
entre une  zone blanche et  une zone noire  puisse être blanc  dans un
fichier et noir dans l'autre.

J'ai également porté les fonctions traitant le cache pour les fontes,
[`gdFontCacheSetup`](https://libgd.github.io/manuals/2.3.3/files/gdft-c.html#gdFontCacheSetup)
et [`gdFontCacheShutdown`](https://libgd.github.io/manuals/2.3.3/files/gdft-c.html#gdFontCacheShutdown).
À vrai dire, je ne suis pas sûr  de la façon dont il faut utiliser ces
fonctions. Pour
[`gdImageDestroy`](https://libgd.github.io/manuals/2.3.3/files/gd-c.html#gdImageDestroy)
et [`gdFree`](https://libgd.github.io/manuals/2.3.3/files/gdhelpers-c.html),
il  s'agit de  désallouer  des  tampons dont  on  n'a clairement  plus
besoin. Ici, il s'agit d'un cache mémorisant les fontes qui pourraient
être  réutilisées.  Néanmoins, j'estime  qu'il  faut  les porter  dans
`GD::Raw` si la fonction `gdImageStringFT` est portée.

Voici les fonctions qui n'ont pas été adaptées pour Raku :

* `gdImageChar`  et  `gdImageCharUp`,  parce  que  `gdImageString`  et
  `gdImageStringUp` font l'affaire.

* `gdImageString16`  et `gdImageStringUp16`,  parce  que  je n'ai  pas
  d'exemple de fichier fonte avec un encodage sur 16 bits et parce que
  `gdImageStringFT`  permet d'accéder  à  la  totalité des  caractères
  Unicode au lieu de seulement 65536 caractères.

* `gdImageStringFTEx`   parce  qu'il   faut   décrire  une   structure
  `gdFTStringExtra`  dans le  module Raku  et que  je préfère  laisser
  cette tâche à un successeur.

* `gdFreeFontCache`   parce  que   c'est  seulement   un  alias   pour
  `gdFontCacheShutdown`.

Module `GD:ver<0.0.3>` amélioré
-------------------------------

### Utilisation de Git et Github (bis)

Commencer par « forker » le
[répertoire communautaire](https://github.com/raku-community-modules/GD)
en  cliquant sur  le bouton  comportant un  symbole de  branche et  la
mention  `Fork`.  Puis renseigner  tout  ce  qu'il faut  et  confirmer
l'opération.

Pour créer une branche, je l'ai fait sur
[mon dossier Github](https://github.com/jforget/GD/) :

* cliquer sur le bouton comportant un symbole de branche, ainsi que le
  nom de la branche courante `master`

* taper  le nom  de la  nouvelle branche  « `dev` » dans  le champ  de
  recherche  (symbole  de  loupe,  mention  « Find  or  create  a  new
  branch... »).

Puis les lignes de commande suivantes en local :

```
git clone https://github.com/jforget/GD.git
cd GD
git branch -a
git checkout dev
```

et à l'avenir

```
git push -u --tags origin dev
```

### Remise à neuf

Évidemment, il faut commencer par  incrémenter le numéro de version de
`0.0.2` à `0.0.3`.

Je profite de ce changement de version pour éliminer les extensions de
fichier  rappelant Perl  :  `.pm`,  `.pl`, `.pod`  et  `.t`, pour  les
remplacer par les extensions spécifiques à Raku : `.rakumod`, `.raku`,
`.rakudoc` et `.rakutest`. Également, la mention de la licence ne doit
plus faire référence  à Perl, mais à la licence  artistique. Cela dit,
je n'ai pas osé la mention de Perl 6 dans le fichier `META6.json`.

Plus quelques opérations disparates, remplacer les tabulations par des
espaces et  enlever les  espaces en  fin de ligne.  Ce n'est  pas fait
partout, mais c'est déjà un début.

### Données PNG (ou autres) sans passer par un fichier

Avant mon intervention, le module `GD` faisait appel au module
[`NativeHelpers::Array`](https://raku.land/zef:jonathanstowe/NativeHelpers::Array).
Lorsque j'ai adapté `GD::Raw`, j'ai ajouté le module
[`NativeHelpers::Blob`](https://raku.land/github:salortiz/NativeHelpers::Blob)
car la
[documentation de native call](https://docs.raku.org/language/nativecall#Buffers_and_blobs)
pointait  vers  cet autre  module.  Y  aurait-il eu  moyen  d'utiliser
`NativeHelpers::Array` à la place ? J'ai essayé et je n'ai pas réussi.
Donc `GD` devra utiliser les deux modules.

En version  0.0.2, les types  de fichier disponibles pour  stocker une
image étaient GIF, JPEG et PNG.  Dans `GD::Raw`, j'ai prévu de générer
des blobs  pour ces trois  formats, plus BMP,  GD, TIFF et  WEBP. J'ai
repris tous  ces formats pour la  génération de blobs dans  la version
0.0.3 de `GD`.

### Documentation

J'avoue que je ne comprends pas très bien comment la communauté Raku a
organisé la documentation du module.

Je ne suis pas  dérangé par le fait que la  documentation soit dans un
fichier `.pod` ou `.rakudoc` séparé du source du module (fichier `.pm`
ou `.rakumod`). Ce n'est pas un problème.

En  revanche, il  y a  un problème  dans la  mesure où,  en dehors  du
synopsis, cette documentation se contente de lister les méthodes, sans
aucune précision  sur l'utilité de  la méthode ou sur  ses paramètres.
J'ai donc  ajouté le nom  des méthodes que  j'ai codées, avec  le même
laconisme.  Ce  n'est  pas  satisfaisant,  mais  c'est  cohérent  avec
l'existant.

Un autre problème,  c'est le fichier `TODO`. Contrairement  à son nom,
ce  fichier  énumère les  fonctions  de  `libgd`  qui ont  *déjà*  été
reprises dans le module Raku. Ce fichier comporte une légende avec des
codes  indiquant  si  telle  ou  telle  entrée  est  implémentée,  est
documentée, dispose d'un test ou dispose d'un exemple. Je ne comprends
pas pourquoi  les fonctions de `libgd`  nécessitent une documentation,
étant donné qu'elles sont nécessairement  des fonctions de bas niveau,
Toujours est-il que, comme pour la documentation POD, j'ai complété le
fichier  à  l'identique  avec  les   fonctions  de  `libgd`  que  j'ai
utilisées.  Encore une  fois, ce  n'est pas  satisfaisant, mais  c'est
cohérent.

Une autre façon de documenter un  module, c'est de donner des exemples
d'utilisation. Il y a les scripts de tests dans le sous-répertoire `t`
et il  y a des  scripts d'exemple dans le  sous-répertoire `examples`.
C'est une bonne idée. En temps utile, je recopierai les exemples de ce
dépôt dans le sous-répertoire `examples` de ce module. Également, j'ai
ajouté un sous-répertoire `xt` pour les tests avancés.

### Rectangle

Après les méthode `png` et  similaires, la nouvelle fonctionnalité que
je  voulais  ajouter, c'était  le  choix  de l'épaisseur  des  traits,
mathode `setThickness`.

Lors de la  rédaction des tests pour la méthode  `setThickness`, je me
suis aperçu d'un problème lors  du dessin des rectangles. Le paramètre
`size`,  contrairement à  son nom,  contient les  coordonnées du  coin
inférieur  droit du  rectangle.  Ce  problème a  déjà  été constaté  à
l'occasion du
[problème 14](https://github.com/raku-community-modules/GD/issues/14).
Donc  je  corrige  ce  problème  14 en  même  temps  que  j'implémente
l'épaisseur des traits. J'ai fait d'une pierre deux coups.

J'aurais pu  supprimer le  paramètre `size` pour  le remplacer  par un
paramètre `alt-location` permettant de donner le coin inférieur droit.
J'ai   préféré   conserver  le   mot-clé   `size`   et  restaurer   sa
signification.  Puis  j'ai  partiellement  changé  d'avis.  Je  laisse
choisir l'utilisateur pour adopter le paramètre `size` ou le paramètre
`alt-location`,  selon   son  humeur   du  moment.  C'est   bien,  les
multi-méthodes !

Comme dit le proverbe, il y a trois gros problèmes en programmation :

* l'encodage des caractères,
* l'invalidation des données en cache,
* les règles de nommage,
* les décalages de 1.

Et un  décalage de 1  s'est glissé dans l'implémentation  du paramètre
`size` de la méthode `rectangle`.

Si un utilisateur demande un rectangle situé  en `x1 = 10, y1 = 10` et
de taille `(20, 10)`, alors dans  la première version que j'ai écrite,
la méthode détermine que le coin  opposé du rectangle se trouve en `x2
= 30, y2 = 20`. Et cela fait  un rectangle de largeur 21 et de hauteur
11.  En   effet,  si  les   points  géométriques  sont   des  « objets
géométriques  sans dimension »,  les  pixels ont  une  largeur et  une
hauteur. De x1 =  10 jusqu'à x2 = 30, on compte donc  21 pixels et non
pas 20.  Idem en  hauteur, de y1  = 10  jusqu'à y2 =  20 on  compte 11
pixels et non pas 10.

Tant que  j'y suis, j'ajoute  une troisième variante pour  dessiner un
rectangle, en positionnant  le centre du rectangle au  lieu d'un coin.
Au lieu d'un paramètre `size` pour préciser la taille du rectangle, je
donne  un  paramètre `half-size`.  Il y  a deux
raisons pour le choix du mot-clé `half-size`. D'une part, il n'y a pas
de problème de  reste de division par 2, d'autre  part, cela simplifie
l'aiguillage des multi-méthodes, le paramètre `size` étant utilisé dans
une seule méthode (tout comme `half-size` et `alt-location`).

Un peu plus de  détails sur le problème de la division  par 2. Si l'on
demande

```
$im.rectangle( center    => (20, 15)
             , half-size => (10, 5)
             );
```

il n'y a aucune ambiguïté  pour deviner que l'intervalle des abscisses
sera 10..30 pour  une largeur de 21 et que  l'intervalle des ordonnées
sera  10..20  pour  une  hauteur  de 11.  En  d'autres  termes,  c'est
équivalent à l'un des deux appels

```
$im.rectangle( location     => (10, 10)
             , alt-location => (30, 20)
             );
$im.rectangle( location => (10, 10)
             , size     => (21, 11)
             );
```

et à la solution qui n'a pas été retenue :

```
$im.rectangle( center => (20, 15)
             , size   => (21, 11)
             );
```

Mais  si l'on  avait utilisé  le  paramètre `size`  avec le  paramètre
`center` et que l'on avait indiqué des tailles paires, comme :

```
$im.rectangle( center => (20, 15)
             , size   => (20, 10)
             );
```

après avoir  mis de côté le  pixel pour le centre  (horizontalement et
verticalement),  comment  faudrait-il  répartir  en  deux  moitiés  la
largeur impaire restante  et la hauteur impaire restante  ? Lequel des
deux appels ci-dessous faudrait-il privilégier ?

```
$im.rectangle( location     => (10, 10)
             , alt-location => (29, 19)
             );
$im.rectangle( location     => (11, 11)
             , alt-location => (30, 20)
             );
```

Module `GD:ver<0.0.5>` amélioré
-------------------------------

### Utilisation de Git et Github (ter)

Ce  n'est  pas moi  qui  ai  écrit la  version  0.0.4,  mais c'est  la
« communauté Raku » (en fait, Liz).  Donc, la version que je développe
est la version 0.0.5.

Si j'ai fait une légère remise à neuf en version 0.0.3 (changement des
extensions  de fichiers),  la  version 0.0.4  a  été l'occasion  d'une
grosse  remise à  neuf avec  de  nouveaux répertoires  et de  nouveaux
fichiers, plus  la suppression  de quelques fichiers  périmés. J'avais
déjà commencé à  travailler sur l'ajout de chaînes  de caractères dans
les images.  Si je tentais  de fusionner  la branche `master`  avec ma
branche `dev`, il risquerait d'y avoir un nombre important de conflits
de fusion. J'ai donc préféré créer une nouvelle branche `dev1`.

Sur [mon dossier Github](https://github.com/jforget/GD/) :

* sélectionner la branche `master`

* cliquer sur le bouton _sync fork_ puis sur _update branch_.

* cliquer sur le bouton comportant un symbole de branche, ainsi que le
  nom de la branche courante `master`

* taper le  nom de  la nouvelle  branche « `dev1` »  dans le  champ de
  recherche  (symbole  de  loupe,  mention  « Find  or  create  a  new
  branch... »).

Puis les lignes de commande suivantes en local :

```
cd GD
git checkout dev
cd ..
mv GD GD-dev
git clone https://github.com/jforget/GD.git
cd GD
git branch -a
git checkout dev1
```

De la sorte, j'ai en parallèle  un premier répertoire `GD-dev` avec le
travail que j'ai  déjà fait sur l'ajout de chaînes  de caractères dans
les images et un second répertoire `GD` où je travaillerai et à partir
duquel je pourrai soumettre une nouvelle _pull request_.

Il faut juste que je pense dorénavant à taper :

```
git push -u --tags origin dev1
```

Avec la refonte, sont apparus  quelques actions de CI/CD. Le principal
effet de ces actions est de  m'envoyer tout plein de messages à chaque
`push`, pour  m'indiquer que cela ne  fonctionne pas sur Macos  et sur
Windows.  Comme je  ne  peux rien  faire  sur le  sujet  et comme  ces
messages encombrent ma boîte de  messagerie, je les désactive. Cela se
fait sur Github :

* Sur la  ligne _Code  - Pull  Requests -  ... Settings_,  cliquer sur
  _Settings_.

* Sur le menu de gauche, cliquer sur _Actions → General_

* Cliquer sur _Disable actions_

* Cliquer sur _Save_

### Insertion de chaînes de caractères

Pour les  cinq fontes  internes GD, je  voulais utiliser  des méthodes
`GD::giant-font`.   J'ai  fait   quelques  tentatives,   notamment  en
déclarant que `GD`  n'est pas un `module`, mais une  `class`. Cela n'a
pas réussi. J'ai  donc déclaré ces cinq fontes en  tant que fonctions.
J'ai  priviligié  le   _kebab  case_  plutôt  que   le  _camel  case_,
`GD-small-font` plutôt que `GDSmallFont`.

AUTEUR
======

Jean Forget / J2N-FORGET at orange dot fr

COPYRIGHT ET LICENCE
====================

Copyright (c) 2026 Jean Forget, tous droits réservés.

Les  programmes et  fontes sont  diffusés avec  la licence  **Artistic
License 2.0**. Voir le texte (en anglais) dans `LICENSE`.

Les divers textes  et images de ce dépôt sont  publiés avec la licence
Creative Commons : Attribution - Partage dans les Mêmes Conditions (CC
-SA ).

