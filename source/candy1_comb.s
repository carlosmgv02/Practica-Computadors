	@;=                                                               		=
	@;=== candy1_combi.s: rutinas para detectar y sugerir combinaciones   ===
	@;=                                                               		=
	@;=== Programador tarea 1G: carlos.martinezg@estudiants.urv.cat				  ===
	@;=== Programador tarea 1H: carlos.martinezg@estudiants.urv.cat				  ===
	@;=                                                             	 	=



	.include "../include/candy1_incl.i"

	@;-- .text. c�digo de las rutinas ---
	.text	
			.align 2
			.arm

	@;TAREA 1G;
	@; hay_combinacion(*matriz): rutina para detectar si existe, por lo menos, una
	@;	combinaci�n entre dos elementos (diferentes) consecutivos que provoquen
	@;	una secuencia v�lida, incluyendo elementos en gelatinas simples y dobles.
	@;	Par�metros:
	@;		R0 = direcci�n base de la matriz de juego
	@;	Resultado:
	@;		R0 = 1 si hay una secuencia, 0 en otro caso
	@; USO DE REGISTROS
	@;		R1 = i
	@;		R2 = j
	@;		R3 = matriz[i][j]
	@;		R4 = posicion actual
	@;		R5 = COLUMNS
	@;		R6 = ROWS
	@;		R7 = matriz[i+1][j]
	@;		R8 = aux
	@;		R9 = not used
	@;		R10 = 
	@;		R11 = 
	@; 		R12 = 
		.global hay_combinacion
	hay_combinacion:
			push {r1-r12,lr}
			mov r5, #COLUMNS
			mov r6, #ROWS
			mov r1 ,#0	@;i
			
			mov r4, r0
		.Lfor_Row:
			cmp r1,r6
			bhs .Lendfor_Rows		@; saltar al final si excede el rango
			mov r2 ,#0	@;j
		.Lfor_Col:
			cmp r2,r5
			bhs .Lendfor_Col		@; saltar al final si excede el rango
	@;	.Lifz:	
			mla r8,r1,r5,r2			@;cálculo dirección (i*COLUMNS)+j
			ldrb r3, [r4, r8]		@;guardo el contenido de la posicion de memoria
			
			tst r3, #0x07			@;tst	0111, 0[000] = 0000 miro si son 0
									@; para ver si un bloque es sólido(0111), hueco(1111)
			beq	.Lendiftotal		
			mvn r7, r3				@;alternativament 0xF8=NOT(0x07) 
			tst r7, #0x07			@; miro si son 1(espacio vacio)
			beq	.Lendiftotal
	@;	If2
			cmp r2, #COLUMNS-1		@;miro si estoy en la ultima columna para saltar a comprobar si zona blanca o naranja
			bne .Lelse				@; si no estoy, salto y compruebo si estoy en la ultima fila
	@; 	If3	zona azul, solo compruebo con el de abajo, porq estoy en la ultima col
			cmp r1, #ROWS-1			@;si estoy en la ultima col y ultima fil, salto al fin del if
			beq .Lendiftotal
			@;comprovamos si bloq solido, etc
			add r1, #1				@;fila++
			mla r8, r1, r5, r2		@;cálculo dirección (i*COLUMNS)+j
			ldrb r7, [r4, r8]		@;matriz[i+1][j]
			tst r7, #0x07			@;tst	0111, 0[000] = 0000 AND bit a bit
			@;add r1, #-1
			beq .Lendiftotal
			mvn r7, r7
			tst r7, #0x07
			beq .Lendiftotal
			mvn r7, r7
			cmp r7, r3    			@; r3 = num arriba  r7 = num abajo
			beq .Lendiftotal
			
			bl swapV				@;cambio actual con el de abajo

			bl detectar_orientacion
			mov r12, r7
			mov r7, r3
			mov r3, r12
			bl swapV
			cmp r0, #6
			blo .Lreturn1
			mov r12, r7
			mov r7, r3
			mov r3, r12
			bl swapV
			add r1, #1
			bl detectar_orientacion
			add r1, #-1
			mov r12, r7
			mov r7, r3
			mov r3, r12
			bl swapV
			cmp r0, #6
			blo .Lreturn1
			b .Lendiftotal
		
		.Lelse:		@;zona naranja, ultima fila, comprobar con el de la derecha
			
			cmp r1, #ROWS-1
			bne .Lelse2		@;si no estoy en última fila ni ultima col, estoy en zona blanca
			
			add r2, #1
			mla r8, r1, r5, r2		@;cálculo dirección (i*COLUMNS)+j
			ldrb r7, [r4, r8]		@;matriz[i][j+1]
			tst r7, #0x07			@;tst	0111, 0[000] = 0000
			add r2, #-1
			beq .Lendiftotal
			mvn r7, r7
			tst r7, #0x07
			beq .Lendiftotal
			mvn r7, r7
			cmp r7, r3    @; r3 = num arriba  r7 = num abajo
			beq .Lendiftotal
		
			bl swapH						@;estan intercambiados
		
			bl detectar_orientacion			@;devuelve numero 1-6, 0-5 combinaciones y 6 no comb/miramos posi actual
			mov r12, r7
			mov r7, r3
			mov r3, r12
			bl swapH						@;estan como estaban originalmente, antes de mirar nada
			cmp r0, #6
			blo .Lreturn1					@;hay comb
			mov r12, r7
			mov r7, r3
			mov r3, r12
			bl swapH						@;intercambiados
			add r2, #1
			bl detectar_orientacion			@;miramos posi de la derecha
			add r2, #-1
			mov r12, r7
			mov r7, r3
			mov r3, r12
			bl swapH						@;como originalmente
			cmp r0, #6
			blo .Lreturn1
			b .Lendiftotal
			
		.Lelse2:	@;zona blanca, hay que comprobar con derecha y abajo
			
			add r1, #1
			mla r8, r1, r5, r2		@;cálculo dirección (i*COLUMNS)+j
			ldrb r7, [r4, r8]		@;matriz[i+1][j]
			tst r7, #0x07			@;tst	0111, 0[000] = 0000
			add r1, #-1
			beq .LHor
			mvn r7, r7
			tst r7, #0x07
			beq .LHor
			mvn r7, r7
			cmp r7, r3    @; r3 = num izquierda  r7 = num derecha
			beq .LHor
			
			bl swapV
		
			bl detectar_orientacion
			mov r12, r7
			mov r7, r3
			mov r3, r12
			bl swapV
			cmp r0, #6
			blo .Lreturn1
			mov r12, r7
			mov r7, r3
			mov r3, r12
			bl swapV
			add r1, #1
			bl detectar_orientacion
			add r1, #-1
			mov r12, r7
			mov r7, r3
			mov r3, r12
			bl swapV
			cmp r0, #6
			blo .Lreturn1
			mov r3, r7

	.LHor:						
			add r2, #1
			mla r8, r1, r5, r2		@;cálculo dirección (i*COLUMNS)+j
			ldrb r7, [r4, r8]		@;matriz[i][j+1]
			tst r7, #0x07			@;tst	0111, 0[000] = 0000
			add r2, #-1
			beq .Lendiftotal
			mvn r7, r7
			tst r7, #0x07
			beq .Lendiftotal
			mvn r7, r7
			cmp r7, r3    @; r3 = num izquierda  r7 = num derecha
			beq .Lendiftotal

			bl swapH
		
			bl detectar_orientacion
			mov r12, r7
			mov r7, r3
			mov r3, r12
			bl swapH
			cmp r0, #6
			blo .Lreturn1
			mov r12, r7
			mov r7, r3
			mov r3, r12
			bl swapH
			add r2, #1
			bl detectar_orientacion
			add r2, #-1
			mov r12, r7
			mov r7, r3
			mov r3, r12
			bl swapH
			cmp r0, #6
			blo .Lreturn1
			
			
		.Lendiftotal:
			add	r2, #1	@; j++
			b .Lfor_Col	@; saltar al for
		.Lendfor_Col:	
			add r1, #1	@; i++
			b .Lfor_Row
		.Lendfor_Rows:
			mov r0, #0
			b .Lreturn0
		.Lreturn1:
			mov r0, #1
		.Lreturn0:
			pop {r1-r12,pc}




	@;TAREA 1H;
	@; sugiere_combinacion(*matriz, *sug): rutina para detectar una combinaci�n
	@;	entre dos elementos (diferentes) consecutivos que provoquen una secuencia
	@;	v�lida, incluyendo elementos en gelatinas simples y dobles, y devolver
	@;	las coordenadas de las tres posiciones de la combinaci�n (por referencia).
	@;	Restricciones:
	@;		* se supone que existe por lo menos una combinaci�n en la matriz
	@;			 (se debe verificar antes con la rutina 'hay_combinacion')
	@;		* la combinaci�n sugerida tiene que ser escogida aleatoriamente de
	@;			 entre todas las posibles, es decir, no tiene que ser siempre
	@;			 la primera empezando por el principio de la matriz (o por el final)
	@;		* para obtener posiciones aleatorias, se invocar� la rutina 'mod_random'
	@;			 (ver fichero "candy1_init.s")
	@;	Par�metros:
	@;		R0 = direcci�n base de la matriz de juego
	@;		R1 = direcci�n del vector de posiciones (char *), donde la rutina
	@;				guardar� las coordenadas (x1,y1,x2,y2,x3,y3), consecutivamente.
		.global sugiere_combinacion
	sugiere_combinacion:
			push {r0-r12,lr}
			mov r4,r0	@;direccion base de la matriz de juego
			mov r8,r1	@;direccion del vector de posiciones
			mov r0,#COLUMNS
			mov r5,#COLUMNS
			bl mod_random
			mov r2,r0 @;columna aleatoria
			mov r0,#ROWS
			bl mod_random
			mov r1,r0	@;fila aleatoria


			.Lwhile:
			
			mla r6, r1, r5, r2
			add r10, r4, r6
			ldrb r3,[r4,r6]
			tst r3, #7
			beq .Lfinal
			mvn r9,r3
			tst r9, #7
			beq .Lfinal
			
			cmp r1, #ROWS-1
			bhs .LLastRow
			cmp r2, #COLUMNS-1
			bhs .LLastColumn
			@;zona blanca comprobar derecha i abajo	

				@;Horizontal
			add r10, #1		@;direccio mem matriu+1
			ldrb r7, [r10]
			add r10, #-1	@;deixo r10 com estava
			tst r7, #7
			beq .Lfinal
			mvn r9,r7
			tst r9, #7
			beq .Lfinal
			cmp r3, r7
			beq .Lfinal

			bl swapH

			mov r11, #0		@;ficha naranja der
			bl detectar_orientacion
			cmp r0, #6		@;si no hay sec, ficha nar izq
			blt .LfiHor		@;si no hay sec, sigo, si no, salto
			add r2, #1		@;j+1 para mirar posi derecha
			mov r11, #1		@;ficha naranja en izq
			bl detectar_orientacion
			add r2, #-1		@;restauro valor de j
			cmp r0, #6
			blt .LfiHor
			mov r12, r7
			mov r7, r3
			mov r3, r12
			bl swapH
			mov r3, r7

				@;vertical
			add r1, #1
			mla r6, r1, r5, r2	@;dir memoria de j+1
			add r1, #-1			@;j--, la dejo como estaba
			add r10, r4, r6
			ldrb r7, [r10]
			tst r7, #7
			beq .Lfinal
			mvn r9,r7
			tst r9, #7
			beq .Lfinal
			cmp r3, r7
			beq .Lfinal

			bl swapV

			mov r11, #2		@;ficha naranja abajo
			bl detectar_orientacion
			cmp r0, #6		@;si no hay sec
			blt .LfiVer
			add r1, #1		@;swap vertical, i++ para mirar siguiente
			mov r11, #3		@;ficha naranja arriba
			bl detectar_orientacion
			add r1, #-1		@;restauro valor de i
			cmp r0, #6
			blt .LfiVer
			mov r12, r7
			mov r7, r3
			mov r3, r12
			@; r3=r7 i r7=r3
			bl swapV		
			mov r3, r7

			b .Lfinal
		
			@;Ultima Columna, zona azul, solo swap vert
		.LLastColumn:

			add r1, #1		@;dir mem i+1
			mla r6, r1, r5, r2
			add r1, #-1		@;restauro valor i
			add r10, r4, r6
			ldrb r7, [r10]
			tst r7, #7
			beq .Lfinal
			mvn r9,r7
			tst r9, #7
			beq .Lfinal
			cmp r3, r7
			beq .Lfinal
			

			bl swapV

			mov r11, #2			@;ficha naranja abajo
			bl detectar_orientacion
			cmp r0, #6			@; si no hay sec, ficha nar arrib
			blt .LfiVer
			add r1, #1
			mov r11, #3			@;ficha naranja arriba 
			bl detectar_orientacion
			add r1, #-1
			cmp r0, #6
			blt .LfiVer
			mov r12, r7
			mov r7, r3
			mov r3, r12
			bl swapV
			mov r3, r7

			b .Lfinal
			
			@;Última fila, zona naranja, solo swap horiz
		.LLastRow:
			cmp r2, #COLUMNS-1
			movhs r1, #0
			movhs r2, #0
			bhs .Lwhile

			add r10, #1
			ldrb r7, [r10]
			add r10, #-1
			tst r7, #7
			beq .Lfinal
			mvn r9,r7
			tst r9, #7
			beq .Lfinal
			cmp r3, r7
			beq .Lfinal

			bl swapH

			mov r11, #0
			bl detectar_orientacion
			cmp r0, #6
			blt .LfiHor
			add r2, #1
			mov r11, #1
			bl detectar_orientacion
			add r2, #-1
			cmp r0, #6
			blt .LfiHor
			mov r12, r7
			mov r7, r3
			mov r3, r12
			bl swapH
			mov r3, r7

		.Lfinal:

			add r2, #1

			cmp r2, #COLUMNS
			blo .Lfi
			addhs r1, #1
			movhs r2, #0

			cmp r1, #ROWS
			movhs r1, #0
			movhs r2, #0
			bhs	.Lwhile
		.Lfi:
			b .Lwhile

		.LfiHor:		@;primer restauro les posicions de cada número

			mov r12, r7
			mov r7, r3
			mov r3, r12
			bl swapH

			b .Lsugerir

		.LfiVer:		@;primer restauro les posicions de cada número

			mov r12, r7
			mov r7, r3
			mov r3, r12
			bl swapV

		.Lsugerir:	
			cmp r11, #1
			addeq r2, #1 @;como hacemos swap con el de izq le sumamos 1 a j
			cmp r11, #3
			addeq r1, #1
		
			mov r3, r0
			mov r0, r8
			mov r4, r11

			bl generar_posiciones
		
			
			pop {r0-r12,pc}


	@;:::RUTINAS DE SOPORTE:::



	@; generar_posiciones(vect_pos,f,c,ori,cpi): genera las posiciones de sugerencia
	@;	de combinación, a partir de la posición inicial (f,c), el código de
	@;	orientación 'ori' y el código de posición inicial 'cpi', dejando las
	@;	coordenadas en el vector 'vect_pos'.
	@;	Restricciones:
	@;		* se supone que la posición y orientación pasadas por parámetro se
	@;			corresponden con una disposición de posiciones dentro de los límites
	@;			de la matriz de juego
	@;	Parámetros:
	@;		R0 = dirección del vector de posiciones 'vect_pos'
	@;		R1 = fila inicial 'f'
	@;		R2 = columna inicial 'c'
	@;		R3 = código de orientación;
	@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
	@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
	@;		R4 = código de posición inicial:
	@;				0 -> izquierda, 1 -> derecha, 2 -> arriba, 3 -> abajo
	@;	Resultado:
	@;		vector de posiciones (x1,y1,x2,y2,x3,y3), devuelto por referencia
	generar_posiciones:
			push {r0-r4,lr}
				
			cmp r4, #0
			beq .Lcpi0
			cmp r4, #1
			beq .Lcpi1
			cmp r4, #2
			beq .Lcpi2
			cmp r4, #3
			beq .Lcpi3
			
			b .Lfin

		.Lcpi0:
			add r2, #1
			strb r2, [r0]
			add r2, #-1
			add r0, #1
			strb r1, [r0]
			add r0, #1
			
			b .Lcori

		.Lcpi1:
			add r2, #-1
			strb r2, [r0]
			add r2, #1
			add r0, #1
			strb r1, [r0]
			add r0, #1
			
			b .Lcori

		
		.Lcpi2:
			strb r2, [r0]
			add r0, #1
			add r1, #1
			strb r1, [r0]
			add r1, #-1
			add r0, #1
			
			b .Lcori

		.Lcpi3:
			strb r2, [r0]
			add r0, #1
			add r1, #-1
			strb r1, [r0]
			add r1, #1
			add r0, #1
			
		.Lcori:
			cmp r3, #0
			beq .Lcori0
			cmp r3, #1
			beq .Lcori1
			cmp r3, #2
			beq .Lcori2
			cmp r3, #3
			beq .Lcori3
			cmp r3, #4
			beq .Lcori4
			cmp r3, #5
			beq .Lcori5
			
			b .Lfin

		
			
		.Lcori0:
			add r2,#1
			strb r2,[r0]
			add r0,#1
			strb r1,[r0]
			add r2,#1
			add r0,#1
			strb r2,[r0]
			add r0,#1
			strb r1,[r0]
		
			b .Lfin

		.Lcori1:
			strb r2,[r0]
			add r0,#1
			add r1,#1
			strb r1,[r0]
			add r0,#1
			strb r2,[r0]
			add r0,#1
			add r1,#1
			strb r1,[r0]

			b .Lfin
			
		.Lcori2:
			add r2,#-1
			strb r2,[r0]
			add r0,#1
			strb r1,[r0]
			add r2,#-1
			add r0,#1
			strb r2,[r0]
			add r0,#1
			strb r1,[r0]
		
			b .Lfin

		
		.Lcori3:
			strb r2,[r0]
			add r0,#1
			add r1,#-1
			strb r1,[r0]
			add r0,#1
			strb r2,[r0]
			add r0,#1
			add r1,#-1
			strb r1,[r0]

			b .Lfin
		
		.Lcori4:
			add r2,#-1
			strb r2,[r0]
			add r0,#1
			strb r1,[r0]
			add r2,#2
			add r0,#1
			strb r2,[r0]
			add r0,#1
			strb r1,[r0]
			
			b .Lfin
		.Lcori5:
			strb r2,[r0]
			add r0,#1
			add r1,#-1
			strb r1,[r0]
			add r0,#1
			strb r2,[r0]
			add r1,#2
			add r0,#1
			strb r1,[r0]

		.Lfin:


			pop {r0-r4,pc}


	@; detectar_orientacion(f,c,mat): devuelve el c�digo de la primera orientaci�n
	@;	en la que detecta una secuencia de 3 o m�s repeticiones del elemento de la
	@;	matriz situado en la posici�n (f,c).
	@;	Restricciones:
	@;		* para proporcionar aleatoriedad a la detecci�n de orientaciones en las
	@;			que se detectan secuencias, se invocar� la rutina 'mod_random'
	@;			(ver fichero "candy1_init.s")
	@;		* para detectar secuencias se invocar� la rutina 'cuenta_repeticiones'
	@;			(ver fichero "candy1_move.s")
	@;		* s�lo se tendr�n en cuenta los 3 bits de menor peso de los c�digos
	@;			almacenados en las posiciones de la matriz, de modo que se ignorar�n
	@;			las marcas de gelatina (+8, +16)
	@;	Par�metros:
	@;		R1 = fila 'f'
	@;		R2 = columna 'c'
	@;		R4 = direcci�n base de la matriz
	@;	Resultado:
	@;		R0 = c�digo de orientaci�n;
	@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
	@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
	@;				sin secuencia: 6 
	detectar_orientacion:
			push {r3, r5, lr}
			
			mov r5, #0				@;R5 = �ndice bucle de orientaciones
			mov r0, #4
			bl mod_random
			mov r3, r0				@;R3 = orientaci�n aleatoria (0..3)
		.Ldetori_for:
			mov r0, r4
			bl cuenta_repeticiones
			cmp r0, #1
			beq .Ldetori_cont		@;no hay inicio de secuencia
			cmp r0, #3
			bhs .Ldetori_fin		@;hay inicio de secuencia
			add r3, #2
			and r3, #3				@;R3 = salta dos orientaciones (m�dulo 4)
			mov r0, r4
			bl cuenta_repeticiones
			add r3, #2
			and r3, #3				@;restituye orientaci�n (m�dulo 4)
			cmp r0, #1
			beq .Ldetori_cont		@;no hay continuaci�n de secuencia
			tst r3, #1
			bne .Ldetori_vert
			mov r3, #4				@;detecci�n secuencia horizontal
			b .Ldetori_fin
		.Ldetori_vert:
			mov r3, #5				@;detecci�n secuencia vertical
			b .Ldetori_fin
		.Ldetori_cont:
			add r3, #1
			and r3, #3				@;R3 = siguiente orientaci�n (m�dulo 4)
			add r5, #1
			cmp r5, #4
			blo .Ldetori_for		@;repetir 4 veces
			
			mov r3, #6				@;marca de no encontrada
			
		.Ldetori_fin:
			mov r0, r3				@;devuelve orientaci�n o marca de no encontrada
			
			pop {r3, r5, pc}



			@; r3 = num izquierda  r7 = num derecha
			@; r4 = direccion de la matriz r5 = Columnas
			@; r1 = i  r2 = j
		swapH:
			push {r1-r7,lr}
				
			mla r6, r1, r5, r2
			strb r7,[r4,r6]
			add r2, #1
			mla r6, r1, r5, r2
			strb r3,[r4,r6]
				
			pop {r1-r7,pc}
		
		
		
			@; r3 = num arriba  r7 = num abajo
			@; r4 = direccion de la matriz r5 = Columnas
			@; r1 = i  r2 = j
		swapV:
			push {r1-r7,lr}
			
				mla r6, r1, r5, r2
				strb r7,[r4,r6]
				add r1, #1
				mla r6, r1, r5, r2
				strb r3,[r4,r6]
			
			pop {r1-r7,pc}

	.end
