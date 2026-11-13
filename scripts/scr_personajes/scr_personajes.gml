// ======================================================
// PERSONAJES (en línea): stats, pasivas y habilidad en la Q
//   0 ASALTO       Impulso  — se lanza hacia adelante, las balas no le pegan mientras
//                  Pasiva: las armas automaticas hacen 2 a 3 de dano extra por bala
//   1 TANQUE       Coraza   — 4 s con la mitad de daño (camina a 2.5 con ella puesta)
//                  Pasiva: el golpe cuerpo a cuerpo hace 4 de dano extra
//   2 EXPLORADORA  Red      — lanza una red que deja quieto al rival 2 s
//                  Pasiva: los rivales no la ven en el mini mapa ni en los circulitos del borde
//   3 SARGENTO     Botiquín — se cura 30 de vida al instante
//                  Pasiva: puede disparar llevando la bandera (solo pistolas y subfusiles)
// Cada quien usa su habilidad en su juego: los demás la ven por sharedProperties
// (_HCO, _HDA, _HGF/_HGX/_HGY) y el botiquín por el evento "hab_botiquin".
// El que recibe el daño es el que aplica la coraza (evento "hit"), como ya pasaba con el escudo.
// ======================================================
#macro HAB_TECLA           ord("Q")
#macro HAB_DASH_FUERZA     14     // empuje del impulso (recorre ~130 px)
#macro HAB_DASH_INVUL      12     // frames sin que le peguen (0.2 s)
#macro HAB_CORAZA_T        240    // 4 s
#macro HAB_CORAZA_DANO     0.5    // recibe la mitad
#macro HAB_CORAZA_VEL      (2.5 / 2.8)   // con la coraza el Tanque camina a 2.5
#macro HAB_GANCHO_ALCANCE  260
#macro HAB_GANCHO_VEL      22     // lo que avanza la punta por frame
#macro HAB_GANCHO_JALON    13     // lo que te jala por frame
#macro HAB_BOTI_T          360    // 6 s
#macro HAB_BOTI_RADIO      80
#macro HAB_BOTI_CURA       8      // vida por segundo
#macro SARG_REGEN_ESPERA   300    // 5 s sin recibir daño
#macro SARG_REGEN          0      // (ya no: la pasiva del Sargento ahora es disparar con la bandera)
#macro ASALTO_RECARGA      1      // (ya no: la pasiva del Asalto ahora es dano extra con automaticas)
#macro TANQUE_GOLPE_EXTRA  4      // pasiva del Tanque
#macro SARG_CURA           30     // botiquin del Sargento: se cura esto al instante
#macro EXPLO_RED_T         120    // red de la Exploradora: 2 s quieto
#macro EXPLO_RED_VEL       10
#macro EXPLO_RED_DANO      5

/// Datos de cada personaje. La vida ya va ×1.5 (las armas pegan fuerte).
function scr_pj_datos(_i) {
	switch (_i) {
		case 1: return { nombre: "TANQUE",      hab: "CORAZA",   vida: 220, vel: 2.8, salto: -13,   bandera: 0.85, cd: 15, col: make_color_rgb(255, 77, 94) };
		case 2: return { nombre: "EXPLORADORA", hab: "RED",      vida: 140, vel: 3.4, salto: -15,   bandera: 0.65, cd: 12, col: make_color_rgb(94, 224, 138) };
		case 3: return { nombre: "SARGENTO",    hab: "BOTIQUIN", vida: 180, vel: 3.0, salto: -13.5, bandera: 0.70, cd: 18, col: make_color_rgb(215, 124, 255) };
	}
	return { nombre: "ASALTO", hab: "IMPULSO", vida: 160, vel: 3.2, salto: -14, bandera: 0.70, cd: 7, col: make_color_rgb(255, 212, 71) };
}

/// Pone los stats del personaje elegido (oPlayer Create).
function scr_pj_aplicar() {
	pj = scr_pj_datos(mi_clase);
	walksp_base = pj.vel;
	jumpsp = pj.salto;
	max_health = pj.vida;
	if (scr_modo_tiro()) max_health = 1;   // UN TIRO: 1 golpe = 1 baja (scr_reloj)
	health = max_health;
	melee_damage = 20 + ((mi_clase == 1) ? TANQUE_GOLPE_EXTRA : 0);   // PASIVA TANQUE
	hab_cd = 0;
	hab_cd_max = 1;
	scr_hab_reset();
}

// ------------------------------------------------------
// PASIVAS NUEVAS
// ------------------------------------------------------
/// ¿Este personaje tiene personaje? (en local solo contra el bot de partida rapida)
function __pj_activo() {
	if (!variable_instance_exists(id, "mi_clase") || mi_clase < 0) return false;
	if ((object_index == oPlayer_offline || object_index == oPlayer2_local) && !global.bot_partida) return false;
	return true;
}

/// PASIVA ASALTO: dano extra por bala con armas automaticas (rapidas y de 1 bala)
function scr_pj_bono_auto(_w) {
	if (!__pj_activo() || mi_clase != 0 || !is_struct(_w)) return 0;
	if (!variable_struct_exists(_w, "frequency") || _w.frequency > 10) return 0;
	if (variable_struct_exists(_w, "balas") && _w.balas > 1) return 0;
	if (variable_struct_exists(_w, "cohete") && _w.cohete) return 0;
	if (variable_struct_exists(_w, "efecto") && _w.efecto != "") return 0;
	return irandom_range(2, 3);
}

/// PASIVA SARGENTO: puede disparar con la bandera si trae pistola o subfusil
/// (no: ametralladora, lanzallamas, railgun, bazooka, francotirador, escopeta, armas con efecto)
function scr_pj_dispara_con_bandera() {
	if (!__pj_activo() || mi_clase != 3) return false;
	if (!variable_instance_exists(id, "guns")) return false;
	var _w = guns[weapon.index];
	if (_w == noone || !is_struct(_w)) return false;
	var _t = variable_struct_exists(_w, "ammoType") ? _w.ammoType : "";
	if (_t != "gun" && _t != "smg") return false;
	if (variable_struct_exists(_w, "giro") && _w.giro > 0) return false;
	if (variable_struct_exists(_w, "efecto") && _w.efecto != "") return false;
	return true;
}

/// PASIVA EXPLORADORA: ¿este jugador (oOtherPlayer o el bot de local) es una Exploradora rival?
/// Si es asi no sale en el mini mapa ni en los circulitos del borde.
function scr_pj_oculto(_mi_team) {
	var _t = variable_instance_exists(id, "team") ? string(team) : "";
	if (_t == _mi_team) return false;
	if (object_index == oPlayer2_local) return variable_instance_exists(id, "mi_clase") && mi_clase == 2;
	return variable_instance_exists(id, "mySelectedPJ") && mySelectedPJ == 2;
}

/// Limpia lo que esté activo (al aparecer y al reaparecer).
function scr_hab_reset() {
	hab_dash_t = 0;      // frames que quedan sin que le peguen
	hab_dash_vis = 0;    // frames que se ve la estela
	hab_cor_t = 0;
	hab_g_fase = 0;      // 0 nada, 1 la punta vuela, 2 me jala, 3 regresa
	hab_g_dist = 0;
	hab_g_dir = 0;
	hab_g_x = x;
	hab_g_y = y;
	hab_g_t = 0;
	hab_g_px = x;
	hab_g_py = y;
	hab_g_quieto = 0;
	hab_sin_danio = 0;   // frames desde el último daño (pasiva del Sargento)
	hab_regen_acc = 0;
}

/// Qué tan rápido camina con la bandera.
function scr_pj_mult_bandera() {
	if (variable_instance_exists(id, "pj")) return pj.bandera;
	return 0.7;
}

/// Velocidad extra o menos por la habilidad (la coraza pesa).
function scr_hab_vel_mult() {
	if (variable_instance_exists(id, "hab_cor_t") && hab_cor_t > 0) return HAB_CORAZA_VEL;
	return 1;
}

/// Asalto recarga más rápido. Sirve en scrReloadWeapon / scrStartReload (en local siempre da 1).
function scr_pj_recarga_mult() {
	if ((object_index == oPlayer || object_index == oPlayer_offline) && variable_instance_exists(id, "mi_clase") && mi_clase == 0) return ASALTO_RECARGA;
	return 1;
}

/// Recarga de la habilidad en frames (el gancho tarda el doble si traes la bandera).
function scr_hab_cd() {
	var _s = pj.cd;
	if (mi_clase == 2 && has_flag) _s *= 2;
	return round(_s * game_get_speed(gamespeed_fps));
}

/// ¿La coraza está puesta?
function scr_hab_coraza_activa() {
	return variable_instance_exists(id, "hab_cor_t") && hab_cor_t > 0;
}

/// Daño que de verdad recibo (lo llama el evento "hit" en mi juego).
function scr_hab_dano_recibido(_dmg) {
	if (scr_hab_coraza_activa()) _dmg = round(_dmg * HAB_CORAZA_DANO);
	hab_sin_danio = 0;
	return _dmg;
}

/// ¿Estoy en el impulso? (las balas me atraviesan)
function scr_hab_esquivando() {
	return variable_instance_exists(id, "hab_dash_t") && hab_dash_t > 0;
}

// ------------------------------------------------------
// STEP (oPlayer, después de leer las teclas)
// ------------------------------------------------------
function scr_hab_step() {
	if (!variable_instance_exists(id, "hab_cd")) scr_pj_aplicar();
	var _fps = game_get_speed(gamespeed_fps);

	if (hab_cd > 0) hab_cd--;
	if (hab_dash_t > 0) hab_dash_t--;
	if (hab_dash_vis > 0) hab_dash_vis--;
	if (hab_cor_t > 0) hab_cor_t--;
	hab_sin_danio++;

	if (isDead || state == PLAYERSTATE.DEAD) {
		hab_g_fase = 0; hab_cor_t = 0; hab_dash_t = 0; hab_dash_vis = 0;
		exit;
	}

	// PASIVA SARGENTO: si no le pegan en 5 s, se cura solo
	if (mi_clase == 3 && hab_sin_danio > SARG_REGEN_ESPERA && health < max_health) {
		hab_regen_acc += SARG_REGEN / _fps;
		if (hab_regen_acc >= 1) {
			var _c = floor(hab_regen_acc);
			hab_regen_acc -= _c;
			health = min(max_health, health + _c);
		}
	}

	// USAR LA HABILIDAD
	if (hab_cd > 0 || !vkey_pressed(HAB_TECLA)) exit;
	if (state == PLAYERSTATE.INTRO || global.game_over) exit;
	if (variable_global_exists("pausa") && global.pausa) exit;

	var _ok = false;
	switch (mi_clase) {
		case 0: _ok = scr_hab_impulso();  break;
		case 1: _ok = scr_hab_coraza();   break;
		case 2: _ok = scr_hab_red();      break;   // antes: gancho
		case 3: _ok = scr_hab_botiquin(); break;
	}
	if (_ok) {
		hab_cd_max = scr_hab_cd();
		hab_cd = hab_cd_max;
	}
}

function scr_hab_impulso() {
	var _dir = key_right - key_left;
	if (_dir == 0) _dir = sign(image_xscale);
	if (_dir == 0) _dir = 1;
	push_h = _dir * HAB_DASH_FUERZA;     // usa el mismo empuje del guante: choca con paredes igual
	if (vsp > 0) vsp = 0;                 // en el aire no se cae al empezar
	image_xscale = _dir * 1.5;
	hab_dash_t = HAB_DASH_INVUL;
	hab_dash_vis = 18;
	fx_dust(x, bbox_bottom, 8, -_dir);
	if (global.sfx) audio_play_sound(snd_melee, 5, false, 1, 0, 1.4);
	return true;
}

function scr_hab_coraza() {
	hab_cor_t = HAB_CORAZA_T;
	if (global.sfx) audio_play_sound(snd_shield_impact, 5, false, 1, 0, 0.6);
	return true;
}

function scr_hab_gancho() {
	hab_g_fase = 1;
	hab_g_dist = 0;
	hab_g_t = 0;
	hab_g_quieto = 0;
	hab_g_dir = point_direction(x, y - 20, aim_x(), aim_y());
	hab_g_x = x;
	hab_g_y = y - 20;
	if (global.sfx) audio_play_sound(snd_grab, 5, false, 0.8, 0, 1.2);
	return true;
}

/// BOTIQUIN: se cura 30 al instante (solo a el)
function scr_hab_botiquin() {
	if (health >= max_health) return false;   // con la vida llena no se gasta
	health = min(max_health, health + SARG_CURA);
	repeat (4) instance_create_layer(x + random_range(-14, 14), y - random_range(4, 30), "Instances", oHealFX);
	if (global.sfx) audio_play_sound(snd_ammo_pickup, 5, false, 1, 0, 0.8);
	return true;
}

/// RED de la Exploradora: una red en arco; al que le pega queda quieto 2 s (scr_armas: efecto "red_hab")
function scr_hab_red() {
	var _dir = point_direction(x, y - 20, aim_x(), aim_y());
	var _b = instance_create_layer(x + lengthdir_x(14, _dir), y - 20 + lengthdir_y(14, _dir), "Instances", global.ONLINE ? oMyEntity : oPlayer_bullet);
	_b.owner_name = global.myName;
	_b.owner_team = global.myTeam;
	_b.owner_id = id;
	_b.direction = _dir;
	_b.image_angle = _dir;
	_b.speed = EXPLO_RED_VEL;
	_b.life = 90;
	_b.damage = EXPLO_RED_DANO;
	_b.sprite_index = sprBullet_smg;
	_b.efecto = "red_hab";
	_b.gravity = 0.32;
	_b.gravity_direction = 270;
	_b.image_xscale = 1.5;
	_b.image_yscale = 1.5;
	if (!global.ONLINE) _b.team = team;
	if (global.sfx) audio_play_sound(snd_escop, 5, false, 0.6, 0, 1.4);
	return true;
}

/// Movimiento del gancho. Va en el Step de oPlayer justo antes de los choques con paredes,
/// así el jalón usa las mismas colisiones de siempre.
function scr_hab_mov() {
	if (!variable_instance_exists(id, "hab_g_fase") || hab_g_fase == 0) exit;
	var _ox = x, _oy = y - 20;

	if (hab_g_fase == 1) {
		// La punta avanza en pasitos de 4 px para no brincarse plataformas delgadas
		var _d0 = hab_g_dist;
		var _pego = false;
		hab_g_dist = min(hab_g_dist + HAB_GANCHO_VEL, HAB_GANCHO_ALCANCE);
		for (var d = _d0 + 4; d <= hab_g_dist; d += 4) {
			var _tx = _ox + lengthdir_x(d, hab_g_dir);
			var _ty = _oy + lengthdir_y(d, hab_g_dir);
			if (position_meeting(_tx, _ty, obj_wall) || position_meeting(_tx, _ty, oPlataformaPasable)) {
				hab_g_x = _tx; hab_g_y = _ty; hab_g_dist = d; _pego = true;
				break;
			}
		}
		if (_pego) {
			hab_g_fase = 2;
			hab_g_t = 0;
			hab_g_px = x; hab_g_py = y;
			if (global.sfx) audio_play_sound(snd_hit, 5, false, 0.6, 0, 1.6);
		} else {
			hab_g_x = _ox + lengthdir_x(hab_g_dist, hab_g_dir);
			hab_g_y = _oy + lengthdir_y(hab_g_dist, hab_g_dir);
			if (hab_g_dist >= HAB_GANCHO_ALCANCE) {
				hab_g_fase = 3;
				// Si no pegó en nada, la recarga es corta
				hab_cd = min(hab_cd, round(1.5 * game_get_speed(gamespeed_fps)));
			}
		}
	}
	else if (hab_g_fase == 2) {
		hab_g_t++;
		// Si me quedé atorado (pared en medio), suelto
		if (abs(x - hab_g_px) + abs(y - hab_g_py) < 0.5) hab_g_quieto++; else hab_g_quieto = 0;
		hab_g_px = x; hab_g_py = y;

		var _dir = point_direction(x, y - 20, hab_g_x, hab_g_y);
		var _dist = point_distance(x, y - 20, hab_g_x, hab_g_y);
		if (_dist < 24 || hab_g_t > 40 || hab_g_quieto > 3 || key_jump || state == PLAYERSTATE.DEAD) {
			hab_g_fase = 0;
			vsp = min(vsp, -5);      // saltito para quedar arriba de la plataforma
			hsp *= 0.5;
			exit;
		}
		var _v = min(HAB_GANCHO_JALON, _dist);
		hsp = lengthdir_x(_v, _dir);
		vsp = lengthdir_y(_v, _dir);
		push_h = 0;
		if (state != PLAYERSTATE.HIT) state = PLAYERSTATE.JUMP;
	}
	else if (hab_g_fase == 3) {
		hab_g_dist -= 30;
		if (hab_g_dist <= 0) { hab_g_fase = 0; exit; }
		hab_g_x = _ox + lengthdir_x(hab_g_dist, hab_g_dir);
		hab_g_y = _oy + lengthdir_y(hab_g_dist, hab_g_dir);
	}
}

// ------------------------------------------------------
// DIBUJO (lo mismo para mí y para los demás)
// ------------------------------------------------------
/// _co coraza, _da estela del impulso, _gf/_gx/_gy gancho.
function __hab_draw(_co, _da, _gf, _gx, _gy) {
	if (_co) {
		var _a = 0.45 + 0.2 * sin(current_time / 90);
		draw_set_alpha(_a);
		draw_set_colour(make_color_rgb(255, 77, 94));
		draw_ellipse(x - 24, y - 52, x + 24, y + 4, true);
		draw_ellipse(x - 25, y - 53, x + 25, y + 5, true);
		draw_set_alpha(1);
	}
	if (_da) {
		var _s = sign(image_xscale);
		for (var k = 1; k <= 3; k++) {
			draw_sprite_ext(sprite_index, image_index, x - _s * k * 14, y, image_xscale, image_yscale, 0, make_color_rgb(255, 212, 71), 0.35 - k * 0.09);
		}
	}
	if (_gf > 0) {
		draw_set_colour(make_color_rgb(201, 195, 230));
		draw_line_width(x, y - 20, _gx, _gy, 2);
		draw_set_colour(c_white);
		draw_rectangle(_gx - 2, _gy - 2, _gx + 2, _gy + 2, false);
	}
	draw_set_colour(c_white);
}

/// Draw de oPlayer (al final).
function scr_hab_draw() {
	if (!variable_instance_exists(id, "hab_cd") || state == PLAYERSTATE.DEAD) exit;
	__hab_draw(hab_cor_t > 0, hab_dash_vis > 0, hab_g_fase, hab_g_x, hab_g_y);

	// (la flecha de la Exploradora hacia el ladron se quito: su pasiva ahora es no salir en el mini mapa)
	if (false) {
		var _ladron = noone;
		with (oOtherPlayer) if (has_flag && team != global.myTeam) _ladron = id;
		if (_ladron != noone) {
			var _d = point_direction(x, y - 20, _ladron.x, _ladron.y - 20);
			var _r = 44 + 3 * sin(current_time / 120);
			var _cx = x + lengthdir_x(_r, _d), _cy = y - 20 + lengthdir_y(_r, _d);
			draw_set_colour(make_color_rgb(94, 224, 138));
			draw_triangle(_cx + lengthdir_x(9, _d), _cy + lengthdir_y(9, _d),
			              _cx + lengthdir_x(6, _d + 130), _cy + lengthdir_y(6, _d + 130),
			              _cx + lengthdir_x(6, _d - 130), _cy + lengthdir_y(6, _d - 130), false);
			draw_set_colour(c_white);
		}
	}
}

/// Draw de oOtherPlayer (al final): lo que mandó por la red.
function scr_hab_draw_otro() {
	if (!variable_instance_exists(id, "hab_co") || state == PLAYERSTATE.DEAD) exit;
	__hab_draw(hab_co, hab_da, hab_gf, hab_gx, hab_gy);
}

/// Icono de la habilidad en el HUD, junto a la vida (oPlayer Draw GUI).
function scr_hab_hud(_x, _y) {
	if (!variable_instance_exists(id, "hab_cd")) exit;
	var _r = 24;
	var _listo = (hab_cd <= 0);
	var _p = _listo ? 1 : clamp(1 - hab_cd / max(1, hab_cd_max), 0, 1);
	var _col = pj.col;

	draw_set_alpha(0.6);
	draw_set_colour(c_black);
	draw_circle(_x, _y, _r + 3, false);
	draw_set_alpha(1);
	draw_set_colour(make_color_rgb(51, 46, 71));
	draw_circle(_x, _y, _r, true);
	draw_circle(_x, _y, _r - 1, true);

	// arco de recarga
	draw_set_colour(_listo ? _col : merge_colour(_col, c_gray, 0.5));
	var _n = max(2, ceil(40 * _p));
	var _px = _x, _py = _y - _r;
	for (var i = 1; i <= _n; i++) {
		var _ang = 90 - 360 * _p * (i / _n);
		var _nx = _x + lengthdir_x(_r, _ang), _ny = _y + lengthdir_y(_r, _ang);
		draw_line_width(_px, _py, _nx, _ny, 4);
		_px = _nx; _py = _ny;
	}

	draw_set_font(fnt_menu);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _s = _listo ? 0.8 + 0.06 * sin(current_time / 160) : 0.75;
	var _txt = touch_mode() ? "" : "Q";
	if (!_listo) _txt = string(ceil(hab_cd / game_get_speed(gamespeed_fps)));
	var _tc = _listo ? _col : c_ltgray;
	draw_text_transformed_color(_x, _y + 1, _txt, _s, _s, 0, _tc, _tc, _tc, _tc, 1);
	draw_text_transformed_color(_x, _y + _r + 14, pj.hab, 0.45, 0.45, 0, c_white, c_white, c_white, c_white, 0.9);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_colour(c_white);
}

/// Nombre del personaje y su habilidad en la selección (draw_bomb_slot).
function scr_pj_slot_texto(_pj, _x, _y) {
	if (_pj < 0 || _pj > 3) exit;
	var _d = scr_pj_datos(_pj);
	draw_set_font(fnt_menu);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text_transformed_color(_x + 2, _y + 2, _d.nombre, 0.6, 0.6, 0, c_black, c_black, c_black, c_black, 0.8);
	draw_text_transformed_color(_x, _y, _d.nombre, 0.6, 0.6, 0, _d.col, _d.col, _d.col, _d.col, 1);
	var _t = "Q: " + _d.hab + "  ·  VIDA " + string(_d.vida);
	draw_text_transformed_color(_x + 1, _y + 23, _t, 0.42, 0.42, 0, c_black, c_black, c_black, c_black, 0.8);
	draw_text_transformed_color(_x, _y + 22, _t, 0.42, 0.42, 0, c_white, c_white, c_white, c_white, 1);
	draw_set_valign(fa_top);
}
