; Les entiers sont non signés.
; On divise r0 par r1 et on met le quotient dans r2 et le reste dans r3.

	leti r0 4242
	leti r1 17
	leti r2 0
	let r3 r0
	let r4 r1

; initialisation de la boucle

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
	shift left r2 1
	cmp r4 r3
	jumpif gt label
	    add2i r2 1
			sub2 r3 r4
label:
	shift right r4 1
	jump debutBoucle2
fin:
	jump -13


; nombre total de bits d'instructions lus dans l'exécution d'une itération : 102
