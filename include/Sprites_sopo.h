/*------------------------------------------------------------------------------

	$Id: Sprites_sopo.h $

	Declaraciones de funciones globales de "Sprites_sopo.s"

------------------------------------------------------------------------------*/

extern void SPR_actualizarSprites(u16* base, int limite);
extern void SPR_crearSprite(int indice, int forma, int tam, int baldosa);
extern void SPR_mostrarSprite(int indice);
extern void SPR_ocultarSprite(int indice);
extern void SPR_ocultarSprites(int limite);
extern void SPR_moverSprite(int indice, int px, int py);
extern void SPR_fijarPrioridad(int indice, int prioridad);
extern void SPR_activarRotacionEscalado(int indice, int grupo);
extern void SPR_desactivarRotacionEscalado(int indice);
extern void SPR_fijarEscalado(int igrp, short sx, short sy);
