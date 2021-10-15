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
@; matrices de recombinación: matrices de soporte para generar una nueva matriz
@;	de juego recombinando los elementos de la matriz original.
	mat_recomb1:	.space ROWS*COLUMNS
	mat_recomb2:	.space ROWS*COLUMNS



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1A;
@; inicializa_matriz(*matriz, num_mapa): rutina para inicializar la matriz de
@;	juego, primero cargando el mapa de configuración indicado por parámetro (a
@;	obtener de la variable global 'mapas'), y después cargando las posiciones
@;	libres (valor 0) o las posiciones de gelatina (valores 8 o 16) con valores
@;	aleatorios entre 1 y 6 (+8 o +16, para gelatinas)
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			'mod_random'
@;		* para evitar generar secuencias se invocará la rutina
@;			'cuenta_repeticiones' (ver fichero "candy1_move.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		Uso de registros:
@;		r1 = i 
@;		r2 = j 
@; 		r3 = orientación
@;		r4 = posicion inicial mapa de configuración
@;		r5 = número de mapa de configuración
@;		r6 = ROWS * COLUMNS
@;		r7 = COLUMNS
@;		r8 = (i*COLUMNS)+j
@;		r9 = nose
@;		r10 = valor de la posición actual (mapa)
@;		r11 = r0 temporal para llamar mod_random()
@;		r12 = 

	.global inicializa_matriz
inicializa_matriz:
		push {r1-r12, lr}		@;guardar registros utilizados
		mov r5, r1				@;mover el número de mapa a r5
		mov r7, #COLUMNS		@;mover valor de COLUMNS a r7
		ldr r4, =mapas			@;cargar la dirección inicial de mapa a r4, r4=@mapa
		mov r6, #ROWS*COLUMNS	@;memoria que ocupa 1 mapa
		mla r4, r6, r5, r4		@;@([memoria que ocupa 1 mapa](r6) * n_mapa(r5) + dirección inicial de mapa (r4)) = @mapa_n[0][0]
		mov r1, #0				@;r1 = i
		mov r2, #0				@;r2 = j
	.Lfor1:
		cmp r1, #ROWS			@;compara si y ha salido del rango del mapa
		bhi .LendFor1			@; salta si i > filas
	.Lfor2:
		cmp r2, #COLUMNS		@;compara si x ha salido del rango del mapa
		bhi .LendFor2			@;salta si j > columnas
@;  LIf
		mla r8, r1, r7, r2		@;@(i*columnas)+j = @la pocision actual (indiferente del mapa)
		add r9, r4, r8			@;@posicion de la fila "i" y columna actual "j" = @Posicion actual (mapa)
		ldrb r10, [r9]			@;r10= valor de @Posicion actual / Valor en esa posicion
		tst r10, #0x07			@;compara el valor de la posicion actual con la mascara, y modifica el flag de ceros
		beq .Lelse				@;si el flag de 0 está activo
		add r9, r0, r8			@;se añade la posicion de la actual al la direccion base = @matriz[i][j]
		strb r10, [r9]			@;carga el contenido de la posicion actual de la matriz a la direccion @matriz[i][j]
		b .LendIf				
	.Lelse:						@; si el flag de 0 NO está activo
		mov r11,r0				@;backup de la dirección base de la matriz
		mov r0, #6				@;mod_random(), n = 6
		bl mod_random			@;llamar a mod_random con r0=6, retorna un valor de 0 a 5
		add r0, #1				@;ahora r0 pertenece a {1, 2, 3, 4, 5, 6}
		add r9, r8, r11			@;se añade la posicion de la actual al la direccion base = @matriz[i][j]
		ldrb r10, [r9]
		add r10, r0				@;matriz[i][j] + n
		strb r10, [r9]			@;carga el valor mapa[i][j] + n a la memoria de matriz[i][j]
@;while
		mov r0, r11				@;pasar la direccion de la matriz por r0
		mov r3, #3				@;pasar la orientación oeste por parámetro
		bl cuenta_repeticiones	@;Llamar a la función cuenta_repeticiones
		cmp r0, #3				@;Comparar si el resultado és mayor o igual a 3
		bhs .Lwhile				@;saltar si se cumple r0>=#3
		mov r0, r11				@;pasar la matriz por r0
		mov r3, #2				@;pasar la orientación norte por parámetro 
		bl cuenta_repeticiones	@;Llamar a la función cuenta_repeticiones
		cmp r0, #3				@;Comparar si el resultado és mayor o igual a 3
		blo .Lendwhile
	.Lwhile:
		mov r0, #6				@;mod_random(), n = 6
		bl mod_random			@;llamar a mod_random con r0=6, retorna un valor de 0 a 5
		add r0, #1				@;ahora r0 pertenece a {1, 2, 3, 4, 5, 6}
		ldrb r10, [r9]
		add r10, r0				@;matriz[i][j] + n
		strb r10, [r9]			@;carga el valor mapa[i][j] + n a la memoria de matriz[i][j]
		cmp r0, #3
		blo .Lendwhile
		b .Lwhile
	.Lendwhile:
	.LendIf:
	add r2, #1
	b .LendFor2
	.LendFor2:
	add r1, #1
	b .LendFor1
	.LendFor1:
	
	pop {r1-r12, pc}			@;recuperar registros y volver



@;TAREA 1B;
@; recombina_elementos(*matriz): rutina para generar una nueva matriz de juego
@;	mediante la reubicación de los elementos de la matriz original, para crear
@;	nuevas jugadas.
@;	Inicialmente se copiará la matriz original en 'mat_recomb1', para luego ir
@;	escogiendo elementos de forma aleatoria y colocandolos en 'mat_recomb2',
@;	conservando las marcas de gelatina.
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			'mod_random'
@;		* para evitar generar secuencias se invocará la rutina
@;			'cuenta_repeticiones' (ver fichero "candy1_move.s")
@;		* para determinar si existen combinaciones en la nueva matriz, se
@;			invocará la rutina 'hay_combinacion' (ver fichero "candy1_comb.s")
@;		* se supondrá que siempre existirá una recombinación sin secuencias y
@;			con combinaciones
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
	.global recombina_elementos
recombina_elementos:
		push {lr}
		
		
		pop {pc}



@;:::RUTINAS DE SOPORTE:::



@; mod_random(n): rutina para obtener un número aleatorio entre 0 y n-1,
@;	utilizando la rutina 'random'
@;	Restricciones:
@;		* el parámetro 'n' tiene que ser un valor entre 2 y 255, de otro modo,
@;		  la rutina lo ajustará automáticamente a estos valores mínimo y máximo
@;	Parámetros:
@;		R0 = el rango del número aleatorio (n)
@;	Resultado:
@;		R0 = el número aleatorio dentro del rango especificado (0..n-1)                                                         		=

	.global mod_random
mod_random:
		push {r1-r4, lr}
		
		cmp r0, #2				@;compara el rango de entrada con el mínimo
		bge .Lmodran_cont
		mov r0, #2				@;si menor, fija el rango mínimo
	.Lmodran_cont:
		and r0, #0xff			@;filtra los 8 bits de menos peso
		sub r2, r0, #1			@;R2 = R0-1 (número más alto permitido)
		mov r3, #1				@;R3 = máscara de bits
	.Lmodran_forbits:
		cmp r3, r2				@;genera una máscara superior al rango requerido
		bhs .Lmodran_loop
		mov r3, r3, lsl #1
		orr r3, #1				@;inyecta otro bit
		b .Lmodran_forbits
		
	.Lmodran_loop:
		bl random				@;R0 = número aleatorio de 32 bits
		and r4, r0, r3			@;filtra los bits de menos peso según máscara
		cmp r4, r2				@;si resultado superior al permitido,
		bhi .Lmodran_loop		@; repite el proceso
		mov r0, r4			@; R0 devuelve número aleatorio restringido a rango
		
		pop {r1-r4, pc}




@; random(): rutina para obtener un número aleatorio de 32 bits, a partir de
@;	otro valor aleatorio almacenado en la variable global 'seed32' (declarada
@;	externamente)
@;	Restricciones:
@;		* el valor anterior de 'seed32' no puede ser 0
@;	Resultado:
@;		R0 = el nuevo valor aleatorio (también se almacena en 'seed32')
random:
	push {r1-r5, lr}
		
	ldr r0, =seed32				@;R0 = dirección de la variable 'seed32'
	ldr r1, [r0]				@;R1 = valor actual de 'seed32'
	ldr r2, =0x0019660D
	ldr r3, =0x3C6EF35F
	umull r4, r5, r1, r2
	add r4, r3					@;R5:R4 = nuevo valor aleatorio (64 bits)
	str r4, [r0]				@;guarda los 32 bits bajos en 'seed32'
	mov r0, r5					@;devuelve los 32 bits altos como resultado
		
	pop {r1-r5, pc}	



.end
