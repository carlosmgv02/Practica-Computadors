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
		push {r1-r8, lr}
		
		mov r5, #COLUMNS
		mla r6, r1, r5, r2		@;R6 = f * COLUMNS + c
		add r4, r0, r6			@;R4 apunta al elemento (f,c) de 'mat'
		ldrb r5, [r4]
		
		and r5, #7				@;R5 es el valor filtrado (sin marcas de gel.)
		mov r0, #1				@;R0 = número de repeticiones
		
		@; r7 = # posiciones a comprovar  
		@; r8 = posiciones a moverse hasta la siguiente casilla a evaluar
		@; Este
		cmp r3, #0
		rsb r7, r2, #COLUMNS 	
		moveq r8, #1			
		@; Sur
		cmp r3, #1
		rsb r7, r1, #ROWS
		moveq r8, #COLUMNS
		@; Oeste
		cmp r3, #2
		moveq r7, r2
		moveq r8, #-1			
		@;Norte
		cmp r3, #3
		moveq r7, r1
		moveq r8, #-COLUMNS
			
	.LBucle:
		@; (i != 0)
		cmp r7, #0
		beq .LFinBucle
		@; Obtener el siguiente valor
		add r4, r8
		ldrb r3, [r4]
		and r3, #7
		@; Evaluar el siguiente valor
		cmp r5, r3
		addeq r0, #1
		bne .LFinBucle
		@; i--
		sub r7, #1
		b .LBucle
	.LFinBucle:
		
		pop {r1-r8, pc}



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
		cmp r0, #0
		bleq baja_laterales
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
					@; obtengo los 3 bits de menor peso
					and r0, r5, #0x7
					and r1, r7, #0x7
					@; los intercambio
					sub r5, r0
					add r5, r1
					sub r7, r1
					add r7, r0
					
					strb r5, [r4, r6]
					strb r7, [r4, r8]
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
		
		bl genera_elementos
		@; Si ha habido una bajada de elemento o se han generado elementos entonces retorna cierto
		orr r0, r11
		pop {r1-r11,pc}




@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en diagonal; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 
baja_laterales:
		push {r1-r12,lr}
		mov r11, #0			@; r11 = valor de retorno, por defecto es falso
		mov r2, #ROWS-1		@; r2 = i = ROWS-1
		
	.LBucleFilas3:
		@; while (i>0)
		cmp r2, #0
		ble .LFinBucleFilas3
		@; r3 = j = COLUMNS-1
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
				
				mov r0, #0
				mov r1, #0
				.LSiIzquierdoEsValido:
					@; r1 = !limDerecho && esValorValido(valorDerecho)
					cmp r3, #COLUMNS-1
					bge .LSiDerechoEsValido
					sub r8, r6, #COLUMNS-1
					ldrb r7, [r4, r8]
					mov r0, r7
					bl es_valor_valido
					mov r1, r0
				.LSiDerechoEsValido:
					@; r0 = !limIzquierdo && esValorValido(valorIzquierdo)
					cmp r3, #0
					ble .LFinEsValido
					sub r8, r6, #COLUMNS+1
					ldrb r7, [r4, r8]
					mov r0, r7
					bl es_valor_valido
				.LFinEsValido:
				
					
				@; ValorIzquierdo: !limIzquierdo && (es_valor_valido(valorIzquierdo) && (limDerecho || random==0) )
				@; ValorDerecho: !limDerecho && (es_valor_valido(valorDerecho) && (limIzquierdo || random==1) )
				
				tst r0, r1
				bne .LAmbosValidos
				cmp r0, #1
				beq .LIzquierdoValido
				cmp r1, #1
				beq .LDerechoValido
				b .LNoValidos
				
				.LAmbosValidos:
					mov r0, #2
					bl mod_random
					cmp r0, #0
					subeq r8, r6, #COLUMNS+1	@; r8 = *valorIzquierdo
					subne r8, r6, #COLUMNS-1	@; r8 = *valorDerecho
					b .LFinValidos
				.LIzquierdoValido:
					sub r8, r6, #COLUMNS+1	@; r8 = *valorIzquierdo
					b .LFinValidos
				.LDerechoValido:
					sub r8, r6, #COLUMNS-1	@; r8 = *valorIzquierdo
					b .LFinValidos
				.LFinValidos:
					@; r7 = elemento seleccionado (Izquierdo o derecho)
					ldrb r7, [r4, r8]
					@; Bajo el elemento
					and r12, r7, #0x7
					sub r7, r12
					add r5, r12
					strb r5, [r4, r6]
					strb r7, [r4, r8]
					@; Exito
					mov r11, #1
				.LNoValidos:
				
			.LFinSiCero3:
			sub r3, #1
			b .LBucleColumnas3
		.LFinBucleColumnas3:
		sub r2, #1
		b .LBucleFilas3
	.LFinBucleFilas3:
		
		bl genera_elementos
		@; Si ha habido una bajada de elemento o se han generado elementos entonces retorna cierto
		orr r0, r11
		pop {r1-r12,pc}

@; genera_elementos(mat): rutina para generar aleatoriamente el valor de los
@;	elementos de las posiciones más altas de cada columna, sin tener en cuenta
@;	los huecos, siempre y cuando sea un elemento vacío
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica si ha generado algún valor. 
genera_elementos:
	push {r1-r6,lr}
	mov r6, #0
	mov r1, #0
	mov r2, #0
	.LBucleColumnasGeneraElementos:
		@; while (r1<COLUMNS-1)
		cmp r1, #COLUMNS
		bge .LFinBucleColumnasGeneraElementos
		@; Obtener el primer elemento de la columna
		mov r3, #COLUMNS
		mla r5, r2, r3, r1
		ldrb r3, [r4, r5]
		@; No tengo en cuenta los huecos
		.LBuclePasaHueco:
			cmp r2, #ROWS
			bge .LFinBuclePasaHueco
			cmp r3, #0xF
			bne .LFinBuclePasaHueco
			@; En caso de hueco obtengo el siguiente valor
			add r5, #COLUMNS
			ldrb r3, [r4, r5]
			add r2, #1
			b .LBuclePasaHueco
		.LFinBuclePasaHueco:
		@; Si es un elemento vacío lo cambio por un numero aleatorio
		.LSiElementoVacio:
			tst r3, #0x7
			bne .LFinSiElementoVacio
			@; Generar elemento random
			mov r0, #6
			bl mod_random
			add r0, #1
			@; Añado el elemento a la casilla, como es 0 solo tengo que sumarlo
			add r3, r0
			strb r3, [r4, r5]
			@; Generado con exito
			mov r6, #1
		.LFinSiElementoVacio:
		mov r2, #0
		add r1, #1
		b .LBucleColumnasGeneraElementos
	.LFinBucleColumnasGeneraElementos:
	mov r0, r6
	pop {r1-r6,pc}


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

.end
