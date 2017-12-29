GoL:

; "Méta on n'est pas torique, torique on n'est pas méta."
; (hint inside)

; We use two tables to store both the current state
; and the previous state of each cell.
; Instead of counting each cell's neighbours number, which would
; mean counting each cell eigth times, we consider each cell and
; add 1 to its neighbours' neighbours number in the other table.
; then depending on each cells neighbours number we calculate
; whether it's dead or alive and then update the screen.
; we also update the table so that it be easy to know
; whether it's alive when we do the next step.
; each cell is encoded on 4 bits because it has up to 8 neighbours.


; notes
; leti r2 0x60000 ; pixel (0,0) in the even table (aka NW cell)
; leti r3 0x6027C ; pixel (0,159)     //          (aka NE cell)
; leti r4 0x73D80 ; pixel (127,0)     //          (aka SW cell)
; leti r5 0x73FFC ; pixel (127,159)   //          (aka SE cell)
; + 0x14000 for the odd table

; bud test

leti r0 0x0000 ; black
;call clear_screen
leti r7 0xFFFF ; white
leti r6 1

leti r1 0x60000
setctr a0 r1
leti r2 1
clear_memory:
cmpi r2 0x5000
jumpif gt init
  write a0 64 r0
  add2i r2 16
  jump clear_memory

  init:
  leti r1 0x60288
  setctr a0 r1
  write a0 4 r6
  leti r1 0x6028C
  setctr a0 r1
  write a0 4 r6
  leti r1 0x60290
  setctr a0 r1
  write a0 4 r6
  leti r1 0x60508
  setctr a0 r1
  write a0 4 r6
  leti r1 0x60510
  setctr a0 r1
  write a0 4 r6
  leti r1 0x60788
  setctr a0 r1
  write a0 4 r6
  leti r1 0x60790
  setctr a0 r1
  write a0 4 r6

; ----------------------------------------------------------
                        GameOfLife:
; ----------------------------------------------------------

sleep 999
push r0 ; side-effects prevention
push r1
push r2
push r3
push r4
push r5
push r6
push r7

leti r0 0x0000 ; black
leti r7 0xffff ; white

jump evenDisplay

oddTimeLoop:
    sleep 999
    leti r3 0
    leti r4 0
    leti r5 0
    leti r6 0
    leti r1 0 ; cell counter
    leti r2 0x60000
    setctr a0 r2 ; we're reading in the even table

    oddLoop:

        ; for NW we can directly write "1 neighbour" since
        oddNW:  ; the cells haven't been updated at all yet
        cmpi r1 0
        jumpif gt oddN
            setctr a1 r2 ; reading NW's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endOddLoop ; dead cell => nothing to do
                leti r4 0x87FFC
                setctr a1 r4 ; moving to the odd NWrn neighbour
                write a1 4 r3

                leti r4 0x87D7F
                setctr a1 r4 ; moving to the odd Nrn neighbour
                write a1 4 r3

                write a1 4 r3 ; the NErn neighbour is right after

                leti r4 0x74004
                setctr a1 r4 ; moving to the odd Ern neighbour
                write a1 4 r3

                add2i r4 632 ; 4 (move from writing note taken into account) + 157*4 -> +1 line -3 cells
                setctr a1 r4 ; moving to the odd Wrn neighbour
                write a1 4 r3

                write a1 4 r3 ; that's the odd Srn neighbour

                write a1 4 r3 ; that's the odd SErn neighbour

                add2i r4 640 ; 632 + 12 for the three previous moves
                setctr a1 r4 ; moving to the odd SWrn neighbour
                write a1 4 r3
                jump endOddLoop

        ; for these cells only the NErn, Ern and SErn cells
        ; can be modified directly, for the others we will
        oddN:   ; have to consider what has been written before.
        cmpi r1 158
        jumpif gt oddNE
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endOddLoop ; dead cell => nothing to do
                let r4 r2
                add2i r4 0x27D7C
                setctr a1 r4 ; moving to the odd NWrn neighbour
                readze a1 4 r3
                add2i r3 1 ; neighbours number ++
                setctr a1 r4 ; a1 moved on so what have to make it
                write a1 4 r3 ; come back before we update

                add2i r4 4
                readze a1 4 r3 ; that's the Nrn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                leti r3 1
                write a1 4 r3 ; that's the NErn neighbour

                let r4 r2
                add2i r4 0x13FFC
                setctr a1 r4 ; moving to the Wrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 8 ; passing the cell itself
                setctr a1 r4 ; and now to the Ern neighbour
                leti r3 1
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; moving to the SWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; that's the Srn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                leti r3 1
                write a1 4 r3 ; that's the SErn neighbour
                jump endOddLoop

        oddNE: ; the NErn can still be modified directly
        cmpi r1 159
        jumpif gt oddSW
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endOddLoop ; dead cell => nothing to do
                leti r4 0x87FF8
                setctr a1 r4 ; moving to the NWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; that's the Nrn neighbour (ie SE)
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                leti r4 0x87D80
                setctr a1 r4 ; moving to the NErn neighbour (ie SW)
                leti r3 1
                write a1 4 r3

                leti r4 0x74000
                setctr a1 r4 ; moving to the Ern neighbour (ie NW)
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; that's the Wrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 8 ; passing the cell itself
                setctr a1 r4 ; now we're at the SErn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; that's the SWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; that's the Srn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3
                jump endOddLoop

        oddSW:
        cmpi r1 20320
        jumpif lt oddW
        jumpif gt oddS
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endOddLoop ; dead cell => nothing to do
                leti r4 0x74000
                setctr a1 r4 ; moving to the Srn neighbour (NW)
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; that's the SErn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4
                readze a1 4 r3 ; that's the SWrn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                leti r4 0x87AFF
                setctr a1 r4 ; moving to the Nrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                setctr a1 r4 ; NErn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; NWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 8
                setctr a1 r4
                readze a1 4 r3 ; Ern neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; Wrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3
                jump endOddLoop

        oddS:
        cmpi r1 20478
        jumpif gt oddSE
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endOddLoop ; dead cell => nothing to do
                let r4 r2
                add2i r4 0x13D7C
                setctr a1 r4 ; moving to the NWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; that's the Nrn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; that's the NErn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; moving to the Wrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 8
                setctr a1 r4 ; Ern neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                sub2i r4 0x13D88
                setctr a1 r4 ; jumping to SWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; Srn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                setctr a1 r4 ; SErn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3
                jump endOddLoop

        oddSE:
        cmpi r1 20479
        jumpif gt endOddTimeLoop
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endOddLoop ; dead cell => nothing to do
                leti r4 0x74000
                setctr a1 r4 ; moving to the SErn neighbour (NW)
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; that's the SWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; that's the Srn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                leti r4 0x87AFF
                setctr a1 r4 ; moving to the NErn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; NWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; Nrn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; Ern neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; Wrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3
                jump endOddLoop

        oddW:
        leti r5 0
    	let r3 r1
    	leti r4 160
        ; On divise r1 par 160 et on met le quotient dans r5 et le reste dans r3.
        debutBoucle1:
        	cmp r4 r3
        	jumpif gt finBoucle1
        	shift left r4 1
        	jump debutBoucle1
        finBoucle1:
        	shift right r4 1
        debutBoucle2:
        	cmpi r4 160
        	jumpif lt fin
        	shift left r5 1
        	cmp r4 r3
        	jumpif gt label
        	    add2i r5 1
        		sub2 r3 r4
        label:
        	shift right r4 1
        	jump debutBoucle2
        fin:
            ; ---------------------------------
        cmpi r3 0
        jumpif gt oddMiddle
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endOddLoop ; dead cell => nothing to do
                let r4 r2
                add2i r4 0x13D80
                setctr a1 r4 ; Nrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; NErn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4
                readze a1 4 r3 ; NWrn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 8
                setctr a1 r4 ; Ern neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; Wrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                leti r3 1
                write a1 4 r3 ; Srn neighbour

                write a1 4 r3 ; SErn neighbour

                add2i r4 640
                setctr a1 r4 ; SWrn neighbour
                write a1 4 r3
                jump endOddLoop

        oddMiddle:
        cmpi r3 158
        jumpif gt oddE
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endOddLoop ; dead cell => nothing to do
                let r4 r2
                add2i r4 0x13D7C
                setctr a1 r4 ; NWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; Nrn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; NErn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; Wrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 8
                setctr a1 r4 ; Ern neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; SWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; Srn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                leti r3 1
                write a1 4 r3 ; SErn neighbour
                jump endOddLoop

        oddE:
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endOddLoop ; dead cell => nothing to do
                let r4 r2
                add2i r4 0x13B04
                setctr a1 r4 ; NErn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; NWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; Nrn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                setctr a1 r4 ; Ern neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; Wrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 8
                setctr a1 r4 ; SErn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; SWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                setctr a1 r4 ; Srn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3


    endOddLoop:
        add2i r1 1
        add2i r2 4
        jump oddLoop

endOddTimeLoop: ;every cell's neighbours number is up-to-date
    leti r1 0
    leti r2 0x74000
    setctr a0 r2 ; table
    leti r3 0x10000
    setctr a1 r3 ; screen

    oddLifeLoop:
        getctr a0 r4
        cmpi r1 0x4FFF
        jumpif gt oddDisplay
            readze a0 4 r5
            cmpi r5 3
            jumpif neq odd2neighbours
                setctr a0 r4 ; to write over the cell we read
                leti r5 1
                write a0 4 r5
                add2i r1 1
                jump oddLifeLoop
            odd2neighbours: ; depends on whether the cell was alive
            cmpi r5 2
            jumpif neq oddDead
                ; sub3i r5 r4 0x14000
                leti r5 0x14000
                sub3 r5 r4 r5
                setctr a0 r5
                readze a0 4 r5
                cmpi r5 1
                jumpif neq oddDead
                    setctr a0 r4
                    ;leti r5 1 // inutile car cette branche implique r5 == 1
                    write a0 4 r5
                    add2i r1 1
                    jump oddLifeLoop
            oddDead:
                setctr a0 r4
                leti r5 0
                write a0 4 r5
                add2i r1 1
                jump oddLifeLoop

    oddDisplay:
    ;leti r7 0b1111100000000000
    ;leti r0 0b0000011111000000
        leti r1 0
        leti r2 0x74000
        setctr a0 r2 ; table
        leti r3 0x10000
        setctr a1 r3 ; screen
        oddDisplayLoop:
            add2i r1 1
            cmpi r1 0x5000
            jumpif gt evenTimeLoop
            ;jumpif gt sleepfu
                readze a0 4 r5
                cmpi r5 1
                jumpif neq Black
                    write a1 16 r7
                    jump oddDisplayLoop
                Black:
                    write a1 16 r0
                    jump oddDisplayLoop

sleepfu:
    sleep 999
    jump sleepfu

; ------------------------------------------------------
; ------------------------------------------------------

evenTimeLoop:
    sleep 999
    leti r3 0
    leti r4 0
    leti r5 0
    leti r6 0
    leti r1 0 ; cell counter
    leti r2 0x74000
    setctr a0 r2 ; we're reading in the even table

    evenLoop:

        ; for NW we can directly write "1 neighbour" since
        evenNW:  ; the cells haven't been updated at all yet
        cmpi r1 0
        jumpif gt evenN
            setctr a1 r2 ; reading NW's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endEvenLoop ; dead cell => nothing to do
                leti r4 0x73FFC
                setctr a1 r4 ; moving to the odd NWrn neighbour
                write a1 4 r3

                leti r4 0x73D80
                setctr a1 r4 ; moving to the odd Nrn neighbour
                write a1 4 r3

                write a1 4 r3 ; the NErn neighbour is right after

                leti r4 0x60004
                setctr a1 r4 ; moving to the odd Ern neighbour
                write a1 4 r3

                add2i r4 632 ; 157*4 -> +1 line -3 cells
                setctr a1 r4 ; moving to the odd Wrn neighbour
                write a1 4 r3

                write a1 4 r3 ; that's the odd Srn neighbour

                write a1 4 r3 ; that's the odd SErn neighbour

                add2i r4 640
                setctr a1 r4 ; moving to the odd SWrn neighbour
                write a1 4 r3
                jump endEvenLoop

        ; for these cells only the NErn, Ern and SErn cells
        ; can be modified directly, for the others we will
        evenN:   ; have to consider what has been written before.
        cmpi r1 158
        jumpif gt evenNE
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endEvenLoop ; dead cell => nothing to do
                let r4 r2
                sub2i r4 644
                setctr a1 r4 ; moving to the odd NWrn neighbour
                readze a1 4 r3
                add2i r3 1 ; neighbours number ++
                setctr a1 r4 ; a1 moved on so what have to make it
                write a1 4 r3 ; come back before we update

                add2i r4 4
                readze a1 4 r3 ; that's the Nrn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                leti r3 1
                write a1 4 r3 ; that's the NErn neighbour

                let r4 r2
                sub2i r4 0x14004
                setctr a1 r4 ; moving to the Wrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 8
                leti r3 1
                setctr a1 r4 ; and now to the Ern neighbour
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; moving to the SWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; that's the Srn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                leti r3 1
                write a1 4 r3 ; that's the SErn neighbour
                jump endEvenLoop

        evenNE: ; the NErn can still be modified directly
        cmpi r1 159
        jumpif gt evenSW
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endEvenLoop ; dead cell => nothing to do
                leti r4 0x73FF8
                setctr a1 r4 ; moving to the NWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; that's the Nrn neighbour (ie SE)
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                leti r4 0x73D80
                setctr a1 r4 ; moving to the NErn neighbour (ie SW)
                leti r3 1
                write a1 4 r3

                leti r4 0x60000
                setctr a1 r4 ; moving to the Ern neighbour (ie NW)
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; that's the Wrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 8 ; passing the cell itself
                setctr a1 r4 ; now we're at the SErn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4
                readze a1 4 r3 ; that's the SWrn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; that's the Srn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3
                jump endEvenLoop

        evenSW:
        cmpi r1 20320
        jumpif lt evenW
        jumpif gt evenS
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endEvenLoop ; dead cell => nothing to do
                leti r4 0x60000
                setctr a1 r4 ; moving to the Srn neighbour (NW)
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; that's the SErn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4
                readze a1 4 r3 ; that's the SWrn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                leti r4 0x73B00
                setctr a1 r4 ; moving to the Nrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; NErn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; NWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 8
                setctr a1 r4
                readze a1 4 r3 ; Ern neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; Wrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3
                jump endEvenLoop

        evenS:
        cmpi r1 20478
        jumpif gt evenSE
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endEvenLoop ; dead cell => nothing to do
                let r4 r2
                sub2i r4 0x14284
                setctr a1 r4 ; moving to the NWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; that's the Nrn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; that's the NErn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; moving to the Wrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 8
                setctr a1 r4 ; Ern neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                sub2i r4 0x13D88
                setctr a1 r4 ; jumping to SWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; Srn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4 ; SErn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3
                jump endEvenLoop

        evenSE:
        cmpi r1 20479
        jumpif gt endEvenTimeLoop
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endEvenLoop ; dead cell => nothing to do
                leti r4 0x60000
                setctr a1 r4 ; moving to the SErn neighbour (NW)
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4
                readze a1 4 r3 ; that's the SWrn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; that's the Srn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                leti r4 0x73B00
                setctr a1 r4 ; moving to the NErn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; NWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4 ; Nrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; Ern neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; Wrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3
                jump endEvenLoop

        evenW:
        leti r5 0
    	let r3 r1
    	leti r4 160
        ; On divise r1 par 160 et on met le quotient dans r5 et le reste dans r3.
        DebutBoucle1:
        	cmp r4 r3
        	jumpif gt FinBoucle1
        	shift left r4 1
        	jump DebutBoucle1
        FinBoucle1:
        	shift right r4 1
        DebutBoucle2:
        	cmpi r4 160
        	jumpif lt Fin
        	shift left r5 1
        	cmp r4 r3
        	jumpif gt Label
        	    add2i r5 1
        		sub2 r3 r4
        Label:
        	shift right r4 1
        	jump DebutBoucle2
        Fin:
            ; ---------------------------------
        cmpi r3 0
        jumpif gt evenMiddle
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endEvenLoop ; dead cell => nothing to do
                let r4 r2
                sub2i r4 0x14280
                setctr a1 r4 ; Nrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; NErn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4
                readze a1 4 r3 ; NWrn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 8
                setctr a1 r4 ; Ern neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; Wrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                leti r3 1
                write a1 4 r3 ; Srn neighbour

                write a1 4 r3 ; SErn neighbour

                add2i r4 640
                setctr a1 r4 ; SWrn neighbour
                write a1 4 r3
                jump endEvenLoop

        evenMiddle:
        cmpi r3 158
        jumpif gt evenE
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endEvenLoop ; dead cell => nothing to do
                let r4 r2
                sub2i r4 0x14284
                setctr a1 r4 ; NWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; Nrn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; NErn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; Wrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 8
                setctr a1 r4 ; Ern neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; SWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; Srn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                leti r3 1
                write a1 4 r3 ; SErn neighbour
                jump endEvenLoop

        evenE:
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endEvenLoop ; dead cell => nothing to do
                let r4 r2
                sub2i r4 0x144FC
                setctr a1 r4 ; NErn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4
                readze a1 4 r3 ; NWrn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; Nrn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                setctr a1 r4 ; Ern neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4 ; Wrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 8
                setctr a1 r4 ; Srn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 632
                setctr a1 r4
                readze a1 4 r3 ; SErn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                setctr a1 r4 ; SWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

    endEvenLoop:
        add2i r1 1
        add2i r2 4
        jump evenLoop

endEvenTimeLoop:
;leti r7 0b1111100000111110
;leti r0 0b0000011111111110
    leti r1 0
    leti r2 0x60000
    setctr a0 r2 ; table
    leti r3 0x10000
    setctr a1 r3 ; screen

    evenLifeLoop:
        getctr a0 r4
        cmpi r1 0x4FFF
        jumpif gt evenDisplay
            readze a0 4 r5
            cmpi r5 3
            jumpif neq even2neighbours
                setctr a0 r4 ; to write over the cell we read
                leti r5 1
                write a0 4 r5
                add2i r1 1
                jump evenLifeLoop
            even2neighbours: ; depends on whether the cell was alive
            cmpi r5 2
            jumpif neq evenDead
                add3i r5 r4 0x14000
                setctr a0 r5
                readze a0 4 r5
                cmpi r5 1
                jumpif neq evenDead
                    setctr a0 r4
                    ;leti r5 1 // inutile car cette branche implique r5 == 1
                    write a0 4 r5
                    add2i r1 1
                    jump evenLifeLoop
            evenDead:
                setctr a0 r4
                leti r5 0
                write a0 4 r5
                add2i r1 1
                jump evenLifeLoop

    evenDisplay:
        leti r1 0
        leti r2 0x60000
        setctr a0 r2 ; table
        leti r3 0x10000
        setctr a1 r3 ; screen
        evenDisplayLoop:
            add2i r1 1
            cmpi r1 0x5000
            jumpif gt oddTimeLoop
                readze a0 4 r5
                cmpi r5 1
                jumpif neq black
                    write a1 16 r7
                    jump evenDisplayLoop
                black:
                    write a1 16 r0
                    jump evenDisplayLoop

; clear_screen
; ------------

clear_screen:
push r1 ; to prevent side-effects

leti r1 0
setctr a0 r1

; 160*128 = 0x5000 -> dernier pixel à 0x4FFF

clearSL:
  cmpi r1 0x4FFF
  jumpif gt clearEL
  write a0 16 r0
  add2i r1 1
  jump clearSL
clearEL:
  pop r3
  return
