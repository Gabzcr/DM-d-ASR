# DM-d-ASR

Pour plus d'informations sur les conventions adoptées pour l'implémentation de certaines instructions, voir le fichier remarques.txt.
Il est pratique de pouvoir écrire un bit à une adresse repérée par sa position dans la mémoire et non par la valeur d'un compteur. La fonction write\_bit\_addr sert ce but. Elle est utilisée pour gérer les entrées clavier dont les informations sont stockées après la table ascii.
Voici par ailleurs la disposition de la mémoire: programme chargé, puis écran, puis table ascii, puis clavier, puis espace de travail (pile, mais qui commence en fin de mémoire). 

La démo graphique permettant de tester les fonctions `clear_screen`, `fill`, `draw` et `putchar` est disponible.
Pour la lancer, il suffit de taper la commande `./simu -g ASM/routines.obj` dans un terminal.

En ce qui concerne les labels, les tailles des constantes sont optimales et obtenues en seulement deux passes (elles sont calculées entre la première et la deuxième passe à l'aide d'informations collectées pendant la première passe).
