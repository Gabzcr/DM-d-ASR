; Base graphical routines

main:
    leti r0 63
    leti r1 60
    leti r2 10
    leti r3 10
    leti r4 50
    call draw
    leti r0 63
    leti r1 50
    leti r2 50
    leti r3 2
    call putchar




    jump -13






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
  pop r3
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

; fill
; ----

;push r5 ; to prevent side-effects
;push r6 ; to prevent side-effects
;push r7 ; to prevent side-effects
;
;let r5 r1
;shift left r5 2
;add2 r5 r1
;shift left r5 5
;add2 r5 r2
;shift left r5 4
;add2i r5 0x10000 ; r5 ~ (r1,r2)
;setctr a0 r5
;
;let r6 r3
;shift left r6 2
;add2 r6 r3
;shift left r6 5
;add2 r6 r4
;shift left r5 4
;add2i r6 0x10000 ; r6 ~ (r3,r4)
;
;fillSL:
;  cmp r5 r6
;  jumpif gt fillEL
;  write a0 16 r0
;  ; (r5>>4 - 0x10000) mod 160
;  cmpi r5 ; fin de ligne?
;  jumpif z chgtLg
;    jump startPut
;  chgtLg:
;    add2i r4 2432
;    setctr a0 r4
;    jump startPut
;
;  ; jumpif chgtLgn
;    add2i r1 1
;  chgtLgn:
;    add2i r1 160-r5+r2-1
;  jump fillSL
;fillEL:
;  pop r7
;  pop r6
;  pop r5
;  return

; draw
; ----

; x1 = r1, y1 = r2, x2 = r3, y2 = r4
; dx = r5, dy = r6
; e = r7




;procédure tracerSegment(entier x1, entier y1, entier x2, entier y2) est
;  déclarer entier dx, dy ;
;  déclarer entier e ; // valeur d’erreur
;  e  ← x2 - x1 ;        // -e(0,1)
;  dx ← e × 2 ;          // -e(0,1)
;  dy ← (y2 - y1) × 2 ;  // e(1,0)
;  tant que x1 ≤ x2 faire
;    tracerPixel(x1, y1) ;
;    x1 ← x1 + 1 ;  // colonne du pixel suivant
;    si (e ← e - dy) ≤ 0 alors  // erreur pour le pixel suivant de même rangée
;      y1 ← y1 + 1 ;  // choisir plutôt le pixel suivant dans la rangée supérieure
;      e ← e + dx ;  // ajuste l’erreur commise dans cette nouvelle rangée
;    fin si ;
;  fin faire ;
;  // Le pixel final (x2, y2) n’est pas tracé.
;fin procédure ;



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

push r3 ; to prevent side-effects
push r4 ; to prevent side-effects
push r5 ; to prevent side-effects

; 160*x = (x+x<<2)<<5
  let r4 r1
  shift left r4 2
  add2 r4 r1
  shift left r4 5
add2 r4 r2
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
