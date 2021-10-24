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
		push {r4,lr}
		mov r4, r0
		bl baja_verticales
		@;cmp r0, #0
		@;ble baja_laterales
		pop {r4,pc}



@;:::RUTINAS DE SOPORTE:::



@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en vertical; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 
baja_verticales:
		push {r1-r11,lr}
		mov r11, #0			@; r11 = false
		mov r1, #ROWS-1		@; r1 = i = ROWS-1
		mov r2, #COLUMNS-1 	@; r2 = j = COLUMNS-1
		mov r3, #COLUMNS	@; r3 = const
		
	@; Recorrido de la matriz sin la primera fila buscando los valores 0
	.LBucleFilas:
		@; while (i>0)
		cmp r1, #0
		ble .LFinBucleFilas
		mov r2, #COLUMNS-1
		.LBucleColumnas:
			@; while (j>=0)
			cmp r2, #0
			blt .LFinBucleColumnas
			@; r5 = matriz[i][j]
			mla r6, r1, r3, r2
			ldrb r5, [r4, r6]
			.LSiCero:
				@; if (valorFiltrado == 0)
				tst r5, #0x7
				bne .LFinSiCero
				@; r8 = valorSup = matriz[i-1][j]
				sub r8, r6, #COLUMNS
				ldrb r7, [r4, r8]
				
				@; r10 = iTemp
				mov r10, r1
				@; Pasar por los huecos superiores
				.LBucleHueco:
					@; while (iTemp>0 && valorSup==hueco)
					cmp r10, #0
					ble .LFinBucleHueco
					cmp r7, #0xF
					bne .LFinBucleHueco
					@; Obtengo el siguiente valor superior
					sub r8, #COLUMNS
					ldrb r7, [r4, r8]
					@; iTemp--
					sub r10, #1
					b .LBucleHueco
				.LFinBucleHueco:
				
				@; Si hay un elemento superior válido, entonces hay una bajada vertical
				mvn r9, r7
				.LSiElementoValido:
					@; if (valorSup != elementoVacío && valorSup != bloqueSolido\hueco)
					tst r7, #0x7
					beq .LFinSiElementoValido
					tst r9, #0x7
					beq .LFinSiElementoValido
					
					mov r10, r1
					mov r0, r5
					mov r1, r7
					bl cambiar_3bits_menores
					strb r0, [r4, r6]
					strb r1, [r4, r8]
					mov r1, r10
					
					@; Ya que ha habido una bajada vertical r11 = true
					mov r11, #1
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
		mov r1, #0
		.LBucleFilas2:
			@; while (i<ROWS)
			cmp r1, #ROWS
			bge .LFinBucleFilas2
			@; r5 = matriz[i][j]
			mla r6, r1, r3, r2
			ldrb r5, [r4, r6]
			
			@; if (matriz[i][j] == bloqueSolido) break;
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
				strb r5, [r4, r6]
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
		mov r0, r11
		pop {r1-r11,pc}



@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en diagonal; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 
baja_laterales:
		push {r1-r11,lr}
		mov r11, #0			@; r11 = valor de retorno, por defecto es falso
		mov r2, #ROWS-1		@; r2 = i = ROWS
		mov r3, #COLUMNS-1	@; r3 = j = COLUMNS
		
	.LBucleFilas3:
		@; while (i>0)
		cmp r2, #0
		ble .LFinBucleFilas3
		mov r3, #COLUMNS-1
		.LBucleColumnas3:
			@; while (j>=0)
			cmp r3, #0
			blt .LFinBucleColumnas3
			@; r5 = matriz[i][j], r6 = *matriz[i][j]
			mov r6, #COLUMNS
			mla r6, r2, r6, r3
			ldrb r5, [r4, r6]
			.LSiCero3:
				@; if (matriz[i][j] == 0)
				tst r5, #0x7
				bne .LFinSiCero3
				
				.LSiValorValido:
					@; if (j>=COLUMNS-1 && es_valor_valido(valorIzquierdo))
					cmp r3, #COLUMNS-1
					blt .LSinoValorValido1
					sub r8, r6, #COLUMNS+1	@; r8 = *valorIzquierdo = *matriz[i-1][j-1] = *matriz[i][j]-(COLUMNS+1)
					ldrb r7, [r4, r8]
					mov r0, r7
					bl es_valor_valido
					cmp r0, #1
					bne .LSinoValorValido1
					
					mov r0, r5
					mov r1, r7
					bl cambiar_3bits_menores
					strb r0, [r4, r6]
					strb r1, [r4, r8]
					mov r11, #1
					
					b .LFinSiValorValido
				.LSinoValorValido1:
					@; else if (j<=0 && es_valor_valido(valorDerecho))
					cmp r3, #0
					blt .LSinoValorValido2
					sub r8, r6, #COLUMNS-1	@; r8 = *valorDerecho = *matriz[i-1][j+1] = *matriz[i][j]-(COLUMNS-1)
					ldrb r7, [r4, r8]
					mov r0, r7
					bl es_valor_valido
					cmp r0, #1
					bne .LSinoValorValido2
					
					mov r0, r5
					mov r1, r7
					bl cambiar_3bits_menores
					strb r0, [r4, r6]
					strb r1, [r4, r8]
					mov r11, #1
					
					b .LFinSiValorValido
				.LSinoValorValido2:
					
					sub r8, r6, #COLUMNS+1	@; r8 = *valorIzquierdo
					ldrb r7, [r4, r8]
					sub r10, r6, #COLUMNS-1	@; r10 = *valorDerecho = *matriz[i-1][j+1] = *matriz[i][j]-(COLUMNS-1)
					ldrb r9, [r4, r10]
					
					.LSiAmbosValidos:
						@; if (es_valor_valido(valorIzquierdo) && es_valor_valido(valorDerecho))
						mov r0, r7
						bl es_valor_valido
						cmp r0, #1
						bne .LFinSiAmbosValidos
						mov r0, r9
						bl es_valor_valido
						cmp r0, #1
						bne .LFinSiAmbosValidos
						
						mov r0, #2
						bl mod_random
						@; r0 = 0 -> r7 = valorIzquierdo, r8 = *valorIzquierdo
						@; r0 != 0 -> r7 = valorDerecho, r8 = *valorDerecho
						cmp r0, #0
						movne r7, r9
						movne r8, r10
						
						mov r0, r5
						mov r1, r7
						bl cambiar_3bits_menores
						strb r0, [r4, r6]
						strb r1, [r4, r8]
						mov r11, #1
						
						b .LFinSiAmbosValidos
					.LSinoAmbosValidos1:
						@; else if (esValorValido(valorIzquierdo))
						mov r0, r7
						bl es_valor_valido
						cmp r0, #1
						bne .LSinoAmbosValido2
						
						mov r0, r5
						mov r1, r7
						bl cambiar_3bits_menores
						strb r0, [r4, r6]
						strb r1, [r4, r8]
						mov r11, #1
						
						b .LFinSiAmbosValidos
					.LSinoAmbosValido2:
						@; else if (esValorValido(valorDerecho))
						mov r0, r9
						bl es_valor_valido
						cmp r0, #1
						bne .LFinSiAmbosValidos
						
						mov r0, r5
						mov r1, r9
						bl cambiar_3bits_menores
						strb r0, [r4, r6]
						strb r1, [r4, r10]
						mov r11, #1
						
					.LFinSiAmbosValidos:
					
					ldrb r7, [r4, r8]
					
				.LFinSiValorValido:
				
			.LFinSiCero3:
			sub r3, #1
			b .LBucleColumnas3
		.LFinBucleColumnas3:
		sub r2, #1
		b .LBucleFilas3
	.LFinBucleFilas3:
	
		mov r2, #0
		mov r3, #0
	@; Busqueda de los valores 0 más altos de cada columna
	.LBucleColumnas4:
		@; while (j<COLUMNS)
		cmp r3, #COLUMNS
		bge .LFinBucleColumnas4
		mov r2, #0
		.LBucleFilas4:
			@; while (i<ROWS)
			cmp r2, #ROWS
			bge .LFinBucleFilas4
			@; r5 = matriz[i][j]
			mov r5, #COLUMNS
			mla r6, r2, r5, r3
			ldrb r5, [r4, r6]
			
			@; if (matriz[i][j] == bloqueSolido) break;
			cmp r5, #0x7
			beq .LFinBucleFilas4
			
			.LSiCero4:
				@; if (matriz[i][j] == 0)
				tst r5, #0x7
				bne .LFinSiCero4
				@; Genero numero random entre 1 y 6
				mov r0, #5
				bl mod_random
				add r0, #1
				@; Asigno al valor 0 el numero aleatorio
				add r5, r0
				strb r5, [r4, r6]
				@; break
				b .LFinBucleFilas4
			.LFinSiCero4:
			
			add r2, #1
			b .LBucleFilas4
		.LFinBucleFilas4:
		
		add r3, #1
		b .LBucleColumnas4
	.LFinBucleColumnas4:
		mov r0, r11
		pop {r1-r11,pc}


@; es_valor_valido(valor): rutina para comprovar si un elemento es valido.
@;	Un elemento es considerado valido si sus 3 bits de menor peso están
@;	entre [001..110], es decir entre 1 y 6.
@;	devuelve cierto (1) si el valor es valido o falso (0) si no lo es.
@;	Parámetros:
@;		R0 = el valor a comprovar la validez
@;	Resultado:
@;		R0 = booleano indicando si el valor es o no valido. 
es_valor_valido:
		push {r1,lr}
		mvn r1, r0
	.LSi:
		@; if ((valor & 0x7 == 0) && (!valor & 0x7 == 0))
		tst r0, #0x7
		beq .LSino
		tst r1, #0x7
		beq .LSino
		@; el valor es valido
		mov r0, #1
		b .LFinSi
	.LSino:
		mov r0, #0
	.LFinSi:
		pop {r1,pc}

@; cambiar_3bits_menores(valor1, valor2): rutina para intercambiar los 3 bits
@;	de menor peso de 2 valores.
@;	Parámetros:
@;		R0 = el primer valor a intercambiar
@;		R1 = el segundo valor a intercambiar
@;	Resultado:
@;		En los 3 bits de menor peso de R1 quedan los 3 bits de menor peso de R0
@;		y viceversa.
cambiar_3bits_menores:
		push {r2-r3,lr}
		@; obtengo los 3 bits de menor peso
		and r2, r0, #0x7
		and r3, r1, #0x7
		@; los intercambio
		sub r0, r2
		add r0, r3
		sub r1, r3
		add r1, r2
		pop {r2-r3,pc}
.end
