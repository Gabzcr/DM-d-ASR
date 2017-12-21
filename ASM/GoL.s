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

push r0 ; side-effects prevention
push r1
push r2
push r3
push r4
push r5
push r6
push r7

; leti r0 0x0000 ; black
; leti r7 0xffff ; white

; initialisation
leti r4 0
leti r2 0x60000 ; pixel (0,0) in the even table (aka NW cell)
leti r3 0x6027B ; pixel (0,159)     //          (aka NE cell)
leti r4 0x73D7F ; pixel (127,0)     //          (aka SW cell)
leti r5 0x73FFB ; pixel (127,159)   //          (aka SE cell)
; + 0x14000 for the odd table

oddTimeLoop:

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
                leti r4 0x87FF7
                setctr a1 r4 ; moving to the odd NWrn neighbour
                write a1 4 r3

                leti r4 0x87D7F
                setctr a1 r4 ; moving to the odd Nrn neighbour
                write a1 4 r3

                write a1 4 r3 ; the NErn neighbour is right after

                leti r4 0x74004
                setctr a1 r4 ; moving to the odd Ern neighbour
                write a1 4 r3

                add2i r4 628 ; 157*4 -> +1 line -3 cells
                setctr a1 r4 ; moving to the odd Wrn neighbour
                write a1 4 r3

                write a1 4 r3 ; that's the odd Srn neighbour

                write a1 4 r3 ; that's the odd SErn neighbour

                add2i r4 628
                setctr a1 r4 ; moving to the odd SWrn neighbour
                write a1 4 r3

; ------------------------------------------------------
                ; for these cells only the NErn, Ern and SErn cells
                ; can be modified directly, for the others we will
        oddN:   ; have to consider what has been written before.
        cmpi r1 126
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

                write a1 4 r3 ; that's the NErn neighbour

                leti r4 r2
                sub2i r4 4
                setctr a1 r4 ; moving to the Wrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 8 ; passing the cell itself
                setctr a1 r4 ; and now to the Ern neighbour
                write a1 4 r3

                add2i r4 628
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

                write a1 4 r3 ; that's the SErn neighbour

; ------------------------------------------------------
        oddNE: ; the NErn can still be modified directly
        cmpi r1 126
        jumpif gt oddSW
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endOddLoop ; dead cell => nothing to do
                leti r4 0x73FF7
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

                leti r4 0x87FF7
                setctr a1 r4 ; moving to the NErn neighbour (ie SW)
                write a1 4 r3

                leti r4 0x74000
                setctr a1 r4 ; moving to the Ern neighbour (ie NW)
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 628
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

                add2i r4 628
                readze a1 4 r3 ; that's the SWrn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; that's the Srn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

; ------------------------------------------------------
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

                add2i r4 628
                readze a1 4 r3 ; that's the SWrn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                leti r4 0x73AFF
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

                add2i r4 628
                setctr a1 r4 ; NWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 8
                readze a1 4 r3 ; Ern neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 628
                setctr a1 r4 ; Wrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

; ------------------------------------------------------
        oddS:
        cmpi r1 20479
        jumpif gt oddSE
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endOddLoop ; dead cell => nothing to do
                let r4 r2
                sub2i r4 644 ;
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

                add2i r4 628
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

                sub2i r4 20328
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

; ------------------------------------------------------
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

                add2i r4 628
                readze a1 4 r3 ; that's the SWrn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; that's the Srn neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                leti r4 0x73AFF
                setctr a1 r4 ; moving to the NErn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 628
                setctr a1 r4 ; NWrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                setctr a1 r4 ; Nrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                readze a1 4 r3 ; Ern neighbour
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 628
                setctr a1 r4 ; Wrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

; ------------------------------------------------------
        oddW:
        ; calcul de r = r1 mod 160
        ; q = r/160 = (r1/10) >> 4
        ; en effet (r mod 10) < 16 donc (16r mod 160) < 160
        ; donc ne fausse pas la division entière
        ; donc r = r1 - (r1/10) >> 4
        ; plus rapide à calculer que r1/160 directement
        let r3 r1
        leti r4 10
    	leti r5 0
        debutBoucle1:
        	cmp r4 r3
        	jumpif ge finBoucle1
        	shift left r4 1
        	jump debutBoucle1
        finBoucle1:
        	shift right r4 1
        debutBoucle2:
        	cmp r4 r1
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
            shift right r5 4 ; /16
            sub3 r3 r1 r5
            ; ---------------------------------
        cmpi r3 0
        jumpif gt oddMiddle
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endOddLoop ; dead cell => nothing to do
                let r4 r2
                sub2i r4 640
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

                add2i r4 628
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

                add2i r4 628
                setctr a1 r4 ; Wrn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 4
                write a1 4 r3 ; Srn neighbour

                add2i r4 4
                write a1 4 r3 ; SErn neighbour

                add2i r4 628
                setctr a1 r4 ; SWrn neighbour
                write a1 4 r3

; ------------------------------------------------------
        oddMiddle:
        cmpi r3 158
        jumpif gt oddSE
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endOddLoop ; dead cell => nothing to do
                let r4 r2
                sub2i r4 644
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

                add2i r4 628
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

                add2i r4 628
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

                write a1 4 r3 ; SErn neighbour

; ------------------------------------------------------
        oddE:
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r3 ; |
            cmpi r3 1 ; alive ?
            jumpif neq endOddLoop ; dead cell => nothing to do
                let r4 r2
                sub2i r4 1276
                setctr a1 r4 ; NErn neighbour
                readze a1 4 r3
                add2i r3 1
                setctr a1 r4
                write a1 4 r3

                add2i r4 628
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

                add2i r4 628
                setctr a1 r4 ; Wrn neighbour
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

                add2i r4 628
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


    endOddLoop:
        add2i r1 1
        add2i r2 4
        jump oddLoop

endOddTimeLoop:
