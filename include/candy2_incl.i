@;=== candy2_incl.i: definiciones comunes para ficheros en ensamblador  ===
@;===				(versión 2)											===

.include "../include/candy1_incl.i"

@; Píxeles por casilla del tablero de juego
MTWIDTH = 256 / COLUMNS				@; núm. píxeles de ancho (e.g. 32)
MTHEIGHT = 192 / ROWS				@; núm. píxeles de alto (e.g. 32)

@; Dimensiones de las metabaldosas
MTROWS = MTHEIGHT / 8				@; núm. filas metabaldosa (e.g. 4)
MTCOLS = MTWIDTH / 8				@; núm. columnas metabaldosa (e.g. 4)
MTOTAL = MTROWS * MTCOLS			@; núm. total de baldosas simples


@; Estructura 'elemento' (ver fichero "candy2_incl.h")
ELE_II = 0
ELE_PX = 2
ELE_PY = 4
ELE_VX = 6
ELE_VY = 8
ELE_TAM = 10


@; Estructura 'gelatina' (ver fichero "candy2_incl.h")
GEL_II = 0
GEL_IM = 1
GEL_TAM = 2
