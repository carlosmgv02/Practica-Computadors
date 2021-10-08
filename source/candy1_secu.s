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
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
	.global hay_secuencia
hay_secuencia:
		push {r1-r11,lr}
		mov r1, #ROWS                  @; r1=filas-->9
		mov r2, #COLUMNS               @; r2=columnas-->9
		mov r3, #0                     @; r3 = i
		mov r4, #0                     @; r4 = j
		sub r8, r1, #2				   @; r8 = filas-2-->7
		sub r9, r2, #2                 @; r9 = columnas-2-->7
.Lfor1:
		cmp r3, r1
		bhs .Lfifor1
.Lfor2:
		cmp r4, r2
		bhs .Lfifor2
		mla r6, r3, r2, r4
		add r7, r0, r4
		ldrb r5,[r7]
.Lif1:
		tst r5, #0x07
		beq .Lfiif1
		mvn r5, r5
		tst r5, #0x07  
		beq .Lfiif1
.Lif2:
		cmp r3, r8
		bhs .Lelse2
		cmp r4, r9
		bhs .Lelse2
.Lif3:
		mov r10, r1
		mov r11, r2
		mov r1, r3
		mov r2, r4
		mov r12, r0
		mov r3, #1
		bl cuenta_repeticiones
		cmp r0, #3
		blo .Lelse3
		b .Lreturn1
.Lelse3:
		mov r0, r11
		mov r3, #0
		bl cuenta_repeticiones
		cmp r0, #3
		blo .Lfiif2
		b .Lreturn1
.Lelse2:
		cmp r3, r8
		blo .Lelse22
.Lif4:
		mov r10, r1
		mov r11, r2
		mov r1, r3
		mov r2, r4
		mov r12, r0
		mov r3, #0
		bl cuenta_repeticiones
		cmp r0, #3
		blo .Lfiif2
		b .Lreturn1
.Lelse22:
		cmp r4, r9
		blo .Lfiif1
		mov r10, r1
		mov r11, r2
		mov r1, r3
		mov r2, r4
		mov r12, r0
		mov r3, #1
		bl cuenta_repeticiones
		cmp r0, #3
		blo .Lfiif2
		b .Lreturn1
.Lfiif2:	
		mov r3, r1
		mov r4, r2
		mov r0, r12
		mov r3, r10
		mov r2, r11
.Lfiif1:
		add r4, #1
		b .Lfor2
.Lfifor2:
		add r3, #1
		b .Lfor1
.Lfifor1:
		mov r0, #0
		b .Lreturn0
.Lreturn1:
		mov r0, #1
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
