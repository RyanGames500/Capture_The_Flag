// ======================================================
// FONDO CON PROFUNDIDAD, PLATAFORMA DE SALTO, RAILGUN Y MINA
// ======================================================
#macro SALTO_VSP      -21    // fuerza de la plataforma de salto (sube unos 440 px: llega al camino de arriba)
#macro SALTO_ALTO     440
#macro RAIL_CARGA     30     // frames de carga antes del disparo (medio segundo)
#macro RAIL_LARGO     900    // alcance del rayo
#macro RAIL_DANO      75
#macro MINA_ARMADO    45     // frames hasta que la mina queda activa
#macro MINA_MECHA     16     // frames entre que la pisan y explota
#macro MINA_RADIO     64
#macro MINA_DANO      60
#macro MINA_MAX       2      // minas puestas por jugador
#macro MINA_VIDA      2700   // 45 s y se apaga sola

// ------------------------------------------------------
// FONDO: 3 capas que se mueven más lento que la cámara.
// Va en el Step de las cámaras, después de mover la vista.
// Si el room no tiene esas capas, no hace nada.
// ------------------------------------------------------
function scr_fondo_parallax(_cam) {
	// Primera vez en este nivel (la cámara es nueva en cada room): elegir fondo y clima
	if (!variable_instance_exists(id, "fondo_t")) {
		fondo_t = 0;
		scr_fondo_variante();
		if (layer_get_id("Fondo_nubes") != -1 && !instance_exists(oClima)) {
			var _lt = layer_get_id("Fondo_torres");
			instance_create_depth(0, 0, (_lt != -1) ? layer_get_depth(_lt) - 1 : 0, oClima);
		}
	}
	fondo_t += 1;

	var _cx = camera_get_view_x(_cam);
	var _cy = camera_get_view_y(_cam);
	var _l = layer_get_id("Fondo_cielo");
	if (_l != -1) { layer_x(_l, _cx); layer_y(_l, _cy); }
	_l = layer_get_id("Fondo_montes");
	if (_l != -1) { layer_x(_l, _cx * 0.88); layer_y(_l, _cy * 0.94 + 40); }
	_l = layer_get_id("Fondo_torres");
	if (_l != -1) { layer_x(_l, _cx * 0.70); layer_y(_l, _cy * 0.85 + 90); }
	// capas que además se mueven solas (humo de la fábrica, nubes de la tormenta)
	_l = layer_get_id("Fondo_humo");
	if (_l != -1) { layer_x(_l, _cx * 0.80 - fondo_t * 0.3); layer_y(_l, _cy * 0.90 + 30); }
	_l = layer_get_id("Fondo_nubes");
	if (_l != -1) { layer_x(_l, _cx * 0.95 - fondo_t * 0.4); layer_y(_l, _cy * 0.975); }
}

/// Nivel 1: la mitad de las partidas es de noche y la otra mitad de amanecer.
/// En línea sale igual para todos los de la sala (se decide con el código de la sala).
function scr_fondo_variante() {
	var _l = layer_get_id("Fondo_cielo");
	if (_l == -1) return;
	var _bg = layer_background_get_id(_l);
	if (layer_background_get_sprite(_bg) != spr_fondo_cielo) return;   // solo el fondo de noche tiene variante

	var _sem = (global.ONLINE && variable_global_exists("roomId")) ? string(global.roomId) : string(current_time);
	if (ord(string_char_at(md5_string_utf8(_sem), 1)) mod 2 == 0) return;   // se queda de noche

	layer_background_change(_bg, spr_fondo_amanecer_cielo);
	var _l2 = layer_get_id("Fondo_montes");
	if (_l2 != -1) layer_background_change(layer_background_get_id(_l2), spr_fondo_amanecer_lejos);
	var _l3 = layer_get_id("Fondo_torres");
	if (_l3 != -1) layer_background_change(layer_background_get_id(_l3), spr_fondo_amanecer_cerca);
}

// ------------------------------------------------------
// PLATAFORMA DE SALTO: si estás parado encima y aprietas saltar,
// sales disparado hacia arriba. Caminar encima no hace nada.
// Lo llama el jugador (y el bot) justo antes de su máquina de estados.
// Devuelve true si te lanzó.
// ------------------------------------------------------
function scr_salto_usar() {
	var _p = instance_place(x, y + 2, oSalto);
	if (_p == noone) return false;
	vsp = SALTO_VSP;
	with (_p) golpe = 12;
	fx_dust(x, bbox_bottom, 14, 0);
	if (global.sfx) audio_play_sound(snd_grab, 5, false, 0.9, 0, 1.4);
	return true;
}

// ------------------------------------------------------
// Punta del cañón (la misma cuenta que usan tus armas para la bala)
// ------------------------------------------------------
function scr_arma_punta(_largo = 34) {
	var _d = sign(image_xscale);
	var _a = weapon.angle;
	var _hx = x + 2 * _d + lengthdir_x(14, _a);
	var _hy = y - 18 + lengthdir_y(14, _a);
	var _adj = (_a > 90 && _a < 270) ? 4 : -4;
	return [_hx + lengthdir_x(_largo, _a) + lengthdir_x(_adj, _a - 90),
	        _hy + lengthdir_y(_largo, _a) + lengthdir_y(_adj, _a - 90)];
}

/// Hasta dónde llega el rayo: se corta en los muros (atraviesa plataformas y jugadores).
function scr_rail_fin(_x, _y, _ang) {
	var _px = _x, _py = _y;
	for (var d = 8; d <= RAIL_LARGO; d += 8) {
		var _nx = _x + lengthdir_x(d, _ang);
		var _ny = _y + lengthdir_y(d, _ang);
		if (position_meeting(_nx, _ny, obj_wall)) break;
		_px = _nx; _py = _ny;
	}
	return [_px, _py];
}

/// Se gasta una carga del arma especial; sin cargas, vuelves a las manos.
function scr_arma_especial_gastar(_w) {
	if (!infinite_ammo) _w.ammo -= 1;
	weapon.frequency = _w.frequency;
	if (_w.ammo <= 0) guns[weapon.index] = noone;
	else guns[weapon.index] = _w;
}

// ------------------------------------------------------
// RAILGUN: aprietas, carga medio segundo (con línea de aviso) y dispara solo.
// Lo llama scrPlayerWeaponUpdate / _offline cuando el arma es "rail".
// ------------------------------------------------------
function scr_rail_update() {
	var _w = guns[weapon.index];
	if (!variable_instance_exists(id, "rail_carga")) { rail_carga = 0; rail_ultimo = 0; }

	// Si dejó de llamarse (agarraste la bandera, te pegaron...), la carga se pierde
	if (rail_carga > 0 && current_time - rail_ultimo > 150) rail_carga = 0;
	rail_ultimo = current_time;

	if (rail_carga == 0) {
		if (vmouse(mb_left) && weapon.frequency <= 0 && _w.ammo > 0) {
			rail_carga = 1;
			var _c = instance_create_layer(x, y, "Instances", oRayo);
			_c.modo = "carga"; _c.owner = id; _c.vida = RAIL_CARGA; _c.vida_max = RAIL_CARGA;
			if (global.sfx) audio_play_sound(snd_reload, 5, false, 0.8, 0, 1.8);
			if (global.ONLINE && instance_exists(oOtherPlayer)) {
				var _p0 = scr_arma_punta();
				var _m0 = { x: _p0[0], y: _p0[1], ang: weapon.angle };
				with (oOtherPlayer) SendEventToClient(clientId, "fx_rail_carga", _m0);
			}
		}
		return;
	}

	rail_carga += 1;
	if (rail_carga < RAIL_CARGA) return;
	rail_carga = 0;

	// --- DISPARO ---
	var _p = scr_arma_punta();
	var _ang = weapon.angle;
	var _fin = scr_rail_fin(_p[0], _p[1], _ang);
	var _dmg = _w.damage * damage_boost;
	var _golpes = 0;
	var _lista = ds_list_create();

	if (global.ONLINE) {
		var _n = collision_line_list(_p[0], _p[1], _fin[0], _fin[1], oOtherPlayer, false, true, _lista, true);
		for (var i = 0; i < _n; i++) {
			var _t = _lista[| i];
			if (!variable_instance_exists(_t, "team") || _t.team == global.myTeam) continue;
			if (_t.state == PLAYERSTATE.DEAD || !_t.visible) continue;
			if (_t.has_shield) {
				// el escudo para el rayo ahí
				instance_create_layer(_t.x, _t.y - 16, "Instances", oShieldSparkFX);
				if (global.sfx) audio_play_sound(snd_shield_impact, 20, false, 2.0);
				with (oOtherPlayer) SendEventToClient(clientId, "fx_shield_hit", { ex: _t.x, ey: _t.y - 16 });
				_fin = [_t.x, _t.y - 16];
				break;
			}
			if (_t.invulnerable) continue;
			_golpes += 1;
			fx_damage_number(_t.x, _t.bbox_top - 8, _dmg, 2);
			scr_predict_hit(_t, _dmg, 10);
			scr_hit_confirm(_t, false, false);
			SendEventToClient(_t.clientId, "hit", { damage: _dmg, killer: global.myName, reason: "pvp" });
		}
	} else {
		var _nb = collision_line_list(_p[0], _p[1], _fin[0], _fin[1], oPlayer2_local, false, true, _lista, true);
		for (var k = 0; k < _nb; k++) {
			var _b = _lista[| k];
			if (_b.team == team) continue;
			if (scr_dano_bot(_b, _dmg, global.myName, false)) {
				_golpes += 1;
				fx_damage_number(_b.x, _b.bbox_top - 8, _dmg, 2);
			}
		}
	}
	ds_list_destroy(_lista);

	var _r = instance_create_layer(_p[0], _p[1], "Instances", oRayo);
	_r.x1 = _p[0]; _r.y1 = _p[1]; _r.x2 = _fin[0]; _r.y2 = _fin[1];
	if (global.ONLINE && instance_exists(oOtherPlayer)) {
		var _m = { x1: _p[0], y1: _p[1], x2: _fin[0], y2: _fin[1] };
		with (oOtherPlayer) SendEventToClient(clientId, "fx_rail", _m);
	}

	if (_golpes >= 2) {
		fb_toast("DOBLE IMPACTO!", "Railgun", c_yellow);
	}

	scrCamShake(8);
	recoil_kick += 8;
	hsp -= lengthdir_x(5, _ang);
	if (global.sfx) audio_play_sound(snd_bazooka, 1, false, 0.9, 0, 1.6);
	scr_arma_especial_gastar(_w);
}

// ------------------------------------------------------
// MINA: disparo = la pones en el piso, a tus pies. Máximo 2 a la vez.
// ------------------------------------------------------
function scr_mina_update() {
	var _w = guns[weapon.index];
	if (!vmouse_pressed(mb_left) || weapon.frequency > 0 || _w.ammo <= 0) return;
	if (!is_grounded) return;   // solo en el piso

	if (!variable_instance_exists(id, "mina_n")) mina_n = 0;
	mina_n += 1;
	var _mid = string(global.ONLINE ? global.clientId : 0) + "_" + string(mina_n) + "_" + string(irandom(9999));
	// en línea, tu equipo de la sala; en local, el de tu jugador (el bot es del otro)
	var _team = global.ONLINE ? scr_my_team() : team;
	var _nom = global.myName;

	// Si ya tengo 2, se quita la más vieja
	var _mias = [];
	with (oMina) if (es_mia) array_push(_mias, id);
	if (array_length(_mias) >= MINA_MAX) {
		var _vieja = _mias[0];
		for (var i = 1; i < array_length(_mias); i++) if (_mias[i].creada < _vieja.creada) _vieja = _mias[i];
		var _qid = _vieja.mid;
		instance_destroy(_vieja);
		if (global.ONLINE) with (oOtherPlayer) SendEventToClient(clientId, "mina_quitar", { mid: _qid });
	}

	scr_mina_crear(x, bbox_bottom + 1, _team, _nom, _mid, true);
	if (global.ONLINE && instance_exists(oOtherPlayer)) {
		var _m = { mid: _mid, x: x, y: bbox_bottom + 1, team: _team, owner: _nom };
		with (oOtherPlayer) SendEventToClient(clientId, "mina_poner", _m);
	}
	if (global.sfx) audio_play_sound(snd_grab, 5, false, 0.8, 0, 0.8);
	scr_arma_especial_gastar(_w);
}

function scr_mina_crear(_x, _y, _team, _owner, _mid, _mia) {
	var _m = instance_create_layer(_x, _y, "Instances", oMina);
	_m.team = _team;
	_m.owner_name = _owner;
	_m.mid = _mid;
	_m.es_mia = _mia;
	return _m;
}

function scr_mina_buscar(_mid) {
	var _r = noone;
	with (oMina) if (mid == _mid) _r = id;
	return _r;
}

/// Empieza la mecha (alguien la pisó). _menos = frames que ya pasaron por el ping.
function scr_mina_encender(_mina, _menos) {
	if (!instance_exists(_mina)) return;
	with (_mina) {
		if (mecha >= 0) return;
		mecha = max(3, MINA_MECHA - _menos);
	}
}

/// Daño de la mina a tu jugador en línea (cada uno se revisa a sí mismo, como el "hit").
function scr_mina_dano_local(_mx, _my, _dmg, _killer) {
	if (!instance_exists(oPlayer)) return;
	with (oPlayer) {
		if (isDead || invulnerable) return;
		if (point_distance(x, y - 16, _mx, _my) > MINA_RADIO) return;

		if (has_shield) {
			has_shield = false;
			shield_timer = 0;
			impact_alpha = 0.6;
			impact_color = c_aqua;
			scrCamShake(12);
			if (global.sfx) audio_play_sound(snd_hit, 20, false, 1.5);
		} else {
			last_killer = _killer;
			death_reason = "mina";
			damage_alpha = 0.4;
			health -= _dmg;
			fx_damage_number(x, bbox_top - 8, _dmg, 3);
		}

		// salta por los aires
		vsp = -9;
		push_h = (x < _mx) ? -10 : 10;
		if (state != PLAYERSTATE.DEAD) { state = PLAYERSTATE.HIT; hit_bloqueo_timer = 14; image_index = 0; }

		// si llevabas la bandera, la sueltas
		if (has_flag) {
			has_flag = false;
			var _obj_bandera = (global.myTeam == "AZUL") ? oFlag : oFlag2;
			var _dx = x, _dy = y - 25;
			with (_obj_bandera) {
				has_flag = false;
				portador_instancia = noone;
				x = _dx;
				y = _dy;
				velocidad_caida = -6;
			}
			with (oOtherPlayer) {
				SendEventToClient(clientId, "flag_dropped", { team: global.myTeam, dropX: _dx, dropY: _dy });
			}
		}
	}
}

/// Explota la mina: efecto para todos y cada uno revisa su daño.
function scr_mina_explotar(_mina) {
	if (!instance_exists(_mina)) return;
	var _mx = _mina.x, _my = _mina.y - 8;
	var _team = _mina.team, _owner = _mina.owner_name;

	instance_create_layer(_mx, _my, "Instances", oExplosionFX);
	if (global.sfx) audio_play_sound(snd_pearl_explodes, 10, false);
	scrCamShake(12);

	if (global.ONLINE) {
		if (scr_my_team() != _team) scr_mina_dano_local(_mx, _my, MINA_DANO, _owner);
		// Los bots de la sala privada: el lider les hace el dano (scr_objetivo)
		if (oBrain.AmIPseudoHost) {
			with (oOtherPlayer) {
				if (bot_local && !isDead && team != _team && point_distance(x, y - 16, _mx, _my) <= MINA_RADIO) {
					scr_botnet_dano(id, { damage: MINA_DANO, killer: _owner, reason: "mina" }, -1);
					vsp = -9;
					push_h = (x < _mx) ? -10 : 10;
					if (has_flag) scr_botnet_soltar(-6, 25);
				}
			}
		}
	} else {
		with (oPlayer2_local) {
			if (team != _team && point_distance(x, y - 16, _mx, _my) <= MINA_RADIO) {
				if (scr_dano_bot(id, MINA_DANO, _owner, false)) {
					vsp = -9;
					push_h = (x < _mx) ? -10 : 10;
					fx_damage_number(x, bbox_top - 8, MINA_DANO, 2);
				}
			}
		}
	}
	instance_destroy(_mina);
}
