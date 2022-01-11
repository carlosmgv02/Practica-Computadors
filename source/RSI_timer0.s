@;=                                                          	     	=
@;=== RSI_timer0.s: rutinas para mover los elementos (sprites)		  ===
@;=                                                           	    	=
@;=== Programador tarea 2E: xxx.xxx@estudiants.urv.cat				  ===
@;=== Programador tarea 2G: yyy.yyy@estudiants.urv.cat				  ===
@;=== Programador tarea 2H: joseluis.pueyo@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables globales inicializadas ---
.data
		.align 2
		.global update_spr
	update_spr:	.hword	0			@;1 -> actualizar sprites
		.global timer0_on
	timer0_on:	.hword	0 			@;1 -> timer0 en marcha, 0 -> apagado
	divFreq0: .hword	@;?			@;divisor de frecuencia inicial para timer 0


@;-- .bss. variables globales no inicializadas ---
.bss
		.align 2
	divF0: .space	2				@;divisor de frecuencia actual


@;-- .text. c?digo de las rutinas ---
.text	
		.align 2
		.arm

@;TAREAS 2Ea,2Ga,2Ha;
@;rsi_vblank(void); Rutina de Servicio de Interrupciones del retroceso vertical;
@;Tareas 2E,2F: actualiza la posici?n y forma de todos los sprites
@;Tarea 2G: actualiza las metabaldosas de todas las gelatinas
@;Tarea 2H: actualiza el desplazamiento del fondo 3
	.global rsi_vblank
rsi_vblank:
		push {r0-r2,lr}
		
@;Tareas 2Ea


@;Tarea 2Ga


@;Tarea 2Ha
		ldr r0, =update_bg3
		ldrb r1, [r0]
		cmp r1, #1
		bne .LFiUpdateBg
		ldr r1, =offsetBG3X
		ldrh r2, [r1]
		ldr r1, =#0x04000038 @;dirección del REG_BG3X
		mov r2, r2, lsl #8
		strh r2, [r1]
		mov r1, #1
		strb r1, [r0]
	.LFiUpdateBg:
		pop {r0-r2,pc}




@;TAREA 2Eb;
@;activa_timer0(init); rutina para activar el timer 0, inicializando o no el
@;	divisor de frecuencia seg?n el par?metro init.
@;	Par?metros:
@;		R0 = init; si 1, restablecer divisor de frecuencia original 'divFreq0'
	.global activa_timer0
activa_timer0:
		push {lr}
		
		
		pop {pc}


@;TAREA 2Ec;
@;desactiva_timer0(); rutina para desactivar el timer 0.
	.global desactiva_timer0
desactiva_timer0:
		push {lr}
		
		
		pop {pc}



@;TAREA 2Ed;
@;rsi_timer0(); rutina de Servicio de Interrupciones del timer 0: recorre todas
@;	las posiciones del vector 'vect_elem' y, en el caso que el c?digo de
@;	activaci?n (ii) sea mayor que 0, decrementa dicho c?digo y actualiza
@;	la posici?n del elemento (px, py) de acuerdo con su velocidad (vx,vy),
@;	adem?s de mover el sprite correspondiente a las nuevas coordenadas;
@;	si no se ha movido ning?n elemento, se desactivar? el timer 0. En caso
@;	contrario, el valor del divisor de frecuencia se reducir? para simular
@;  el efecto de aceleraci?n (con un l?mite).
	.global rsi_timer0
rsi_timer0:
		push {lr}
		
		
		pop {pc}



.end
