@;=                                                          	     	=
@;=== RSI_timer0.s: rutinas para mover los elementos (sprites)		  ===
@;=                                                           	    	=
@;=== Programador tarea 2E: xxx.xxx@estudiants.urv.cat				  ===
@;=== Programador tarea 2G: yyy.yyy@estudiants.urv.cat				  ===
@;=== Programador tarea 2H: ismael.ruiz@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables globales inicializadas ---
.data
		.align 2
		.global update_spr
	update_spr:	.hword	0			@;1 -> actualizar sprites
		.global timer0_on
	timer0_on:	.hword	0 			@;1 -> timer0 en marcha, 0 -> apagado
	divFreq0: .hword 	-5728			@;divisor de frecuencia inicial para timer 0


@;-- .bss. variables globales no inicializadas ---
.bss
		.align 2
	divF0: .space	2				@;divisor de frecuencia actual


@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm

@;TAREAS 2Ea,2Ga,2Ha;
@;rsi_vblank(void); Rutina de Servicio de Interrupciones del retroceso vertical;
@;Tareas 2E,2F: actualiza la posici�n y forma de todos los sprites
@;Tarea 2G: actualiza las metabaldosas de todas las gelatinas
@;Tarea 2H: actualiza el desplazamiento del fondo 3
	.global rsi_vblank
rsi_vblank:
		push {r0-r7,lr}
		
@;Tareas 2Ea


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

	
		pop {r0-r7,pc}




@;TAREA 2Eb;
@;activa_timer0(init); rutina para activar el timer 0, inicializando o no el
@;	divisor de frecuencia seg�n el par�metro init.
@;	Par�metros:
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
@;	las posiciones del vector 'vect_elem' y, en el caso que el c�digo de
@;	activaci�n (ii) sea mayor que 0, decrementa dicho c�digo y actualiza
@;	la posici�n del elemento (px, py) de acuerdo con su velocidad (vx,vy),
@;	adem�s de mover el sprite correspondiente a las nuevas coordenadas;
@;	si no se ha movido ning�n elemento, se desactivar� el timer 0. En caso
@;	contrario, el valor del divisor de frecuencia se reducir� para simular
@;  el efecto de aceleraci�n (con un l�mite).
	.global rsi_timer0
rsi_timer0:
		push {lr}
		
		
		pop {pc}



.end
