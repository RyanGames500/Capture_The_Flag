// ======================================================
// ARMAS NUEVAS (19): todas usan el mismo disparo, cada una con sus números.
// Tus armas de antes (pistola, SMG, M4, escopeta, bazooka, guante, railgun, mina)
// siguen con su propio código y no cambian.
// ======================================================

/// Crea una arma nueva con los mismos campos que tus armas de siempre + los suyos.
function __arma(_tipo, _spr, _nombre, _datos) {
	var _w = {
		sprite_suelo: _spr, sprite: _spr, object: oGun, subimage: 0,
		type2: _tipo, generica: true, nombre: _nombre, index: 0,
		ammo: 10, maxAmmo: 10, frequency: 10, damage: 10, ammoType: "gun", clipSize: 30, reloadTime: room_speed * 1.2,
		vel: 16, vida: 36, disp: 0, balas: 1, rec: 0, rec_max: 0, rafaga: 0, atraviesa: 0, cohete: false, zoom: false,
		silenciada: false, lento: false, kick: 3, shake: 1, empuje: 0, mz: "gun",
		snd: snd_gun, tono: 1, vol: 1, peso: 2   // peso = qué tan seguido sale en el mapa
	};
	var _n = variable_struct_get_names(_datos);
	for (var i = 0; i < array_length(_n); i++) _w[$ _n[i]] = _datos[$ _n[i]];
	_w.maxAmmo = _w.ammo;
	return _w;
}

/// Lista de armas nuevas. La llama oBrain en su Create (una sola vez).
function scr_armas_init() {
	var _rs = room_speed;
	global.armas_nuevas = [
		// --- PISTOLAS ---
		__arma("g_luger",    spr_arma_luger,      "LUGER",          { damage: 14, frequency: 22, vel: 17, vida: 36, disp: 0.5, ammo: 8,  ammoType: "gun", snd: snd_gun, tono: 1.15, vol: 0.85 }),
		__arma("g_glock",    spr_arma_glock,      "GLOCK 18",       { damage: 7,  frequency: 5,  vel: 16, vida: 34, disp: 3,   ammo: 18, rec: 0.8, rec_max: 8, ammoType: "gun", snd: snd_gun, tono: 1.35, vol: 0.65 }),
		__arma("g_silen",    spr_arma_silenciada, "SILENCIADA",     { damage: 12, frequency: 18, vel: 16, vida: 38, disp: 0.8, ammo: 12, silenciada: true, ammoType: "gun", snd: snd_silenciador, tono: 1, vol: 0.9 }),
		__arma("g_deagle",   spr_arma_deagle,     "DESERT EAGLE",   { damage: 28, frequency: 34, vel: 19, vida: 38, disp: 0.3, ammo: 7,  kick: 6, shake: 3, empuje: 3, ammoType: "gun", snd: snd_gun, tono: 0.75, vol: 1, peso: 1 }),
		__arma("g_revolver", spr_arma_revolver,   "REVOLVER",       { damage: 36, frequency: 42, vel: 19, vida: 40, disp: 0,   ammo: 6,  kick: 7, shake: 3.5, empuje: 3, ammoType: "gun", snd: snd_gun, tono: 0.62, vol: 1, peso: 1 }),
		// --- SUBFUSILES ---
		__arma("g_uzi",      spr_arma_uzi,        "UZI",            { damage: 8,  frequency: 4,  vel: 16, vida: 28, disp: 4.5, ammo: 32, rec: 1,   rec_max: 10, ammoType: "smg", mz: "smg", snd: snd_smg, tono: 1.3, vol: 0.65 }),
		__arma("g_mp5",      spr_arma_mp5,        "MP5",            { damage: 10, frequency: 6,  vel: 16, vida: 34, disp: 2,   ammo: 30, rec: 0.6, rec_max: 8,  ammoType: "smg", mz: "smg", snd: snd_smg, tono: 1.1, vol: 0.8 }),
		__arma("g_mp5s",     spr_arma_mp5s,       "MP5 SILENCIADA", { damage: 9,  frequency: 6,  vel: 16, vida: 32, disp: 2,   ammo: 30, rec: 0.6, rec_max: 8,  silenciada: true, ammoType: "smg", snd: snd_silenciador, tono: 1.18, vol: 0.75 }),
		__arma("g_mp40",     spr_arma_mp40,       "MP40",           { damage: 13, frequency: 9,  vel: 16, vida: 36, disp: 1.5, ammo: 32, rec: 0.5, rec_max: 6,  ammoType: "smg", mz: "smg", snd: snd_smg, tono: 0.85, vol: 0.9 }),
		__arma("g_thompson", spr_arma_thompson,   "THOMPSON",       { damage: 12, frequency: 6,  vel: 16, vida: 34, disp: 3,   ammo: 50, rec: 0.8, rec_max: 10, lento: true, ammoType: "smg", mz: "smg", snd: snd_smg, tono: 0.75, vol: 0.9 }),
		// --- RIFLES ---
		__arma("g_carabina", spr_arma_carabina,   "CARABINA",       { damage: 13, frequency: 7,  vel: 19, vida: 40, disp: 0.8, ammo: 30, rec: 0.4, rec_max: 5,  ammoType: "rifle", mz: "smg", snd: snd_M4, tono: 1.15, vol: 0.8 }),
		__arma("g_ak47",     spr_arma_ak47,       "AK-47",          { damage: 18, frequency: 8,  vel: 19, vida: 40, disp: 2.5, ammo: 30, rec: 1.1, rec_max: 12, kick: 4, shake: 1.5, ammoType: "rifle", mz: "smg", snd: snd_M4, tono: 0.85, vol: 0.95 }),
		__arma("g_g36",      spr_arma_g36,        "G36",            { damage: 14, frequency: 6.5,vel: 19, vida: 40, disp: 1.5, ammo: 36, rec: 0.6, rec_max: 8,  ammoType: "rifle", mz: "smg", snd: snd_M4, tono: 1.05, vol: 0.8 }),
		__arma("g_scar",     spr_arma_scar,       "SCAR",           { damage: 16, frequency: 26, vel: 20, vida: 40, disp: 1,   ammo: 30, rafaga: 3, ammoType: "rifle", mz: "smg", snd: snd_M4, tono: 0.95, vol: 0.9 }),
		__arma("g_fal",      spr_arma_fal,        "FAL",            { damage: 30, frequency: 14, vel: 21, vida: 40, disp: 0.6, ammo: 20, kick: 5, shake: 2, ammoType: "rifle", mz: "smg", snd: snd_M4, tono: 0.7, vol: 1 }),
		// --- ESCOPETA ---
		__arma("g_recortada", spr_arma_recortada, "RECORTADA",      { damage: 14, frequency: 18, vel: 8,  vida: 14, disp: 30, balas: 9, ammo: 2, kick: 8, shake: 4, empuje: 7, ammoType: "escop", mz: "escop", reloadTime: _rs * 1.4, snd: snd_escop, tono: 0.85, vol: 1 }),
		// --- FRANCOTIRADORES ---
		__arma("g_franco",   spr_arma_franco,     "FRANCOTIRADOR",  { damage: 80, frequency: 70, vel: 30, vida: 36, disp: 0, ammo: 5, kick: 8, shake: 5, empuje: 4, zoom: true, ammoType: "sniper", mz: "bazooka", reloadTime: _rs * 2, snd: snd_M4, tono: 0.5, vol: 1, peso: 1 }),
		__arma("g_antimat",  spr_arma_antimaterial, "ANTIMATERIAL", { damage: 100, frequency: 95, vel: 32, vida: 36, disp: 0, ammo: 3, kick: 10, shake: 7, empuje: 8, zoom: true, atraviesa: 2, ammoType: "sniper", mz: "bazooka", reloadTime: _rs * 2.5, snd: snd_antimaterial, tono: 1, vol: 1, peso: 1 }),
		// --- LANZACOHETES ---
		__arma("g_rpg",      spr_arma_rpg,        "RPG",            { damage: 60, frequency: 85, vel: 4, vida: 160, disp: 0, ammo: 2, kick: 9, shake: 6, empuje: 6, cohete: true, ammoType: "heavy", mz: "bazooka", reloadTime: _rs * 2.5, snd: snd_rpg, tono: 1, vol: 1, peso: 1 })
	];
}

/// Busca una de las armas nuevas por su nombre interno (type2).
function __arma_nueva(_tipo) {
	for (var i = 0; i < array_length(global.armas_nuevas); i++) {
		if (global.armas_nuevas[i].type2 == _tipo) return global.armas_nuevas[i];
	}
	return oBrain.weapon_struct_pistola;
}

/// Una arma al azar para los puntos de armas (en línea y en local). Devuelve una COPIA, nunca la original.
///   _nivel 1 = pistolas y subfusiles (junto a las bases)
///   _nivel 2 = rifles y escopetas (los pasillos)
///   _nivel 3 = las fuertes (arriba al centro)
///   _nivel 0 = de todo (los mapas que no tienen niveles marcados)
/// El número junto a cada arma es qué tan seguido sale dentro de su grupo.
function scr_arma_al_azar(_nivel = 0) {
	if (!variable_global_exists("armas_nuevas")) scr_armas_init();
	var _b = oBrain;
	var _ops;
	switch (_nivel) {
		case 1: _ops = [
			[_b.weapon_struct_pistola, 3], [_b.weapon_struct_smg, 3], [_b.weapon_struct_box, 2],
			[__arma_nueva("g_luger"), 3], [__arma_nueva("g_glock"), 3], [__arma_nueva("g_silen"), 2],
			[__arma_nueva("g_uzi"), 3], [__arma_nueva("g_mp5"), 3], [__arma_nueva("g_mp5s"), 2],
			[__arma_nueva("g_mp40"), 3], [__arma_nueva("g_thompson"), 2]
		]; break;
		case 2: _ops = [
			[_b.weapon_struct_m4, 3], [_b.weapon_struct_escopeta, 3],
			[__arma_nueva("g_carabina"), 3], [__arma_nueva("g_ak47"), 3], [__arma_nueva("g_g36"), 3],
			[__arma_nueva("g_scar"), 2], [__arma_nueva("g_fal"), 2], [__arma_nueva("g_recortada"), 2],
			[__arma_nueva("g_deagle"), 1], [__arma_nueva("g_revolver"), 1], [_b.weapon_struct_mina, 2]
		]; break;
		case 3: _ops = [
			[__arma_nueva("g_rpg"), 3], [_b.weapon_struct_bazooka, 3], [_b.weapon_struct_rail, 3],
			[__arma_nueva("g_franco"), 2], [__arma_nueva("g_antimat"), 1]
		]; break;
		default:
			_ops = [
				[_b.weapon_struct_pistola, 3], [_b.weapon_struct_escopeta, 3], [_b.weapon_struct_smg, 3],
				[_b.weapon_struct_bazooka, 3], [_b.weapon_struct_box, 3], [_b.weapon_struct_m4, 3],
				[_b.weapon_struct_rail, 2], [_b.weapon_struct_mina, 2]
			];
			for (var i = 0; i < array_length(global.armas_nuevas); i++) array_push(_ops, [global.armas_nuevas[i], global.armas_nuevas[i].peso]);
		break;
	}
	return variable_clone(__al_azar_con_peso(_ops, _b.weapon_struct_pistola));
}

/// Elige de una lista [[cosa, peso], ...]. Más peso = sale más seguido.
function __al_azar_con_peso(_ops, _si_falla) {
	var _tot = 0;
	for (var i = 0; i < array_length(_ops); i++) _tot += _ops[i][1];
	var _r = random(_tot);
	for (var i = 0; i < array_length(_ops); i++) {
		_r -= _ops[i][1];
		if (_r < 0) return _ops[i][0];
	}
	return _si_falla;
}

/// Poder al azar. _nivel 1 = los de la base, 2 = los del centro, 0 = todos.
function scr_poder_al_azar(_nivel = 0) {
	var _ops;
	switch (_nivel) {
		case 1:  _ops = [["heal", 3], ["speed", 2]]; break;
		case 2:  _ops = [["shield", 2], ["damage", 1], ["ammo", 2]]; break;
		default: _ops = [["heal", 3], ["speed", 2], ["shield", 2], ["damage", 1], ["ammo", 2]]; break;
	}
	return __al_azar_con_peso(_ops, "heal");
}

/// Cuánto tarda en volver a salir algo en un punto (en frames), con ±20% para que no sea predecible.
///   _tipo: "ammo" | "weapon" | "powerup"
function scr_spawn_frames(_tipo, _nivel = 0) {
	var _seg = 12;
	if (_tipo == "ammo") _seg = 8;
	else if (_tipo == "powerup") _seg = 18;
	else if (_tipo == "weapon") {
		switch (_nivel) {
			case 1: _seg = 10; break;
			case 2: _seg = 15; break;
			case 3: _seg = 25; break;
			default: _seg = 12; break;
		}
	}
	return round(_seg * random_range(0.8, 1.2) * game_get_speed(gamespeed_fps));
}

/// Primera espera de las armas fuertes (arriba al centro): 20 segundos.
function scr_spawn_primera_espera() { return 20 * game_get_speed(gamespeed_fps); }

/// Nombre bonito de un arma para el aviso.
function scr_arma_nombre(_w) {
	if (!is_struct(_w)) return "ARMA";
	if (variable_struct_exists(_w, "nombre")) return _w.nombre;
	switch (_w.type2) {
		case "bazooka": return "BAZOOKA";
		case "rail":    return "RAILGUN";
	}
	return string_upper(string(_w.type2));
}

/// Color del anillo según lo que sale en el punto.
function scr_spawn_color(_tipo, _nivel) {
	if (_tipo == "powerup") return make_color_rgb(215, 124, 255);
	if (_tipo == "ammo") return make_color_rgb(201, 195, 230);
	switch (_nivel) {
		case 1: return make_color_rgb(94, 224, 138);
		case 2: return make_color_rgb(63, 176, 255);
		case 3: return make_color_rgb(255, 138, 61);
	}
	return c_white;
}

/// Anillo en el piso que se va llenando mientras vuelve a salir algo.
/// _t = frames que faltan, _max = frames totales.
function scr_spawn_anillo(_x, _y, _t, _max, _col, _grande) {
	if (_t <= 0 || _max <= 0) return;
	var _r = _grande ? 16 : 12;
	var _p = clamp(1 - _t / _max, 0, 1);
	var _a = draw_get_alpha();
	draw_set_alpha(0.35);
	draw_set_colour(c_black);
	draw_circle(_x, _y, _r + 2, false);
	draw_set_alpha(0.3);
	draw_set_colour(_col);
	draw_circle(_x, _y, _r, true);
	draw_set_alpha(0.9);
	var _n = max(2, ceil(32 * _p));
	var _px = _x, _py = _y - _r;
	for (var i = 1; i <= _n; i++) {
		var _ang = 90 - 360 * _p * (i / _n);
		var _nx = _x + lengthdir_x(_r, _ang), _ny = _y + lengthdir_y(_r, _ang);
		draw_line_width(_px, _py, _nx, _ny, 2);
		_px = _nx; _py = _ny;
	}
	draw_set_alpha(_a);
	draw_set_colour(c_white);
}

/// ¿El arma en la mano es una de las nuevas?
function scr_arma_es_generica(_w) {
	return is_struct(_w) && variable_struct_exists(_w, "generica") && _w.generica;
}

/// La Thompson pesa: caminas un poco más lento con ella.
function scr_arma_peso_mult() {
	var _w = guns[weapon.index];
	if (scr_arma_es_generica(_w) && _w.lento) return 0.85;
	return 1;
}

/// Disparo de las armas nuevas. Lo llaman scrPlayerWeaponUpdate y _offline.
function scr_arma_generica_update() {
	var _w = guns[weapon.index];
	if (!variable_instance_exists(id, "rafaga_quedan")) { rafaga_quedan = 0; rafaga_t = 0; }

	// Ráfaga en curso (SCAR): una bala cada 4 frames
	if (rafaga_quedan > 0) {
		rafaga_t -= 1;
		if (rafaga_t <= 0) {
			if (_w.ammo > 0) { scr_arma_generica_tiro(_w); rafaga_quedan -= 1; rafaga_t = 4; }
			else rafaga_quedan = 0;
		}
		return;
	}

	if (!vmouse(mb_left) || weapon.frequency > 0) return;

	if (_w.ammo <= 0) {
		if (empty_cd <= 0) { if (global.sfx) audio_play_sound(snd_empy, 1, false); empty_cd = 10; }
		scrReloadWeapon();
		weapon.frequency = 3;
		return;
	}

	weapon.frequency = _w.frequency;
	scr_arma_generica_tiro(_w);
	if (_w.rafaga > 1) { rafaga_quedan = _w.rafaga - 1; rafaga_t = 4; }
}

/// Un tiro (con todas sus balas, si es escopeta)
function scr_arma_generica_tiro(_w) {
	var _ang = weapon.angle;
	var _p = scr_arma_punta(22 + sprite_get_width(_w.sprite));   // la punta del cañón según lo largo del arma
	var _bx = _p[0], _by = _p[1];
	var _base = point_direction(_bx, _by, aim_x(), aim_y());

	if (_w.rec > 0) ak_recoil = clamp(ak_recoil + _w.rec, 0, _w.rec_max);

	for (var i = 0; i < _w.balas; i++) {
		var _d = _base;
		if (_w.balas > 1) {
			var _tt = i / (_w.balas - 1);
			_d += lerp(-_w.disp * 0.5, _w.disp * 0.5, _tt) + random_range(-3, 3);
		} else {
			_d += random_range(-_w.disp, _w.disp);
			if (_w.rec > 0) _d -= ak_recoil * random_range(0.4, 0.7);
		}

		var _b = instance_create_layer(_bx, _by, "Instances", global.ONLINE ? oMyEntity : oPlayer_bullet);
		_b.owner_name = global.myName;
		_b.owner_team = global.myTeam;
		_b.owner_id = id;
		_b.direction = _d;
		_b.image_angle = _d;
		_b.speed = _w.vel * ((_w.balas > 1) ? random_range(0.9, 1.1) : 1);
		_b.life = _w.vida - ((_w.balas > 1) ? irandom(4) : 0);
		_b.damage = _w.damage * damage_boost;
		_b.sprite_index = _w.silenciada ? spr_bala_silenciada : ((_w.balas > 1) ? sprBullet_escop : sprBullet_smg);
		if (!global.ONLINE) _b.team = team;
		if (_w.atraviesa > 1) _b.atraviesa = _w.atraviesa;
		if (_w.cohete) {
			_b.is_rocket = true;
			_b.sprite_index = sprBullet_bazooka;
			_b.acel = 1.06;          // el cohete sale lento y acelera
			_b.vel_max = 16;
			if (!global.ONLINE) _b.damage_rocket = _w.damage * damage_boost;
		}
		if (damage_boost > 1) _b.image_blend = c_red;
	}

	// Destello y efecto para los demás (las silenciadas no tienen)
	if (!_w.silenciada) {
		var _f = instance_create_layer(_bx, _by, "Instances", oMuzzleFlash);
		_f.sprite_index = (_w.mz == "escop" || _w.mz == "bazooka") ? sprMuzzle_escop : ((_w.mz == "smg") ? sprMuzzle_smg : sprMuzzle_gun);
		_f.image_angle = _ang;
		if (_w.mz == "bazooka") _f.image_xscale = 2;
		if (global.ONLINE && instance_exists(oOtherPlayer)) {
			var _m = { x: _bx, y: _by, ang: _ang, muzzle: _w.mz, snd: audio_get_name(_w.snd), vol: _w.vol, tono: _w.tono };   // el sonido, para que los demas lo oigan
			with (oOtherPlayer) SendEventToClient(clientId, "fx_shot", _m);
		}
	}

	scrCamShake(_w.shake);
	recoil_kick += _w.kick;
	recoil_angle += random_range(-1, 1) * (_w.kick / 3);
	if (_w.empuje > 0) push_h = -lengthdir_x(_w.empuje * 2, _ang);

	if (global.sfx) audio_play_sound(_w.snd, 1, false, _w.vol, 0, _w.tono * random_range(0.97, 1.03));

	if (!infinite_ammo) _w.ammo -= 1;
	guns[weapon.index] = _w;
	if (_w.ammo <= 0) scrReloadWeapon();
}
