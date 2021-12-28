@;=                                                          	     	=
@;=== RSI_timer1.s: rutinas para escalar los elementos (sprites)	  ===
@;=                                                           	    	=
@;=== Programador tarea 2F: xxx.xxx@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2
		.global timer1_on
	timer1_on:	.hword	0 			@;1 -> timer1 en marcha, 0 -> apagado
	divFreq1: .hword	@;?			@;divisor de frecuencia para timer 1


@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
	escSen: .space	2				@;sentido de escalado (0-> dec, 1-> inc)
	escFac: .space	2				@;factor actual de escalado
	escNum: .space	2				@;n�mero de variaciones del factor


@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Fb;
@;activa_timer1(init); rutina para activar el timer 1, inicializando el sentido
@;	de escalado seg�n el par�metro init.
@;	Par�metros:
@;		R0 = init;  valor a trasladar a la variable 'escSen' (0/1)
	.global activa_timer1
activa_timer1:
		push {lr}
		
		
		pop {pc}


@;TAREA 2Fc;
@;desactiva_timer1(); rutina para desactivar el timer 1.
	.global desactiva_timer1
desactiva_timer1:
		push {lr}
		
		
		pop {pc}



@;TAREA 2Fd;
@;rsi_timer1(); rutina de Servicio de Interrupciones del timer 1: incrementa el
@;	n�mero de escalados y, si es inferior a 32, actualiza factor de escalado
@;	actual seg�n el c�digo de la variable 'escSen'; cuando se llega al m�ximo,
@;	se desactiva el timer1.
	.global rsi_timer1
rsi_timer1:
		push {lr}
		
		
		pop {pc}



.end
