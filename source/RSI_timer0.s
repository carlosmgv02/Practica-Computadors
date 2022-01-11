
@;=                                                          	     	=
@;=== RSI_timer0.s: rutinas para mover los elementos (sprites)		  ===
@;=                                                           	    	=
@;=== Programador tarea 2E: jialiang.chen@estudiants.urv.cat		  ===
@;=== Programador tarea 2G: carlos.martínez@estudiants.urv.cat		  		  ===
@;=== Programador tarea 2H: ismael.ruiz@estudiants.urv.cat		 		  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables globales inicializadas ---
.data
		.align 2
		.global update_spr
	update_spr:	.hword	0			@;1 -> actualizar sprites
		.global timer0_on
	timer0_on:	.hword	0 			@;1 -> timer0 en marcha, 0 -> apagado
	divFreq0: .hword	-5727		@;divisor de frecuencia inicial para timer 0
									@;pdf pág 35

@;-- .bss. variables globales no inicializadas ---
.bss
		.align 2
	divF0: .space	2				@;divisor de frecuencia actual


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm

@;TAREAS 2Ea,2Ga,2Ha;
@;rsi_vblank(void); Rutina de Servicio de Interrupciones del retroceso vertical;
@;Tareas 2E,2F: actualiza la posición y forma de todos los sprites
@;Tarea 2G: actualiza las metabaldosas de todas las gelatinas
@;Tarea 2H: actualiza el desplazamiento del fondo 3
	.global rsi_vblank
rsi_vblank:
		push {r0-r7, lr}
		
@;Tareas 2Ea
		ldr r3, =update_spr 
		ldrh r1, [r3]			@;r1= update_spr
		cmp r1, #0x01
		bne .LfinalRSI
		mov r0, #0x07000000		@;parámetro base , es decir, el OAM(PDF pág 30)
		ldr r2, =n_sprites		@;Límite de sprites
		ldr r1, [r2]
		bl SPR_actualizarSprites@;Llamada a la funcion
		mov r0, #0x00
		strh r0, [r3]			@;guardar 0 en update_spr
		.LfinalRSI:
@;Tarea 2Ga
		ldr r4,=update_gel
		ldrh r5,[r4]
		cmp r5,#0
		beq .Lfin
		mov r1,#0
		ldr r7,=mat_gel
		.LforCol:
		mov r2,#0		@;r2=j(cols)
		
		.LforFil:
		ldsb r3, [r7,#GEL_II]
		cmp r3, #0
		bne .LfiforCol
		ldrb r3,[r7,#GEL_IM]
	
		mov r0,#0x06000000
		bl fija_metabaldosa
	
		mov r6,#10
		strb r6,[r7,#GEL_II]

		.LfiforCol:
		add r7,#GEL_TAM
		add r2,#1
		cmp r2,#COLUMNS
		blt .LforFil

		.LfiforFil:
		add r1,#1
		cmp r1,#ROWS
		blt .LforCol
		mov r5,#0
		strh r5,[r4]
	
		.Lfin:

@;Tarea 2Ha
		ldr r1, =update_bg3
		ldrh r0, [r1]
		cmp r0, #0
		beq .Lfinal_vBlank3
	
		ldr r2, =offsetBG3X
		ldrh r0, [r2]
		mov r0, r0, lsl #8
		ldr r2, =0x04000038
		str r0, [r2]
		mov r0, #0
		strh r0, [r1]
		
	.Lfinal_vBlank3:
		
		pop {r0-r7, pc}




@;TAREA 2Eb;
@;activa_timer0(init); rutina para activar el timer 0, inicializando o no el
@;	divisor de frecuencia según el parámetro init.
@;	Parámetros:
@;		R0 = init; si 1, restablecer divisor de frecuencia original 'divFreq0'
	.global activa_timer0
activa_timer0:
		push {r0-r3, lr}
		cmp r0, #0x00
		beq .LfinalActivarTimer0 @; ignorar si init=0
		ldr r0, =divFreq0		@;cargar var
		ldrh r1, [r0]
		ldr r2, =divF0
		strh r1, [r2]			@;copiar divFreq0 a divF0
		ldr r3, =0x04000100		@;cargar reg de data de timer0 PDF pag 37)
		strh r1, [r3]
		.LfinalActivarTimer0:
		ldr r0, =timer0_on		
		mov r1, #0x01
		strh r1, [r0]
		ldr r0, =0x04000102		@;cargar reg de control de timer0
		mov r1, #0b11000001		@;definir los bits (pág 37)
		strh r1, [r0]			@;activar el timer e interrupciones
		
		
		pop {r0-r3, pc}

@;TAREA 2Ec;
@;desactiva_timer0(); rutina para desactivar el timer 0.
	.global desactiva_timer0
desactiva_timer0:
		push {r0-r1, lr}
		ldr r0, =0x04000102		@;cargar reg de control
		mov r1, #0b00000000		@;poner el bit 7 a 0 (desactivar)
		strh r1, [r0]			@;guardar el registro
		ldr r0, =timer0_on	
		mov r1, #0x0	
		strh r1, [r0]			@;guardar 0 en la var timer._on
		pop {r0-r1, pc}



@;TAREA 2Ed;
@;rsi_timer0(); rutina de Servicio de Interrupciones del timer 0: recorre todas
@;	las posiciones del vector 'vect_elem' y, en el caso que el código de
@;	activación (ii) sea mayor que 0, decrementa dicho código y actualiza
@;	la posición del elemento (px, py) de acuerdo con su velocidad (vx,vy),
@;	además de mover el sprite correspondiente a las nuevas coordenadas;
@;	si no se ha movido ningún elemento, se desactivará el timer 0. En caso
@;	contrario, el valor del divisor de frecuencia se reducirá para simular
@;  el efecto de aceleración (con un límite).
	.global rsi_timer0
rsi_timer0:
		push {r0-r12, lr}
		mov r0, #0			@;r0=i
		mov r10, #0			@;booleano
		ldr r4, =n_sprites
		ldr r3, [r4]		@;r3=n_sprites (32bits)
		ldr r4, =vect_elem	@;elemento actual (Direccion actual)
		.LwhileRSITimer0:
		cmp r0, r3			@;comparar 
		bhs .LfiBucleWhileRSI0
		ldrh r12, [r4]		@;r12=vect_elem (valor actual (16bits))
		cmp r12, #0
		beq .LsiguientePosicion
		cmp r12, #-1
		beq .LsiguientePosicion
		sub r12, #1
		strh r12, [r4]		@;decrementar y guardar ii
		ldrh r1, [r4,#2]	@;r1=px
		ldrh r2, [r4,#4]	@;r2=py
		ldrh r5, [r4,#6]	@;r5=vx
		ldrh r6, [r4,#8]	@;r6=vy

		cmp r5, #0
		addne r1, r5		@;px=px+vx
		addne r10, #1		@;se ha movido
		strneh r1, [r4,#2]	@;actualizar valor px
		cmp r6, #0
		addne r2, r6		@;py=py+vy
		addne r10, #1		@;se ha movido
		strneh r2, [r4,#4]	@;actualizar valor py
		bl SPR_moverSprite	@;actualizar sprites
		.LsiguientePosicion:
		add r4, #10			@;saltar al siguiente elemento
		add r0, #1			@;i++
		b .LwhileRSITimer0
		.LfiBucleWhileRSI0:
		cmp r10, #0
		bleq desactiva_timer0
		.LfiServicioInterrupcionesTimer0:
		ldr r0, =update_spr
		ldrh r1, [r0]
		mov r1, #1
		strh r1, [r0]
		ldr r0, =divFreq0
		ldrh r1, [r0]
		cmp r1, #-300
		addle r1, #256		strleh r1, [r0]
		pop {r0-r12, lr}
.end
