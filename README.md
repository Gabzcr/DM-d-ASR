# DM-d-ASR

Pour plus d'informations sur les conventions adoptées pour l'implémentation de certaines instructions, voir le fichier remarques.txt.

La démo graphique permettant de tester les fonctions `clear_screen`, `fill`, `draw` et `putchar` est disponible.
Pour la lancer, il suffit de taper la commande `./simu -g ASM/routines.obj` dans un terminal.

En ce qui concerne les labels, les tailles des constantes sont optimales et obtenues en seulement deux passes (elles sont calculées entre la première et la deuxième passe à l'aide d'informations collectées pendant la première passe).
