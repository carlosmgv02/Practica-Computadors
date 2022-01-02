/*------------------------------------------------------------------------------

	$ candy2_main.c $

	Programa principal para la práctica de Computadores: Candy Crash para NDS
	(2º curso del Grado de Ingeniería Informática - ETSE - URV)
	
	Analista-programador principal: santiago.romani@urv.cat
	Analista-programador auxiliar:  pere.millan@urv.cat
	Programador 1: xxx.xxx@estudiants.urv.cat
	Programador 2: yyy.yyy@estudiants.urv.cat
	Programador 3: zzz.zzz@estudiants.urv.cat
	Programador 4: uuu.uuu@estudiants.urv.cat

------------------------------------------------------------------------------*/
#include <nds.h>
#include <stdio.h>
#include <time.h>
#include <candy2_incl.h>


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


/* inicializa_interrupciones(): configura las direcciones de las RSI y los bits
	de habilitación (enable) del controlador de interrupciones para que se
	puedan generar las interrupciones requeridas.*/
void inicializa_interrupciones()
{
	irqSet(IRQ_VBLANK, rsi_vblank);
	TIMER0_CR = 0x00;  		// inicialmente los timers no generan interrupciones
	irqSet(IRQ_TIMER0, rsi_timer0);		// cargar direcciones de las RSI
	irqEnable(IRQ_TIMER0);				// habilitar la IRQ correspondiente
	TIMER1_CR = 0x00;
	irqSet(IRQ_TIMER1, rsi_timer1);
	irqEnable(IRQ_TIMER1);
	TIMER2_CR = 0x00;
	irqSet(IRQ_TIMER2, rsi_timer2);
	irqEnable(IRQ_TIMER2);
	TIMER3_CR = 0x00;
	irqSet(IRQ_TIMER3, rsi_timer3);
	irqEnable(IRQ_TIMER3);
}




/* Programa principal: control general del juego */
int main(void)
{
	int lapse = 0;				// contador de tiempo sin actividad del usuario
	int change = 0;				// =1 indica que ha habido cambios en la matriz
	int falling = 0;			// =1 indica que los elementos estan bajando
	int fall_init = 1;			// =1 inicializa la frecuencia de movimiento
	int initializing = 1;		// =1 indica que hay que inicializar un juego
	int mX, mY, dX, dY;			// variables de detección de pulsaciones

	seed32 = time(NULL);		// fijar semilla de números aleatorios
	init_grafA();
	inicializa_interrupciones();

	consoleDemoInit();			// inicialización de pantalla de texto
	printf("CandyNDS (version 2: graficos)\n");
	printf("\x1b[38m\x1b[1;0H  nivel:");
	printf("\x1b[39m\x1b[2;0H puntos:");
	printf("\x1b[38m\x1b[1;15H movimientos:");
	printf("\x1b[37m\x1b[2;15H   gelatinas:");
	printf("\x1b[38m\x1b[3;0H despl.fondo (tecla Y): no");
	actualizar_contadores(15);

	do							// bucle principal del juego
	{
		if (initializing)		//////	SECCIÓN DE INICIALIZACIÓN	//////
		{
			inicializa_matriz(matrix, level);
			genera_sprites(matrix);
			genera_mapa1(matrix);
			genera_mapa2(matrix);
			escribe_matriz(matrix);
			retardo(5);
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
				fall_init = 1;
			}
			else change = 1;					//sino, revisar estado matriz
			movements = max_mov[level];
			gelees = contar_gelatinas(matrix);
			actualizar_contadores(15);
		}
		else if (falling)		//////	SECCIÓN BAJADA DE ELEMENTOS	//////
		{
			falling = baja_elementos(matrix);	// realiza la siguiente bajada
			if (falling)
			{									// si hay bajadas
				activa_timer0(fall_init);		// activar timer de movimientos
				while (timer0_on) swiWaitForVBlank();	// espera final
				fall_init = 0;					// continuar acelerando
			}
			else								// si no está bajando
			{
				if (hay_secuencia(matrix))		// si hay secuencias
				{
					elimina_secuencias(matrix, mat_mar);	// eliminarlas
					points += calcula_puntuaciones(mat_mar);
					falling = 1;				// volver a bajar
					fall_init = 1;				// con velocidad inicial
					gelees = contar_gelatinas(matrix);
					actualizar_contadores(10);
				}
				else change = 1;				// sino, revisar estado matriz
			}
			escribe_matriz(matrix);			// visualiza bajadas o eliminaciones
		}
		else					//////	SECCIÓN DE JUGADAS	//////
		{
			if (procesar_touchscreen(matrix, &mX, &mY, &dX, &dY))
			{
				intercambia_posiciones(matrix, mX, mY, dX, dY);
				escribe_matriz(matrix);	  // muestra el movimiento por pantalla
				if (hay_secuencia(matrix))	// si el movimiento genera secuencia
				{
					elimina_secuencias(matrix, mat_mar);
					borra_puntuaciones();
					points += calcula_puntuaciones(mat_mar);
					falling = 1;
					fall_init = 1;
					movements--;
					gelees = contar_gelatinas(matrix);
					actualizar_contadores(14);
					lapse = 0;
				}
				else						// si no genera secuencia,
				{							// deshacer el cambio
					intercambia_posiciones(matrix, mX, mY, dX, dY);
				}
				escribe_matriz(matrix);	// muetra las eliminaciones o el retorno
			}
			while (keysHeld() & KEY_TOUCH)		// esperar la liberación de la
			{	swiWaitForVBlank();				// pantalla táctil
				scanKeys();
			}
		}
		if (!falling)			//////	SECCIÓN DE DEPURACIÓN	//////
		{
			swiWaitForVBlank();
			scanKeys();
			if (keysHeld() & KEY_B)		// forzar cambio de nivel
			{	points = 0;
				gelees = 0;					// botón B: nivel superado
				change = 1;
			}
			else if (keysHeld() & KEY_START)	
			{	movements = 0;				// botón START: repetir nivel
				change = 1;
			}
			else if (keysHeld() & KEY_Y)	// activar o desactivar desplazam.
			{	if (timer3_on) desactiva_timer3();	// imagen del fondo 3
				else activa_timer3();
				printf("\x1b[38m\x1b[3;24H%s",(timer3_on ? "si" : "no"));
				while (keysHeld() & KEY_Y)		// esperar liberación tecla Y
				{	swiWaitForVBlank();	
					scanKeys();
				}
			}
			lapse++;					// incrementar paso del tiempo
		}
		if (change)				//////	SECCIÓN CAMBIO DE NIVEL	//////
		{
			change = 0;
			if (((points >= 0) && (gelees == 0))
					|| (movements == 0) || !hay_combinacion(matrix))
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
					scanKeys();					// esperar pulsación botón A
				} while (!(keysHeld() & KEY_A));
				printf("\x1b[6;20H           ");
				printf("\x1b[8;20H           ");	// borra mensajes
				
				if (((points >= 0) && (gelees == 0)) || (movements == 0))
				{
					if ((points >= 0) && (gelees == 0))
						level = (level + 1) % MAXLEVEL;	// incrementa nivel
					printf("\x1b[2;8H      ");	// borra puntos anteriores
					initializing = 1;			// pasa a inicializar nivel
				}
				else
				{
					recombina_elementos(matrix);
					activa_timer0(1);		// activar timer de movimientos
					while (timer0_on) swiWaitForVBlank();	// espera final
					escribe_matriz(matrix);
					change = 1;					// forzar nueva verificación
				}								// de combinaciones
				borra_puntuaciones();
			}
			lapse = 0;
		}
		else if (lapse >= 192)	//////	SECCIÓN DE SUGERENCIAS	//////
		{
			if (lapse == 192) 		// a los 8 segundos sin actividad (aprox.)
			{
				sugiere_combinacion(matrix, pos_sug);
				borra_puntuaciones();
			}
			if ((lapse % 64) == 0)		// cada segundo (aprox.)
			{
				reduce_elementos(matrix);
				aumenta_elementos(matrix);
			}
		}
	} while (1);				// bucle infinito
	
	return(0);					// nunca retornará del main
}

