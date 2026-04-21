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
my $ptr  = gdImagePngPtr($im, $size);
my $blob = blob-from-pointer($ptr, elems => $size, type => Blob[int8]);
my $src  = MIME::Base64.encode($png-data);
print "<img src='data:image/png;base64,$src'/>";
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

Module `GD::Raw:ver<0.7>` amélioré
----------------------------------

Le but de la version 0.7 est d'ajouter la notion de style de trait.
Avant de commencer à coder cela dans le module Raku, j'ai quelques
expériences à réaliser sur ce sujet.

### Mémorisation du style dans un fichier `toto.gd`

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
pixels bleus,  chaque chiffres  « 1 » apparaît sous  la forme  de deux
pixels  rouges.  La  séparation   entre  deux  chiffres  binaires  est
constituée de deux pixels gris clair. La séparation entre deux nombres
(de 0 à 255)  contient un pixel noir. Avec 33  pixels par nombre, cela
donne un style gigantesque de 8481 pixels.

Le  résultat est  satisfaisant,  avec  une particularité  surprenante.
Lorsque le programme Perl trace une  ligne de droite à gauche, on peut
constater qu'en réalité  la bibliothèque `libgd` la trace  de gauche à
droite. C'est  la même  chose pour  les lignes tracées  de bas  en bas
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
`10-mem-leak.raku`.  Je ne  sais pas  comment remédier  à cet  état de
fait.  D'un   autre  côté,  gardons   à  l'esprit  que   le  programme
`25-mem-leak.raku` utilise un style  de plusieurs milliers d'éléments,
tandis  que les  programmes ordinaires  utilisent des  styles avec  un
nombre nettement réduit de pixels.

AUTEUR
======

Jean Forget / J2N-FORGET at orange dot fr

COPYRIGHT ET LICENCE
====================

Copyright (c) 2026 Jean Forget, tous droits réservés.

Les programmes sont diffusés avec la licence **Artistic License 2.0**.
Voir le texte (en anglais) dans `LICENSE`.

Les divers textes  et images de ce dépôt sont  publiés avec la licence
Creative Commons : Attribution - Partage dans les Mêmes Conditions (CC
BY-SA ).

