/*------------------------------------------------------------------------------

	$ candy1_main.c $

	Programa principal para la prï¿½ctica de Computadores: candy-crash para NDS
	(2ï¿½ curso de Grado de Ingenierï¿½a Informï¿½tica - ETSE - URV)
	
	Analista-programador: santiago.romani@urv.cat

	Programador 1: Jialiang.chen@estudiants.urv.cat
	Programador 2: Ismael.ruiz@estudiants.urv.cat
	Programador 3: Joseluis.pueyo@estudiants.urv.cat
	Programador 4: Carlos.martinezg@estudiants.urv.cat

------------------------------------------------------------------------------*/
#include <nds.h>
#include <stdio.h>
#include <time.h>
#include <candy1_incl.h>


/* variables globales */
char matrix[ROWS][COLUMNS];		// matriz global de juego
int seed32;						// semilla de nï¿½meros aleatorios
int level = 0;					// nivel del juego (nivel inicial = 0)
int points;						// contador global de puntos
int movements;					// nï¿½mero de movimientos restantes
int gelees;						// nï¿½mero de gelatinas restantes



/* actualizar_contadores(code): actualiza los contadores que se indican con el
	parï¿½metro 'code', que es una combinaciï¿½n binaria de booleanos, con el
	siguiente significado para cada bit:
		bit 0:	nivel
		bit 1:	puntos
		bit 2:	movimientos
		bit 3:	gelatinas  */
void actualizar_contadores(int code)
{
	if (code & 1) printf("\x1b[38m\x1b[1;10H %d", level);
	if (code & 2) printf("\x1b[39m\x1b[2;8H %d  ", points);
	if (code & 4) printf("\x1b[38m\x1b[1;28H %d ", movements);
	if (code & 8) printf("\x1b[37m\x1b[2;28H %d ", gelees);
}



/* ---------------------------------------------------------------- */
/* candy1_main.c : función principal main() para test de tarea 1A 	*/

/*					(requiere tener implementada la tarea 1E)		*/
/* ---------------------------------------------------------------- */
int main(void)
{

	int lapse = 0;				// contador de tiempo sin actividad del usuario
	int change = 0;				// =1 indica que ha habido cambios en la matriz
	int falling = 0;			// =1 indica que los elementos estan bajando
	int initializing = 1;		// =1 indica que hay que inicializar un juego
	int mX, mY, dX, dY;			// variables de detecciï¿½n de pulsaciones

	seed32 = time(NULL);		// fijar semilla de nï¿½meros aleatorios
	consoleDemoInit();			// inicializaciï¿½n de pantalla de texto
	printf("candyNDS (version 1: texto)\n");


	printf("\x1b[38m\x1b[1;0H  nivel:");
	actualizar_contadores(1);

	do							// bucle principal de pruebas
	{
		if (initializing)		//////	SECCIï¿½N DE INICIALIZACIï¿½N	//////
		{
			inicializa_matriz(matrix, level);
			//copia_mapa(matrix, 8);
			escribe_matriz(matrix);
			retardo(10);
			initializing = 0;
			falling = 0;
			change = 0;
			lapse = 0;
			points = pun_obj[level];
			if (hay_secuencia(matrix))			// si hay secuencias
			{
				elimina_secuencias(matrix, mat_mar);	// eliminarlas
				points += calcula_puntuaciones(mat_mar);
				escribe_matriz(matrix);
				falling = 1;							// iniciar bajada
			}
			else change = 1;					//sino, revisar estado matriz
			movements = max_mov[level];
			gelees = contar_gelatinas(matrix);
			actualizar_contadores(15);
		}
		else if (falling)		//////	SECCIï¿½N BAJADA DE ELEMENTOS	//////
		{
			falling = baja_elementos(matrix);	// realiza la siguiente bajada
			retardo(4);
			if (!falling)						// si no estï¿½ bajando
			{
				if (hay_secuencia(matrix))		// si hay secuencias
				{
					elimina_secuencias(matrix, mat_mar);	// eliminarlas
					points += calcula_puntuaciones(mat_mar);
					falling = 1;							// volver a bajar
					gelees = contar_gelatinas(matrix);
					actualizar_contadores(10);
				}
				else change = 1;				// sino, revisar estado matriz
			}
			escribe_matriz(matrix);			// visualiza bajadas o eliminaciones
		}
		else					//////	SECCIï¿½N DE JUGADAS	//////
		{
			if (procesar_touchscreen(matrix, &mX, &mY, &dX, &dY))
			{
				intercambia_posiciones(matrix, mX, mY, dX, dY);
				escribe_matriz(matrix);	  // muestra el movimiento por pantalla
				if (hay_secuencia(matrix))	// si el movimiento es posible
				{
					elimina_secuencias(matrix, mat_mar);
					borra_puntuaciones();
					points += calcula_puntuaciones(mat_mar);
					falling = 1;
					movements--;
					gelees = contar_gelatinas(matrix);
					actualizar_contadores(14);
					lapse = 0;
				}
				else						// si no es posible,
				{	retardo(5);				// deshacer el cambio
					intercambia_posiciones(matrix, mX, mY, dX, dY);
				}
				escribe_matriz(matrix);	// muetra las eliminaciones o el retorno
			}
			while (keysHeld() & KEY_TOUCH)		// esperar a liberar la
			{	swiWaitForVBlank();				// pantalla tï¿½ctil
				scanKeys();
			}
		}
		if (!falling)			//////	SECCIï¿½N DE DEPURACIï¿½N	//////
		{
			swiWaitForVBlank();
			escribe_matriz_debug(matrix);
			printf("\x1b[38m\x1b[3;10H (A >> Baja Elementos)");
			printf("\x1b[38m\x1b[4;10H (B >> Repetir Mapa)");
		}

		if (change)				//////	SECCIï¿½N CAMBIO DE NIVEL	//////
		{
			if (ntest < NUMTESTS1E || !baja_elementos(matrix)) 
			{
				if ((points >= 0) && (gelees == 0))
					printf("\x1b[39m\x1b[6;20H _SUPERADO_");
				else if (movements == 0)
					printf("\x1b[39m\x1b[6;20H _REPETIR_");
				else
					printf("\x1b[39m\x1b[6;20H _BARAJAR_");
				
				printf("\x1b[39m\x1b[8;20H (pulse A)");
				do
				{	swiWaitForVBlank();
					scanKeys();					// esperar pulsaciï¿½n tecla 'A'
				} while (!(keysHeld() & KEY_A));
				printf("\x1b[6;20H           ");
				printf("\x1b[8;20H           ");	// borra mensajes
				
				if (((points >= 0) && (gelees == 0)) || (movements == 0))
				{
					if (((points >= 0) && (gelees == 0))
							&& (level < MAXLEVEL-1))
						level++;				// incrementa nivel
					printf("\x1b[2;8H      ");	// borra puntos anteriores
					initializing = 1;			// passa a inicializar nivel
				}
				else
				{
					recombina_elementos(matrix);
					escribe_matriz(matrix);
					change = 1;					// forzar nueva verificaciï¿½n
				}								// de combinaciones
				borra_puntuaciones();			}
		}
		else if (lapse >= 192)	//////	SECCIï¿½N DE SUGERENCIAS	//////
		{
			if (lapse == 192) 		// a los 8 segundos sin actividad (aprox.)
			{
				sugiere_combinacion(matrix, pos_sug);
				borra_puntuaciones();
			}
			if ((lapse % 64) == 0)		// cada segundo (aprox.)
			{
				oculta_elementos(matrix);
				escribe_matriz(matrix);
				retardo(5);
				muestra_elementos(matrix);
				escribe_matriz(matrix);
			}
		}
	} while (1);				// bucle infinito
	
	return(0);					// nunca retornarï¿½ del main

}
