@;=                                                               		=
@;== candy2_supo.s: rutinas de soporte a la práctica CandyNDS (fase 2)===
@;=                                                         			=
@;=== Analista-programador: santiago.romani@urv.cat			 		  ===
@;=                                                         	      	=

.include "../include/candy2_incl.i"


@;-- .text. Program code ---
.text	
		.align 2
		.arm


@;busca_elemento(int fil, int col);
@;Rutina para buscar un elemento dentro del vector de elementos, a partir de las
@;	coordenadas de fila y columna del elemento, que se tienen que contrastar con
@;	las coordenadas (px,py) de cada sprite;
@;	la rutina devuelve el índice del elemento, o ROWS*COLUMNS si no lo ha
@;	encontrado.
@;	Variables globales involucradas:
@;		n_sprites :	número de sprites creados
@;		vect_elem :	vector de elementos (sprites)
@;	Parámetros:
@;		R0 :	fila del elemento
@;		R1 :	columna del elemento
@;	Resultado:
@;		R0 :	índice del elemento encontrado, o ROWS*COLUMNS 
	.global busca_elemento
busca_elemento:
		push {r2-r6,lr}
		
		ldr r6, =n_sprites
		ldr r6, [r6]			@;R6 = número de sprites creados
		mov r2, r1, lsl #5		@;R2 = px (columna * 32)
		mov r3, r0, lsl #5		@;R3 = py (fila * 32)
		mov r0, #0				@;R0 es índice de elementos
		ldr r4, =vect_elem		@;R4 es dirección base del vector elementos
	.Lbe_bucle:
		ldsh r5, [r4, #ELE_II]
		cmp r5, #-1
		beq .Lbe_cont			@;continuar si vect_elem[i].ii == -1
		ldsh r5, [r4, #ELE_PX]
		cmp r5, r2
		bne .Lbe_cont			@;continuar si vect_elem[i].px != posición px
		ldsh r5, [r4, #ELE_PY]
		cmp r5, r3
		beq .Lbe_finbucle		@;salir si vect_elem[i].py == posición py
		
	.Lbe_cont:
		add r4, #ELE_TAM
		add r0, #1				@;repetir para todos los sprites creados
		cmp r0, r6
		blo .Lbe_bucle
		mov r0, #ROWS*COLUMNS	@;código de no encontrado (>= n_sprites)
		
	.Lbe_finbucle:
		
		pop {r2-r6, pc}
	
	
@;crea_elemento(int tipo, int fil, int col);
@;Rutina para crear un nuevo elemento de juego, buscando un sprite libre
@;	(ii = -1) y asignandole el índice de baldosa correspondiente al tipo del
@;	elemento que se pasa por parámetro, además de la posición inicial según la
@;	fila y columna en la matriz de juego;
@;	la rutina devuelve como resultado el índice del sprite/elemento que se ha
@;	reservado, o bien el total de posiciones del tablero de juego (ROWS*COLUMNS)
@;	si no ha encontrado ningún espacio libre.
@;	Variables globales involucradas:
@;		vect_elem :	vector de elementos (sprites)
@;	Parámetros:
@;		R0 :	tipo de elemento
@;		R1 :	fila del elemento
@;		R2 :	columna del elemento
@;	Resultado:
@;		R0 :	índice del elemento encontrado, o ROWS*COLUMNS 
	.global crea_elemento
crea_elemento:
		push {r1-r5,lr}
		
		mov r3, r0					@;R3 = tipo de elemento
	@;	int i = 0;
		mov r0, #0					@;R0 es índice de elementos (i)
		
	@;	while ((vect_elem[i].ii != -1) && (i < ROWS*COLUMNS))
	@;		i++;
		ldr r4, =vect_elem			@;R4 es dirección base del vector elementos
	.Lce_bucle:
		ldsh r5, [r4, #ELE_II]
		cmp r5, #-1
		beq .Lce_finbucle			@;salir si vect_elem[i].ii == -1
		add r4, #ELE_TAM
		add r0, #1
		cmp r0, #ROWS*COLUMNS
		blo .Lce_bucle				@;repetir para todos los sprites posibles
		b .Lce_fin
	.Lce_finbucle:
	@;	if (i < ROWS*COLUMNS)		// si lo ha encontrado
	@;	{							// inicializar sus campos principales
		mov r5, #0
		strh r5, [r4, #ELE_II]		@;vect_elem[i].ii = 0;
		mov r5, r2, lsl #5
		strh r5, [r4, #ELE_PX]		@;vect_elem[i].px = col*MTWIDTH;
		mov r5, r1, lsl #5
		strh r5, [r4, #ELE_PY]		@;vect_elem[i].py = fil*MTHEIGHT;
		
	@;		SPR_crearSprite(i, 0, 2, 'indice metabaldosa');
		sub r1, r3, #1
		mov r2, #MTOTAL
		mul r3, r1, r2				@;indice metabaldosa = (tipo-1)*MTOTAL
		mov r1, #0
		mov r2, #2
		bl SPR_crearSprite
	@;		SPR_moverSprite(i, vect_elem[i].px, vect_elem[i].py);
		ldsh r5, [r4, #ELE_PX]
		mov r1, r5
		ldsh r5, [r4, #ELE_PY]
		mov r2, r5
		bl SPR_moverSprite
	@;		SPR_fijarPrioridad(i, 1);
		mov r1, #1
		bl SPR_fijarPrioridad
	@;		SPR_mostrarSprite(i);
		bl SPR_mostrarSprite
	@;	}
	.Lce_fin:
		pop {r1-r5, pc}



@;elimina_elemento(int fil, int col);
@;Rutina para eliminar un elemento de juego, a partir de sus coordenadas fila
@;	y columna actuales; si se encuentra dicho elemento, se libera la posición
@;	del vector y se oculta el sprite asociado;
@;	la rutina devuelve el índice del elemento eliminado, o bien el total de
@;	posiciones del tablero de juego (ROWS*COLUMNS) si no lo ha encontrado.
@;	Variables globales involucradas:
@;		n_sprites :	número de sprites creados
@;		vect_elem :	vector de elementos (sprites)
@;	Parámetros:
@;		R0 :	fila del elemento
@;		R1 :	columna del elemento
@;	Resultado:
@;		R0 :	índice del elemento encontrado, o ROWS*COLUMNS
	.global elimina_elemento
elimina_elemento:
		push {r1-r4,lr}
		
	@;	int i = busca_elemento(fil, col);
		bl busca_elemento
		
	@;	if (i < ROWS*COLUMNS)			// si lo ha encontrado
		cmp r0, #ROWS*COLUMNS
		beq .Lee_fin
	@;	{
	@;		vect_elem[i].ii = -1;		// libera la entrada en el vector
		ldr r4, =vect_elem
		mov r3, #ELE_TAM
		mla r4, r0, r3, r4				@;R4 = @vect_elem + (i * TAMELEM)
		mov r1, #-1
		strh r1, [r4, #ELE_II]
	@;		SPR_ocultarSprite(i);		// ocultar el sprite asociado
		bl SPR_ocultarSprite
	@;	}
	.Lee_fin:
		pop {r1-r4,pc}



@;activa_elemento(int fil, int col, int f2, int c2);
@;Rutina para activar la animación del movimiento de un elemento/sprite
@;	a partir de sus coordenadas fila y columna actuales, así como la posición
@;	del tablero donde se tiene que mover dicho elemento;
@;	la rutina devuelve el índice del elemento activado, o bien el total de
@;	posiciones del tablero de juego (ROWS*COLUMNS) si no lo ha encontrado.
@;	Variables globales involucradas:
@;		n_sprites :	número de sprites creados
@;		vect_elem :	vector de elementos (sprites)
@;	Parámetros:
@;		R0 :	fila del elemento
@;		R1 :	columna del elemento
@;		R2 :	fila destino
@;		R3 :	columna destino
@;	Resultado:
@;		R0 :	índice del elemento encontrado, o ROWS*COLUMNS
	.global activa_elemento
activa_elemento:
		push {r1-r6,lr}
		
		mov r5, r0						@;R5 guarda valor de fila del elemento
	@;	int i = busca_elemento(fil, col);
		bl busca_elemento
		
	@;	if (i < ROWS*COLUMNS)			// si lo ha encontrado
		cmp r0, #ROWS*COLUMNS
		beq .Lae_fin
	@;	{
		ldr r4, =vect_elem
		mov r6, #ELE_TAM
		mla r4, r0, r6, r4				@;R4 = @vect_elem + (i * TAMELEM)
	@;		vect_elem[i].vx = c2 - col;	// fija la velocidad como la diferencia
	@;		vect_elem[i].vy = f2 - fil;	// de posiciones a desplazarse
		sub r3, r1
		strh r3, [r4, #ELE_VX]
		sub r2, r5 
		strh r2, [r4, #ELE_VY]
	@;		vect_elem[i].ii = 32;		// activa el movimiento (32 interrups.)
		mov r5, #32
		strh r5, [r4, #ELE_II]
	@;	}
	.Lae_fin:
		pop {r1-r6,pc}



@;activa_escalado(int fil, int col);
@;Rutina para activar la animación de escalado de un elemento/sprite
@;	a partir de sus coordenadas fila y columna actuales;
@;	la rutina devuelve el índice del elemento activado, o bien el total de
@;	posiciones del tablero (ROWS*COLUMNS) si no lo ha encontrado.
@;	Variables globales involucradas:
@;		n_sprites :	número de sprites creados
@;		vect_elem :	vector de elementos (sprites)
@;	Parámetros:
@;		R0 :	fila del elemento
@;		R1 :	columna del elemento
@;	Resultado:
@;		R0 :	índice del elemento encontrado, o ROWS*COLUMNS
	.global activa_escalado
activa_escalado:
		push {r1,lr}
		
	@;	int i = busca_elemento(fil, col);
		bl busca_elemento
		
	@;	if (i < ROWS*COLUMNS)			// si lo ha encontrado
		cmp r0, #ROWS*COLUMNS
		beq .Laes_fin
	@;	{								// activa escalado del sprite (grupo 0)
	@;		SPR_activarRotacionEscalado(i,0);
		mov r1, #0
		bl SPR_activarRotacionEscalado
	@;	}
	.Laes_fin:
		pop {r1,pc}



@;desactiva_escalado(int fil, int col);
@;Rutina para desactivar la animación de escalado de un elemento/sprite
@;	a partir de sus coordenadas fila y columna actuales;
@;	la rutina devuelve el índice del elemento activado, o bien el total de
@;	posiciones del tablero (ROWS*COLUMNS) si no lo ha encontrado.
@;	Variables globales involucradas:
@;		n_sprites :	número de sprites creados
@;		vect_elem :	vector de elementos (sprites)
@;	Parámetros:
@;		R0 :	fila del elemento
@;		R1 :	columna del elemento
@;	Resultado:
@;		R0 :	índice del elemento encontrado, o ROWS*COLUMNS
	.global desactiva_escalado
desactiva_escalado:
		push {lr}
		
	@;	int i = busca_elemento(fil, col);
		bl busca_elemento
		
	@;	if (i < ROWS*COLUMNS)			// si lo ha encontrado
		cmp r0, #ROWS*COLUMNS
		beq .Ldes_fin
	@;	{								// desactiva escalado del sprite
	@;		SPR_desactivarRotacionEscalado(i);
		bl SPR_desactivarRotacionEscalado
	@;	}
	.Ldes_fin:
		pop {pc}




@;fija_metabaldosa(u16 * mapaddr, int fil, int col, int imeta);
@;Rutina para guardar, en el mapa de baldosas cuya dirección base se pasa por
@;	parámetro, los índices de las baldosas correspondientes a una metabaldosa
@;	de MTROWS x MTCOLS (MTWIDTH x MTHEIGHT píxeles), a partir de la posición
@;	(fil, col) del espacio de juego y del índice de la metabaldosa.
@;	Parámetros:
@;		R0 :	dirección base del mapa de baldosas
@;		R1 :	fila del elemento
@;		R2 :	columna del elemento
@;		R3 :	índice de metabaldosa (imeta)
	.global fija_metabaldosa
fija_metabaldosa:
		push {r1-r10, lr}
		
		mov r4, #MTOTAL
		mul r5, r3, r4
	@;	i_baldosa = imeta*MTOTAL;
		mov r3, r5					@;R3 = índice inicial de baldosas simples
		mov r4, #MTROWS
		mul r5, r1, r4
		mov r1, r5					@;R1 = i*MTROWS
		mov r5, #MTCOLS
		mul r6, r2, r5
		mov r2, r6					@;R2 = j*MTCOLS
		
		mov r6, #0					@;R6 es fila de metabaldosa (df)
	@;	for (df = 0; df < MTROWS; df++)
	@;	{								// dir. base en mapa de fila actual
	.Lfm_for_df:
	@;		desp_fila = (i*MTROWS + df)*32;
		add r8, r1, r6
		mov r10, r8, lsl #5			@;R10 = despl. de fila actual 
		
		mov r9, #0					@;R9 es columna de metabaldosa (dc)
	@;		for (dc = 0; dc < MTCOLS; dc++)
	.Lfm_for_dc:
	@;			*(mapaddr + base_fila + j*MTCOLS + dc) = i_baldosa;
		add r8, r2, r9				@;R8 = despl. de columna actual
		add r8, r10					@;R8 = despl. de (fil,col) actual
		mov r8, r8, lsl #1			@; 		* 2 bytes/posición
		strh r3, [r0, r8]			@;actualizar mapa de baldosas
	@;			i_baldosa++;	
		add r3, #1					@;aumentar índice de baldosa simple
		add r9, #1
		cmp r9, #MTCOLS
		blo .Lfm_for_dc				@;repetir para todas las filas metabaldosa
		
		add r6, #1
		cmp r6, #MTROWS
		blo .Lfm_for_df				@;repetir para todas las columnas metabaldosa
		
		pop {r1-r10, pc}


@;elimina_gelatina(u16 * mapaddr, int fil, int col);
@;Rutina para eliminar una gelatina del tablero de juego, a partir de la
@;	dirección base del mapa de baldosas con el dibujo de las gelatinas, y
@;	de las coordenadas de fila y columna de la gelatina en la matriz de juego.
@;	Variables globales involucradas:
@;		mat_gel :	matriz de gelatinas
@;	Parámetros:
@;		R0 :	dirección base del mapa de baldosas para las gelatinas
@;		R1 :	fila de la gelatina
@;		R2 :	columna de la gelatina
	.global elimina_gelatina
elimina_gelatina:
		push {r3-r6,lr}
		
		ldr r4, =mat_gel
		mov r6, #COLUMNS
		mla r5, r1, r6, r2				@;R5 = (fil * COLUMNS + col)
		mov r3, #GEL_TAM
		mla r4, r5, r3, r4		@;R4 = @mat_gel + (fil*COLUMNS + col) * GEL_TAM;
	@;	imeta = mat_gel[fil,col].im;
		ldrb r3, [r4, #GEL_IM]
	@;	if (imeta > 8)
	@;	{								// si código animación gelatina doble
		cmp r3, #8
		blo .Leligel_else
	@;		imeta -= 8;					// pasar a animación gelatina simple
		sub r3, #8
	@;		mat_gel[fil,col].im = imeta
		strb r3, [r4, #GEL_IM]
		b .Leligel_finif
	@;	}
	@;	else
	@;	{								// si código animación gelatina simple
	.Leligel_else:
	@;		mat_gel[fil,col].ii = -1	// desactivar gelatina
		mov r5, #-1
		strb r5, [r4, #GEL_II]
	@;		imeta = 19;					// índice de metabaldosa transparente
		mov r3, #19
	@;	}
	.Leligel_finif:
		bl fija_metabaldosa			@; parámetros conservados: R0, R1 y R2
		
		pop {r3-r6,pc}

.end
