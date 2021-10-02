@;=                                                         	      	=
@;=== candy1_move: rutinas para contar repeticiones y bajar elementos ===
@;=                                                          			=
@;=== Programador tarea 1E: joseluis.pueyo@estudiants.urv.cat		  ===
@;=== Programador tarea 1F: joseluis.pueyo@estudiants.urv.cat		  ===
@;=                                                         	      	=



.include "../include/candy1_incl.i"



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1E;
@; cuenta_repeticiones(*matriz,f,c,ori): rutina para contar el número de
@;	repeticiones del elemento situado en la posición (f,c) de la matriz, 
@;	visitando las siguientes posiciones según indique el parámetro de
@;	orientación 'ori'.
@;	Restricciones:
@;		* sólo se tendrán en cuenta los 3 bits de menor peso de los códigos
@;			almacenados en las posiciones de la matriz, de modo que se ignorarán
@;			las marcas de gelatina (+8, +16)
@;		* la primera posición también se tiene en cuenta, de modo que el número
@;			mínimo de repeticiones será 1, es decir, el propio elemento de la
@;			posición inicial
@;	Parámetros:
@;		R0 = dirección base de la matriz
@;		R1 = fila 'f'
@;		R2 = columna 'c'
@;		R3 = orientación 'ori' (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte)
@;	Resultado:
@;		R0 = número de repeticiones detectadas (mínimo 1)
	.global cuenta_repeticiones
cuenta_repeticiones:
		push {r1-r2, r4-r10, lr}
		
		mov r5, #COLUMNS
		mla r6, r1, r5, r2		@;R6 = f * COLUMNS + c
		add r4, r0, r6			@;R4 apunta al elemento (f,c) de 'mat'
		ldrb r5, [r4]
		and r5, #7				@;R5 es el valor filtrado (sin marcas de gel.)
		mov r0, #1				@;R0 = número de repeticiones
		
		ldrb r11, [r4]			@;R11 es el valor sin filtrado
		
		@;cmp r3, #0
		@;beq .Lconrep_este
		@;cmp r3, #1
		@;beq .Lconrep_sur
		@;cmp r3, #2
		@;beq .Lconrep_oeste
		@;cmp r3, #3
		@;beq .Lconrep_norte
		@;b .Lconrep_fin
		
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
			
		@;Bucle
		add r9, r4, r8
	.Linicio_bucle:
		cmp r7, #0
		blt .Lfin_bucle
		
		add r9, r8
		ldrb r10, [r9]
		
		cmp r5, #0
		beq .LigualCeroSiete
		cmp r5, #7
		bne .LdiferenteCeroSiete
	.LigualCeroSiete:
		cmp r10, r11
		addeq r0, #1
		b .LfinIgualCeroSiete
	.LdiferenteCeroSiete:
		and r12, r10, #7
		cmp r5, r12
		addeq r0, #1
	.LfinIgualCeroSiete:
		
		sub r7, #1
		
		b .Linicio_bucle
	.Lfin_bucle:
		
		pop {r1-r2, r4-r12, pc}



@;TAREA 1F;
@; baja_elementos(*matriz): rutina para bajar elementos hacia las posiciones
@;	vacías, primero en vertical y después en sentido inclinado; cada llamada a
@;	la función sólo baja elementos una posición y devuelve cierto (1) si se ha
@;	realizado algún movimiento, o falso (0) si está todo quieto.
@;	Restricciones:
@;		* para las casillas vacías de la primera fila se generarán nuevos
@;			elementos, invocando la rutina 'mod_random' (ver fichero
@;			"candy1_init.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica se ha realizado algún movimiento, de modo que puede que
@;				queden movimientos pendientes. 
	.global baja_elementos
baja_elementos:
		push {lr}
		
		
		pop {pc}



@;:::RUTINAS DE SOPORTE:::



@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en vertical; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 
baja_verticales:
		push {lr}
		
		
		pop {pc}



@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en diagonal; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 
baja_laterales:
		push {lr}
		
		
		pop {pc}



.end
