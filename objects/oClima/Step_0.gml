proximo -= 1;
if (proximo <= 0) {
	proximo = 180 + irandom(240);
	flash = 1;
	trueno = 18 + irandom(20);
	rayo = [];
	var _x = 200 + random(camera_get_view_width(view_camera[0]) - 400);
	var _y = 0;
	array_push(rayo, [_x, _y]);
	while (_y < 260) { _x += random_range(-20, 20); _y += 26; array_push(rayo, [_x, _y]); }
}
if (flash > 0) {
	if (!(flash > 0.85 && random(1) < 0.3)) flash -= 0.06;   // a veces parpadea dos veces
	if (flash < 0) flash = 0;
}
if (trueno > 0) {
	trueno -= 1;
	if (trueno == 0 && global.sfx) audio_play_sound(snd_pearl_explodes, 1, false, 0.25, 0, 0.45);
}

// lluvia (en coordenadas de pantalla)
var _vw = camera_get_view_width(view_camera[0]);
for (var i = 0; i < array_length(gotas); i++) {
	var _g = gotas[i];
	_g.y += _g.s;
	_g.x -= 1.5;
	if (_g.y > 490) { _g.y = -10; _g.x = random(_vw + 60); }
}
