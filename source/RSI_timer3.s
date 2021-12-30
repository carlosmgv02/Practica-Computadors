@;=                                                          	     	=
@;=== RSI_timer3.s: rutinas para desplazar el fondo 3 (imagen bitmap) ===
@;=                                                           	    	=
@;=== Programador tarea 2H: xxx.xxx@estudiants.urv.cat				  ===
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
	divFreq3: .hword	0			@;divisor de frecuencia para timer 3
	


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Hb;
@;activa_timer3(); rutina para activar el timer 3.
	.global activa_timer3
activa_timer3:
		push {lr}
		
		
		pop {pc}


@;TAREA 2Hc;
@;desactiva_timer3(); rutina para desactivar el timer 3.
	.global desactiva_timer3
desactiva_timer3:
		push {lr}
		
		
		pop {pc}



@;TAREA 2Hd;
@;rsi_timer3(); rutina de Servicio de Interrupciones del timer 3: incrementa o
@;	decrementa el desplazamiento X del fondo 3 (sobre la variable global
@;	'offsetBG3X'), según el sentido de desplazamiento actual; cuando el
@;	desplazamiento llega a su límite, se cambia el sentido; además, se avisa
@;	a la RSI de retroceso vertical para que realice la actualización del
@;	registro de control del fondo correspondiente.
	.global rsi_timer3
rsi_timer3:
		push {lr}
		
		
		pop {pc}



.end
