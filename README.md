# DM-d-ASR

Pour plus d'informations sur les conventions adoptées pour l'implémentation de certaines instructions, voir le fichier remarques.txt.
Il est pratique de pouvoir écrire un bit à une adresse repérée par sa position dans la mémoire et non par la valeur d'un compteur. La fonction write\_bit\_addr sert ce but. Elle est utilisée pour gérer les entrées clavier dont les informations sont stockées après la table ascii.
Voici par ailleurs la disposition de la mémoire: programme chargé, puis écran, puis table ascii, puis clavier, puis espace de travail (pile, mais qui commence en fin de mémoire).

Il restait de la place dans l'ISA pour 3 instructions (1111101, 1111110 et 1111111).
L'instruction 1111101 a été utilisée pour générer un nombre aléatoire et le stocker dans un registre (ce nombre est un entier compris entre 0 et une borne à spécifier).
L'instruction 1111110 a été utilisée pour mettre le processeur en pause pendant un nombre de millisecondes à spécifier.

En ce qui concerne les _labels_, les tailles des constantes sont optimales et obtenues en seulement deux passes (elles sont calculées entre la première et la deuxième passe à l'aide d'informations collectées pendant la première passe).

Nous avons rajouté une option `--stats` lors de l'exécution de `simu` qui affiche à la fin de l'exécution, pour chaque instruction de l'isa, le pourcentage de fois que cette opération a été exécutée par le processeur pendant l'exécution du fichier.
Lorsqu'un `jump -13` est détecté, le processeur virtuel se ferme (Le fichier processeur.cpp exécute `exit(EXIT_SUCCESS)`).

----------------------------------------------------------------------
Undertale
----------------------------------------------------------------------

Un mini-jeu du genre _bullet hell_ est disponible. Ce mini-jeu est très largement inspiré du corps des combats du jeu Undertale (un jeu sorti en fin 2015 qui a été très apprécié dès sa sortie). 
Je vous encourage à aller voir cette [courte vidéo](https://www.youtube.com/watch?v=rJhX_-X6atk) (de 40s) pour avoir la référence.
Pour le lancer, il suffit de taper la commande `./simu -g ASM/undertale.obj`.

Le joueur contrôle un coeur avec les flèches du clavier et doit éviter toute collision avec les ennemis représentés par des petites bulles blanches. 
Les ennemis se déplacent verticalement du haut vers le bas et horizontalement vers le coeur jusqu'à ce qu'ils aient dépassé le sprite du coeur.
Quand un ennemi atteint le bas de l'écran, il est remplacé par un nouvel ennemi généré en haut de l'écran avec une abscisse aléatoire. 
Les premiers ennemis sont générés aléatoirement partout sur l'écran (pour que la répartition soit uniforme) mais assez loin du coeur pour éviter les _game overs_ instantannés en lançant le jeu.
Les ennemis se déplacent deux fois plus lentement que le coeur controlé par le joueur pour rendre possible les esquives.
Il y a un petit délai d'un peu moins d'une seconde au début du jeu pour laisser au joueur le temps de voir la position initiale des ennemis et de les éviter.

**IMPORTANT** Certains paramètres peuvent être modifiés pour le jeu:
- Le nombre d'ennemis présents sur l'écran peut être modifié aux lignes 12 **et** 115 (ne pas oublier de modifier la valeur aux deux endroits!).
- La vitesse des ennemis peut être baissée à la ligne 166, mais elle ne peut pas être augmentée (la vitesse des ennemis est la vitesse du coeur divisée par un entier supérieur ou égal à 2).
- La vitesse globale du jeu peut-être modifiée à la ligne 244. C'est le temps (en ms) que le processeur attend entre chaque tour de boucle, cela détermine donc la vitesse de déplacement du coeur et des ennemis. La valeur actuelle (19) est empirique, c'est celle qui semblait bien fonctionner pour que le jeu ne soit ni trop dur ni trop facile sur mon ordinateur, mais elle dépend (un peu) de l'ordinateur utilisé.

Amusez-vous à tester différentes difficultés si vous voulez (beaucoup d'ennemis et peu de temps entre chaque tour de boucle (vitesse rapide) ou peu d'ennemis et une vitesse plus faible par exemple).

Voilà ce que j'aurais codé ensuite si j'avais eu plus de temps (dans l'ordre):
- un menu présentant plusieurs difficultés et qui ajuste le nombre d'ennemis et la vitesse du jeu selon la difficulé choisie
- une barre de vie qui diminue à chaque fois que le coeur prend un coup (au lieu du _game over_ direct)
- une mesure du temps pendant lequel le joueur a survécu, affiché sur l'écran du _game over_
- une diversification des ennemis
et bien plus encore...


-----------------------------------------------------------------------

La démo graphique permettant de tester les fonctions `clear_screen`, `fill`, `draw` et `putchar` est disponible.
Pour la lancer, il suffit de taper la commande `./simu -g ASM/routines.obj` dans un terminal.

