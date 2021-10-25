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
@;		R9 = 
@;		R10 = 
@;		R11 = 
@; 		R12 = 
	.global hay_combinacion
hay_combinacion:
		push {r1-r12,lr}
		mov r5, #COLUMNS
		mov r6, #ROWS
		mov r1 ,#0	@;i
		mov r2 ,#0	@;j
		mov r4, r0
	.Lfor_Row:
		cmp r1,r6
		bhs .Lendfor_Rows		@; saltar al final si excede el rango
		mov r2 ,#0	@;j
	.Lfor_Col:
		cmp r2,r5
		bhs .Lendfor_Col		@; saltar al final si excede el rango
@;	.Lifz:	@;If different from 0
		mla r8,r1,r5,r2		@;cálculo dirección (i*COLUMNS)+j
		ldrb r3, [r4, r8]	@;guardo el contenido de la posicion de memoria
		tst r3, #0x07			@;tst	0111, 0[000] = 0000
		beq	.Lendiftotal
		mvn r7, r3
		tst r7, #0x07
		beq	.Lendiftotal
@;	If2
		cmp r2, #COLUMNS-1
		bne .Lelse
@; 	If3
		cmp r1, #ROWS-1
		beq .Lendiftotal
		
		add r1, #1
		mla r8, r1, r5, r2
		ldrb r7, [r4, r8]	@;matriz[i+1][j]
		tst r7, #0x07			@;tst	0111, 0[000] = 0000
		add r1, #-1
		beq .Lendiftotal
		mvn r7, r7
		tst r7, #0x07
		beq .Lendiftotal
		mvn r7, r7
		cmp r7, r3    @; r3 = num arriba  r7 = num abajo
		beq .Lendiftotal
		
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
		b .Lendiftotal
	
	.Lelse:	
		
		cmp r1, #ROWS-1
		bne .Lelse2
		
		add r2, #1
		mla r8, r1, r5, r2
		ldrb r7, [r4, r8]	@;matriz[i][j+1]
		tst r7, #0x07			@;tst	0111, 0[000] = 0000
		add r2, #-1
		beq .Lendiftotal
		mvn r7, r7
		tst r7, #0x07
		beq .Lendiftotal
		mvn r7, r7
		cmp r7, r3    @; r3 = num arriba  r7 = num abajo
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
		b .Lendiftotal
		
	.Lelse2:
		
		add r1, #1
		mla r8, r1, r5, r2
		ldrb r7, [r4, r8]	@;matriz[i+1][j]
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
		mla r8, r1, r5, r2
		ldrb r7, [r4, r8]	@;matriz[i][j+1]
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
		
		add r1, #1
		mla r8, r1, r5, r2
		ldrb r7, [r4, r8]	@;matriz[i+1][j]
		tst r7, #0x07			@;tst	0111, 0[000] = 0000
		add r1, #-1
		beq .Lendiftotal
		mvn r7, r7
		tst r7, #0x07
		beq .Lendiftotal
		mvn r7, r7
		cmp r7, r3    @; r3 = num arriba  r7 = num abajo
		beq .Lendiftotal
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

@;		push {r1-r12,lr}
@;			mov r1,#COLUMNS
@;			bl mod_random
@;			add r1,#1
@;			mov r1,r0
@;			mov r1,#ROWS		@;i
@;			bl mod_random
@;			add r1,#1

@;			.Ini_combi:
@;			bl hay_combinacion
@;			cmp r0,#1
@;			bne .noCombi
@;
@;			bl detectar_orientacion
@;			mov r3,r0
@;			bl generar_posiciones
@;
@;			.noCombi:
@;			add r1,#1
@;			add r2,#1
@;			cmp r2,#ROWS-1
@;			beq .Checkcols
@;			bl .Ini_combi
			
@;			.Checkcols:
@;			cmp r1,#COLUMNS-1
@;			beq .sugiere_combinacion


			



		push {r1-r12,lr}
			mov r4,r0
			mov r3,r1
			mov r5, #COLUMNS
			mov r0, #COLUMNS
			bl mod_random
			mov r2,r0	@;mod_random me devuelve por r0  el num aleatorio
			
			mov r0,#ROWS
			bl mod_random
			mov r1,r0

.Lwhile:


.Lfor1:
			cmp r1, #ROWS-1
			bhs .Lfifor1
			mov r2, #0
.Lfor2:
			cmp r2, #COLUMNS
			bhs .Lfifor2



			mla r6, r1, r5, r2	@;Calculamos la dirección a partir de la dir base de la matriz
			strb r3, [r4, r6]	@;Guardamos el contenido en la dirección
			add r6, #1			@;Para no tener que hacer add r2,#r1 y mla otra vez  
			strb r7, [r4, r6]	@guardamos en r7 el contenido de la p
			add r6, #-1	


			mov r10, #0
			bl swapH	@;swap horizontal
			bl detectar_orientacion
			mov r12, r7
			mov r7, r3
			mov r3, r12
			bl swapH
			cmp r0, #6
			beq .Continuar1
			bl generar_posiciones
			b .Lfinal
.Continuar1:
			mla r6, r1, r5, r2	@;Calculamos la dirección a partir de la dir base de la matriz
			strb r3, [r4, r6]	@;Guardamos el contenido en la dirección
			add r6, #-1			@;Para no tener que hacer add r2,#r1 y mla otra vez  
			strb r7, [r4, r6]	@guardamos en r7 el contenido de la p
			add r6, #1	


			mov r10, #1
			bl swapH2
			bl detectar_orientacion
			mov r12, r7
			mov r7, r3
			mov r3, r12
			bl swapH2
			cmp r0, #6
			beq .Continuar2
			bl generar_posiciones
			b .Lfinal

.Continuar2:
			mla r6, r1, r5, r2	@;Calculamos la dirección a partir de la dir base de la matriz
			strb r3, [r4, r6]	@;Guardamos el contenido en la dirección
			add r1, #1			@;Para no tener que hacer add r2,#r1 y mla otra vez  
			mla r6, r1, r5, r2
			strb r7, [r4, r6]	@guardamos en r7 el contenido de la p
			add r6, #-1	

		
			mov r10, #2
			
			bl swapV		@;swap vertical abajo

			bl detectar_orientacion
			mov r12, r7
			mov r7, r3
			mov r3, r12
			bl swapV
			cmp r0, #6
			beq .Continuar3
			bl generar_posiciones
			b .Lfinal

.Continuar3:

			mla r6, r1, r5, r2	@;Calculamos la dirección a partir de la dir base de la matriz
			strb r3, [r4, r6]	@;Guardamos el contenido en la dirección
			add r1, #-1			@;Para no tener que hacer add r2,#r1 y mla otra vez  
			mla r6, r1, r5, r2
			strb r7, [r4, r6]	@guardamos en r7 el contenido de la p
			add r6, #1	

@;		pop {pc}

			mov r10, #3
			
			bl swapV2		@;swap vertical abajo


			bl detectar_orientacion
			mov r12, r7
			mov r7, r3
			mov r3, r12
			bl swapV2
			cmp r0, #6
			beq .Continuar4
			bl generar_posiciones
			b .Lfinal	

.Continuar4:

			add r2, #1
			b .Lfor2
.Lfifor2:
			add r1, #1
			b .Lfor1
.Lfifor1:	
			mov r1, #0
			mov r2, #0
			b .Lwhile

.Lfinal:

		pop {pc}




@;:::RUTINAS DE SOPORTE:::

@; generar_posiciones(vect_pos,f,c,ori,cpi): genera las posiciones de sugerencia
@;	de combinaci�n, a partir de la posici�n inicial (f,c), el c�digo de
@;	orientaci�n 'ori' y el c�digo de posici�n inicial 'cpi', dejando las
@;	coordenadas en el vector 'vect_pos'.
@;	Restricciones:
@;		* se supone que la posici�n y orientaci�n pasadas por par�metro se
@;			corresponden con una disposici�n de posiciones dentro de los l�mites
@;			de la matriz de juego
@;	Par�metros:
@;		R0 = direcci�n del vector de posiciones 'vect_pos'
@;		R1 = fila inicial 'f'
@;		R2 = columna inicial 'c'
@;		R3 = c�digo de orientaci�n;
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
@;		R4 = c�digo de posici�n inicial:
@;				0 -> izquierda, 1 -> derecha, 2 -> arriba, 3 -> abajo
@;	Resultado:

@; Si detectas en r10 = 0 el primer x1,y1 es el de la derecha, si r10 = 1 el primer x1,y1 es el de la izquierda, si r10 = 2 el primer x1,y1 es el de abajo, si r10 = 3 el primer x1,y1 es el de arriba,

@; Si r0 = 0 los dos segundos puntos son el de la derecha, si r0 = 1 los ods puntos don los de abajo, 
@;si r0 = 2 los dos puntos son los de la izquierda, si r0 = 3 los dos puntos son los de arriba, si r0 = 4 
@;el segundo punto es el de la izquierda y el otro es de la derecha, si r0 = 5 el segundo es de arriba y el 
@;otro es de abajo


@;		vector de posiciones (x1,y1,x2,y2,x3,y3), devuelto por referencia
generar_posiciones:
		push {lr}
			cmp r10,#0
			bne .Next
			add r2,#1
			mla r6,r1,r5,r2		@;cálculo dirección (i*COLUMNS)+j
			ldrb r7,[r6]
			strb r7,[r4] 	@;r4 dir del vect
			add r2,#1
			add r4,#1
			mla r6,r1,r5,r2
			ldrb r7,[r6]
			strb r7,[r4]
			add r2,#-2
			.Liniposis:
			cmp r0,#0
			bne .ContPunt
			add r2,#1	@;cojo la columna de la derecha
			mla r6,r1,r5,r2	@;calculo dir de memoria de la derecha
			ldrb r7,[r6]	@;cargo contenido de la dir de memoria
			add r4,#1		
			strb r7,[r4]	@;lo cargo en la posi siguiente del vector para no perder los valores q hay
			add r2,#1
			mla r6,r1,r5,r2
			ldrb r7, [r6]
			add r4,#1
			strb r7,[r4]
			.ContPunt:	@;fila de abajo
			cmp r0,#1
			bne .ContPunt2
			add r1,#1
			mla r6,r1,r5,r2
			ldrb r7,[r6]
			add r4,#1
			strb r7,[r4]
			add r1,#1
			mla r6,r1,r5,r2
			ldrb r7, [r6]
			add r4,#1
			strb r7,[r4]
			.ContPunt2:	@;abajo
			cmp r0,#2
			bne .ContPunt3
			add r2,#-1
			mla r6,r1,r5,r2
			ldrb r7,[r6]
			add r4,#1
			strb r7,[r4]
			add r2,#-1
			mla r6,r1,r5,r2
			ldrb r7, [r6]
			add r4,#1
			strb r7,[r4]
			.ContPunt3:
			cmp r0,#3
			bne .ContPunt4
			add r1,#-1
			mla r6,r1,r5,r2
			ldrb r7,[r6]
			add r4,#1
			strb r7,[r4]
			add r1,#-1
			mla r6,r1,r5,r2
			ldrb r7, [r6]
			add r4,#1
			strb r7,[r4]
			.ContPunt4:
			cmp r0,#4
			bne .ContPunt5
			add r2,#1
			mla r6,r1,r5,r2
			ldrb r7,[r6]
			add r4,#1
			strb r7,[r4]
			add r2,#-2
			mla r6,r1,r5,r2
			ldrb r7, [r6]
			add r4,#1
			strb r7,[r4]
			.ContPunt5:
			cmp r0,#5
			bne .ContPunt3
			add r1,#1
			mla r6,r1,r5,r2
			ldrb r7,[r6]
			add r4,#1
			strb r7,[r4]
			add r1,#-2
			mla r6,r1,r5,r2
			ldrb r7, [r6]
			add r4,#1
			strb r7,[r4]
			b .Lfin


			.Next:
			cmp r10,#1
			bne .Next1
			add r2,#-1
			mla r6,r1,r5,r2		@;cálculo dirección (i*COLUMNS)+j
			ldrb r7,[r6]
			strb r7,[r4] 	@;r4 dir del vect
			add r2,#-1
			add r4,#1
			mla r6,r1,r5,r2
			ldrb r7,[r6]
			strb r7,[r4]
			add r2,#2
			b .Liniposis
			.Next1:
			cmp r10,#2
			bne .Next2
			add r1,#1
			mla r6,r1,r5,r2		@;cálculo dirección (i*COLUMNS)+j
			ldrb r7,[r6]
			strb r7,[r4] 	@;r4 dir del vect
			add r1,#1
			add r4,#1
			mla r6,r1,r5,r2
			ldrb r7,[r6]
			strb r7,[r4]
			add r1,#-2
			b .Liniposis
			.Next2:
			cmp r10,#3
			bne .Lfin
			add r1,#-1
			mla r6,r1,r5,r2		@;cálculo dirección (i*COLUMNS)+j
			ldrb r7,[r6]
			strb r7,[r4] 	@;r4 dir del vect
			add r1,#-1
			add r4,#1
			mla r6,r1,r5,r2
			ldrb r7,[r6]
			strb r7,[r4]
			add r1,#2
			b .Liniposis

			
			
			.Lfin:
			
		pop {pc}




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

		@; r3 = num izquierda  r7 = num derecha
		@; r4 = direccion de la matriz r5 = Columnas
		@; r1 = i  r2 = j
	swapH2:
		push {r1-r7,lr}
			
		mla r6, r1, r5, r2
		strb r7,[r4,r6]
		add r2, #-1
		mla r6, r1, r5, r2
		strb r3,[r4,r6]
			
		pop {r1-r7,pc}




	@; r3 = num arriba  r7 = num abajo
		@; r4 = direccion de la matriz r5 = Columnas
		@; r1 = i  r2 = j
	swapV2:
		push {r1-r7,lr}
		
			mla r6, r1, r5, r2
			strb r7,[r4,r6]
			add r1, #-1
			mla r6, r1, r5, r2
			strb r3,[r4,r6]
		
		pop {r1-r7,pc}

.end
