@;=                                                        				=
@;=== candy1_conf: variables globales de configuración del juego  	  ===
@;=                                                       	        	=
@;=== autor: santiago.romani@urv.cat 	(2014-08-20)				  ===
@;=                                                       	        	=


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2


@; límites de movimientos para cada nivel;
@;	los límites corresponderán a los niveles 0, 1, 2, ..., hasta MAXLEVEL-1
@;								(MAXLEVEL está definida en "include/candy1.h")
@;	cada límite debe ser un número entre 3 y 99.
		.global max_mov
	max_mov:	.byte 20, 27, 31, 45, 52, 32, 21, 90, 50 


@; objetivo de puntos para cada nivel;
@;	si el objetivo es cero, se supone que existe otro reto para superar el
@;	nivel, por ejemplo, romper todas las gelatinas.
@;	el objetivo de puntos debe ser un número menor que cero, que se irá
@;	incrementando a medida que se rompan elementos.
		.align 2
		.global pun_obj
	pun_obj:	.word -1000, -830, -500, 0, -240, -500, -200, -900, 0



@; mapas de configuración de la matriz;
@;	cada mapa debe contener tantos números como posiciones tiene la matriz,
@;	con el siguiente significado para cada posicion:
@;		0:		posición vacía (a rellenar con valor aleatorio)
@;		1-6:	elemento concreto
@;		7:		bloque sólido (irrompible)
@;		8+:		gelatinas simple (a sumarle código de elemento)
@;		16+:	gelatina doble (a sumarle código de elemento)
		.global mapas
	mapas:

	@; mapa 0: todo aleatorio
		.byte 2,1,1,1,1,1,1,1,3
		.byte 2,0,4,4,4,4,4,0,3
		.byte 2,0,0,0,0,0,0,2,3
		.byte 0,0,4,0,5,0,5,2,3
		.byte 4,4,4,4,5,5,5,2,3
		.byte 6,0,4,0,5,0,5,0,0
		.byte 6,6,6,0,5,5,5,5,5
		.byte 6,0,0,0,0,0,0,0,0
		.byte 6,6,6,6,6,0,0,0,0

	@; mapa 1: paredes horizontales y verticales
		.byte 0,0,0,0,0,0,0,0,0
		.byte 1,2,3,3,3,4,0,0,0
		.byte 1,2,0,0,3,0,6,6,6
		.byte 1,1,1,2,3,0,0,6,0
		.byte 4,4,4,2,0,0,6,6,6
		.byte 4,2,2,2,2,2,0,6,0
		.byte 4,5,5,5,5,5,6,6,6
		.byte 0,5,0,5,0,5,0,0,0
		.byte 0,5,0,5,0,5,0,0,0

	@; mapa 2: huecos y bloques sólidos
		.byte 15,15,7,15,0,0,0,0,0
		.byte 0,15,15,7,15,0,0,0,15
		.byte 0,0,0,0,0,15,0,0,15
		.byte 0,0,0,0,0,0,7,7,7
		.byte 0,0,0,0,0,0,0,15,15
		.byte 15,0,15,15,0,0,0,0,15
		.byte 0,0,15,0,0,0,0,0,0
		.byte 0,0,0,0,0,15,0,0,0
		.byte 0,0,0,0,0,0,0,0,15
	
	@; mapa 3: gelatinas simples
		.byte 0,0,0,8,8,8,0,0,15
		.byte 0,0,0,0,8,0,0,0,15
		.byte 0,0,8,8,8,8,0,0,15
		.byte 0,0,8,0,8,0,0,0,15
		.byte 0,0,8,0,8,0,0,0,15
		.byte 0,0,8,0,8,0,0,0,15
		.byte 0,0,8,8,8,8,0,0,15
		.byte 0,0,0,0,0,0,0,0,15
		.byte 0,0,0,0,0,0,0,0,15

	@; mapa 4: gelatinas dobles
		.byte 0,15,0,15,0,7,0,15,15
		.byte 0,0,7,0,0,7,0,0,15
		.byte 10,3,8,1,1,8,3,3,0
		.byte 10,1,9,0,0,20,3,4,7
		.byte 17,2,15,15,3,19,4,3,15
		.byte 3,2,10,0,0,20,0,15,0
		.byte 2,3,15,0,0,16,0,0,15
		.byte 0,0,8,0,0,8,0,0,0
		.byte 0,4,7,0,0,7,0,0,15

	@; mapa 5: combinaciones en horizontal de 3, 4 y 5 elementos
		.byte 1,1,1,15,2,2,2,2,7
		.byte 3,3,3,3,3,15,7,7,15
		.byte 4,1,4,4,4,4,15,7,15
		.byte 1,4,4,2,6,3,7,0,15
		.byte 5,2,2,15,5,5,5,5,5
		.byte 6,5,5,2,5,6,6,6,15
		.byte 15,7,6,6,6,7,7,7,7
		.byte 7,7,7,15,7,7,7,15,15
		.byte 15,15,7,15,15,15,7,15,15

	@; mapa 6: combinaciones en vertical de 3, 4 y 5 elementos
		.byte 1,3,4,1,5,6,2,15,15
		.byte 1,3,1,4,2,5,7,15,15
		.byte 1,3,4,4,2,5,15,7,15
		.byte 2,3,4,2,6,15,2,7,15
		.byte 2,3,4,15,6,6,5,7,15
		.byte 2,7,4,3,5,15,6,7,15
		.byte 2,7,15,6,6,5,6,7,7
		.byte 7,15,15,7,7,5,6,7,15
		.byte 15,15,7,15,15,5,7,15,15

	@; mapa 7: combinaciones cruzadas (hor/ver) de 5, 6 y 7 elementos
		.byte 15,15,7,15,15,7,15,15,15
		.byte 1,2,3,3,4,3,7,0,15
		.byte 1,2,7,5,3,7,7,0,15
		.byte 4,1,1,2,3,8,7,0,15
		.byte 1,4,4,2,6,3,7,0,15
		.byte 4,2,2,5,2,2,7,0,15
		.byte 4,5,5,2,5,5,7,0,15
		.byte 7,8,1,5,4,6,8,0,15
		.byte 8,8,8,8,8,8,8,0,15
		
	@; mapa 8: no hay combinaciones ni secuencias
		.byte 15,15,15,15,15,15,15,15,15
		.byte 15,15,15,15,15,15,15,15,15
		.byte 1,2,3,3,7,3,15,15,15
		.byte 1,2,7,5,3,7,15,15,15
		.byte 7,1,1,2,3,9,15,15,15
		.byte 1,4,20,10,9,6,15,15,15
		.byte 6,18,22,5,6,2,15,15,15
		.byte 12,5,4,3,11,5,15,15,15
		.byte 7,7,17,19,4,6,15,15,15

@;		Rutinas para testear la función 1B:

	@; mapa 9:	hay elementos en los extremos y un solo elemento con gelatina en el medio
		.byte 15,15,15,15,15,15,15,15,0
		.byte 15,15,15,15,15,15,15,15,0
		.byte 15,15,15,15,15,15,15,15,0
		.byte 15,15,15,15,15,15,15,15,0
		.byte 15,15,15,15,16,15,15,15,0
		.byte 15,15,15,15,15,15,15,15,0
		.byte 15,15,15,15,15,15,15,15,0
		.byte 15,15,15,15,15,15,0,0,0
		.byte 0,0,0,0,0,0,0,0,0
		
	@; mapa 10: hay gelatinas dobles vacías
		.byte 16,16,16,16,16,16,16,16,16
		.byte 16,16,16,16,16,16,16,16,16
		.byte 16,16,16,16,16,16,16,16,16
		.byte 16,16,16,16,16,16,16,16,16
		.byte 16,16,16,16,16,16,16,16,16
		.byte 16,16,16,16,16,16,16,16,16
		.byte 16,16,16,16,16,16,16,16,16
		.byte 16,16,16,16,16,16,16,16,16
		.byte 16,16,16,16,16,16,16,16,16
	
	@; mapa 11: hay gelatines simples
		.byte 8,8,8,8,8,8,8,8,8
		.byte 8,8,8,8,8,8,8,8,8
		.byte 8,8,8,8,8,8,8,8,8
		.byte 8,8,8,8,8,8,8,8,8
		.byte 8,8,8,8,8,8,8,8,8
		.byte 8,8,8,8,8,8,8,8,8
		.byte 8,8,8,8,8,8,8,8,8
		.byte 8,8,8,8,8,8,8,8,8
		.byte 8,8,8,8,8,8,8,8,8
		
	@; mapa 12: no hay ninguna combinación
		.byte 1,3,6,5,2,1,3,2,6
		.byte 3,2,2,1,5,6,2,1,6
		.byte 1,1,4,3,4,2,3,5,2
		.byte 3,2,4,1,5,5,6,1,2
		.byte 1,6,6,2,1,2,1,4,4
		.byte 4,5,1,5,4,3,3,6,1
		.byte 6,1,4,3,1,2,6,5,2
		.byte 4,2,3,1,5,6,4,4,2
		.byte 1,2,6,2,3,3,5,5,1
	
	@; mapa 13: no hay ninguna combinación versión 2
		.byte 1,6,1,6,1,6,1,6,1
		.byte 2,5,2,4,5,3,5,4,5
		.byte 3,4,1,6,1,6,1,6,1
		.byte 4,3,2,4,5,3,5,4,5
		.byte 5,2,1,6,1,6,1,6,1
		.byte 6,5,2,4,5,3,5,4,5
		.byte 1,6,1,6,1,6,1,6,1
		.byte 2,5,2,4,5,3,5,4,5
		.byte 3,4,1,6,1,6,1,6,1
	
	@; mapa 14: como el 13 pero con gelatinas simples
		.byte 9,14,9,14,9,14,9,14,9
		.byte 10,13,10,13,10,13,10,13,10
		.byte 11,12,9,14,9,14,9,14,9
		.byte 12,11,10,12,13,11,13,10,13
		.byte 13,10,9,14,9,14,9,14,9
		.byte 14,13,10,12,13,11,13,12,13
		.byte 9,14,9,14,9,14,9,14,9
		.byte 10,13,10,12,13,11,13,12,13
		.byte 11,12,9,14,9,14,9,14,9
		

.end
	
