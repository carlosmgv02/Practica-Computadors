@;=                                                          	     	=
@;=== RSI_timer3.s: rutinas para desplazar el fondo 3 (imagen bitmap) ===
@;=                                                           	    	=
@;=== Programador tarea 2H: joseluis.pueyo@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables globales inicializadas ---
.data
		.align 2
		.global update_bg3
	update_bg3:	.hword	0			@;1 -> actualizar fondo 3
		.global timer3_on
	timer3_on:	.hword	0 			@;1 -> timer3 en marcha, 0 -> apagado
		.global offsetBG3X
	offsetBG3X: .hword	0			@;desplazamiento vertical fondo 3
	sentidBG3X:	.hword	0			@;sentido desplazamiento (0-> inc / 1-> dec)
	divFreq3: .hword	52365	@;divisor de frecuencia para timer 3, resultado de calcular Frec_Entrada / -Frec_Salida = -(523655,97/10) = -52365.597, en valor absoluto -> |-52365.597| < 65.536
	


@;-- .text. c?digo de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Hb;
@;activa_timer3(); rutina para activar el timer 3.
	.global activa_timer3
activa_timer3:
		push {r0-r1,lr}
		@; Cargar un 1 a la variable timer_on
		ldr r0, =timer3_on
		mov r1, #1
		strb r1, [r0]
		@; Activar el timer3
		ldr r0, =0x0400010E		@;TIMER3_CR
		ldrh r1, [r0]
		@; Aplico la mascara para escribir solo en los bits 0..1,6,7
		@; 0..1 Prescaler Selection = 01 = F/64
		@; 6	Timer IRQ Enable -> 1
		@; 7	Timer Start/Stop -> 1
		orr r1, #0b11000001
		bic r1, #0b00000010
		strh r1, [r0]
		@; Cargar el divisor de frequencia al timer3
		ldr r0, =divFreq3
		ldrh r1, [r0]
		ldr r0, =0x0400010C		@;TIMER3_DATA
		strh r1, [r0]
		pop {r0-r1,pc}


@;TAREA 2Hc;
@;desactiva_timer3(); rutina para desactivar el timer 3.
	.global desactiva_timer3
desactiva_timer3:
		push {r0-r1,lr}
		@; Cargar un 0 a la variable timer_on
		ldr r0, =timer3_on
		mov r1, #0
		strb r1, [r0]
		@; Desactivar el timer3
		ldr r0, =0x0400010E		@;TIMER3_CR
		ldrh r1, [r0]
		@; Aplico la mascara para escribir solo en los bits 6,7
		@; 6	Timer IRQ Enable -> 0
		@; 7	Timer Start/Stop -> 0
		bic r1, #0b11000000
		strh r1, [r0]
		pop {r0-r1,pc}



@;TAREA 2Hd;
@;rsi_timer3(); rutina de Servicio de Interrupciones del timer 3: incrementa o
@;	decrementa el desplazamiento X del fondo 3 (sobre la variable global
@;	'offsetBG3X'), seg?n el sentido de desplazamiento actual; cuando el
@;	desplazamiento llega a su l?mite, se cambia el sentido; adem?s, se avisa
@;	a la RSI de retroceso vertical para que realice la actualizaci?n del
@;	registro de control del fondo correspondiente.
	.global rsi_timer3
rsi_timer3:
		push {r0-r3,lr}
		
		ldr r0, =sentidBG3X
		ldrh r1, [r0]
		ldr r2, =offsetBG3X
		ldrh r3, [r2]
		@; Modificar el offset 1 unidad en el sentido adecuado
		cmp r1, #0
		addeq r3, #1
		subne r3, #1
		@; Limite superior
		cmp r3, #320
		subeq r1, #1
		streqh r1, [r0]
		@; Limite inferior
		cmp r3, #0
		addeq r1, #1
		streqh r1, [r0]
		@; Activar la variable update_bg3
		mov r1, #1
		ldr r0, =update_bg3
		strh r1, [r0]
		
		pop {r0-r3,pc}



.end

