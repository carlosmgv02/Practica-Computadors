/*------------------------------------------------------------------------------

	$ candy1_sopo.c $

	Funciones de soporte para el programa principal (ver 'candy1_main.c')
	
	Analista-programador: santiago.romani@urv.cat
	programador auxiliar: pere.millan@urv.cat

------------------------------------------------------------------------------*/
#include <nds.h>
#include <stdio.h>
#include <candy1_incl.h>


/* variables globales */
char mat_mar[ROWS][COLUMNS];	// matriz de marcas
char pos_sug[6];				// posiciones sugerencia de combinación
char ele_sug[3];				// elementos de las posiciones sugeridas
char texto[12];					// texto de puntuaciones
int ult_tex = 0;				// último número de textos de puntuación
int num_pun = 0;				// número de puntuaciones



/* escribe_matriz_h(*mat, debug): escribe por pantalla de texto de la NDS el
	contenido de la matriz usando secuencias escape de posicionamiento en fila
	y columna (\x1b['fila';'columna'H), donde 'fila' es una coordenada entre 0
	y 23, y columna es una coordenada entre 0 y 31, y la posición (0,0) 
	corresponde a la casilla superior izquierda; además, se usa la secuencia 
	escape para cambiar el color del texto (\x1b['color'm), donde 'color'
	es un código de color de la librería NDS;
 
	Oct/2020: versió adaptada per a debug/test *** pere.millan@urv.cat ***
	Jul/2021: versió híbrida, amb paràmetre debug=0, visualització normal,
				amb paràmetre debug=1, visualització per a depuració.
*/
void escribe_matriz_h(char mat[][COLUMNS], int debug)
{
	int i, j, value, color;

	for (i = 0; i < ROWS; i++)			// para todas las filas
	{
		for (j = 0; j < COLUMNS; j++)	// para todas las columnas
		{
			value = mat[i][j];				// obtiene el valor del elemento (i,j)
			
			if ((value == 0) || ((value & 7) == 7))
				color = 39;						// color del "hueco", bloc sòlid o buit (light white)
			else if (value >= 16)
				color = 38;						// el color de la gelatina doble (dark grey)
			else if (value >= 8)
				color = 37;						// el color de la gelatina simple (light grey)
			else
				color = 40 + value;				// el color normal (brillant)
			printf("\x1b[%dm", color);
			
			printf("\x1b[%d;%dH", (i*2+DFIL), (j*2+1));	// posicionar cursor
			
			if (value == 255)
				printf("_ ");					// sugerir
			else if ((value == 7) && debug)
				printf("# ");					// bloc sòlid en mode debug
			else if ((value == 15) && debug)
				printf(": ");					// hueco en mode debug
			else if (value != 15)
				printf("%d ", (value & 7));		// valor en mode normal
			else
				printf(" ");					// hueco en mode normal
		}
	}
}

/* escribe_matriz(*mat): llama a escribe_matriz_h() con visualitzación normal
*/
void escribe_matriz(char mat[][COLUMNS])
{
	escribe_matriz_h(mat, 0);
}

/* escribe_matriz_debug(*mat): llama a escribe_matriz_h() con visualitzación
	para depuración de errores
*/
void escribe_matriz_debug(char mat[][COLUMNS])
{
	escribe_matriz_h(mat, 1);
}


/* contar_gelatinas(*mat): calcula cuantas gelatinas quedan en la matriz de
	juego, contando 1 para gelatines simples y 2 para gelatinas dobles */
int contar_gelatinas(char mat[][COLUMNS])
{
	int i, j, value, count = 0;

	for (i = 0; i < ROWS; i++)			// para todas las filas
	{
		for (j = 0; j < COLUMNS; j++)	// para todas las columnas
		{
			value = mat[i][j];			// obtiene el valor del elemento (i,j)
			if ((value > 16) && (value < 23))
				count += 2;				// cuenta 2 por gelatina doble
			else if ((value > 8) && (value < 15))
				count++;				// cuenta 1 por gelatina simple
		}
	}
	return(count);
}


/* retardo(dsecs): pone el programa en pausa durante el número de décimas de
	segundo que indica el parámetro */
void retardo(int dsecs)
{	
	int i, j;
	
	for (i = 0; i < dsecs; i++)		// por cada décima de segundo
		for (j = 0; j < 6; j++)		// esperar 6 retrocesos verticales
			swiWaitForVBlank();
}



/* procesar_touchscreen(*mat, *p1X, *p1Y, *p2X, *p2Y): procesa la entrada de la
	pantalla táctil esperando a que el usuario realice un movimiento de
	intercambio válido, desde una posición de la matriz (p1X,p1Y) hasta otra
	posición (p2X,p2Y) que deberá ser contigüa en horizontal y en vertical,
	y sólo deberá contener elementos simples (sin gelatinas ni espacios ni
	bloques sólidos);
	devuele cierto (1) si el movimiento es posible, o falso (0) si no lo es,
	además de cargar las coordenadas en las variables que se han pasado por
	referencia */
int procesar_touchscreen(char mat[][COLUMNS],
									int *p1X, int *p1Y, int *p2X, int *p2Y)
{
	touchPosition	posXY;			// variables de detección de pulsaciones
	int v1X, v1Y, v2X, v2Y;
	char temp1, temp2;

	swiWaitForVBlank();			
	scanKeys();
	if (keysHeld() & KEY_TOUCH)			// detecta pulsación en pantalla
	{
		touchRead(&posXY);					// capta posición (x,y), en píxeles
		v1X = (posXY.px >> 3) / 2;			// convierte a posición matriz
		if (v1X >= COLUMNS) v1X = COLUMNS-1;	// limitando coordenadas
		v1Y = ((posXY.py >> 3)-DFIL) / 2;
		if (v1Y < 0) v1Y = 0;
		v2X = v1X;							// igualar coordenadas segunda pos.
		v2Y = v1Y;
		while ((keysHeld() & KEY_TOUCH) &&		// mientras se esté tocando
				(v2X == v1X) && (v2Y == v1Y))	// y no hay nueva posición
		{
			touchRead(&posXY);					// capta nuevas posiciones
			v2X = (posXY.px >> 3) / 2;
			v2Y = ((posXY.py >> 3)-DFIL) / 2;
			if ((v2X >= COLUMNS) || (v2Y < 0))	// si fuera de límites,
			{	v2X = v1X; 						// igualar coordenadas
				v2Y = v1Y;
			}
			swiWaitForVBlank();
			scanKeys();
		}
		if ((v2X != v1X) || (v2Y != v1Y))		// si tenemos nueva posición
		{
			if (v2X > v1X) v2X = v1X + 1;		// limitar rango movimientos
			else if (v2X < v1X) v2X = v1X - 1;
			if (v2Y > v1Y) v2Y = v1Y + 1;
			else if (v2Y < v1Y) v2Y = v1Y - 1;
			if ((v2X != v1X) && (v2Y != v1Y))	// si hay movimiento en dos
				v2Y = v1Y;						// direcciones, priorizar X
				
			temp1 = mat[v1Y][v1X] & 0x7;
			temp2 = mat[v2Y][v2X] & 0x7;
			if ((temp1 > 0) && (temp1 < 7) && (temp2 > 0) && (temp2 < 7))
			{
				*p1X = v1X; *p1Y = v1Y;
				*p2X = v2X; *p2Y = v2Y;
				return 1;
			}
		}
	}
	return 0;
}


/* oculta_elementos(*mat): almacena los códigos de los 3 elementos contenidos
	en las posiciones de la matriz de juego indicadas en el vector 'pos_sug[6]'
	dentro del vector 'ele_sug[3]', para luego colocar un código -1 en dichas
	posiciones, lo cual provocará que la función 'escribe_matriz()' muestre
	un carácter '_' (elemento oculto) */
void oculta_elementos(char mat[][COLUMNS])
{
	int i,x,y;
	
	for (i=0; i<3; i++)
	{
		x = pos_sug[i*2];
		y = pos_sug[i*2+1];
		ele_sug[i] = mat[y][x];
		mat[y][x] = -1;
	}
}


/* muestra_elementos(*mat): restablece los códigos de los 3 elementos contenidos
	en las posiciones de la matriz de juego indicadas en el vector 'pos_sug[6]',
	según el contenido del vector 'ele_sug[3]' */
void muestra_elementos(char mat[][COLUMNS])
{
	int i,x,y;
	
	for (i=0; i<3; i++)
	{
		x = pos_sug[i*2];
		y = pos_sug[i*2+1];
		mat[y][x] = ele_sug[i];
	}
}



/* intercambia_posiciones(*mat, p1X, p1Y, p2X, p2Y): intercambia los
	elementos de las dos posiciones de la matriz que indican los parámetros,
	conservando las características de gelatina en las posiciones originales */
void intercambia_posiciones(char mat[][COLUMNS],
											int p1X, int p1Y, int p2X, int p2Y)
{
	char temp1 = mat[p1Y][p1X];
	char temp2 = mat[p2Y][p2X];
	mat[p1Y][p1X] = (temp2 & 0x7) | (temp1 & 0xF8);
	mat[p2Y][p2X] = (temp1 & 0x7) | (temp2 & 0xF8);
}




/* detectar_combo(nhor,nver,mensaje): función auxiliar para detectar el tipo
	de combinación de secuencias hallado con la función 'marca_combos', a partir
	de las longitudes máximas de secuencia horizontal 'nhor' y vertical 'nver',
	generando el mensaje correspondiente sobre el string pasado por referencia
	'mensaje' y devolviendo como resultado los puntos correspondientes a la
	combinación. */
int detectar_combo(int nhor, int nver, char mensaje[])
{
	int combi = 0;
	int puntos = 0;
	
	if (nver < 3)			// si sólo secuencia horizontal
	{
		if (nhor == 3) 
		{
			sprintf(mensaje, "SH3: %3d", PUNT_SEC3);
			puntos = PUNT_SEC3;
		}
		else if (nhor == 4) 
		{
			sprintf(mensaje, "SH4: %3d", PUNT_SEC4);
			puntos = PUNT_SEC4;
		}
		else if (nhor == 5) 
		{
			sprintf(mensaje, "SH5: %3d", PUNT_SEC5);
			puntos = PUNT_SEC5;
		}
	}
	else if (nhor < 3)		// si sólo secuencia vertical
	{
		if (nver == 3) 
		{
			sprintf(mensaje, "SV3: %3d", PUNT_SEC3);
			puntos = PUNT_SEC3;
		}
		else if (nver == 4) 
		{
			sprintf(mensaje, "SV4: %3d", PUNT_SEC4);
			puntos = PUNT_SEC4;
		}
		else if (nver == 5) 
		{
			sprintf(mensaje, "SV5: %3d", PUNT_SEC5);
			puntos = PUNT_SEC5;
		}
	}
	else					// en caso de combinación de secuencias
	{						// calcular la suma de sec. horizontal y vertical
		combi = nhor + nver - 1;	// restando 1 por la casilla de coincidencia
		if (combi == 5)
		{
			sprintf(mensaje, "CB5: %3d", PUNT_COM5);
			puntos = PUNT_COM5;
		}
		else if (combi == 6) 
		{
			sprintf(mensaje, "CB6: %3d", PUNT_COM6);
			puntos = PUNT_COM6;
		}
		else if (combi == 7) 
		{
			sprintf(mensaje, "CB7: %3d", PUNT_COM7);
			puntos = PUNT_COM7;
		}
	}
	return(puntos);
}


/* calcula_puntuaciones(*mar): detecta los conjuntos de secuencias indicados en
	la matriz que se pasa por parámetro, donde cada conjunto se marca con un
	identificador único, y obtiene el tipo de combinación (combo) que corres-
	ponde a la longitud máxima de secuencias en horizontal y en vertical; dicho
	tipo se muestra por pantalla (para cada conjunto) y se devuelve el total
	de puntos acumulados como resultado de la función.
 ATENCIÓN:	esta función requiere de la correcta implementación de la rutina
			'cuenta_repeticiones', ubicada en el fichero 'candy1_move.s' */
int calcula_puntuaciones(char mar[][COLUMNS])
{
	int i,j,k,m,m2,n;
	int nh,nv,puntos,total;
	
	total = 0;
	for (i=0; i<ROWS; i++)					// para todas las filas
	{
		for (j=0; j<COLUMNS; j++)			// para todas las columnas
		{
			if (mar[i][j] != 0)			// si detecta un identificador
			{
				nh = cuenta_repeticiones(mar,i,j,0);
				if (nh > 1)	
				{							// hay una secuencia horizontal
					nv = 1; k = 0;
					do
					{			// busca combinaciones verticales
						m = cuenta_repeticiones(mar,i,j+k,1);
						if (m > nv) nv = m;			// actualizar máximo vert.
						for (n=0; n<m; n++)
							mar[i+n][j+k] = 0;		// eliminar marca
						k++;
					} while (k < nh);
				}
				else
				{							// hay una secuencia vertical
					nv = cuenta_repeticiones(mar,i,j,1);
					nh = 1; k = 0;
					do
					{			// busca combinaciones horizontales 
						m = cuenta_repeticiones(mar,i+k,j,0);
							// también hacia atrás (Oeste), para comb. cruzadas
						m2 = cuenta_repeticiones(mar,i+k,j,2) - 1;
						m += m2;					// m = longitud total sec.
						if (m > nh) nh = m;			// actualizar máximo hor.
						for (n=0; n<m; n++)
							mar[i+k][j+n-m2] = 0;	// eliminar marca
						k++;
					}  while (k < nv);
				}
				puntos = detectar_combo(nh,nv,texto);
				printf("\x1b[%dm\x1b[%d;20H %s",(37 + num_pun%3),
														(12+ult_tex), texto);
				ult_tex++;
				total += puntos;
			}
		}
	}
	return(total);
}


/* borra_puntuaciones(): permite eliminar los textos de puntuaciones anteriores,
	además de poner el contador 'ult_tex' a cero e incrementar el contador
	'num_pun' */
void borra_puntuaciones()
{
	int i;
	
	for (i=0; i<ult_tex; i++)
		printf("\x1b[%d;20H            ",(12+i));
	ult_tex = 0;
	num_pun++;
}



/* copia_mapa(*mat, num_map): copia directamente el contenido del mapa de
	configuración 'num_map' (almacenado en la variable global 'mapas') dentro
	de la matriz de juego 'mat' */
void copia_mapa(char mat[][COLUMNS], int num_map)
{
	int i, j;

	for (i = 0; i < ROWS; i++)			// para todas las filas
	{
		for (j = 0; j < COLUMNS; j++)	// para todas las columnas
		{
			mat[i][j] = mapas[num_map][i][j];		// copia elemento (i,j)
		}
	}
}
