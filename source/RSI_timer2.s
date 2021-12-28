@;=                                                          	     	=
@;=== RSI_timer2.s: rutinas para animar las gelatinas (metabaldosas)  ===
@;=                                                           	    	=
@;=== Programador tarea 2G: xxx.xxx@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables globales inicializadas ---
.data
		.align 2
		.global update_gel
	update_gel:	.hword	0			@;1 -> actualizar gelatinas
		.global timer2_on
	timer2_on:	.hword	0 			@;1 -> timer2 en marcha, 0 -> apagado
	divFreq2: .hword	@;?			@;divisor de frecuencia para timer 2



@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Gb;
@;activa_timer2(); rutina para activar el timer 2.
	.global activa_timer2
activa_timer2:
		push {lr}
		
		
		pop {pc}


@;TAREA 2Gc;
@;desactiva_timer2(); rutina para desactivar el timer 2.
	.global desactiva_timer2
desactiva_timer2:
		push {lr}
		
		
		pop {pc}



@;TAREA 2Gd;
@;rsi_timer2(); rutina de Servicio de Interrupciones del timer 2: recorre todas
@;	las posiciones de la matriz 'mat_gel' y, en el caso que el c�digo de
@;	activaci�n (ii) sea mayor que 0, decrementa dicho c�digo en una unidad y
@;	pasa a analizar la siguiente posici�n de la matriz 'mat_gel';
@;	en el caso que ii sea igual a 0, incrementa su c�digo de metabaldosa y
@;	activa una variable global 'update_gel' para que la RSI de VBlank actualize
@;	la visualizaci�n de dicha metabaldosa.
	.global rsi_timer2
rsi_timer2:
		push {lr}
		
		
		pop {pc}



.end
