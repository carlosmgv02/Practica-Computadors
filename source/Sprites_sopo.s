@;=                                                               		=
@;== Sprites_sopo.s: rutinas de manipular sprites para plataforma NDS ===
@;=                                                         			=
@;=== Analista-programador: santiago.romani@urv.cat			 		  ===
@;=                                                         	      	=


@;-- .bss. variables globales no inicializadas ---
.bss
		.align 2
	oam_data:	.space 128 * 8		@; espacio de trabajo para 128 sprites

@;-- .text. Program code ---
.text	
		.align 2
		.arm


@;SPR_actualizarSprites(u16* base, int limite);
@;Rutina para copiar la información de los sprites en los registros de E/S
@;correspondientes, según la base OAM pasada por parámetro
@;Parámetros:
@;	base (R0):	0700 0000 para procesador gráfico principal
@;				0700 0400 para procesador gráfico secundario
@;	límite (R1):	valor máximo del índice de los sprites 
	.global SPR_actualizarSprites
SPR_actualizarSprites:
		push {r1-r4, lr}
		
		ldr r4, =oam_data		@; R4 = dirección inicial de datos oam
		mov r1, r1, lsl #3		@; R1 = límite índice * 8 (= límite posiciones)
		mov r2, #0				@; R2 = índice de posiciones
	.LaS_bucle:
		cmp r2, r1				@; mientras índice < límite (*8)
		beq .LaS_fibucle
		ldr r3, [r4, r2]		@; cargar valor de atributos 0 y 1
		str r3, [r0, r2]		@; guarda el valor en los registros de E/S
		add r2, #4
		ldr r3, [r4, r2]		@; cargar valor de atributo 2 + Rot/esc
		str r3, [r0, r2]		@; guarda el valor en los registros de E/S
		add r2, #4
		b .LaS_bucle
	.LaS_fibucle:
		pop {r1-r4, pc}



@;SPR_crearSprite(int indice, int forma, int tam, int baldosa);
@;Rutina para configurar el sprite indicado por parámetro
@;Parámetros:
@;	indice (R0):	índice del sprite a crear
@;	forma (R1):		0-> cuadrada, 1-> horizontal, 2-> vertical
@;	tam (R2):	forma cuadrada		0-> 8x8, 1-> 16x16, 2-> 32x32, 3-> 64x64
@;				forma horizontal	0-> 8x16, 1-> 8x32, 2-> 16x32, 3-> 32x64
@;				forma vertical		0-> 16x8, 1-> 32x8, 2-> 32x16, 3-> 64x32
@;	baldosa (R3):	índice de baldosa de 8x8 píxeles (256 colores)
	.global SPR_crearSprite
SPR_crearSprite:
		push {r4-r5, lr}
		
		and r0, #127			@; filtrar índice de sprite
		and r1, #3				@; filtrar forma
		and r2, #3				@; filtrar tamaño
		bic r3, #0xFC00			@; filtrar índice de baldosa (0..1023)
		ldr r4, =oam_data		@; R4 = direccion inicial de datos oam
		add r4, r0, lsl #3		@; sumar índice de sprite * 8
		ldrh r5, [r4]			@; cargar valor de atributo 0
		orr r5, #0x2000			@; activar bit 13 (256 colores)
		bic r5, #0xC000			@; borrar bits 15..14
		orr r5, r1, lsl #14		@; activar bits forma, desplazado a bits 15..14
		strh r5, [r4]			@; guarda el nuevo valor del atributo 0
		ldrh r5, [r4, #2]		@; cargar valor de atributo 1
		bic r5, #0xC000			@; borrar bits 15..14
		orr r5, r2, lsl #14		@; activar bits tamaño, desplazado a bits 15..14
		strh r5, [r4, #2]		@; guarda el nuevo valor del atributo 1
		ldrh r5, [r4, #4]		@; cargar valor de atributo 2
		bic r5, #0x00FF			@; borrar bits 7..0
		bic r5, #0x0300			@; borrar bits 9..8
		orr r5, r3, lsl #1		@; activar bits índice baldosa (desplazado un
								@; un bit a la izquierda por ser 256 colores)
		strh r5, [r4, #4]		@; guarda el nuevo valor del atributo 2
		
		pop {r4-r5, pc}



@;SPR_mostrarSprite(int indice);
@;Rutina para mostrar el sprite indicado por parámetro
@;Parámetros:
@;	indice (R0):	índice del sprite a mostrar
	.global SPR_mostrarSprite
SPR_mostrarSprite:
		push {r1-r3, lr}
		
		and r0, #127			@; filtrar índice de sprite (0..127)
		ldr r1, =oam_data		@; R1 = dirección inicial de datos oam
		mov r2, r0, lsl #3		@; R2 = índice sprite * 8
		ldrh r3, [r1, r2]		@; cargar valor de atributo 0
		bic r3, #0x0200			@; desactivar bit 9 para mostrar sprite
		strh r3, [r1, r2]		@; guarda el nuevo valor del atributo
		
		pop {r1-r3, pc}


@;SPR_ocultarSprite(int indice);
@;Rutina para ocultar el sprite indicado por parámetro
@;Parámetros:
@;	indice (R0):	índice del sprite a ocultar
	.global SPR_ocultarSprite
SPR_ocultarSprite:
		push {r1-r3, lr}
		
		and r0, #127			@; filtrar índice de sprite
		ldr r1, =oam_data		@; R1 = direccion inicial de datos oam
		mov r2, r0, lsl #3		@; R2 = índice sprite * 8
		ldrh r3, [r1, r2]		@; cargar valor de atributo 0
		orr r3, #0x0200			@; activar bit 9 para ocultar sprite
		strh r3, [r1, r2]		@; guarda el nuevo valor del atributo
		
		pop {r1-r3, pc}


@;SPR_ocultarSprites(int límite);
@;Rutina para ocultar todos los sprites hasta el límite indicado
@;Parámetros:
@;	límite (R0):	valor máximo del índice de los sprites 
	.global SPR_ocultarSprites
SPR_ocultarSprites:
		push {r0-r1, lr}
		
		mov r1, r0				@; R1 guardará el límite
		mov r0, #0				@; R0 = índice de sprite
	.LbSbucle:
		cmp r0, r1
		beq .LbS_fibucle		@; por cada índice,
		bl SPR_ocultarSprite	@; llamar a la rutina que efectúa la ocultación
		add r0, #1
		b .LbSbucle
	.LbS_fibucle:
		
		pop {r0-r1, pc}



@;SPR_moverSprite(int indice, int px, int py);
@;Rutina para mover el extremo superior-izquierdo
@;hasta la posición (px, py) indicada por parámetro
@;Parámetros:
@;	indice (R0):	índice del sprite a mover
@;	px (R1):		nueva coordenada x del sprite
@;	py (R2):		nueva coordenada y del sprite
	.global SPR_moverSprite
SPR_moverSprite:
		push {r4-r5, lr}
		
		and r0, #127			@; filtrar índice de sprite
		bic r1, #0xFE00			@; filtrar coordenada X (0..511)
		and r2, #255			@; filtrar coordenada Y (0..255)
		ldr r4, =oam_data		@; R4 = direccion inicial de datos oam
		add r4, r0, lsl #3		@; sumar índice de sprite * 8
		ldrh r5, [r4]			@; cargar valor de atributo 0
		bic r5, #0x00FF			@; borrar bits 7..0
		orr r5, r2				@; activar bits py
		strh r5, [r4]			@; guarda el nuevo valor del atributo 0
		ldrh r5, [r4, #2]		@; cargar valor de atributo 1
		bic r5, #0x00FF			@; borrar bits 7..0
		bic r5, #0x0100			@; borrar bit 8
		orr r5, r1				@; activar bits px
		strh r5, [r4, #2]		@; guarda el nuevo valor del atributo 1
		
		pop {r4-r5, pc}


@;SPR_fijarPrioridad(int indice, int prioridad);
@;Rutina para fijar la prioridad del sprite respecto a los fondos gráficos
@;Parámetros:
@;	indice (R0):	índice del sprite a modificar su prioridad
@;	prioridad (R1):	prioridad relativa (0..3, 0 -> màxima)
	.global SPR_fijarPrioridad
SPR_fijarPrioridad:
		push {r2-r3, lr}
		
		and r0, #127			@; filtrar índice de sprite (0..127)
		and r1, #3				@; filtrar prioridad (0..3)
		ldr r2, =oam_data		@; R2 = direccion inicial de datos oam
		add r2, r0, lsl #3		@; sumar índice de sprite * 8
		ldrh r3, [r2, #4]		@; cargar valor de atributo 2
		bic r3, #0x0C00			@; borrar bits 11..10
		orr r3, r1, lsl #10		@; añadir prioridad, desplazada a bits 11..10
		strh r3, [r2, #4]		@; guarda el nuevo valor del atributo
		
		pop {r2-r3, pc}



@;SPR_activarRotacionEscalado(int indice, int grupo);
@;Rutina para asignar un grupo de rotación/escalado el sprite indicado
@;Parámetros:
@;	indice (R0):	índice del sprite a fijar
@;	grupo (R1):		índice del grupo (0..31)
	.global SPR_activarRotacionEscalado
SPR_activarRotacionEscalado:
		push {r4-r5, lr}
		
		and r0, #127			@; filtrar índice de sprite
		and r1, #31				@; filtrar índice de grupo (0..31)
		ldr r4, =oam_data		@; R4 = direccion inicial de datos oam
		add r4, r0, lsl #3		@; sumar índice de sprite * 8
		ldrh r5, [r4, #2]		@; cargar valor de atributo 1
		bic r5, #0x3E00			@; borrar bits 13..9
		orr r5, r1, lsl #9		@; fijar grupo, desplazado a bits 13..9
		strh r5, [r4, #2]		@; guarda el nuevo valor del atributo 1
		ldrh r5, [r4]			@; cargar valor de atributo 0
		orr r5, #0x0100			@; activar bit 8 (rotación/escalado activo)
		bic r5, #0x0200			@; desactivar bit 9 (tamaño normal)
		strh r5, [r4]			@; guarda el nuevo valor del atributo 0
		
		pop {r4-r5, pc}


@;SPR_desactivarRotacionEscalado(int indice);
@;Rutina para desactivar la rotación/escalado del sprite indicado
@;Restricciones: el sprite siempre quedará visible, porque se supone que ya lo
@;	era; en caso contrario, habrá que llamar a SPR_ocultarSprite() después de
@;	llamar a esta rutina.
@;Parámetros:
@;	indice (R0):	índice del sprite a fijar
	.global SPR_desactivarRotacionEscalado
SPR_desactivarRotacionEscalado:
		push {r4-r5, lr}
		
		and r0, #127			@; filtrar índice de sprite
		and r1, #31				@; filtrar índice de grupo (0..31)
		ldr r4, =oam_data		@; R4 = direccion inicial de datos oam
		add r4, r0, lsl #3		@; sumar índice de sprite * 8
		ldrh r5, [r4]			@; cargar valor de atributo 0
		bic r5, #0x0300			@; desactivar bit 8 (rotación/escalado)
								@; desactivar bit 9 (sprite visible)
		strh r5, [r4]			@; guarda el nuevo valor del atributo 0
		
		pop {r4-r5, pc}


@;SPR_fijarEscalado(int igrp, short sx, short sy);
@;Rutina para fijar un valor de escala en cada coordenada (sx,sy) de un grupo
@;	de rotación/escalado indicado en el parámetro igrp
@;Parámetros:
@;	igrp (R0):		índice del grupo de rotación-escalado (0..31)
@;	sx (R1):		factor de escalado x (formato 0.8.8)
@;	sy (R2):		factor de escalado y (formato 0.8.8) 
	.global SPR_fijarEscalado
SPR_fijarEscalado:
		push {r4-r5, lr}
		
		and r0, #31				@; filtrar índice de grupo (0..31)
		mov r5, #0
		ldr r4, =oam_data		@; R4 = direccion inicial de datos oam
		add r4, r0, lsl #5		@; sumar índice de grupo * 32
		strh r1, [r4, #6]		@; PA = sx
		strh r5, [r4, #14]		@; PB = 0
		strh r5, [r4, #22]		@; PC = 0
		strh r2, [r4, #30]		@; PD = sy
		
		pop {r4-r5, pc}




.end
