t--;
if (t <= 0) { instance_destroy(); exit; }
if (team != global.myTeam || !instance_exists(oPlayer)) exit;

// ¿Mi jugador está adentro? Entonces me curo yo solo, en mi juego
var _b = id;
with (oPlayer) {
	if (isDead || state == PLAYERSTATE.DEAD) break;
	if (point_distance(_b.x, _b.y, x, y - 20) > HAB_BOTI_RADIO + 10) break;
	if (health >= max_health) break;

	_b.acc += HAB_BOTI_CURA / game_get_speed(gamespeed_fps);
	if (_b.acc >= 1) {
		var _c = floor(_b.acc);
		_b.acc -= _c;
		health = min(max_health, health + _c);
	}
	_b.fx_cd--;
	if (_b.fx_cd <= 0) {
		_b.fx_cd = 20;
		instance_create_layer(x + random_range(-14, 14), y - random_range(4, 30), "Instances", oHealFX);
	}
}
