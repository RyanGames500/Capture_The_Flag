// ======================================================
// DAÑO EN MODO LOCAL
// Todo lo que lastima al bot o a tu jugador pasa por aquí,
// así todos respetan igual el escudo, la invulnerabilidad y quién mató.
// ======================================================

/// Lastima al bot. Devuelve true si le hizo daño (false si estaba muerto, invulnerable o con escudo).
function scr_dano_bot(_bot, _dmg, _killer) {
	if (!instance_exists(_bot)) return false;
	with (_bot) {
		if (isDead || state == PLAYER2.DEAD) return false;
		if (invulnerable) return false;
		if (has_shield) {
			instance_create_layer(x, y - 16, "Instances", oShieldSparkFX);
			if (global.sfx) audio_play_sound(snd_shield_impact, 20, false, 2.0);
			return false;
		}
		hp -= _dmg;
		last_killer = _killer;
		image_blend = c_red;
		alarm[3] = 5;
		return true;
	}
	return false;
}

/// Lastima a tu jugador en local (usa health, como el resto de tu código).
function scr_dano_jugador_local(_dmg, _killer) {
	if (!instance_exists(oPlayer_offline)) return false;
	with (oPlayer_offline) {
		if (isDead) return false;
		if (invulnerable) return false;
		if (has_shield) {
			instance_create_layer(x, y - 16, "Instances", oShieldSparkFX);
			if (global.sfx) audio_play_sound(snd_shield_impact, 20, false, 2.0);
			return false;
		}
		health -= _dmg;
		last_killer = _killer;
		damage_alpha = 0.4;
		return true;
	}
	return false;
}
