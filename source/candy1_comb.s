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
	.Lfor_Row:
		cmp r1,r6
		bhs .Lendfor_Rows		@; saltar al final si excede el rango
	.Lfor_Col:
		cmp r2,r5
		bhs .Lendfor_Columns	@; saltar al final si excede el rango
@;	.Lifz:	@;If different from 0
		mla r4,r1,r5,r2		@;cálculo dirección (i*COLUMNS)+j
		ldrb r3, [r0, r4]	@;guardo el contenido de la posicion de memoria
		tst r3, #7			@;tst	0111, 0[000] = 0000
		beq	.Lendif
@;	If2
		cmp r2, #COLUMNS-1
		bne .Lelse
@; 	If3
		add r4, #COLUMNS
		ldrb r7, [r0, r4]	@;matriz[i+1][j]
		tst r7, #7			@;tst	0111, 0[000] = 0000
		beq .Lendif3
		cmp r7, r3
		beq .Lendif3
		mov r8, r3			@; aux
		strb r8, [r0, r4]
		sub r4, #COLUMNS
		strb r7, [r0, r4]
		
		
		
		
		
		@;Parte que no sirve a revisar y elimminar después
		
		mla r4,r1,r5,r2	@;cálculo dirección
		add r7,r0,r4 	@;añado la dirección de memoria a la direccion base
		ldrb r3, [r7]	@;guardo el contenido de la posicion de memoria
		cmp r3, #0	@;comparo condición de si es ==0
		bne .Lifc
		cmp r3,#8	@;comparo condición de si es ==8
		bne .Lifc
		cmp r3,#16	@;comparo condición de si es ==16
		bne .Lifc
	.Lifc:
		mov r8,r5
		sub r8,#1	@;para hacer la operación COLUMNS-1
		cmp r2,r8		
		beq .Lifone+	@;If con índice i+1:if1+
	.Lifone+:
		mov r8,r1
		add r8,#1	@;para acceder a matriz[i+1]
		mla r11,r8,r5,r2
		add r9,r0,r11
		ldrb r10,[r9]
		cmp r10,#0
		bne .Lifon+code
		cmp r10,#8
		bne .Lifon+code
		cmp r10,#16
		bne .Lifon+code
		cmp r10,r3
		bne .Lifon+code
	.Lifon+code:
		mov r12,r3	@;aux=matriz [i][j]
		mov r3,r10	@;matriz[i][j]=matriz[i+1][j]
		mov r10,r12	@;matriz [i+1][j]=aux
		
		
	.Lendif3
		b .Lendif
	.Lelse:
		
		
		
		
		
	.Lendif:
		add	r2, #1	@; j++
		b .Lfor_Col	@; saltar al for
	.Lendfor_Col:	
		mov r2, #0	@; resetear j
		add r1, #1	@; i++
	.Lendfor_Rows:
		mov r0, 
		pop {pc}
carlos.txt
3 KB



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
		push {lr}
		
		
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
@;		vector de posiciones (x1,y1,x2,y2,x3,y3), devuelto por referencia
generar_posiciones:
		push {lr}
		
		
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


.end
