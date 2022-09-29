# Práctica Computadores - URV(2021-2022)
Versión final de la práctica de Computadores, consistente en implementar una versión reducida del juego Candy Crush, utilizando el simulador [DeSmuME](http://desmume.org/), basado en conseguir secuencias de 3 o más elementos del mismo tipo en horizontal o en vertical
## Descripción
### Fase 1
Realizar una versión del juego en modo texto: tablero definido como una matriz de 9x9, donde cada casilla contiene un número que representa uno de los siguientes objetos:
* 1..6: *elementos básicos*
* 0: *casila vacía*
* 7: *bloque sólido*
* 15: *hueco*
* 9..14: *gelatinas simples*
* 17..22: *gelatinas dobles*

![Captura de pantalla 2022-09-29 223239](https://user-images.githubusercontent.com/76976573/193136182-7ab6424d-b252-471d-ba67-d616e80626a3.png)
### Fase 2
Utilizar recursos gráficos de las NDS para representar los elementos del juego, animando los gráficos mediante interrupciones.

![Captura de pantalla 2022-09-29 223111](https://user-images.githubusercontent.com/76976573/193135860-66067a33-ae3e-4435-9b7c-378b0ae2977e.png)
## Código
Se incluyen tanto los ficheros de la primera fase de la práctica, como los de la segunda fase (RSI's, sprites...).
### graphics/
  * *Baldosas.s*
  * *Fondo.s*
  * *Grit_config.txt*
  * *Sprites.s*
### include/
  * *candy1_incl.h*
  * *candy1_incl.i*
  * *candy2_incl.h*
  * *candy2_incl.i*
  * *Graphics_data.h*
  * *Sprites_sopo.h*
### source/
  * *candy1_comb.s*
  * *candy1_init.s*
  * *candy1_move.s*
  * *candy1_secu.s*
  * *candy2_conf.s*
  * *candy2_graf.c*
  * *candy2_main.c*
  * *candy2_sopo.c*
  * *candy2_supo.s*
  * *RSI_timer0.s*
  * *RSI_timer1.s*
  * *RSI_timer2.s*
  * *RSI_timer3.s*
  * *Sprites_sopo.s*
## Authors
  * Jialiang Chen - [Prog1](https://github.com/carlosmgv02/Practica-Computadors/tree/prog1)
  * Ismael Ruiz - [Prog2](https://github.com/carlosmgv02/Practica-Computadors/tree/prog2)
  * Carlos Martínez - *[carlosmgv02](https://github.com/carlosmgv02)* - [Prog3](https://github.com/carlosmgv02/Practica-Computadors/tree/prog3)
  * Jose Luis Pueyo - [Prog4](https://github.com/carlosmgv02/Practica-Computadors/tree/prog4)

