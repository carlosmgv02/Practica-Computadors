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

@; Valores Constantes
	@; Booleanos
	TRUE = 1
	FALSE = 0
	@; Manipulacion de elementos
	MASC_3BITS_MENORES = 0x7
	HUECO = 0xF
	BLOQUE_SOLIDO = 0x7
	@; Orientaciones
	ESTE = 0
	SUR = 1
	OESTE = 2
	NORTE = 3

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
	push {r1-r5, lr}
		@;R4 = *mat[i][j]
		mov r4, #COLUMNS
		mla r4, r1, r4, r2
		add r4, r0
		
		ldrb r5, [r4]
		and r5, #MASC_3BITS_MENORES	
		
		@; r1 = # posiciones a comprovar  
		@; r2 = posiciones a moverse hasta la siguiente casilla a evaluar
		
		.LOrientacion:
			@; Este
			cmp r3, #ESTE
			rsbeq r1, r2, #COLUMNS-1 	
			moveq r2, #1
			beq .LFinOrientacion
			@; Sur
			cmp r3, #SUR
			rsbeq r1, r1, #ROWS-1
			moveq r2, #COLUMNS
			beq .LFinOrientacion
			@; Oeste
			cmp r3, #OESTE
			moveq r1, r2
			moveq r2, #-1
			beq .LFinOrientacion	
			@;Norte
			cmp r3, #NORTE
			moveq r1, r1
			moveq r2, #-COLUMNS
			beq .LFinOrientacion
		.LFinOrientacion:
		@;R0 = número de repeticiones
		mov r0, #1
	.LBucle:
		@; (i != 0)
		cmp r1, #0
		beq .LFinBucle
		@; Obtener el siguiente valor
		add r4, r2
		ldrb r3, [r4]
		and r3, #MASC_3BITS_MENORES
		@; Evaluar el siguiente valor
		cmp r5, r3
		addeq r0, #1
		bne .LFinBucle
		@; i--
		sub r1, #1
		b .LBucle
	.LFinBucle:
		
	pop {r1-r5, pc}



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
		cmp r0, #TRUE
		blne baja_laterales
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
	push {r1-r9,lr}
		mov r9, #0			@; r9 = false
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
					
					@; r0 = iTemp
					mov r0, r1
					@; Pasar por los huecos superiores
					.LBucleHueco:
						@; while (iTemp>0 && valorSup==hueco)
						cmp r0, #0
						ble .LFinBucleHueco
						cmp r7, #0xF
						bne .LFinBucleHueco
						@; Obtengo el siguiente valor superior
						sub r8, #COLUMNS
						ldrb r7, [r4, r8]
						@; iTemp--
						sub r0, #1
						b .LBucleHueco
					.LFinBucleHueco:
					
					@; Si hay un elemento superior válido, entonces hay una bajada vertical
					.LSiElementoValido:
						@; if (es_elemento_basico(valorSup))
						mov r0, r7
						bl es_elemento_basico
						cmp r0, #1
						bne .LFinSiElementoValido
						
						push {r0,r1}
						mov r0, r6
						mov r1, r8
						@; r4 -> *base
						bl animar_cambio
						pop {r0,r1}
						
						@; Bajo el elemento
						and r0, r7, #0x7
						bic r7, #0x7
						add r5, r0
						strb r5, [r4, r6]
						strb r7, [r4, r8]
						
						@; Ya que ha habido una bajada vertical r11 = true
						mov r9, #1
					.LFinSiElementoValido:
				.LFinSiCero:
				sub r2, #1
				b .LBucleColumnas
			.LFinBucleColumnas:
			
			sub r1, #1
			b .LBucleFilas
		.LFinBucleFilas:
		
		bl genera_elementos
		orr r0, r9
	pop {r1-r9,pc}




@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en diagonal; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 
baja_laterales:
	push {r1-r9,lr}
		mov r9, #0			@; r9 = valor de retorno, por defecto es falso
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
					
					@; r0 = booleano indicando si el valor izquierdo es valido
					@; r1 = booleano indicando si el valor derecho es valido
					mov r0, #0
					mov r1, #0
					.LSiIzquierdoEsValido:
						@; r1 = !limDerecho && es_elemento_basico(valorDerecho)
						cmp r3, #COLUMNS-1
						bge .LSiDerechoEsValido
						sub r8, r6, #COLUMNS-1
						ldrb r7, [r4, r8]
						mov r0, r7
						bl es_elemento_basico
						mov r1, r0
					.LSiDerechoEsValido:
						@; r0 = !limIzquierdo && es_elemento_basico(valorIzquierdo)
						cmp r3, #0
						ble .LFinEsValido
						sub r8, r6, #COLUMNS+1
						ldrb r7, [r4, r8]
						mov r0, r7
						bl es_elemento_basico
					.LFinEsValido:
					
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
						subeq r8, r6, #COLUMNS+1	@; si r0 = 0 -> r8 = *valorIzquierdo
						subne r8, r6, #COLUMNS-1	@; si r0 != 0 -> r8 = *valorDerecho
						b .LFinValidos
					.LIzquierdoValido:
						sub r8, r6, #COLUMNS+1	@; r8 = *valorIzquierdo
						b .LFinValidos
					.LDerechoValido:
						sub r8, r6, #COLUMNS-1	@; r8 = *valorDerecho
						b .LFinValidos
					.LFinValidos:
						@; r7 = elemento seleccionado (Izquierdo o derecho)
						ldrb r7, [r4, r8]
						@; Bajo el elemento
						and r1, r7, #0x7
						bic r7, #0x7
						add r5, r1
						
						push {r0,r1}
						mov r0, r6
						mov r1, r8
						@; r4 -> *base
						bl animar_cambio
						pop {r0,r1}
						
						strb r5, [r4, r6]
						strb r7, [r4, r8]
						
						push {r0,r1}
						mov r0, r6
						mov r1, r8
						@; r4 -> *base
						bl animar_cambio
						pop {r0,r1}
						
						@; Exito, ha habido bajada
						mov r9, #1
					.LNoValidos:
					
				.LFinSiCero3:
				sub r3, #1
				b .LBucleColumnas3
			.LFinBucleColumnas3:
			sub r2, #1
			b .LBucleFilas3
		.LFinBucleFilas3:
		
		mov r0, r9
	pop {r1-r9,pc}

@; genera_elementos(mat): rutina para generar aleatoriamente el valor de los
@;	elementos de las posiciones más altas de cada columna, sin tener en cuenta
@;	los huecos, siempre y cuando sea un elemento vacío
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica si ha generado algún valor. 
genera_elementos:
	push {r1-r6,lr}
		mov r6, #FALSE
		mov r1, #0
		mov r2, #0
		.LBucleColumnasGeneraElementos:
			@; while (r2<COLUMNS-1)
			cmp r2, #COLUMNS
			bge .LFinBucleColumnasGeneraElementos
			@; No tengo en cuenta los huecos
			mov r0, r4
			@; r1 = 0
			@; r2 = columna
			mov r3, #SUR
			bl saltar_huecos
			mov r5, r0
			ldrb r3, [r5]
			
			@; Si es un elemento vacío lo cambio por un numero aleatorio
			.LSiElementoVacio:
				tst r3, #MASC_3BITS_MENORES
				bne .LFinSiElementoVacio
				@; Generar elemento random
				mov r0, #6
				bl mod_random
				add r0, #1
				@; Añado el elemento a la casilla, como es 0 solo tengo que sumarlo
				add r3, r0
				strb r3, [r5]
				@; Generado con exito
				
				push {r0,r1}
				mov r0, r3
				mov r1, #-1
				@; r2 -> columna
				bl crea_elemento
				pop {r0,r1}
				
				push {r0-r1,r4}
				sub r0, r4, #COLUMNS
				mov r1, r5
				sub r4, r2
				bl animar_cambio
				pop {r0-r1,r4}
				
				mov r6, #TRUE
			.LFinSiElementoVacio:
			
			add r4, #1
			add r2, #1
			b .LBucleColumnasGeneraElementos
		.LFinBucleColumnasGeneraElementos:
		mov r0, r6
	pop {r1-r6,pc}


@; rutina para obtener la direccion del elemento saltando los huecos empezando por la direccion
@;	inicial y en una orientacion especifica
@;	Parametros:
@;		r0 - direccion inicial
@;		r1 - fila de la direccion inicial dentro del tablero de juego
@;		r2 - columna de la direccion inicial dentro del tablero de juego
@;		r3 - orientación (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte)
@;	Retorna:
@;		r0 - la dirección del primer elemento no hueco o del último elemento que pueda evaluar
@;			antes de salirse del tablero de juego
saltar_huecos:
	push {r1-r3,lr}
		
		.LOrientacionRutAUXSH:
			cmp r3, #ESTE
			rsbeq r1, r2, #COLUMNS-1 	
			moveq r2, #1
			beq .LFinOrientacionRutAUXSH
			cmp r3, #SUR
			rsbeq r1, r1, #ROWS-1
			moveq r2, #COLUMNS
			beq .LFinOrientacionRutAUXSH
			cmp r3, #OESTE
			moveq r1, r2
			moveq r2, #-1
			beq .LFinOrientacionRutAUXSH
			cmp r3, #NORTE
			moveq r1, r1
			moveq r2, #-COLUMNS
			beq .LFinOrientacionRutAUXSH
		.LFinOrientacionRutAUXSH:
		
		.LBucleRutAUXSH:
			cmp r1, #0
			beq .LFinBucleRutAUXSH
			ldrb r3, [r0]
			cmp r3, #HUECO
			bne .LFinBucleRutAUXSH
			add r0, r2
			sub r1, #1
			b .LBucleRutAUXSH
		.LFinBucleRutAUXSH:
		
	pop {r1-r3,pc}


@; rutina para obtener la distancia hasta el siguiente elemento de la tabla según en una orientación
@;	Parametros:
@;		r0 - orientacion (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte)
@;	Retorna:
@;		r0 - distancia hasta el siguiente elemento
distancia_siguiente_elemento:
	push {r1,lr}
		tst r0, #0b01
		moveq r1, #1
		moveq r1, #COLUMNS
		tst r0, #0b10
		rsbne r1, #0
		mov r0, r1
	pop {r1,pc}


@; es_elemento_basico(valor): rutina para comprovar si un elemento es valido.
@;	Un elemento es considerado valido si sus 3 bits de menor peso están
@;	entre [001..110], es decir entre 1 y 6.
@;	Parámetros:
@;		R0 = el valor a comprovar la validez
@;	Resultado:
@;		R0 = booleano indicando si es un elemento básico (1) o no lo es (0). 
es_elemento_basico:
	push {lr}
		and r0, #MASC_3BITS_MENORES
		cmp r0, #0x7
		cmpne r0, #0x0
		movne r0, #TRUE
		moveq r0, #FALSE
	pop {pc}


@; animar_cambio(*elem1, *elem2, *base): rutina para animar el intercambio de 2 elementos
@;	Parámetros:
@;		R0 = dirección del primer elemento
@;		R1 = dirección del segundo elemento
@;		R4 = dirección base de la matriz
animar_cambio:
	push {r0-r3,lr}
		sub r0, r4
		mov r1, #0
		sub r2, r4
		mov r3, #0
		
	.LBucleCalculaY1:
		cmp r0, #COLUMNS
		ble .LFiBucleCalculaY2
			sub r0, #COLUMNS
			add r1, #1
		b .LBucleCalculaY1
	.LFiBucleCalculaY1:
		
	.LBucleCalculaY2:
		cmp r2, #COLUMNS
		ble .LFiBucleCalculaY2
			sub r2, #COLUMNS
			add r3, #1
		b .LBucleCalculaY2
	.LFiBucleCalculaY2:
		
		b activa_elemento
		
	pop {r0-r4,pc}



.end
