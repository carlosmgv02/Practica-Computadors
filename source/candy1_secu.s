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
@; n�mero de secuencia: se utiliza para generar n�meros de secuencia �nicos,
@;	(ver rutinas 'marcar_horizontales' y 'marcar_verticales') 
	num_sec:	.space 1



@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1C;
@; hay_secuencia(*matriz): rutina para detectar si existe, por lo menos, una
@;	secuencia de tres elementos iguales consecutivos, en horizontal o en
@;	vertical, incluyendo elementos en gelatinas simples y dobles.
@;	Restricciones:
@;		* para detectar secuencias se invocar� la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
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
@;		R11 = Guardar direcci�n base de la matriz de juego	
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
		bhs .Lelse2
		cmp r2, r9						@; j < columnas-2
		bhs .Lelse2
.Lif3:
		mov r10, r3						@; Guardar filas en R10
		mov r11, r0						@; Guardar direcci�n base de la matriz de juego en R11
		mov r3, #1						@; A�adir direcci�n(sur) en R3
		bl cuenta_repeticiones			@; Llamar funcion cuenta repeticiones
		cmp r0, #3						@; n� de repiticiones >= 3
		blo .Lelse3
		b .Lreturn1
.Lelse3:
		mov r0, r11    					@; Devolver direcci�n base de la matrix de juego en R0
		mov r3, #0						@; A�adir direcci�n(este) en R3
		bl cuenta_repeticiones			@; Llamar funcion cuenta repeticiones
		cmp r0, #3						@; n� de repiticiones >= 3
		blo .Lfiif2
		b .Lreturn1
.Lelse2:
		cmp r1, r8						@; i >= filas-2
		blo .Lelse22
.Lif4:
		mov r10, r3						@; Guardar filas en R10
		mov r11, r0						@; Guardar direcci�n base de la matriz de juego en R11
		mov r3, #0						@; A�adir direcci�n(sur) en R3
		bl cuenta_repeticiones			@; Llamar funcion cuenta repeticiones
		cmp r0, #3						@; n� de re�ticiones >= 3
		blo .Lfiif2
		b .Lreturn1
.Lelse22:
		cmp r2, r9						@; j >= colimnas-2
		blo .Lfiif1
		mov r10, r3						@; Guardar filas en R10
		mov r11, r0						@; Guardar direcci�n base de la matriz de juego en R11
		mov r3, #1						@; A�adir direcci�n(sur) en R3
		bl cuenta_repeticiones			@; Llamar funcion cuenta repeticiones
		cmp r0, #3						@; n� de repeticiones >= 3
		blo .Lfiif2
		b .Lreturn1
.Lfiif2:	
		mov r0, r11						@; Devolver direcci�n base de la matrix de juego en R0 
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
@;	secuencias de 3 o m�s elementos repetidos consecutivamente en horizontal,
@;	vertical o combinaciones, as� como de reducir el nivel de gelatina en caso
@;	de que alguna casilla se encuentre en dicho modo; 
@;	adem�s, la rutina marca todos los conjuntos de secuencias sobre una matriz
@;	de marcas que se pasa por referencia, utilizando un identificador �nico para
@;	cada conjunto de secuencias (el resto de las posiciones se inicializan a 0). 
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;		R1 = direcci�n de la matriz de marcas
	.global elimina_secuencias
elimina_secuencias:
		push {r6-r9, lr}
		
		mov r6, #0
		mov r8, #0				@;R8 es desplazamiento posiciones matriz
	.Lelisec_for0:
		strb r6, [r1, r8]		@;poner matriz de marcas a cero
		add r8, #1
		cmp r8, #ROWS*COLUMNS
		blo .Lelisec_for0
		
		bl marcar_horizontales
		bl marcar_verticales
		

@; ATENCI�N: FALTA C�DIGO PARA ELIMINAR SECUENCIAS MARCADAS Y GELATINAS

		
		pop {r6-r9, pc}

	
@;:::RUTINAS DE SOPORTE:::



@; marcar_horizontales(mat): rutina para marcar todas las secuencias de 3 o m�s
@;	elementos repetidos consecutivamente en horizontal, con un n�mero identifi-
@;	cativo diferente para cada secuencia, que empezar� siempre por 1 y se ir�
@;	incrementando para cada nueva secuencia, y cuyo �ltimo valor se guardar� en
@;	la variable global 'num_sec'; las marcas se guardar�n en la matriz que se
@;	pasa por par�metro 'mat' (por referencia).
@;	Restricciones:
@;		* se supone que la matriz 'mat' est� toda a ceros
@;		* para detectar secuencias se invocar� la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;		R1 = direcci�n de la matriz de marcas
marcar_horizontales:
		push {lr}
		
		
		pop {pc}



@; marcar_verticales(mat): rutina para marcar todas las secuencias de 3 o m�s
@;	elementos repetidos consecutivamente en vertical, con un n�mero identifi-
@;	cativo diferente para cada secuencia, que seguir� al �ltimo valor almacenado
@;	en la variable global 'num_sec'; las marcas se guardar�n en la matriz que se
@;	pasa por par�metro 'mat' (por referencia);
@;	sin embargo, habr� que preservar los identificadores de las secuencias
@;	horizontales que intersecten con las secuencias verticales, que se habr�n
@;	almacenado en en la matriz de referencia con la rutina anterior.
@;	Restricciones:
@;		* se supone que la matriz 'mat' est� marcada con los identificadores
@;			de las secuencias horizontales
@;		* la variable 'num_sec' contendr� el siguiente indentificador (>=1)
@;		* para detectar secuencias se invocar� la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;		R1 = direcci�n de la matriz de marcas
marcar_verticales:
		push {lr}
		
		
		pop {pc}



.end
