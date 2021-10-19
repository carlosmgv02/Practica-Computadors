@;=                                                          	     	=
@;=== candy1_init.s: rutinas para inicializar la matriz de juego	  ===
@;=                                                           	    	=
@;=== Programador tarea 1A: Jialiang.Chen@estudiants.urv.cat				  ===
@;=== Programador tarea 1B: Jialiang.Chen@estudiants.urv.cat				  ===
@;=                                                       	        	=



.include "../include/candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
@; matrices de recombinaci�n: matrices de soporte para generar una nueva matriz
@;	de juego recombinando los elementos de la matriz original.
	mat_recomb1:	.space ROWS*COLUMNS
	mat_recomb2:	.space ROWS*COLUMNS



@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1A;
@; inicializa_matriz(*matriz, num_mapa): rutina para inicializar la matriz de
@;	juego, primero cargando el mapa de configuraci�n indicado por par�metro (a
@;	obtener de la variable global 'mapas'), y despu�s cargando las posiciones
@;	libres (valor 0) o las posiciones de gelatina (valores 8 o 16) con valores
@;	aleatorios entre 1 y 6 (+8 o +16, para gelatinas)
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocar� la rutina
@;			'mod_random'
@;		* para evitar generar secuencias se invocar� la rutina
@;			'cuenta_repeticiones' (ver fichero "candy1_move.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;		R1 = numero de mapa
@;		Uso de registros:
@; 		r0 = direcci�n base de la matriz de juego
@;		r1 = i 
@;		r2 = j 
@; 		r3 = orientaci�n
@;		r4 = (i*COLUMNS)+j
@;		r5 = @mapa[0][0]
@;		r6 = #COLUMNS
@;		r7 = temporal (usado una vez para guardar n de mapa)
@;		r8 = temporal (ROWS * COLUMNS)
@;		r9 = temporal (no usado)
@;		r10 = temporal (usado una vez para conseguir @mapa[0][0])
@;		r11 = mapa[i][j]
@;		r12 = backup de r0

	.global inicializa_matriz
inicializa_matriz:
	push {r0-r12, lr}
	mov r7, r1					@;mover el n�mero de mapa a otro registro
	mov r1, #0					@;inicializar i
	mov r2, #0					@;inicializar j
	mov r8, #ROWS*COLUMNS		@;r8=ROWS*COLUMNS
	mov r6, #COLUMNS			@;r9=COLUMNS
	ldr r10, =mapas				@;r10=direccion base de mapas
	mla r5, r8, r7, r10			@;r5=@mapa[0][0]
	
.Lfor1:
	cmp r1, #ROWS				@;comprovar que no s'ha sortit de la taula
	bhs .Lendfor1				@;saltar si ja ha recorregut totes les files
	mov r2, #0					@;resetejar la variable j per tornar a rec�rrer les columnes
.Lfor2:				
	cmp r2, #COLUMNS			@;comprovar que no s'ha sortit de la taula
	bhs .Lendfor2				@;saltar si ja ha recorregut totes les columnes
	
	mla r4, r1, r6, r2			@;r4=(i*COLUMNS)+j
@; IF
	ldrb r11, [r5, r4]			@;r11=matriz[i][j]
	tst r11, #0x07				@;comparar si t� els tres �ltims bits a 0
	beq .Lelse					@;salta si son tots 0's
	strb r11, [r0, r4]			@;si no son tots 0's, es guarda el valor
	b .Lendif					
.Lelse:
	mov r12, r0					@;backup de r0
.Lwhile:
	mov r0, #6					@;posar el par�metre n
	bl mod_random				@;trucar a la funci�
	add r0, #1					@;obternir un resultat d'entre 1 i 6
	orr r0, r11					@;afegir les gelatines
	strb r0, [r12, r4]			@;guardar el valor en la matriu
@;comprovacions
	mov r0, r12					@;recuperar la matriu
	mov r3, #2					@;pasar el par�metre d'orientaci�
	bl cuenta_repeticiones		
	cmp r0, #3					@;mirar si t� una seq�encia de 3 o m�s
	bhs .Lwhile					@;Si �s igual o major, es retorna a calcular el valor
	mov r0, r12					@;recuperar la matriu
	mov r3, #3					@;pasar el par�metre d'orientaci�
	bl cuenta_repeticiones		@;Si �s igual o major, es retorna a calcular el valor
	cmp r0, #3					@;mirar si t� una seq�encia de 3 o m�s
	mov r0, r12					@;recuperar la matriu
	bhs .Lwhile		
.Lendif:
	add r2, #1					@;j++
	b .Lfor2
.Lendfor2:		
	add r1, #1					@;i++
	b .Lfor1
.Lendfor1:
	
	pop {r0-r12, pc}			@;recuperar registros y volver




@;TAREA 1B;
@; recombina_elementos(*matriz): rutina para generar una nueva matriz de juego
@;	mediante la reubicaci�n de los elementos de la matriz original, para crear
@;	nuevas jugadas.
@;	Inicialmente se copiar� la matriz original en 'mat_recomb1', para luego ir
@;	escogiendo elementos de forma aleatoria y colocandolos en 'mat_recomb2',
@;	conservando las marcas de gelatina.
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocar� la rutina
@;			'mod_random'
@;		* para evitar generar secuencias se invocar� la rutina
@;			'cuenta_repeticiones' (ver fichero "candy1_move.s")
@;		* para determinar si existen combinaciones en la nueva matriz, se
@;			invocar� la rutina 'hay_combinacion' (ver fichero "candy1_comb.s")
@;		* se supondr� que siempre existir� una recombinaci�n sin secuencias y
@;			con combinaciones
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;	7=  00 0[111] (bloque solido)
@;	15= 00 1[111] (hueco)
@;	8=  00 1[000] (gel. s. vacia)
@;	16= 01 0[000] (gel. d. vacia)
@;-------------------------------------------------------
@; USO DE REGISTROS 
@;-------------------------------------------------------
@;	r0= direcci�n base de la matriz de juego
@;	r1= i
@;	r2= j
@;	r3= orientaci�n para otras funciones
@;	r4= (i*COLUMNS)+j
@;	r5= #COLUMNS
@;	r6= valor actual de matriz[i][j]
@;	r7= 
@;	r8= 
@;	r9= 
@;	r10= 
@;	r11= 
@;	r12= Copia de la direcci�n base de la matriz de juego
@;	PAR�METROS: R0 = direcci�n base de la matriz de juego
	.global recombina_elementos
recombina_elementos:
		push {lr}
		mov 12, r0				@;Backup de direcci�n base
		mov r1, #0				@;Inicializar i
		mov r2, #0				@;Inicializar j 
		mov r5, #COLUMNS		@;r5=#COLUMNS
	.Lfor1:
		cmp r1, #ROWS			@;comprovar que no s'ha sortit de la taula
		bhs .Lendfor1			@;saltar si ja ha recorregut totes les files
		mov r2, #0				@;resetejar la variable j per tornar a rec�rrer les columnes
	.Lfor2:
		cmp r2, #COLUMNS		@;comprovar que no s'ha sortit de la taula
		bhs .Lendfor2			@;saltar si ja ha recorregut totes les columnes
		mla r4, r1, r5, r2		@; r4 = (i*COLUMNS)+j
		ldrb r6, [r12, r4]
	@; IF1
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		add r2, #1				@;j++
		b .Lfor2
	.Lendfor2:	
		add r1, #1				@;i++
		b .Lfor1
	.Lendfor1:
		
		pop {pc}



@;:::RUTINAS DE SOPORTE:::



@; mod_random(n): rutina para obtener un n�mero aleatorio entre 0 y n-1,
@;	utilizando la rutina 'random'
@;	Restricciones:
@;		* el par�metro 'n' tiene que ser un valor entre 2 y 255, de otro modo,
@;		  la rutina lo ajustar� autom�ticamente a estos valores m�nimo y m�ximo
@;	Par�metros:
@;		R0 = el rango del n�mero aleatorio (n)
@;	Resultado:
@;		R0 = el n�mero aleatorio dentro del rango especificado (0..n-1)                                                         		=

	.global mod_random
mod_random:
		push {r1-r4, lr}
		
		cmp r0, #2				@;compara el rango de entrada con el m�nimo
		bge .Lmodran_cont
		mov r0, #2				@;si menor, fija el rango m�nimo
	.Lmodran_cont:
		and r0, #0xff			@;filtra los 8 bits de menos peso
		sub r2, r0, #1			@;R2 = R0-1 (n�mero m�s alto permitido)
		mov r3, #1				@;R3 = m�scara de bits
	.Lmodran_forbits:
		cmp r3, r2				@;genera una m�scara superior al rango requerido
		bhs .Lmodran_loop
		mov r3, r3, lsl #1
		orr r3, #1				@;inyecta otro bit
		b .Lmodran_forbits
		
	.Lmodran_loop:
		bl random				@;R0 = n�mero aleatorio de 32 bits
		and r4, r0, r3			@;filtra los bits de menos peso seg�n m�scara
		cmp r4, r2				@;si resultado superior al permitido,
		bhi .Lmodran_loop		@; repite el proceso
		mov r0, r4			@; R0 devuelve n�mero aleatorio restringido a rango
		
		pop {r1-r4, pc}




@; random(): rutina para obtener un n�mero aleatorio de 32 bits, a partir de
@;	otro valor aleatorio almacenado en la variable global 'seed32' (declarada
@;	externamente)
@;	Restricciones:
@;		* el valor anterior de 'seed32' no puede ser 0
@;	Resultado:
@;		R0 = el nuevo valor aleatorio (tambi�n se almacena en 'seed32')
random:
	push {r1-r5, lr}
		
	ldr r0, =seed32				@;R0 = direcci�n de la variable 'seed32'
	ldr r1, [r0]				@;R1 = valor actual de 'seed32'
	ldr r2, =0x0019660D
	ldr r3, =0x3C6EF35F
	umull r4, r5, r1, r2
	add r4, r3					@;R5:R4 = nuevo valor aleatorio (64 bits)
	str r4, [r0]				@;guarda los 32 bits bajos en 'seed32'
	mov r0, r5					@;devuelve los 32 bits altos como resultado
		
	pop {r1-r5, pc}	



.end
