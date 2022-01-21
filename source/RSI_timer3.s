@;=                                                          	     	=
@;=== RSI_timer3.s: rutinas para desplazar el fondo 3 (imagen bitmap) ===
@;=                                                           	    	=
@;=== Programador tarea 2H: ismael.ruiz@estudiants.urv.cat				  ===
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
	divFreq3: .hword	-13091			@;divisor de frecuencia para timer 3
									@; div_freq = -(freq_entrada / freq_salida)   
									@; freq_salida = 10tics/s freq_entrada=130.913,99
									@;div_freq = -(130.913,99/10) = -13.091,39
	


@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Hb;
@;activa_timer3(); rutina para activar el timer 3.
	.global activa_timer3
activa_timer3:
		push {r0-r1,lr}
		
		ldr r1, =timer3_on
		mov r0, #1
		strh r0, [r1]
		
		ldr r1, =divFreq3
		ldrh r0, [r1]
		ldr r1, =0x0400010C
		strh r0,[r1]
		
		ldr r1, =0x0400010E
		mov r0, #0xC2                   @;0b1100 0010
		strh r0, [r1]
		pop {r0-r1,pc}


@;TAREA 2Hc;
@;desactiva_timer3(); rutina para desactivar el timer 3.
	.global desactiva_timer3
desactiva_timer3:
		push {r0-r1,lr}
		
		ldr r1, =timer3_on
		mov r0, #0
		strh r0, [r1]
		
		ldr r1, =0x0400010E
		ldrh r0, [r1]
		bic r0, #0x80
		strh r0, [r1]
	
		pop {r0-r1,pc}



@;TAREA 2Hd;
@;rsi_timer3(); rutina de Servicio de Interrupciones del timer 3: incrementa o
@;	decrementa el desplazamiento X del fondo 3 (sobre la variable global
@;	'offsetBG3X'), seg�n el sentido de desplazamiento actual; cuando el
@;	desplazamiento llega a su l�mite, se cambia el sentido; adem�s, se avisa
@;	a la RSI de retroceso vertical para que realice la actualizaci�n del
@;	registro de control del fondo correspondiente.
	.global rsi_timer3
rsi_timer3:
		push {r0-r3,lr}
		ldr r1, =sentidBG3X
		ldrh r0, [r1]
		ldr r3, =offsetBG3X
		ldrh r2, [r3]
		
		cmp r0, #0
		addeq r2, #1
		addne r2, #-1
		
		strh r2, [r3]
		
		cmp r2, #320
		moveq r0, #1
		cmp r2, #0
		moveq r0, #0
		
		strh r0, [r1]
		
		ldr r1, =update_bg3
		mov r0, #1
		strh r0, [r1]
		
		
		pop {r0-r3,pc}




.end
