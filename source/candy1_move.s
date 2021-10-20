@;=                                                         	      	=
@;=== candy1_move: rutinas para contar repeticiones y bajar elementos ===
@;=                                                          			=
@;=== Programador tarea 1E: joseluis.pueyo@estudiants.urv.cat		  ===
@;=== Programador tarea 1F: joseluis.pueyo@estudiants.urv.cat		  ===
@;=                                                         	      	=



.include "../include/candy1_incl.i"



@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1E;
@; cuenta_repeticiones(*matriz,f,c,ori): rutina para contar el n�mero de
@;	repeticiones del elemento situado en la posici�n (f,c) de la matriz, 
@;	visitando las siguientes posiciones seg�n indique el par�metro de
@;	orientaci�n 'ori'.
@;	Restricciones:
@;		* s�lo se tendr�n en cuenta los 3 bits de menor peso de los c�digos
@;			almacenados en las posiciones de la matriz, de modo que se ignorar�n
@;			las marcas de gelatina (+8, +16)
@;		* la primera posici�n tambi�n se tiene en cuenta, de modo que el n�mero
@;			m�nimo de repeticiones ser� 1, es decir, el propio elemento de la
@;			posici�n inicial
@;	Par�metros:
@;		R0 = direcci�n base de la matriz
@;		R1 = fila 'f'
@;		R2 = columna 'c'
@;		R3 = orientaci�n 'ori' (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte)
@;	Resultado:
@;		R0 = n�mero de repeticiones detectadas (m�nimo 1)
	.global cuenta_repeticiones
cuenta_repeticiones:
		push {r1-r10, lr}
		
		mov r5, #COLUMNS
		mla r6, r1, r5, r2		@;R6 = f * COLUMNS + c
		add r4, r0, r6			@;R4 apunta al elemento (f,c) de 'mat'
		ldrb r5, [r4]
		and r5, #7				@;R5 es el valor filtrado (sin marcas de gel.)
		mov r0, #1				@;R0 = número de repeticiones
		
		@;Este
		cmp r3, #0
		moveq r7, #COLUMNS
		subeq r7, r2			@; r7 = # posiciones a comprovar
		moveq r8, #1			@; r8 = posiciones a moverse hasta la siguiente casilla a evaluar
		
		@;Sur
		cmp r3, #1
		moveq r7, #ROWS
		subeq r7, r1
		moveq r8, #COLUMNS
		
		@;Oeste
		cmp r3, #2
		moveq r7, r2
		moveq r8, #1
		mvneq r8, r8			@; ca2(r8) -> -r8
		addeq r8, #1			
		
		@;Norte
		cmp r3, #3
		moveq r7, r1
		moveq r8, #COLUMNS
		mvneq r8, r8
		addeq r8, #1
			
		mov r9, r4
	.LBucle:
		@; (i != 0)
		cmp r7, #0
		beq .LFinBucle
		@; Obtener el siguiente valor
		add r9, r8
		ldrb r10, [r9]
		and r10, #7
		@; Evaluar el siguiente valor
		cmp r5, r10
		addeq r0, #1
		bne .LFinBucle
		@; i--
		sub r7, #1
		b .LBucle
	.LFinBucle:
		pop {r1-r10, pc}



@;TAREA 1F;
@; baja_elementos(*matriz): rutina para bajar elementos hacia las posiciones
@;	vac�as, primero en vertical y despu�s en sentido inclinado; cada llamada a
@;	la funci�n s�lo baja elementos una posici�n y devuelve cierto (1) si se ha
@;	realizado alg�n movimiento, o falso (0) si est� todo quieto.
@;	Restricciones:
@;		* para las casillas vac�as de la primera fila se generar�n nuevos
@;			elementos, invocando la rutina 'mod_random' (ver fichero
@;			"candy1_init.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica se ha realizado alg�n movimiento, de modo que puede que
@;				queden movimientos pendientes. 
	.global baja_elementos
baja_elementos:
		push {lr}
		
		
		pop {pc}



@;:::RUTINAS DE SOPORTE:::



@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vac�as
@;	en vertical; cada llamada a la funci�n s�lo baja elementos una posici�n y
@;	devuelve cierto (1) si se ha realizado alg�n movimiento.
@;	Par�metros:
@;		R4 = direcci�n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado alg�n movimiento. 
baja_verticales:
		push {lr}
		
		
		pop {pc}



@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vac�as
@;	en diagonal; cada llamada a la funci�n s�lo baja elementos una posici�n y
@;	devuelve cierto (1) si se ha realizado alg�n movimiento.
@;	Par�metros:
@;		R4 = direcci�n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado alg�n movimiento. 
baja_laterales:
		push {lr}
		
		
		pop {pc}



.end
