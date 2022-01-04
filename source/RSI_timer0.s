@;=                                                          	     	=
@;=== RSI_timer0.s: rutinas para mover los elementos (sprites)		  ===
@;=                                                           	    	=
@;=== Programador tarea 2E: jialiang.chen@estudiants.urv.cat		  ===
@;=== Programador tarea 2G: xxx.xxx@estudiants.urv.cat		  		  ===
@;=== Programador tarea 2H: xxx.xxx@estudiants.urv.cat		 		  ===
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
		push {r0-r3, lr}
		
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


@;Tarea 2Ha

		
		pop {pc}




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
		ldr r3, =0x04000100		@;cargar reg de data de timer0PDF pag 37)
		strh r1, [r3]
		.LfinalActivarTimer0:	@;llamada a funcion
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
		mov r1, #0b01000001		@;poner el bit 7 a 0 (desactivar)
		strh r1, [r0]			@;guardar el registro
		ldr r0, =timer0_on	
		mov r1, #0x0	
		strh r1, [r0]			@;guardar 0 en la var timer._on
		
		pop {r0, r1pc}



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
		push {lr}
		ldr r3, =elemento
		ldrh r2, [r3]
		cmp r2, #0
		ble .LfiServicioInterrupcionesTimer0
		sub r2, #0x01
		strh r2, [r3]			@; guardar ii
		
		add r3, #0x06
		ldrh r2, [r3]
		
		
		
		..LfiServicioInterrupcionesTimer0:
		pop {pc}



.end
