/*------------------------------------------------------------------------------

	$ candy2_graf.c $

	Funciones de inicializaci�n de gr�ficos (ver "candy2_main.c")

	Analista-programador: santiago.romani@urv.cat
	Programador tarea 2A: xxx.xxx@estudiants.urv.cat
	Programador tarea 2B: yyy.yyy@estudiants.urv.cat
	Programador tarea 2C: zzz.zzz@estudiants.urv.cat
	Programador tarea 2D: uuu.uuu@estudiants.urv.cat

------------------------------------------------------------------------------*/
#include <nds.h>
#include <candy2_incl.h>
#include <Graphics_data.h>
#include <Sprites_sopo.h>


/* variables globales */
int n_sprites = 0;					// n�mero total de sprites creados
elemento vect_elem[ROWS*COLUMNS];	// vector de elementos
gelatina mat_gel[ROWS][COLUMNS];	// matriz de gelatinas



// TAREA 2Ab
/* genera_sprites(): inicializar los sprites con prioridad 1, creando la
	estructura de datos y las entradas OAM de los sprites correspondiente a la
	representaci�n de los elementos de las casillas de la matriz que se pasa
	por par�metro (independientemente de los c�digos de gelatinas).*/
void genera_sprites(char mat[][COLUMNS])
{


}



// TAREA 2Bb
/* genera_mapa2(*mat): generar un mapa de baldosas como un tablero ajedrezado
	de metabaldosas de 32x32 p�xeles (4x4 baldosas), en las posiciones de la
	matriz donde haya que visualizar elementos con o sin gelatina, bloques
	s�lidos o espacios vac�os sin elementos, excluyendo solo los huecos.*/
void genera_mapa2(char mat[][COLUMNS])
{


}



// TAREA 2Cb
/* genera_mapa1(*mat): generar un mapa de baldosas correspondiente a la
	representaci�n de las casillas de la matriz que se pasa por par�metro,
	utilizando metabaldosas de 32x32 p�xeles (4x4 baldosas), visualizando
	las gelatinas simples y dobles y los bloques s�lidos con las metabaldosas
	correspondientes, (para las gelatinas, basta con utilizar la primera
	metabaldosa de la animaci�n); adem�s, hay que inicializar la matriz de
	control de la animaci�n de las gelatinas mat_gel[][COLUMNS]. */
void genera_mapa1(char mat[][COLUMNS])
{
	int ii=0, im=0;
	int i,j;
	/**
	 * Inicializamos todos los índices ii a -1 para que estén desactivados 
	 * 
	 */
    for(i=0;i<ROWS;i++){
        for(j=0;j<COLUMNS;j++){
            mat_gel[i][j].ii=-1;
        }
    }

    for(i=0; i<ROWS; i++){
        for(j=0; j<COLUMNS; j++){
            if(mat[i][j]!= 7|| mat[i][j]==15){
                fija_metabaldosa((u16 *)0x06000000, i, j, 19);
            }
            if(mat[i][j]==7){
                fija_metabaldosa((u16 *)0x06000000, i, j, 16);
            }
            if(mat[i][j]>=9 && mat[i][j]<=22 && mat[i][j]!=15){
                if(mat[i][j]>=9&&mat[i][j]<=14){
                    im=mod_random(7);
                    fija_metabaldosa((u16 *)0x06000000, i, j, im);
                }else{
                    while(im<8){
                        im=mod_random(15);	//im de gelatina doble >=8 && <=15
                    }
                    fija_metabaldosa((u16 *)0x06000000, i, j, im);
                }
                ii=mod_random(10);
                mat_gel[i][j].ii=ii;
                mat_gel[i][j].im=im;
            }
        }
    }

}



// TAREA 2Db
/* ajusta_imagen3(int ibg): rotar 90 grados a la derecha la imagen del fondo
	cuyo identificador se pasa por par�metro (fondo 3 del procesador gr�fico
	principal), y desplazarla para que se visualice en vertical a partir del
	primer p�xel de la pantalla. */
void ajusta_imagen3(int ibg)
{


}




// TAREAS 2Aa,2Ba,2Ca,2Da
/* init_grafA(): inicializaciones generales del procesador gr�fico principal,
				reserva de bancos de memoria y carga de informaci�n gr�fica,
				generando el fondo 3 y fijando la transparencia entre fondos.*/
void init_grafA()
{
	int bg1A, bg2A, bg3A;

	videoSetMode(MODE_3_2D | DISPLAY_SPR_1D_LAYOUT | DISPLAY_SPR_ACTIVE);
	
// Tarea 2Aa:
	// reservar banco F para sprites, a partir de 0x06400000

// Tareas 2Ba y 2Ca:
	// reservar banco E para fondos 1 y 2, a partir de 0x06000000
	vramSetBankE(VRAM_E_MAIN_BG);

// Tarea 2Da:
	// reservar bancos A y B para fondo 3, a partir de 0x06020000




// Tarea 2Aa:
	// cargar las baldosas de la variable SpritesTiles[] a partir de la
	// direcci�n virtual de memoria gr�fica para sprites, y cargar los colores
	// de paleta asociados contenidos en la variable SpritesPal[]



// Tarea 2Ba:
	// inicializar el fondo 2 con prioridad 2

	

// Tarea 2Ca:
	//inicializar el fondo 1 con prioridad 0
	bg1A = bgInit(1, BgType_Text8bpp, BgSize_T_256x256,0, 1);
	bgSetPriority(bg1A,0);


// Tareas 2Ba y 2Ca:
	// descomprimir (y cargar) las baldosas de la variable BaldosasTiles[] a
	// partir de la direcci�n de memoria correspondiente a los gr�ficos de
	// las baldosas para los fondos 1 y 2, cargar los colores de paleta
	// correspondientes contenidos en la variable BaldosasPal[]

	decompress(BaldosasTiles,bgGetGfxPtr(bg1A), LZ77Vram);
	dmaCopy(BaldosasPal, BG_PALETTE, sizeof(BaldosasPal));
	
// Tarea 2Da:
	// inicializar el fondo 3 con prioridad 3


	// descomprimir (y cargar) la imagen de la variable FondoBitmap[] a partir
	// de la direcci�n virtual de v�deo reservada para dicha imagen



	// fijar display A en pantalla inferior (t�ctil)
	lcdMainOnBottom();

	/* transparencia fondos:
		//	bit 1 = 1 		-> 	BG1 1st target pixel
		//	bit 2 = 1 		-> 	BG2 1st target pixel
		//	bits 7..6 = 01	->	Alpha Blending
		//	bit 11 = 1		->	BG3 2nd target pixel
		//	bit 12 = 1		->	OBJ 2nd target pixel
	*/
	*((u16 *) 0x04000050) = 0x1846;	// 0001100001000110
	/* factor de "blending" (mezcla):
		//	bits  4..0 = 01001	-> EVA coefficient (1st target)
		//	bits 12..8 = 00111	-> EVB coefficient (2nd target)
	*/
	*((u16 *) 0x04000052) = 0x0709;
}

