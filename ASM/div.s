; Les entiers sont non signés.
; On divise r0 par r1 et on met le quotient dans r2 et le reste dans r3.

	leti r0 4242
	leti r1 17
	leti r2 0
	let r3 r0
	let r4 r1

; initialisation de la boucle
	
	cmp r4 r3
	jumpif ge 22
	shift left r4 1
	jump -48
	shift right r4 1
	cmp r4 r1
	jumpif lt 76
	shift left r2 1
	cmp r4 r3
	jumpif gt 19
	    add2i r2 1
		sub2 r3 r4
	shift right r4 1
	jump -102
	jump -13


; nombre total de bits d'instructions lus dans l'exécution d'une itération : 102

