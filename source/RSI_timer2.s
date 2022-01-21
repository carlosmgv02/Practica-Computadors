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
	divFreq2: .hword	-5236		@;divisor de frecuencia para timer 2
	@;GEL_II puede ser 10 max y tienen q haber 10 refrescos por baldosa/s
	@;523655,96/10*10



@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Gb;
@;activa_timer2(); rutina para activar el timer 2.
	.global activa_timer2
activa_timer2:
		push {r0-r2,lr}
		ldr r0,=timer2_on
		mov r1, #1
		strh r1, [r0]
		ldr r0, =0x04000108		@;Dir mem timer2
		ldr r1,=divFreq2
		ldrh r1,[r1]
		strh r1,[r0]
		ldr r2,=0x0400010A 	@;reg de control timer
		mov r1,#0x0C1		@;los otros bits no importan
		strh r1, [r2]			
		pop {r0-r2,pc}
		


@;TAREA 2Gc;
@;desactiva_timer2(); rutina para desactivar el timer 2.
	.global desactiva_timer2
desactiva_timer2:
		push {r0-r3,lr}
		ldr r0,=timer2_on
		mov r1, #0
		strh r1, [r0]
		ldr r2,=0x0400010A 
		mov r3, #0x0	@;todos bits desactiv
		strh r3,[r2]
		pop {r0-r3,pc}

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
		push {r0-r6, lr}
		
		ldr r0, =mat_gel				
		mov r1, #0						@; r1=filas
		
	.LforFil:								
		mov r2, #0						@; r2=cols
		
	.LforCol:								
		ldsb r3, [r0, #GEL_II]			
		cmp r3, #0						
		blt .LfiForCol
		bne .Ldecrease
		ldrb r4, [r0, #GEL_IM]		
		cmp r4, #7						
		bls .LGelsimple
		b .LGeldoble

		.Ldecrease:
		sub r3, #1						
		strb r3, [r0, #GEL_II]		
		b .LfiForCol						
	
	.LGeldoble:
		cmp r4, #15						
		moveq r4, #8					
		addne r4, #1
		b .Lupdate_gel	

	.LGelsimple:
		cmp r4, #7						
		addne r4, #1					
		moveq r4, #0
					
	.Lupdate_gel:
		ldr r5, =update_gel
		mov r6, #1
		strh r6, [r5]			       
		strb r4, [r0, #GEL_IM]			
		
	.LfiForCol:
		add r0, #GEL_TAM
		add r2, #1
		cmp r2, #COLUMNS
		bne .LforCol
		
	.LfiForFil:
		add r1, #1	
		cmp r1, #ROWS
		bne .LforFil
		
	.Lfi:	
		pop {r0-r6, pc}



.end
