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
leti r0 0
leti r2 0x60000 ; pixel (0,0) in the even table (aka NW cell)
leti r3 0x6027B ; pixel (0,159)     //          (aka NE cell)
leti r4 0x73D7F ; pixel (127,0)     //          (aka SW cell)
leti r5 0x73FFB ; pixel (127,159)   //          (aka SE cell)
; + 0x14000 for the odd table

oddTimeLoop:

    setctr a0 r2 ; we're reading in the even table
    leti r1 0 ; cell counter

    oddLoop:

                ; for NW we can directly write "1 neighbour" since
        oddNW:  ; the cells haven't been updated at all yet
        cmpi r1 0
        jumpif gt oddN
            setctr a1 r2 ; reading NW's state
            readze a1 4 r6 ; |
            cmpi r6 1 ; alive ?
            jumpif neq endOddLoop ; dead cell => nothing to do
                leti r0 0x87FF7
                setctr a1 r0 ; moving to the odd NWrn neighbour
                write a1 4 r6

                leti r0 0x87D7F
                setctr a1 r0 ; moving to the odd Nrn neighbour
                write a1 4 r6

                write a1 4 r6 ; the NErn neighbour is right after

                leti r0 0x74004
                setctr a1 r0 ; moving to the odd Ern neighbour
                write a1 4 r6

                add2i r0 628 ; 157*4 -> +1 line -3 cells
                setctr a1 r0 ; moving to the odd Wrn neighbour
                write a1 4 r6

                write a1 4 r6 ; that's the odd Srn neighbour

                write a1 4 r6 ; that's the odd SErn neighbour

                add2i r0 628
                setctr a1 r0 ; moving to the odd SWrn neighbour
                write a1 4 r6


                ; for these cells only the NErn, Ern and SErn cells
                ; can be modified directly, for the others we will
        oddN:   ; have to consider what has been written before.
        cmpi r1 126
        jumpif gt oddNE
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r6 ; |
            cmpi r6 1 ; alive ?
            jumpif neq endOddLoop ; dead cell => nothing to do
                let r0 r2
                add2i r0 0x27D7C
                setctr a1 r0 ; moving to the odd NWrn neighbour
                readze a1 4 r6
                add2i r6 1 ; neighbours number ++
                setctr a1 r0 ; a1 moved on so what have to make it
                write a1 4 r6 ; come back before we update

                add2i r0 4
                readze a1 4 r6 ; that's the Nrn neighbour
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                write a1 4 r6 ; that's the NErn neighbour

                leti r0 r2
                sub2i r0 4
                setctr a1 r0 ; moving to the Wrn neighbour
                readze a1 4 r6
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 8 ; passing the cell itself
                setctr a1 r0 ; and now to the Ern neighbour
                write a1 4 r6

                add2i r0 628
                setctr a1 r0 ; moving to the SWrn neighbour
                readze a1 4 r6
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 4
                readze a1 4 r6 ; that's the Srn neighbour
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                write a1 4 r6 ; that's the SErn neighbour


        oddNE: ; the NErn can still be modified directly
        cmpi r1 126
        jumpif gt oddSW
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r6 ; |
            cmpi r6 1 ; alive ?
            jumpif neq endOddLoop ; dead cell => nothing to do
                leti r0 0x73FF7
                setctr a1 r0 ; moving to the NWrn neighbour
                readze a1 4 r6
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 4
                readze a1 4 r6 ; that's the Nrn neighbour (ie SE)
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                leti r0 0x87FF7
                setctr a1 r0 ; moving to the NErn neighbour (ie SW)
                write a1 4 r6

                leti r0 0x74000
                setctr a1 r0 ; moving to the Ern neighbour (ie NW)
                readze a1 4 r6
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 628
                setctr a1 r0 ; that's the Wrn neighbour
                readze a1 4 r6
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 8 ; passing the cell itself
                setctr a1 r0 ; now we're at the SErn neighbour
                readze a1 4 r6
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 628
                readze a1 4 r6 ; that's the SWrn neighbour
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 4
                readze a1 4 r6 ; that's the Srn neighbour
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

        oddSW:
        cmpi r1 20320
        jumpif lt oddW
        jumpif gt oddS
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r6 ; |
            cmpi r6 1 ; alive ?
            jumpif neq endOddLoop ; dead cell => nothing to do
                leti r0 0x74000
                setctr a1 r0 ; moving to the Srn neighbour (NW)
                readze a1 4 r6
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 4
                readze a1 4 r6 ; that's the SErn neighbour
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 628
                readze a1 4 r6 ; that's the SWrn neighbour
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                leti r0 0x73AFF
                setctr a1 r0 ; moving to the Nrn neighbour
                readze a1 4 r6
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 4
                setctr a1 r0 ; NErn neighbour
                readze a1 4 r6
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 628
                setctr a1 r0 ; NWrn neighbour
                readze a1 4 r6
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 8
                readze a1 4 r6 ; Ern neighbour
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 628
                setctr a1 r0 ; Wrn neighbour
                readze a1 4 r6
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

        oddS:
        cmpi r1 20479
        jumpif gt oddSE
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r6 ; |
            cmpi r6 1 ; alive ?
            jumpif neq endOddLoop ; dead cell => nothing to do
                let r0 r2
                sub2i r0 644 ;
                setctr a1 r0 ; moving to the NWrn neighbour
                readze a1 4 r6
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 4
                readze a1 4 r6 ; that's the Nrn neighbour
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 4
                readze a1 4 r6 ; that's the NErn neighbour
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 628
                setctr a1 r0 ; moving to the Wrn neighbour
                readze a1 4 r6
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 8
                setctr a1 r0 ; Ern neighbour
                readze a1 4 r6
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                sub2i r0 20328
                setctr a1 r0 ; jumping to SWrn neighbour
                readze a1 4 r6
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 4
                readze a1 4 r6 ; Srn neighbour
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 4
                setctr a1 r0 ; SErn neighbour
                readze a1 4 r6
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

        oddSE:
        cmpi r1 20479
        jumpif gt endOddTimeLoop
            setctr a1 r2 ; reading the cell's state
            readze a1 4 r6 ; |
            cmpi r6 1 ; alive ?
            jumpif neq endOddLoop ; dead cell => nothing to do
                leti r0 0x74000
                setctr a1 r0 ; moving to the SErn neighbour (NW)
                readze a1 4 r6
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 628
                readze a1 4 r6 ; that's the SWrn neighbour
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 4
                readze a1 4 r6 ; that's the Srn neighbour
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                leti r0 0x73AFF
                setctr a1 r0 ; moving to the NErn neighbour
                readze a1 4 r6
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 628
                setctr a1 r0 ; NWrn neighbour
                readze a1 4 r6
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 4
                setctr a1 r0 ; Nrn neighbour
                readze a1 4 r6
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 4
                readze a1 4 r6 ; Ern neighbour
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

                add2i r0 628
                setctr a1 r0 ; Wrn neighbour
                readze a1 4 r6
                add2i r6 1
                setctr a1 r0
                write a1 4 r6

    endOddLoop:
        add2i r1 1
        jump oddLoop

endOddTimeLoop:

evenTimeLoop:

    setctr a0 r2 ; 1st cell
    leti r1 0 ; cell counter

    loop:
    cmpi r1 20479 ; 20480 cells
    jumpif gt endLoop

        evenNW:
            cmpi r1 0
            jumpif gt N

            setctr a1 r5

timeLoop:

    setctr a0 r2
    leti r1 0 ; cell counter

    loop:
    cmpi r1 20479
    jumpif gt endLoop

        leti r6 0 ; alive neighbours counter

        NW:
        cmpi r1 1
        jumpif gt N ; no neighbour is up-to-date

            setctr a1 r3
            readze a1 16 r7 ; NE cell state
            and2i r7 0b10 ; is enough to know whether NE is alive
            cmpi r7 10
            jumpif nz 9
                addi r6 1 ; 4+3+2 = 9 bits

            setctr a1 r4
            readze a1 16 r7 ; SW cell state
            and2i r7 0b10
            cmpi r7 10
            jumpif nz 9
                addi r6 1 ; 4+3+2 = 9 bits

            leti r7 0x10010
            setctr a1 r7
            readze a1 16 r7 ; eastern cell state
            and2i r7 0b10
            cmpi r7 10
            jumpif nz 9
                addi r6 1 ; 4+3+2 = 9 bits

            leti r7 0x10A00
            setctr a1 r7
            readze a1 16 r7 ; southern cell state
            and2i r7 0b10
            cmpi r7 10
            jumpif nz 9
                addi r6 1 ; 4+3+2 = 9 bits

            readze a0 1 r7
            cmpi r7 1
            jumpif nz NWisDead
                cmpi r6 1
                jumpif z NWgonnaDie
                    cmpi r6 3
                    jumpif gt NWgonnaDie
                        readze a0 14 r6 ; just to advance a0
                        write a0 1 r0 ; NW hasn't changed
                        jump endNW
                NWgonnaDie:
                    leti r6 0x10000
                    setctr a0 r6
                    write a0 16 r6
                    jump endNW
            NWisDead:
                cmpi r6 3
                jumpif nz NWstaysDead
                    leti r6 0x10000
                    setctr a0 r6
                    leti r7 0x0FFFF
                    write a0 16 r7
                    jump endNW
                NWstaysDead:
                    readze a0 14 r6 ; just to advance a0
                    write a0 1 r0
            endNW:
            add2i r1 1
            jump loop

        N:
            cmpi r1 159
            jumpif gt NE:

        NE:
            cmpi r1 160
            jumpif gt SW:

        SW:
            cmpi r1 20320
            jumpif gt S
            jumpif lt W

        SE:
            cmpi r1 20479
            jumpif lt S

        S:


        W:
            ; cmpi r1 mod 160 0
            cmpi r1
            jumpif E

        E:
            ; cmpi r1 mod 160 159
            cmpi r1
            jumpif land

        land:

    endLoop:

endTimeLoop:
