/*------------------------------------------------------------------------------

	$ candy1_main.c $

	Programa principal para la práctica de Computadores: candy-crash para NDS
	(2º curso de Grado de Ingeniería Informática - ETSE - URV)
	
	Analista-programador: santiago.romani@urv.cat
	Programador 1: xxx.xxx@estudiants.urv.cat
	Programador 2: yyy.yyy@estudiants.urv.cat
	Programador 3: joseluis.pueyo@estudiants.urv.cat
	Programador 4: uuu.uuu@estudiants.urv.cat

------------------------------------------------------------------------------*/
#include <nds.h>
#include <stdio.h>
#include <time.h>
#include <candy1_incl.h>


/* variables globales */
char matrix[ROWS][COLUMNS];		// matriz global de juego
int seed32;						// semilla de números aleatorios
int level = 0;					// nivel del juego (nivel inicial = 0)
int points;						// contador global de puntos
int movements;					// número de movimientos restantes
int gelees;						// número de gelatinas restantes



/* actualizar_contadores(code): actualiza los contadores que se indican con el
	parámetro 'code', que es una combinación binaria de booleanos, con el
	siguiente significado para cada bit:
		bit 0:	nivel
		bit 1:	puntos
		bit 2:	movimientos
		bit 3:	gelatinas  */
void actualizar_contadores(int code)
{
	if (code & 1) printf("\x1b[38m\x1b[1;8H %d", level);
	if (code & 2) printf("\x1b[39m\x1b[2;8H %d  ", points);
	if (code & 4) printf("\x1b[38m\x1b[1;28H %d ", movements);
	if (code & 8) printf("\x1b[37m\x1b[2;28H %d ", gelees);
}



/* ---------------------------------------------------------------- */
/* candy1_main.c : función principal main() para test de tarea 1E 	*/
/* ---------------------------------------------------------------- */
#define NUMTESTS1E 15
#define NUMTESTS1F 5
#define NUMTESTS NUMTESTS1E + NUMTESTS1F
short nmap[] = {4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 8, 8, 0, 1, 2, 3, 4};
short posX[] = {0, 0, 0, 0, 4, 4, 4, 0, 0, 5, 4, 1, 1, 1, 5};
short posY[] = {2, 2, 2, 2, 4, 4, 4, 0, 0, 0, 4, 3, 3, 5, 0};
short cori[] = {0, 1, 2, 3, 0, 1, 2, 0, 3, 0, 0, 1, 3, 0, 0};
short resp[] = {1, 2, 1, 1, 2, 1, 1, 3, 1, 3, 5, 2, 4, 2, 4};
int main(void)
{
	int ntest = 14;
	int result1E;

	consoleDemoInit();			// inicialización de pantalla de texto
	
	printf("\x1b[38m\x1b[1;0H  nivel:");
	level = nmap[ntest];
	actualizar_contadores(1);
	copia_mapa(matrix, level);
	escribe_matriz_debug(matrix);
	swiWaitForVBlank();
	do							// bucle principal de pruebas
	{
		if (ntest < NUMTESTS1E) {
			printf("\x1b[39m\x1b[0;0HcandyNDS (prueba tarea 1E)\n");
			printf("\x1b[39m\x1b[2;0H test %d: posXY (%d, %d), c.ori %d", ntest, posX[ntest], posY[ntest], cori[ntest]);
			printf("\x1b[39m\x1b[3;0H resultado esperado: %d", resp[ntest]);
			
			result1E = cuenta_repeticiones(matrix, posY[ntest], posX[ntest], cori[ntest]);
			
			printf("\x1b[39m\x1b[4;0H resultado obtenido: %d", result1E);
			retardo(5);
			printf("\x1b[38m\x1b[5;19H (pulse A/B)");
		} else if (ntest < NUMTESTS) {
			printf("\x1b[39m\x1b[0;0HcandyNDS (prueba tarea 1F)\n");
			printf("\x1b[39m\x1b[2;0H test %d:", ntest-NUMTESTS1E);
	
			swiWaitForVBlank();
			escribe_matriz_debug(matrix);
			printf("\x1b[38m\x1b[3;10H (A >> Baja Elementos)");
			printf("\x1b[38m\x1b[4;10H (B >> Repetir Mapa)");
		}
		
		do
		{	swiWaitForVBlank();
			scanKeys();					// esperar pulsación tecla 'A' o 'B'
		} while (!(keysHeld() & (KEY_A | KEY_B)));
		
		printf("\x1b[2;0H                                ");
		printf("\x1b[3;0H                                ");
		printf("\x1b[4;0H                                ");
		printf("\x1b[38m\x1b[5;19H            ");
		retardo(5);
		
		
		if (keysHeld() & KEY_A)		// si pulsa 'A',
		{
			if (ntest < NUMTESTS1E || !baja_elementos(matrix)) 
			{
				ntest++;				// siguiente test
				if ((ntest < NUMTESTS && nmap[ntest] != level)) //&& (nmap[ntest] != level))
				{				// si número de mapa del siguiente test diferente
					level = nmap[ntest];		// del número de mapa actual,
					actualizar_contadores(1);		// cambiar el mapa actual
					copia_mapa(matrix, level);
					escribe_matriz_debug(matrix);
				}
			}
		}
		if (keysHeld() & KEY_B)
		{
			copia_mapa(matrix, level);
			escribe_matriz_debug(matrix);
		}
		
	} while (ntest < NUMTESTS);		// bucle de pruebas

	printf("\x1b[38m\x1b[5;19H (fin tests)");
	do { swiWaitForVBlank(); } while(1);	// bucle infinito
	return(0);
}
