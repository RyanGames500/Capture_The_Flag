/// @description Tormenta: rayos que iluminan el cielo y lluvia (lo crea scr_fondo_parallax)
flash = 0;                         // brillo del rayo (1 = máximo)
proximo = 150 + irandom(240);      // frames hasta el siguiente rayo
trueno = -1;                       // el sonido llega un poquito después
rayo = [];                         // puntos del rayo (en pantalla)
gotas = [];
for (var i = 0; i < 110; i++) {
	array_push(gotas, { x: random(1400), y: random(480), s: 6 + random(4) });
}
