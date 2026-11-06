// ======================================================
// DAÑO EN MODO LOCAL
// Todo lo que lastima al bot o a tu jugador pasa por aquí,
// así todos respetan igual el escudo, la invulnerabilidad y quién mató.
// ======================================================

/// Lastima al bot. Devuelve true si le hizo daño (false si estaba muerto, invulnerable o con escudo).
/// _num = mostrar el numerito de dano (false si quien llama ya lo muestra)
function scr_dano_bot(_bot, _dmg, _killer, _num = true) {
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
		// Igual que en linea: numerito de dano y la X en la mira si le pegaste tu
		if (_num) fx_damage_number(x, bbox_top - 8, _dmg, 0);
		if (_killer == global.myName) {
			var _kill = (hp <= 0);
			global.hm_timer = HM_FRAMES;
			global.hm_type  = _kill ? 2 : 0;
			if (global.sfx) audio_play_sound(snd_hitmarker, 30, false, _kill ? 1.2 : 0.9, 0, _kill ? 0.75 : 1);
			if (_kill) scrCamShake(4);
		}
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
		fx_damage_number(x, bbox_top - 8, _dmg, 3);   // igual que en linea
		return true;
	}
	return false;
}
