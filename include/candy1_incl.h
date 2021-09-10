/*------------------------------------------------------------------------------

	$Id: candy1_incl.h $

	Definiciones externas en C para la versión 1 del juego (modo texto)

------------------------------------------------------------------------------*/

// Rango de los números de filas y de columnas:
// mínimo: 3, máximo: 11
#define ROWS	9						// dimensiones de la matriz de juego
#define COLUMNS	9
#define DFIL	(24-ROWS*2)				// desplazamiento vertical de filas

#define MAXLEVEL	9					// nivel màximo (niveles 0..MAXLEVEL-1)

#define PUNT_SEC3	30					// puntos secuencia de 3 elementos
#define PUNT_SEC4	60					// puntos secuencia de 4 elementos
#define PUNT_SEC5	120					// puntos secuencia de 5 elementos
#define PUNT_COM5	150					// puntos combinación de 5 elementos
#define PUNT_COM6	200					// puntos combinación de 6 elementos
#define PUNT_COM7	300					// puntos combinación de 7 elementos


	// candy1_conf.s //
extern int pun_obj[MAXLEVEL];			// objetivo de puntos por nivel
extern char max_mov[MAXLEVEL];			// movimientos máximos por nivel
extern char mapas[MAXLEVEL][ROWS][COLUMNS];	// mapas de configuración

	// candy1_sopo.c //
extern char mat_mar[ROWS][COLUMNS];		// matriz de marcas
extern char pos_sug[6];					// posiciones sugerencia de combinación
extern void escribe_matriz(char mat[][COLUMNS]);
extern void escribe_matriz_debug(char mat[][COLUMNS]);
extern int contar_gelatinas(char mat[][COLUMNS]);
extern void retardo(int dsecs);
extern int procesar_touchscreen(char mat[][COLUMNS],
									int *p1X, int *p1Y, int *p2X, int *p2Y);
extern void oculta_elementos(char mat[][COLUMNS]);
extern void muestra_elementos(char mat[][COLUMNS]);
extern void intercambia_posiciones(char mat[][COLUMNS],
										int p1X, int p1Y, int p2X, int p2Y);
extern int calcula_puntuaciones(char mar[][COLUMNS]);
extern void borra_puntuaciones();
extern void copia_mapa(char mat[][COLUMNS], int num_map);


	// candy1_init.s //
extern void inicializa_matriz(char matriz[][COLUMNS], int num_mapa);	// 1A
extern void recombina_elementos(char matriz[][COLUMNS]);				// 1B

	// candy1_secu.s //
extern int  hay_secuencia(char matriz[][COLUMNS]);						// 1C
extern void elimina_secuencias(char matriz[][COLUMNS],					// 1D
								char marcas[][COLUMNS]);

	// candy1_move.s //
extern int  cuenta_repeticiones(char matriz[][COLUMNS],				// 1E
									int f, int c, int ori);
extern int  baja_elementos(char matriz[][COLUMNS]);					// 1F

	// candy1_comb.s //
extern int  hay_combinacion(char matriz[][COLUMNS]);					// 1G
extern void sugiere_combinacion(char matriz[][COLUMNS], char sug[]);	// 1H
