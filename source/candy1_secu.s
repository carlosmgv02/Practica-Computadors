@;=                                                               		=
@;=== candy1_secu.s: rutinas para detectar y elimnar secuencias 	  ===
@;=                                                             	  	=
@;=== Programador tarea 1C: ismael.ruiz@estudiants.urv.cat				  ===
@;=== Programador tarea 1D: ismael.ruiz@estudiants.urv.cat				  ===
@;=                                                           		   	=



.include "../include/candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
@; número de secuencia: se utiliza para generar números de secuencia únicos,
@;	(ver rutinas 'marcar_horizontales' y 'marcar_verticales') 
	num_sec:	.space 1



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1C;
@; hay_secuencia(*matriz): rutina para detectar si existe, por lo menos, una
@;	secuencia de tres elementos iguales consecutivos, en horizontal o en
@;	vertical, incluyendo elementos en gelatinas simples y dobles.
@;	Restricciones:
@;		* para detectar secuencias se invocará la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = i
@;		R2 = j
@;		R3 = ROWS
@;		R4 = COLUMNS
@;		R5 = Valor de la matriz en la posicion i j
@;		R6 = i * COLUMNS + j
@;		R7 = R0 + R6
@;		R8 = ROWS - 2	
@;		R9 = COLUMNS - 2
@;		R10 = Guardar ROWS
@;		R11 = Guardar dirección base de la matriz de juego	
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
	.global hay_secuencia
hay_secuencia:
		push {r1-r11,lr}
		mov r1, #0                     	@; r1 = i
		mov r2, #0                     	@; r2 = j
		mov r3, #ROWS                  	@; r3 = Filas
		mov r4, #COLUMNS               	@; r4 = Columnas
		sub r8, r3, #2				   	@; r8 = filas-2-->7
		sub r9, r4, #2                 	@; r9 = columnas-2-->7
	.Lfor1:
		cmp r1, r3						@; i < filas
		bhs .Lfifor1
		mov r2, #0
	.Lfor2:
		cmp r2, r4						@; j < columnas
		bhs .Lfifor2
		mla r6, r1, r4, r2				@; R6 = i * NC + j
		add r7, r0, r6
		ldrb r5,[r7]					@; R5 = matriz[i][j]
	.Lif1:
		tst r5, #0x07					@; Comprobar que el valor no sea un espacio vacio
		beq .Lfiif1
		mvn r5, r5
		tst r5, #0x07  					@; Comprobar que no sea un bloque solido o un hueco
		beq .Lfiif1
	.Lif2:
		cmp r1, r8						@; i < filas-2
		bhs .Lelse22
		cmp r2, r9						@; j < columnas-2
		bhs .Lelse2
	.Lif3:
		mov r10, r3						@; Guardar filas en R10
		mov r11, r0						@; Guardar dirección base de la matriz de juego en R11
		mov r3, #1						@; Añadir dirección(sur) en R3
		bl cuenta_repeticiones			@; Llamar funcion cuenta repeticiones
		cmp r0, #3						@; nº de repiticiones >= 3
		blo .Lelse3
		b .Lreturn1
	.Lelse3:
		mov r0, r11    					@; Devolver dirección base de la matrix de juego en R0
		mov r3, #0						@; Añadir dirección(este) en R3
		bl cuenta_repeticiones			@; Llamar funcion cuenta repeticiones
		cmp r0, #3						@; nº de repiticiones >= 3
		blo .Lfiif2
		b .Lreturn1
	.Lelse2:
	.Lif4:
		mov r10, r3						@; Guardar filas en R10
		mov r11, r0						@; Guardar dirección base de la matriz de juego en R11
		mov r3, #1						@; Añadir dirección(este) en R3
		bl cuenta_repeticiones			@; Llamar funcion cuenta repeticiones
		cmp r0, #3						@; nº de reèticiones >= 3
		blo .Lfiif2
		b .Lreturn1
	.Lelse22:
		cmp r2, r9						@; j >= colimnas-2
		bhs .Lfiif1
		mov r10, r3						@; Guardar filas en R10
		mov r11, r0						@; Guardar dirección base de la matriz de juego en R11
		mov r3, #0						@; Añadir dirección(sur) en R3
		bl cuenta_repeticiones			@; Llamar funcion cuenta repeticiones
		cmp r0, #3						@; nº de repeticiones >= 3
		blo .Lfiif2
		b .Lreturn1
	.Lfiif2:	
		mov r0, r11						@; Devolver dirección base de la matrix de juego en R0 
		mov r3, r10						@; Devolver filas en R3
	.Lfiif1:
		add r2, #1						@; j++
		b .Lfor2						@; Saltar al segundo bucle
	.Lfifor2:
		add r1, #1						@; i++
		b .Lfor1						@; Saltar al primer bucle
	.Lfifor1:
		mov r0, #0						@; Hay secuencias = 0 (false)
		b .Lreturn0
	.Lreturn1:
		mov r0, #1						@; Hay secuencias = 1 (true)
	.Lreturn0:
		pop {r1-r11,pc}



@;TAREA 1D;
@; elimina_secuencias(*matriz, *marcas): rutina para eliminar todas las
@;	secuencias de 3 o más elementos repetidos consecutivamente en horizontal,
@;	vertical o combinaciones, así como de reducir el nivel de gelatina en caso
@;	de que alguna casilla se encuentre en dicho modo; 
@;	además, la rutina marca todos los conjuntos de secuencias sobre una matriz
@;	de marcas que se pasa por referencia, utilizando un identificador único para
@;	cada conjunto de secuencias (el resto de las posiciones se inicializan a 0). 
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
	.global elimina_secuencias
elimina_secuencias:
		push {r0-r9, lr}
		
		mov r6, #0
		mov r8, #0				@;R8 es desplazamiento posiciones matriz
	.Lelisec_for0:
		strb r6, [r1, r8]		@;poner matriz de marcas a cero
		add r8, #1
		cmp r8, #ROWS*COLUMNS
		blo .Lelisec_for0
		
		bl marcar_horizontales
		bl marcar_verticales
		
		mov r9, #0x18   @;mascara
		
		mov r6, r0
		mov r7, r1
		mov r1, #0
		mov r8, #COLUMNS
		
	.Lelisec_for1:
		cmp r1, #ROWS
		bhs .Lfi_Elisec_for1
		mov r2, #0
	.Lelisec_for2:
		cmp r2, #COLUMNS
		bhs .Lfi_Elisec_for2
		
		mla r5, r1, r8, r2
		ldrb r3, [r7,r5]
		cmp r3, #0
		beq .Lelisec_foraux
		
		ldrb r4, [r6,r5]
		mov r10, r4, lsr #1
		and r10, r9, r10
		strb r10,[r6,r5]
		
		tst r4, r9
		beq .LnoGelatina
		
		ldr r0, =0x06000000		
		bl elimina_gelatina
	.LnoGelatina:
		mov r0, r1
		mov r3, r1
		mov r1, r2
		bl elimina_elemento
		mov r2, r1
		mov r1, r3
	.Lelisec_foraux:
		add r2, #1
		b .Lelisec_for2
	.Lfi_Elisec_for2:
		add r1, #1
		b .Lelisec_for1
	.Lfi_Elisec_for1:
		
		
		pop {r0-r9, pc}

	
@;:::RUTINAS DE SOPORTE:::



@; marcar_horizontales(mat): rutina para marcar todas las secuencias de 3 o más
@;	elementos repetidos consecutivamente en horizontal, con un número identifi-
@;	cativo diferente para cada secuencia, que empezará siempre por 1 y se irá
@;	incrementando para cada nueva secuencia, y cuyo último valor se guardará en
@;	la variable global 'num_sec'; las marcas se guardarán en la matriz que se
@;	pasa por parámetro 'mat' (por referencia).
@;	Restricciones:
@;		* se supone que la matriz 'mat' está toda a ceros
@;		* para detectar secuencias se invocará la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
marcar_horizontales:
		push {r0-r12,lr}
		
		mov r4, r1							@; R4 = direccion matriz MARCAS
		mov r1, #0							@; R1 = i
		mov r2, #0							@; R2 = j
		mov r6, #COLUMNS-2					@; R6 = Columnas-2 (ex.7)
		mov r11, #COLUMNS					@; R11 = Columnas (ex.9)
		mov r12, #1							@; R12 = num_sec
		
	.L1for1:
		cmp r1, #ROWS					
		bhs .L1fifor1
		mov r2, #0
	.L1for2:
		cmp r2, #COLUMNS
		bhs .L1fifor2
		
		mla r5, r1, r11, r2					@; R5 = i * NC + j
		add r7, r0, r5       				@; R7 = direccion matriz JUEGO + R5
		
		ldrb r9, [r7]						@; R9 = contenido matriz JUEGO
		
	.L1if1:
		tst r9, #0x07						@; Comprobar que el valor no sea un espacio vacio
		beq .L1fiif1
		mvn r9, r9
		tst r9, #0x07  						@; Comprobar que no sea un bloque solido o un hueco
		beq .L1fiif1		
		
	.L1if2:
		cmp r2, r6							@; Comprobar que no este en las 2 ultimas columnas
		bhs .L1fiif2
		
		mov r10, r0							@;  R10 = Guardar direccion matriz JUEGO
		mov r3, #0							@;  R3 = indicar direccion (este:0)
		bl cuenta_repeticiones
	
	.L1if3:
		cmp r0, #3							@; Comprobar numero de repeticiones
		blo .L1else3
		
		add r0, #-1							
		add r3, r0, r2						@; R3 = num de repeticiones(>=3) + j
		
	.L1while:								@; Bucle para numerar las secuencias
		cmp r2, r3							@; de j a j+num de repeticiones
		bhi .L1fiwhile

		mla r5, r1, r11, r2					@; R5 = i * NC + j
		add r8, r4, r5						@; R8 = Direccion matriz Marcas + R5
		
		strb r12, [r8]
		
		add r2, #1
		b .L1while

	.L1fiwhile:
		add r12, #1							@; R12 = num_sec + 1
		add r2, #-1
		b .L1fiif3

	.L1else3:
		add r0,#-1							
		add r2, r0							@; R2 = j + num de repeticiones(<=2)
	.L1fiif3:
		mov r0, r10							@; R0 = Recuperar direccion matriz JUEGO

	.L1fiif2:
	.L1fiif1:
		add r2, #1
		b .L1for2
	.L1fifor2:
		add r1, #1
		b .L1for1
	.L1fifor1:
		
		ldr r11,=num_sec
		strb r12, [r11]						@; Guardar num_sec
		
		
		pop {r0-r12,pc}



@; marcar_verticales(mat): rutina para marcar todas las secuencias de 3 o más
@;	elementos repetidos consecutivamente en vertical, con un número identifi-
@;	cativo diferente para cada secuencia, que seguirá al último valor almacenado
@;	en la variable global 'num_sec'; las marcas se guardarán en la matriz que se
@;	pasa por parámetro 'mat' (por referencia);
@;	sin embargo, habrá que preservar los identificadores de las secuencias
@;	horizontales que intersecten con las secuencias verticales, que se habrán
@;	almacenado en en la matriz de referencia con la rutina anterior.
@;	Restricciones:
@;		* se supone que la matriz 'mat' está marcada con los identificadores
@;			de las secuencias horizontales
@;		* la variable 'num_sec' contendrá el siguiente indentificador (>=1)
@;		* para detectar secuencias se invocará la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
marcar_verticales:
		push {r0-r12,lr}
		
		mov r4, r1        					@; R4 = direccion matriz MARCAS
		mov r1, #0							@; R1 = i
		mov r2, #0							@; R2 = j
		mov r6, #ROWS-2						@; R6 = Filas-2 (ex.7)	
		mov r11, #COLUMNS					@; R11 = Columnas (ex.9)		
		ldr r5, =num_sec					@; Recuperar valor global de num_sec	
		ldrb r12, [r5]							 
		
.L2for1:
		cmp r1, #ROWS
		bhs .L2fifor1
		mov r2, #0
.L2for2:
		cmp r2, #COLUMNS
		bhs .L2fifor2
		
		mla r5, r1, r11, r2					@; R5 = i * NC + j
		add r7, r0, r5       				@; R7 = Direccion matriz Marcas + R5
		
		ldrb r9, [r7]						@; R9 = Contenido matriz juego
		
.L2if1:
		tst r9, #0x07						@; Comprobar que el valor no sea un espacio vacio
		beq .L2fiif1
		mvn r9, r9
		tst r9, #0x07  						@; Comprobar que no sea un bloque solido o un hueco
		beq .L2fiif1		
		
.L2if2:
		cmp r1, r6							@; Comprobar que no este en las ultimas 2 filas
		bhs .L2fiif2
		
		mov r10, r0							@; R10 = Guardar direccion matriz JUEGO
		mov r3, #1							@; R3 = indicar direccion(sur:1)
		bl cuenta_repeticiones
	
.L2if3:
		cmp r0, #3
		blo .L2else3
		
		add r0, #-1
		add r3, r0, r1						@; R3 = num de repeticiones(>=3) + i
		
		mov r7, r1							@; R7 = copia aux de i
		
.L2while1:									@; Bucle para comprobar si intercepta con una secuencia horizontal
		cmp r7, r3
		bhi .L2fiwhile1
		
		mla r5, r7, r11, r2
		add r8, r4, r5
		
		ldrb r9, [r8]
		cmp r9, #0
		movne r12, r9
		bne .L2fiwhile1
		
		add r7, #1
		b .L2while1
.L2fiwhile1:
		
		
.L2while2:									@; Bucle para numerar las secuencias
		cmp r1, r3							@; de i a i+num de repeticiones
		bhi .L2fiwhile2

		mla r5, r1,r11,r2					@; R5 = i * NC + j
		add r8, r4, r5						@; R8 = Direccion matriz Marcas + R5
		
		strb r12, [r8]
		
		add r1, #1
		b .L2while2

.L2fiwhile2:

		ldr r7, =num_sec
		ldrb r8, [r7]						@; Comprobar num secuencia guardada con el utilizado
		cmp r8, r12
		addeq r12, #1
		movne r12, r8
		add r0, #1
		sub r1, r0
		b .L2fiif3

.L2else3:
.L2fiif3:
		mov r0, r10							@; R0 = Recuperar direccion matriz JUEGO
		ldr r7, =num_sec
		strb r12, [r7]						@; Guardar num_sec

.L2fiif2:
.L2fiif1:
		add r2, #1
		b .L2for2
.L2fifor2:
		add r1, #1
		b .L2for1
.L2fifor1:
		
		ldr r11,=num_sec
		strb r12, [r11]
		
		pop {r0-r12,pc}



.end