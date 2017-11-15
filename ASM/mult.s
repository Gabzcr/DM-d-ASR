	leti r0 42
	leti r1 17
	leti r2 0
	    cmpi r0 0
	    jumpif z 57
	    shift right r0 1
	    jumpif nc 10
	    add2 r2 r1
	    shift left r1 1
	jump -82
	; le resultat est dans le registre 2
	jump -13

; nombre total de bits d'instructions lus dans l'exécution d'une itération : 82
