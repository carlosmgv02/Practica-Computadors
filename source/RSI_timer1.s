@;=                                                          	     	=
@;=== RSI_timer1.s: rutinas para escalar los elementos (sprites)	  ===
@;=                                                           	    	=
@;=== Programador tarea 2F: ismael.ruiz@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2
		.global timer1_on
	timer1_on:	.hword	0 			@;1 -> timer1 en marcha, 0 -> apagado
	divFreq1: .hword	-5727,5			@;divisor de frecuencia para timer 1 Div_Frec = -(Frec_Entrada / Frec_Salida)
										@; -( 523.655,96875 / (32/0,35) ) = -5727,487159


@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
	escSen: .space	2				@;sentido de escalado (0-> dec, 1-> inc)
	escFac: .space	2				@;factor actual de escalado
	escNum: .space	2				@;número de variaciones del factor


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Fb;
@;activa_timer1(init); rutina para activar el timer 1, inicializando el sentido
@;	de escalado según el parámetro init.
@;	Parámetros:
@;		R0 = init;  valor a trasladar a la variable 'escSen' (0/1)
	.global activa_timer1
activa_timer1:
		push {r0-r2,lr}
		
		ldr r1, =escSen
		strh r0, [r1]

		cmp r0, #0
		bne .LFinal_activar_timer1
		ldr r2, =escFac
		mov r1, #1
		mov r1, lsl #8
		strh r1, [r2]
		mov r2, r1
		bl SPR_fijarEscalado
	.LFinal_activar_timer1:
		
		mov r0, #0
		ldr r1, =escNum
		strh r0, [r1]
		mov r0, #1
		ldr r1, =timer1_on
		strh r0,[r1]
		ldr r1, =divFreq1
		ldrh r0, [r1]
		ldr r1, =0x04000104   	@;0400 0104 TIMER1_DATA Valor del contador; carga de divisor de frecuencia
		strh r0,[r1]
		ldr r1, =0x04000106		@;0400 0106 TIMER1_CR Registro de control del timer 1
		mov r0, #0xC1           @;1100 0001 --> 0xC1
		strh r0, [r1]	
		
		pop {r0-r2,pc}


@;TAREA 2Fc;
@;desactiva_timer1(); rutina para desactivar el timer 1.
	.global desactiva_timer1
desactiva_timer1:
		push {r0-r1,lr}
		
		
		ldr r1, =0x04000106
		ldrh r0, [r1]
		bic r0, #0x80
		strh r0, [r1]
		mov r0, #0
		ldr r1, =timer1_on
		strh r0, [r1]
		
		pop {r0-r1,pc}



@;TAREA 2Fd;
@;rsi_timer1(); rutina de Servicio de Interrupciones del timer 1: incrementa el
@;	número de escalados y, si es inferior a 32, actualiza factor de escalado
@;	actual según el código de la variable 'escSen'; cuando se llega al máximo,
@;	se desactiva el timer1.
	.global rsi_timer1
rsi_timer1:
		push {lr}
		
		
		pop {pc}



.end
