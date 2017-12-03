; Base graphical routines

; clear_screen
; ------------

push 111 r1 ; to prevent side-effects

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
  pop 111 r3
  return

; plot
; ----

push 111 r3 ; to prevent side-effects

; 160*x = (x+x<<2)<<5
  let r3 r1
  shift 0 r3 2
  add2 r3 r1
  shift 0 r3 5
add2i r3 0x10000
add2 r3 r2
setctr a0 r3
write a0 16 r0

pop 111 r3
return

; fill
; ----

push 111 r5 ; to prevent side-effects
push 111 r6 ; to prevent side-effects
push 111 r7 ; to prevent side-effects

let r5 r1
shift 0 r5 2
add2 r5 r1
shift 0 r5 5
add2i r5 0x10000
add2 r5 r2
setctr a0 r5 ; r5 ~ (r1,r2)

let r6 r3
shift 0 r6 2
add2 r6 r3
shift 0 r6 5
add2i r6 0x10000
add2 r6 r4 ; r6 ~ (r3,r4)

fillSL:
  cmp r5 r6
  jumpif gt fillEL
  write a0 16 r0
  ; (r5 - 0x10000) mod 160
  ; jumpif chgtLgn
    add2i r1 1
  chgtLgn:
    add2i r1 160-r5+r2-1
  jump fillSL
fillEL:
  pop 111 r7
  pop 111 r6
  pop 111 r5
  return

; draw
; ----

; x1 = r1, y1 = r2, x2 = r3, y2 = r4
; dx = r5, dy = r6
; e = r7

sub3 r5 r3 r1
jumpif eq else0
  jumpif lt else1
    sub3 r6 r4 r2
    jumpif eq else2
      jumpif lt else3

      else3
    else2:
  else1:
else0:

return

; putchar
; -------

; putchar r3 de couleur r0 aux coord r1,r2

push r3 ; to prevent side-effects
push r4 ; to prevent side-effects
push r5 ; to prevent side-effects

; 160*x = (x+x<<2)<<5
  let r4 r1
  shift 0 r4 2
  add2 r4 r1
  shift 0 r4 5
add2i r4 0x10000
add2 r4 r2 ; r4 ~ (r1,r2)
setctr a0 r4

; 2^8 * 2^6

shift 0 r3 6
add2i r3 0x60000
setctr a1 r3
leti r5 1

startPut
  cmp r5 32
  jumpif gt endPut
    readze a1 00 r3
    cmpi r3 0
    jumpif z sndPut
      write a0 16 r0
    sndPut:
      and3i r3 r5 0b00111
      addi r5 1
      cmp r3 0b00111
      jumpif z chgtLg
        add2i r4 16
      chgtLg:
        add2i r4 2432
    jump startPut
endPut

pop r5
pop r4
pop r3

return

jump -13
