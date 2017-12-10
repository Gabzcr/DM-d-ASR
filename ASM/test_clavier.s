; Base graphical routines

; r0 : couleur
; (r1,r2) : coordonnées du point sur lequel on travaille
; r5 : valeur du compteur a0 qui regarde dans la mémoire
; r3 : numéro du charactère de la table (coeur) (provisoire)
; r4 vaut 1 si la touche est enfoncée et 0 sinon
; r6 : nombre d'ennemis à gérer
; a0 se balade sur les touches du clavier
; a1 se balade dans la liste des ennemis


main:
    leti r0 0x7c00 ; r0 = couleur
    ;coordonnées initiales du sprite: (r1,r2) =
    leti r1 75
    leti r2 50
    leti r3 3
    leti r6 3 ; nombre d'ennemis à créer. AJUSTER LE NOMBRE D'ENNEMIS ICI!!! (pour l'instant : un ennemi)
    
    ; création des ennemis
    push r1
    push r2
    
    leti r5 409604
    setctr a1 r5
    leti r2 0
    
    creationEnnemis:
    cmpi r6 0
    jumpif z ennemisCrees
        random r1 160
        call plot
        write a1 32 r1
        write a1 32 r2
        sub2i r6 1
    jump creationEnnemis
    ennemisCrees:
    
    pop r2
    pop r1
    
    
    
    
    
label2:

    leti r5 409604
    
    ; gestion des ennemis
    ; on stocke les coordonnées de chaque ennemi après les touches du clavier en mémoire (abscisse + ordonnée = 64 bits pour chaque ennemi)
    push r1
    push r2
    
    leti r6 3 ; NOMBRE D'ENNEMIS A MODIFIER ICI AUSSI!!!
    setctr a1 r5
    
    gestionEnnemis:
    cmpi r6 0
    jumpif z ennemisGeres
        ; TODO : mettre au point une meilleure trajectoire pour les ennemis
        readze a1 32 r1
        readze a1 32 r2
        leti r0 0
        call plot
        leti r0 -1
        add2i r2 1
        call plot
        setctr a1 r5
        write a1 32 r1
        write a1 32 r2
        add2i r5 64
        sub2i r6 1        
    jump gestionEnnemis
    ennemisGeres:
    



    pop r2
    pop r1
    
    leti r5 409600
    
    ; touche 'UP'
    setctr a0 r5
    readze a0 1 r4
    cmpi r4 1
    jumpif neq label1 ; cas où r4 = 0 : on ne bouge pas le pixel
       leti r0 0 ; pour effacer l'ancien emplacement du pixel
       call plot
       leti r0 0x7c00
       sub2i r2 1
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
       leti r0 0
       call plot
       leti r0 0x7c00
       add2i r2 1
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
       leti r0 0
       call plot
       leti r0 0x7c00
       sub2i r1 1
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
       leti r0 0
       call plot
       leti r0 0x7c00
       add2i r1 1
       setctr a0 r5
       leti r4 0
       write a0 1 r4
    label5:
    
    sleep 100
    call plot
    jump label2



















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
