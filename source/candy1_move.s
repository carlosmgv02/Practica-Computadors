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
		mov r4, r0
		bl baja_verticales
		cmp r0, #0
		ble baja_laterales
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
		mov r4, r0			@; r4 = *matriz
		mov r0, #0			@; r0 = false
		mov r1, #ROWS		@; r1 = i
		mov r2, #COLUMNS 	@; r2 = j
		mov r3, #COLUMNS	@; r3 = const
		
	@; Recorrido de la matriz sin la primera fila buscando los valores 0
	.LBucleFilas:
		@; while (i>1)
		cmp r1, #1
		blt .LfinBucleFilas
		
		.LBucleColumnas:
			@; while (j>0)
			cmp r2, #0
			blt .LFinBucleColumnas
			@; r5 = matriz[i][j]
			mla r6, r1, r3, r2
			ldrb r5, [r6, r4]
			.LSiCero:
				@; if (valorFiltrado == 0)
				tst r5, #0x7
				bne .LFinSiCero
				@; r8 = valorSup = matriz[i-1][j]
				sub r6, #COLUMNS
				ldrb r8, [r6]
				
				@; r7 = iTemp
				mov r7, r1
				@; Pasar por los huecos superiores
				.LBucleHueco:
					@; while (iTemp>0 && valorSup==Hueco)
					cmp r7, #0
					ble .LFinBucleHueco
					cmp r8, #0xF
					bne .LFinBucleHueco
					@; Obtengo el siguiente valor superior
					sub r6, #COLUMNS
					ldrb r8, [r6]
					@; iTemp--
					sub r7, #1
					b .LBucleHueco
				.LFinBucleHueco:
				
				@; Si hay un elemento superior válido, entonces hay una bajada vertical
				mvn r9, r8
				.LSiElementoValido:
					@; if (valorSup != ElementoVacío && valorSup != BloqueSolido|Hueco)
					tst r8, #0x7
					beq .LFinSiElementoValido
					tst r9, #0x7
					beq .LFinSiElementoValido
					@; r9 = valorSupFiltrado
					and r9, r8, #0x7
					@; valorSup = 0
					and r8, #0x18
					strb r8, [r6]
					@; valor = valorSup
					add r5, r9
					mla r6, r1, r3, r2
					strb r5, [r6]
					@; Ya que ha habido una bajada vertical r0 = true
					mov r0, #1
				.LFinSiElementoValido:
			.LFinSiCero:
			
			sub r2, #1
			b .LBucleColumnas
		.LFinBucleColumnas:
		
		sub r1, #1
		b .LBucleFilas
	.LFinBucleFilas:
		
		mov r1, #0
		mov r2, #0
	@; Busqueda de los valores 0 más altos de cada columna
	.LBucleColumnas2:
		@; while (j<COLUMNS)
		cmp r2, #COLUMNS
		bge .LFinBucleColumnas2
		
		.LBucleFilas2:
			@; while (i<ROWS)
			cmp r1, #ROWS
			bge .LFinBucleFilas2
			@; r5 = matriz[i][j]
			mla r6, r1, r3, r2
			ldrb r5, [r6, r4]
			
			@; if (matriz[i][j] == BloqueSolido) break;
			cmp r5, #0x7
			beq .LFinBucleFilas2
			
			.LSiCero2:
				@; if (matriz[i][j] == 0)
				tst r5, #0x7
				bne .LFinSiCero2
				@; Genero numero random entre 1 y 6
				mov r7, r0
				mov r0, #5
				bl mod_random
				add r0, #1
				@; Asigno al valor 0 el numero aleatorio
				add r5, r0
				str r5, [r6]
				mov r0, r7
				
				@; break
				b .LFinBucleFilas2
			.LFinSiCero2:
			
			add r1, #1
			b .LBucleFilas2
		.LFinBucleFilas2:
		
		add r2, #1
		b .LBucleColumnas2
	.LFinBucleColumnas2:
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
