/*------------------------------------------------------------------------------

	$ candy1_main.c $

	Programa principal para la práctica de Computadores: candy-crash para NDS
	(2º curso de Grado de Ingeniería Informática - ETSE - URV)
	
	Analista-programador: santiago.romani@urv.cat
	Programador 1: xxx.xxx@estudiants.urv.cat
	Programador 2: yyy.yyy@estudiants.urv.cat
	Programador 3: zzz.zzz@estudiants.urv.cat
	Programador 4: carlos.martinezg@estudiants.urv.cat

------------------------------------------------------------------------------*/
#include <nds.h>
#include <stdio.h>
#include <time.h>
#include <candy1_incl.h>


/* variables globales */
char pos_sug[6];
char matrix[ROWS][COLUMNS];		// matriz global de juego
int seed32;	
int i;					// semilla de números aleatorios
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
/* candy1_main.c : función principal main() para test de tarea 1G 	*/
/*					(requiere tener implementada la tarea 1E)		*/
/* ---------------------------------------------------------------- */
/*
int main(void)
{
	consoleDemoInit();			// inicialización de pantalla de texto
	printf("candyNDS (prueba tarea 1c)\n");
	printf("\x1b[38m\x1b[1;0H  nivel:");
	actualizar_contadores(1);

	do							// bucle principal de pruebas
	{
		copia_mapa(matrix, level);		// sustituye a inicializa_matriz()
		escribe_matriz_debug(matrix);
		if (hay_combinacion(matrix))			// si hay combinaciones
			printf("\x1b[39m\x1b[3;0Hhay combinacion: SI");
		else
			printf("\x1b[39m\x1b[3;0Hhay combinacion: NO");
		retardo(5);
		printf("\x1b[38m\x1b[3;19H (pulse A/B)");
		do
		{	swiWaitForVBlank();
			scanKeys();					// esperar pulsación tecla 'A' o 'B'
		} while (!(keysHeld() & (KEY_A | KEY_B)));
		printf("\x1b[3;0H                               ");
		retardo(5);
		if (keysHeld() & KEY_A)			// si pulsa 'A',
		{								// pasa a siguiente nivel
			level = (level + 1) % MAXLEVEL;
			actualizar_contadores(1);
		}
	} while (1);
*/
	int main(void){
	consoleDemoInit();			// inicialización de pantalla de texto
	printf("candyNDS (prueba tarea 1G-1H)\n");
	printf("\x1b[38m\x1b[1;0H  nivel:");
	
	actualizar_contadores(1);

	for(i=0;i<6;i++){
		pos_sug[i]=0;
	}
	do							// bucle principal de pruebas
	{
		copia_mapa(matrix, level);		// sustituye a inicializa_matriz()
		escribe_matriz_debug(matrix);
		if (hay_combinacion(matrix))	{		// si hay combinaciones
			printf("\x1b[39m\x1b[3;0Hhay combinacion: SI");
				sugiere_combinacion(matrix, pos_sug);
				borra_puntuaciones();
				oculta_elementos(matrix);
				escribe_matriz(matrix);
				retardo(5);
				muestra_elementos(matrix);
				escribe_matriz(matrix);
				
			}
		else
			printf("\x1b[39m\x1b[3;0Hhay combinacion: NO");
		retardo(5);
		printf("\x1b[38m\x1b[3;19H (pulse A/B)");
		do
		{	
			swiWaitForVBlank();
			scanKeys();					// esperar pulsación tecla 'A' o 'B'
		} while (!(keysHeld() & (KEY_A | KEY_B)));
		printf("\x1b[3;0H                               ");
		retardo(5);
		if (keysHeld() & KEY_A)			// si pulsa 'A',
		{								// pasa a siguiente nivel
			level = (level + 1) % MAXLEVEL;
			actualizar_contadores(1);
		}
	} while (1);
	return(0);
}