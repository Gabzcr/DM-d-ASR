; r0 : couleur
; (r1,r2) : coordonnées du point sur lequel on travaille
; r5 : valeur du compteur a0 qui regarde dans la mémoire
; r6 : nombre d'ennemis à gérer/ vitesse des ennemis
; a0 se balade sur les touches du clavier
; a1 se balade dans la liste des ennemis


main:
    ;coordonnées initiales du sprite: (r1,r2) =
    leti r0 -1
    leti r6 12 ; nombre d'ennemis à créer. AJUSTER LE NOMBRE D'ENNEMIS ICI!!!
    
    ; création des ennemis
    leti r5 409604
    setctr a1 r5
    creationEnnemis:
    cmpi r6 0
    jumpif z ennemisCrees
        random r1 160
        random r2 128
        call sprite_ennemis
        write a1 32 r1
        write a1 32 r2
        sub2i r6 1
    jump creationEnnemis
    ennemisCrees:

    leti r1 20
    leti r2 20
    leti r3 140
    leti r4 20
    call draw
    leti r1 20
    leti r2 20
    leti r3 20
    leti r4 108
    call fill
    leti r1 20
    leti r2 108
    leti r3 140
    leti r4 108
    call draw
    leti r1 140
    leti r2 20
    leti r3 140
    leti r4 108
    call fill
    
    leti r1 75
    leti r2 50
    leti r0 0x7c00
    call sprite_coeur
    
    leti r6 1 ; VITESSE DES ENNEMIS A AJUSTER ICI (nombre de tours d'attente entre chaque déplacement de 1 pixel, i.e leti r6 1 revient à diviser la vitesse des ennemis par 2)!!!
    sleep 900
    
    
label2:
    
    push r1
    push r2
    push r3
    push r4
    leti r0 -1
    leti r1 20
    leti r2 20
    leti r3 140
    leti r4 20
    call draw
    leti r1 20
    leti r2 20
    leti r3 20
    leti r4 108
    call fill
    leti r1 20
    leti r2 108
    leti r3 140
    leti r4 108
    call draw
    leti r1 140
    leti r2 20
    leti r3 140
    leti r4 108
    call fill
    pop r4
    pop r3
    pop r2
    pop r1
    
    
    
    leti r5 409604
    
    ; gestion des ennemis
    ; on stocke les coordonnées de chaque ennemi après les touches du clavier en mémoire (abscisse + ordonnée = 64 bits pour chaque ennemi)
    
    let r3 r1
    let r4 r2
    
    
    cmpi r6 0
    jumpif neq freeze_ennemis ; si r6 !=0, on décrémente juste r6. Sinon, on gère les ennemis et on remet r6 à sa valeur initiale
    
    leti r6 12 ; NOMBRE D'ENNEMIS A MODIFIER ICI AUSSI!!!
    setctr a1 r5
    
    gestionEnnemis:
    cmpi r6 0
    jumpif z ennemisGeres
        sub2i r6 1
        ; TODO : mettre au point une meilleure trajectoire pour les ennemis
        readze a1 32 r1
        readze a1 32 r2
        leti r0 0
        call sprite_ennemis
        add2i r2 1
        cmp r2 r4
        jumpif ge depasse
            ;ici on n'a pas dépassé l'ordonnée du coeur donc on se dirige horizontalement vers lui
            cmp r1 r3
            jumpif ge gauche
                ;ici r1 < r3 donc on va à droite
                add2i r1 1
            gauche:
            cmp r3 r1
            jumpif ge centre
                ;ici r3 < r1 donc on va à gauche
                sub2i r1 1
            centre:
            ;si c'est déjà centré, on ne fait pas de déplacement latéral
        depasse:
        cmpi r2 124
        jumpif neq pasSorti ; dans ce bloc, le point est sorti du cadre, donc on en crée un nouveau
            random r1 160
            leti r2 0
            getctr a1 r0
            sub2i r0 64
            setctr a1 r0
            write a1 32 r1
            write a1 32 r2
            add2i r5 64
            jump gestionEnnemis
        pasSorti: ; ceci est un else
        leti r0 -1
        call sprite_ennemis
        setctr a1 r5
        write a1 32 r1
        write a1 32 r2
        add2i r5 64
    jump gestionEnnemis
    ennemisGeres:

    let r2 r4
    let r1 r3
    leti r6 2; on met r6 à un de plus car il est décrémenté juste derrière. VITESSE DES ENNEMIS A MODIFIER ICI AUSSI!!!
    
    
    freeze_ennemis:
    sub2i r6 1
    leti r5 409600
    
    ; touche 'UP'
    setctr a0 r5
    readze a0 1 r4
    cmpi r4 1
    jumpif neq label1 ; cas où r4 = 0 : on ne bouge pas le pixel
    cmpi r2 21
    jumpif eq label1 ; cas où le coeur est déjà tout en haut
       leti r0 0 ; pour effacer l'ancien emplacement du pixel
       call sprite_coeur
       leti r0 0x7c00
       sub2i r2 1
       call sprite_coeur
       setctr a0 r5 ; a0 avait été incrémenté lors de readze a0 1 r4
       leti r4 0
       write a0 1 r4 ; on réécris 0 en mémoire pour indiquer que l'action a été traitée
    label1:
    
    ; touche 'DOWN'
    add2i r5 1
    setctr a0 r5
    readze a0 1 r4
    cmpi r4 1
    jumpif neq label3
    cmpi r2 103
    jumpif eq label3
       leti r0 0
       call sprite_coeur
       leti r0 0x7c00
       add2i r2 1
       call sprite_coeur
       setctr a0 r5
       leti r4 0
       write a0 1 r4
    label3:
    
    ; touche 'LEFT'
    add2i r5 1
    setctr a0 r5
    readze a0 1 r4
    cmpi r4 1
    jumpif neq label4
    cmpi r1 21
    jumpif eq label4
       leti r0 0
       call sprite_coeur
       leti r0 0x7c00
       sub2i r1 1
       call sprite_coeur
       setctr a0 r5
       leti r4 0
       write a0 1 r4
    label4:
    
    ; touche 'RIGHT'
    add2i r5 1
    setctr a0 r5
    readze a0 1 r4
    cmpi r4 1
    jumpif neq label5
    cmpi r1 135
    jumpif eq label5
       leti r0 0
       call sprite_coeur
       leti r0 0x7c00
       add2i r1 1
       call sprite_coeur
       setctr a0 r5
       leti r4 0
       write a0 1 r4
    label5:
    
    sleep 19
    jump label2


; plot_with_game_over
; ----

plot_with_game_over:
;les coordonnées du pixel on déjà été calculé et mis dans r4 avant l'appel de cette fonction
push r3 ; to prevent side-effects


readze a0 16 r3
setctr a0 r4
cmpi r3 0x7c00
jumpif neq plot_ok
    call game_over
plot_ok:
write a0 16 r0
add2i r4 16
setctr a0 r4


pop r3
return




game_over:
    leti r0 0
    call clear_screen
    leti r0 -1
    leti r1 45
    leti r2 60
    leti r3 71 ;G
    call putchar
    add2i r1 7
    leti r3 65; A
    call putchar
    add2i r1 7
    leti r3 77; M
    call putchar
    add2i r1 8
    leti r3 69; E
    call putchar
    add2i r1 14
    leti r3 79; O
    call putchar
    add2i r1 7
    leti r3 86; V
    call putchar
    add2i r1 7
    leti r3 69; E
    call putchar
    add2i r1 7
    leti r3 82; R
    call putchar
    add2i r1 7
    leti r3 33; !
    call putchar
    sleep 999
    jump -13
;pas besoin de return ici car on boucle





; sprite_coeur
; ------------

; fait un coeur personnalisé de coin en haut à gauche r1 r2 et de couleur r0

sprite_coeur:
    push r4 ; to prevent side-effects
    push r5 ; to prevent side-effects

; 160*x = (x+x<<2)<<5
    let r4 r2
    shift left r4 2
    add2 r4 r2
    shift left r4 5
    add2 r4 r1
    shift left r4 4
    add2i r4 0x10000 ; r4 ~ (r1,r2)
    setctr a0 r4
    
    leti r5 0;
    ;1ere ligne
    write a0 16 r0
    write a0 16 r0
    write a0 16 r5
    write a0 16 r0
    write a0 16 r0
    
    add2i r4 2560 ; changement de ligne
    setctr a0 r4
    
    ;2eme ligne
    write a0 16 r0
    write a0 16 r0
    write a0 16 r0
    write a0 16 r0
    write a0 16 r0
    
    add2i r4 2560
    setctr a0 r4
    
    ;3eme ligne
    write a0 16 r0
    write a0 16 r0
    write a0 16 r0
    write a0 16 r0
    write a0 16 r0
    
    add2i r4 2560
    setctr a0 r4
    
    ;4eme ligne
    write a0 16 r5
    write a0 16 r0
    write a0 16 r0
    write a0 16 r0
    write a0 16 r5
    
    add2i r4 2560
    setctr a0 r4
    
    ;5eme ligne
    write a0 16 r5
    write a0 16 r5
    write a0 16 r0
    write a0 16 r5
    write a0 16 r5
    
    add2i r4 2560
    setctr a0 r4

pop r5
pop r4
return


;sprite_ennemis
; ------------
; fait un ennemi personnalisé, gestion du game_over

sprite_ennemis:
push r4 ; to prevent side-effects
push r5 ; to prevent side-effects
push r7

; 160*x = (x+x<<2)<<5
    let r4 r2
    shift left r4 2
    add2 r4 r2
    shift left r4 5
    add2 r4 r1
    shift left r4 4
    add2i r4 0x10000 ; r4 ~ (r1,r2)
    setctr a0 r4
    
    leti r5 0;
    ;1ere ligne
    add2i r4 16
    setctr a0 r4
    call plot_with_game_over
    call plot_with_game_over
    add2i r4 2512 ; changement de ligne
    setctr a0 r4
    
    ;2eme ligne
    call plot_with_game_over
    add2i r4 16
    setctr a0 r4
    call plot_with_game_over
    call plot_with_game_over
    add2i r4 2496
    setctr a0 r4
    
    ;3eme ligne
    call plot_with_game_over
    add2i r4 16
    setctr a0 r4
    add2i r4 16
    setctr a0 r4
    call plot_with_game_over
    add2i r4 2496
    setctr a0 r4
    
    ;4eme ligne
    add2i r4 16
    setctr a0 r4
    call plot_with_game_over
    call plot_with_game_over
    
pop r7
pop r5
pop r4
return





; clear_screen
; ------------

clear_screen:
push r1 ; to prevent side-effects

leti r1 0x10000
setctr a0 r1

; 160*128 = 0x5000 -> dernier pixel à 0x15000

clearSL:
  cmpi r1 0x15000
  jumpif gt clearEL
  write a0 16 r0
  add2i r1 1
  jump clearSL
clearEL:
  pop r1
  return


; plot
; ----

plot:
push r3 ; to prevent side-effects

; 160*y = (y+y<<2)<<5
  let r3 r2
  shift left r3 2
  add2 r3 r2
  shift left r3 5
add2 r3 r1
shift left r3 4 ; don't forget pixels' length
add2i r3 0x10000
setctr a0 r3
write a0 16 r0

pop r3
return


;fill
;---

fill:

push r5 ; to prevent side-effects
push r6
push r7

let r5 r1
let r6 r2

let r7 r2
shift left r7 2
add2 r7 r2
shift left r7 5
add2 r7 r1
shift left r7 4
add2i r7 0x10000
setctr a0 r7 ; a0 ~ (r1,r2)

sub3 r7 r1 r3
add2i r7 160
sub2i r7 1
shift left r7 4 ; r7 = incrément de saut de ligne

forY:
cmp r6 r4
jumpif gt endFY
    forX:
    cmp r5 r3
    jumpif gt endFX
        write a0 16 r0
        add2i r5 1
        jump forX
    endFX:
    getctr a0 r5
    add2 r5 r7
    setctr a0 r5
    let r5 r1
    add2i r6 1
    jump forY
endFY:
    pop r7
    pop r6
    pop r5
    return


; draw
; ----

; x1 = r1, y1 = r2, x2 = r3, y2 = r4
; dx = r5, dy = r6
; e = r7

draw:

push r7
push r6
push r5
cmp r3 r1
jumpif ge draw_not_swap
    ;swap : on inverse x1 et x2
    add2 r1 r3
    sub3 r3 r1 r3
    sub2 r1 r3
    ; swap de y1 et y2
    add2 r2 r4
    sub3 r4 r2 r4
    sub2 r2 r4
draw_not_swap:
sub3 r7 r3 r1
let r5 r7
shift left r5 1
sub3 r6 r4 r2
leti r4 1

jumpif sgt draw_ascending
    leti r4 0
    sub3 r6 r4 r6; si dy <0 on doit l'inverser
    leti r4 -1; on enlevera 1 a y1 au lieu de l'ajouter
draw_ascending:

shift left r6 1

Tantque:
    cmp r1 r3
    jumpif gt FinTantQue
    push r7
    call plot
    pop r7
    add2i r1 1
    sub2 r7 r6
    jumpif gt FinCondition
        add2 r2 r4
        add2 r7 r5
    FinCondition:
    jump Tantque
FinTantQue:
pop r5
pop r6
pop r7
return


putchar:

; putchar r3 de couleur r0 aux coord r1,r2
; a0 parcourt la mémoire dédiée à l'écran (1 pixel = 16 bits)
; a1 parcourt la mémoire dédiée à la table ascii (en bitmap : 1 = pixel de couleur r0, 0 = pas d'écriture)

push r3 ; to prevent side-effects
push r4 ; to prevent side-effects
push r5 ; to prevent side-effects

; 160*x = (x+x<<2)<<5
  let r4 r2
  shift left r4 2
  add2 r4 r2
  shift left r4 5
add2 r4 r1
shift left r4 4
add2i r4 0x10000 ; r4 ~ (r1,r2)
setctr a0 r4

; 2^8 * 2^6

shift left r3 6
add2i r3 0x60000
setctr a1 r3

leti r5 0
startPut:
  cmpi r5 63
  jumpif gt endPut
    readze a1 1 r3
    cmpi r3 0
    jumpif z elsePut
      write a0 16 r0
      add2i r4 16
      jump sndPut
    elsePut:
       add2i r4 16
       setctr a0 r4 ; a0 <- a0 + 16
    sndPut:
      and3i r3 r5 0b00111
      add2i r5 1
      cmpi r3 0b00111; fin de ligne?
      jumpif z chgtLg
        jump startPut
      chgtLg:
        add2i r4 2432
        setctr a0 r4
        jump startPut
endPut:

pop r5
pop r4
pop r3

return

jump -13
