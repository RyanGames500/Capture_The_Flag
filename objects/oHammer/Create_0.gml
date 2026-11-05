/// @description Prensa que aplasta
image_speed = 0;
image_index = 0;

// El host decide cuándo cae y les avisa a todos (evento "hammer_go").
// La primera espera se calcula igual en todas las pantallas, por la posición.
random_set_seed(x + y);
timer = room_speed * random_range(1, 4);
randomize();

estado   = "espera";   // "espera", "aviso" o "cae"
aviso_t  = 0;          // frames de aviso que quedan
golpe_ya = false;      // ya sonó el golpe en esta caída
mato_ya  = false;      // ya aplastó en esta caída
myHammerId = string(round(x)) + string(round(y));

// Dónde está la cabeza de la prensa en cada cuadro (medido del sprite: de arriba, de abajo)
cabeza_arriba = [14, 29, 70, 66, 68, 58, 38, 14];
cabeza_abajo  = [35, 55, 89, 88, 89, 79, 59, 35];
