vida -= 1;
if (vida <= 0) { instance_destroy(); exit; }
if (armado > 0) { armado -= 1; exit; }

if (mecha < 0) {
	// Cada pantalla revisa a SU jugador (en local, al bot). Así quien la pisa no depende del lag de otro.
	var _pisada = false;
	if (global.ONLINE) {
		if (scr_my_team() != team) {
			with (oPlayer) {
				if (!isDead && !invulnerable && collision_rectangle(other.x - 12, other.y - 10, other.x + 12, other.y, id, false, false) != noone) _pisada = true;
			}
		}
	} else {
		with (oPlayer2_local) {
			if (!isDead && team != other.team && collision_rectangle(other.x - 12, other.y - 10, other.x + 12, other.y, id, false, false) != noone) _pisada = true;
		}
	}

	if (_pisada) {
		mecha = MINA_MECHA;
		if (global.sfx) audio_play_sound(snd_empy, 10, false, 1, 0, 2);
		if (global.ONLINE && instance_exists(oOtherPlayer)) {
			var _m = { mid: mid };
			with (oOtherPlayer) SendEventToClient(clientId, "mina_pisada", _m);
		}
	}
} else {
	mecha -= 1;
	if (mecha <= 0) scr_mina_explotar(id);
}
