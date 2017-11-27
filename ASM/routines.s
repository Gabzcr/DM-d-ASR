; Base graphical routines

; clear_screen
; ------------

leti r1 0x10000 ; 42
setctr a0 r1 ; 11

; 160*128 = 0x5000

cmpi r1 0x15000 ; 42
jumpif gt 36 ; 16

write a0 16 r0 ; 14

add2i r1 1 ; 9
jump -94 ; 13

jump -13

; plot
; ----

; 160*x = (x+x<<2)<<5
; let r2 r1
; shift r2 2
; add2 r1 r2
; shift r1 5

; jump -13

; fill
; ----

; draw
; ----

; putchar
; -------
