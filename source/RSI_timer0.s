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
									@;pdf p�g 35

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
		push {r0-r3, lr}
		
@;Tareas 2Ea
	ldr r3, =update_spr 
	ldrh r1, [r3]			@;r1= update_spr
	cmp r1, #0x01
	bne .LfinalRSI
	mov r0, #0x07000000		@;par�metro base , es decir, el OAM(PDF p�g 30)
	ldr r2, =n_sprites		@;L�mite de sprites
	ldr r1, [r2]
	bl SPR_actualizarSprites@;Llamada a la funcion
	mov r0, #0x00
	strh r0, [r3]			@;guardar 0 en update_spr
	.LfinalRSI:
@;Tarea 2Ga


@;Tarea 2Ha

		
		pop {r0-r3, pc}




@;TAREA 2Eb;
@;activa_timer0(init); rutina para activar el timer 0, inicializando o no el
@;	divisor de frecuencia seg�n el par�metro init.
@;	Par�metros:
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
		mov r1, #0b11000001		@;definir los bits (p�g 37)
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
		pop {r0-r1, pc}



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
		push {r0-r12, lr}
		mov r0, #0			@;r0=i
		ldr r4, =n_sprites
		ldr r3, [r4]		@;r3=n_sprites (32bits)
		ldr r4, =vect_elem	@;elemento actual (Direccion actual)
		.LwhileRSITimer0:
		cmp r0, r3			@;comparar 
		bhs .LfiBucleWhileRSI0
		ldrh r12, [r4]		@;r12=vect_elem (valor actual (16bits))
		cmp r12, #-1
		beq .LsiguientePosicion
		cmp r12, #0
		beq .LsiguientePosicion
		sub r12, #1
		strh r12, [r4]		@;decrementar y guardar ii
		ldrh r1, [r4,#1]	@;r1=px
		ldrh r2, [r4,#2]	@;r2=py
		ldrh r5, [r4,#3]	@;r5=vx
		ldrh r6, [r4,#4]	@;r6=vy
		
		cmp r5, #0
		addne r1, r5		@;px=px+vx
		strneh r1, [r4,#1]	@;actualizar valor px
		cmp r6, #0
		addne r2, r6		@;py=py+vy
		strneh r2, [r4,#2]	@;actualizar valor py
		
		bl SPR_moverSprite	@;actualizar sprites
		
		cmp r5,#0
		bne .LseHaMovidoElemento
		cmp r6, #0
		beq .LnoSeHaMovidoElemento
		.LseHaMovidoElemento:
		ldr r7, =update_spr
		ldrh r8, [r7]		@;valor de update_spr
		mov r8, #0x01
		strh r8, [r7]		@;activar update_spr
		ldr r7, =divFreq0	
		ldrh r9, [r7]		@;r9=divFreq0
		add r9, #2000
		strh r9, [r7]
		b .LsiguientePosicion
		.LnoSeHaMovidoElemento:
		bl desactiva_timer0
		
		.LsiguientePosicion:
		add r4, #5			@;saltar al siguiente elemento
		add r0, #1			@;i++
		b .LwhileRSITimer0
		.LfiBucleWhileRSI0:
		.LfiServicioInterrupcionesTimer0:
		pop {r0-r12, lr}



.end
