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
		snd: snd_gun, tono: 1, vol: 1, peso: 2,  // peso = qué tan seguido sale en el mapa
		efecto: "", tinte: c_white, grav: 0, escala: 1,  // armas con efecto (zap, hielo, red, iman)
		giro: 0, pesada: 1                               // ametralladora: frames que gira antes de disparar / que tan lento caminas
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
		__arma("g_rpg",      spr_arma_rpg,        "RPG",            { damage: 60, frequency: 85, vel: 4, vida: 160, disp: 0, ammo: 2, kick: 9, shake: 6, empuje: 6, cohete: true, ammoType: "heavy", mz: "bazooka", reloadTime: _rs * 2.5, snd: snd_rpg, tono: 1, vol: 1, peso: 1 }),
		// --- CON EFECTO (tumban la bandera). Pocos usos y lentas para que no sean injustas ---
		__arma("g_zap",      spr_arma_luger,      "ZAP",            { damage: 12, frequency: 150, vel: 6,  vida: 70, disp: 0, ammo: 4,  kick: 4, shake: 2, efecto: "zap",   tinte: make_color_rgb(120, 225, 255), escala: 1.6, ammoType: "heavy", snd: snd_gun, tono: 1.8, vol: 0.7, peso: 2 }),
		__arma("g_hielo",    spr_arma_uzi,        "CONGELADOR",     { damage: 8,  frequency: 14,  vel: 13, vida: 24, disp: 2, ammo: 12, kick: 2, shake: 1, efecto: "hielo", tinte: make_color_rgb(190, 235, 255), ammoType: "heavy", mz: "smg", snd: snd_smg, tono: 1.6, vol: 0.6, peso: 2 }),
		__arma("g_red",      spr_arma_recortada,  "LANZARREDES",    { damage: 5,  frequency: 80,  vel: 9,  vida: 90, disp: 0, ammo: 2,  kick: 5, shake: 2, efecto: "red",   tinte: make_color_rgb(235, 228, 205), grav: 0.32, escala: 1.5, ammoType: "heavy", mz: "escop", snd: snd_escop, tono: 1.4, vol: 0.6, peso: 2 }),
		__arma("g_iman",     spr_arma_deagle,     "IMAN",           { damage: 6,  frequency: 60,  vel: 22, vida: 11, disp: 0, ammo: 3,  kick: 4, shake: 2, efecto: "iman",  tinte: make_color_rgb(255, 90, 150), ammoType: "heavy", snd: snd_M4, tono: 1.9, vol: 0.6, peso: 2 }),
		// --- NUEVAS 2 (ver ARMAS NUEVAS 2 abajo) ---
		__arma("g_machete",  spr_arma_silenciada, "MACHETE",        { damage: 35, frequency: 28, ammo: 999, efecto: "machete", tinte: make_color_rgb(205, 215, 225), ammoType: "", kick: 0, shake: 2, snd: snd_melee, peso: 2 }),
		__arma("g_bomba_e",  spr_granada,         "GRANADA ELECTRICA", { damage: 10, frequency: 45, vel: 9, vida: 120, ammo: 2, efecto: "bomba_elec", grav: 0.3, silenciada: true, tinte: make_color_rgb(120, 225, 255), ammoType: "heavy", kick: 2, shake: 1, snd: snd_melee, tono: 1.3, vol: 0.6, peso: 2 }),
		__arma("g_bomba_l",  spr_granada,         "GRANADA CEGADORA", { damage: 0, frequency: 45, vel: 9, vida: 120, ammo: 2, efecto: "bomba_luz", grav: 0.3, silenciada: true, tinte: make_color_rgb(255, 250, 200), ammoType: "heavy", kick: 2, shake: 1, snd: snd_melee, tono: 1.5, vol: 0.6, peso: 2 }),
		__arma("g_fuego",    spr_arma_rpg,        "LANZALLAMAS",    { damage: 3, frequency: 3, vel: 6, vida: 18, disp: 14, balas: 2, ammo: 100, efecto: "fuego", tinte: make_color_rgb(255, 140, 30), ammoType: "heavy", kick: 0, shake: 0.3, mz: "smg", snd: snd_smg, tono: 0.5, vol: 0.2, peso: 2 }),
		__arma("g_minigun",  spr_arma_thompson,   "AMETRALLADORA",  { damage: 9, frequency: 3, vel: 18, vida: 40, disp: 4, ammo: 100, rec: 0.5, rec_max: 8, kick: 2, shake: 0.6, giro: 30, pesada: 0.75, tinte: make_color_rgb(150, 150, 165), ammoType: "smg", mz: "smg", snd: snd_smg, tono: 0.7, vol: 0.6, reloadTime: _rs * 3, peso: 2 })
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
	if (EQ_MAPA_SOLO_FUERTES) _nivel = 3;   // con EQUIPAMIENTO en el mapa solo salen las fuertes
	var _b = oBrain;
	var _ops;
	switch (_nivel) {
		case 1: _ops = [
			[_b.weapon_struct_pistola, 3], [_b.weapon_struct_smg, 3], [_b.weapon_struct_box, 2],
			[__arma_nueva("g_luger"), 3], [__arma_nueva("g_glock"), 3], [__arma_nueva("g_silen"), 2],
			[__arma_nueva("g_uzi"), 3], [__arma_nueva("g_mp5"), 3], [__arma_nueva("g_mp5s"), 2],
			[__arma_nueva("g_mp40"), 3], [__arma_nueva("g_thompson"), 2]
		];
		if (global.ONLINE) array_push(_ops, [__arma_nueva("g_machete"), 2]);   // machete solo en linea
		break;
		case 2: _ops = [
			[_b.weapon_struct_m4, 3], [_b.weapon_struct_escopeta, 3],
			[__arma_nueva("g_carabina"), 3], [__arma_nueva("g_ak47"), 3], [__arma_nueva("g_g36"), 3],
			[__arma_nueva("g_scar"), 2], [__arma_nueva("g_fal"), 2], [__arma_nueva("g_recortada"), 2],
			[__arma_nueva("g_deagle"), 1], [__arma_nueva("g_revolver"), 1], [_b.weapon_struct_mina, 2]
		];
		// Las granadas electrica y cegadora ya no son armas: salen en los packs de granadas (scr_armas, GRANADAS)
		if (global.ONLINE) array_push(_ops, [__arma_nueva("g_fuego"), 2]);
		break;
		case 3: _ops = [
			[__arma_nueva("g_rpg"), 3], [_b.weapon_struct_bazooka, 3], [_b.weapon_struct_rail, 3],
			[__arma_nueva("g_franco"), 2], [__arma_nueva("g_antimat"), 1]
		];
		// Las de efecto solo en linea (el modo practica sin internet no las sabe usar)
		if (global.ONLINE) array_push(_ops, [__arma_nueva("g_zap"), 2], [__arma_nueva("g_hielo"), 2], [__arma_nueva("g_red"), 2], [__arma_nueva("g_iman"), 2]);
		array_push(_ops, [__arma_nueva("g_minigun"), 2]);   // ametralladora: en todos lados
		break;
		default:
			_ops = [
				[_b.weapon_struct_pistola, 3], [_b.weapon_struct_escopeta, 3], [_b.weapon_struct_smg, 3],
				[_b.weapon_struct_bazooka, 3], [_b.weapon_struct_box, 3], [_b.weapon_struct_m4, 3],
				[_b.weapon_struct_rail, 2], [_b.weapon_struct_mina, 2]
			];
			for (var i = 0; i < array_length(global.armas_nuevas); i++) {
				if (global.armas_nuevas[i].efecto != "" && !global.ONLINE) continue;   // las de efecto solo en linea
				if (scr_efx_es_bomba(global.armas_nuevas[i].efecto)) continue;       // las granadas salen en los packs
				array_push(_ops, [global.armas_nuevas[i], global.armas_nuevas[i].peso]);
			}
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
	if (!scr_arma_es_generica(_w)) return 1;
	var _m = _w.lento ? 0.85 : 1;
	if (variable_struct_exists(_w, "pesada")) _m *= _w.pesada;   // la ametralladora pesa mas
	return _m;
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

	// Ametralladora: el canon gira un ratito antes de disparar
	if (variable_struct_exists(_w, "giro") && _w.giro > 0) {
		if (!variable_instance_exists(id, "giro_t")) giro_t = 0;
		if (vmouse(mb_left)) { if (giro_t < _w.giro) { giro_t++; return; } }
		else giro_t = 0;
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
	// Machete: no dispara, golpea en arco (ARMAS NUEVAS 2)
	if (variable_struct_exists(_w, "efecto") && _w.efecto == "machete") { scr_machete_golpe(_w); return; }
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
		_b.damage = _w.damage * damage_boost + scr_pj_bono_auto(_w);   // pasiva del Asalto (scr_personajes)
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
		// Armas con efecto: la bala lleva su efecto, la red cae en arco y el zap es mas grande
		if (variable_struct_exists(_w, "efecto") && _w.efecto != "") {
			_b.efecto = _w.efecto;
			if (_w.grav > 0) { _b.gravity = _w.grav; _b.gravity_direction = 270; }
			if (_w.escala != 1) { _b.image_xscale = _w.escala; _b.image_yscale = _w.escala; }
		}
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

// ======================================================
// ARMAS CON EFECTOS: ZAP, CONGELADOR, LANZARREDES, IMAN
// Si le pegan al que lleva la bandera, se le cae (menos en los 1.5 s despues de agarrarla).
// Los dibujos son con codigo (no hay sprites nuevos). Solo salen en linea (salas, partida rapida).
//   1 ZAP: bolita electrica lenta, aturde 1 s (no se mueve ni dispara), brillo celeste.
//   2 CONGELADOR: cada golpe lo hace mas lento; al 3er golpe queda congelado 1 s.
//   3 LANZARREDES: red en arco; atrapado 1.2 s (no se mueve, si dispara).
//   4 IMAN: rayo corto que lo jala hacia ti; la bandera cae a tus pies.
// Codigos que viajan por la red (_EF): 0 nada, 1 aturdido, 2 lento, 3 congelado, 4 atrapado.
// ======================================================
#macro EFX_ZAP_T      60     // frames aturdido por el zap
#macro EFX_CONGELA_T  60     // frames congelado (3er golpe de hielo)
#macro EFX_HIELO_T    150    // cuanto dura lo lento si no le vuelven a pegar
#macro EFX_HIELO_LENTO 0.22  // cada golpe de hielo le quita esto de velocidad
#macro EFX_RED_T      72     // frames atrapado en la red
#macro EFX_INMUNE     90     // 1.5 s despues de agarrar la bandera no te la pueden tumbar
#macro EFX_IMAN_FUERZA 16    // que tan fuerte jala el iman
#macro EFX_COL_ZAP    make_color_rgb(120, 225, 255)
#macro EFX_COL_HIELO  make_color_rgb(190, 235, 255)
#macro EFX_COL_RED    make_color_rgb(235, 228, 205)
#macro EFX_COL_IMAN   make_color_rgb(255, 90, 150)

/// Color del arma (las de efecto vienen pintadas para que se distingan)
function scr_arma_tinte(_w) {
	if (is_struct(_w) && variable_struct_exists(_w, "tinte")) return _w.tinte;
	return c_white;
}

function scr_efx_init() {
	if (!variable_instance_exists(id, "efx_stun")) {
		efx_stun = 0;
		efx_stun_tipo = 0;
		efx_red = 0;
		efx_hielo_n = 0;
		efx_hielo_t = 0;
		efx_inm = 0;
		efx_tenia = false;
	}
}

/// Cada frame (jugador y bots): baja los tiempos y da la inmunidad al agarrar la bandera
function scr_efx_step() {
	scr_efx_init();
	scr_efx_init2();
	if (isDead) {
		efx_stun = 0; efx_red = 0; efx_hielo_n = 0; efx_hielo_t = 0; efx_inm = 0; efx_tenia = false;
		efx_fuego_t = 0; efx_ciego_t = 0;
		return;
	}
	if (efx_ciego_t > 0) efx_ciego_t--;
	if (efx_fuego_t > 0) {   // quemandose: dano poquito a poquito
		efx_fuego_t--;
		if (efx_fuego_t mod EFX_FUEGO_CADA == 0) scr_efx_quemar();
	}
	if (efx_stun > 0) efx_stun--;
	if (efx_red > 0) efx_red--;
	if (efx_hielo_t > 0) { efx_hielo_t--; if (efx_hielo_t <= 0) efx_hielo_n = 0; }
	if (has_flag && !efx_tenia) efx_inm = EFX_INMUNE;
	efx_tenia = has_flag;
	if (efx_inm > 0) efx_inm--;
}

function scr_efx_aturdido() { scr_efx_init(); return efx_stun > 0; }
function scr_efx_atrapado() { scr_efx_init(); return efx_stun > 0 || efx_red > 0; }

/// Cuanto camina (hielo lo hace lento)
function scr_efx_vel_mult() {
	scr_efx_init();
	return max(0.3, 1 - EFX_HIELO_LENTO * efx_hielo_n);
}

/// Aturdido o en la red: no camina ni salta (va despues de leer las teclas)
function scr_efx_controles() {
	if (!scr_efx_atrapado()) return;
	key_left = false;
	key_right = false;
	key_jump = false;
}

/// El codigo que ven los demas
function scr_efx_codigo() {
	scr_efx_init();
	if (efx_stun > 0) return efx_stun_tipo;
	if (efx_red > 0) return 4;
	scr_efx_init2();
	if (efx_fuego_t > 0) return 5;
	if (efx_hielo_n > 0) return 2;
	return 0;
}

/// Le pega un efecto. Devuelve { soltar, x, y }: si hay que tirar la bandera y donde.
/// _ax, _ay = donde esta el que disparo (para el iman).
function scr_efx_aplicar(_ef, _ax, _ay, _de = -1, _quien = "", _bot = false) {
	scr_efx_init();
	var _r = { soltar: false, x: x, y: y - 25 };
	var _tumba = false;
	switch (_ef) {
		case "zap":
			efx_stun = EFX_ZAP_T;
			efx_stun_tipo = 1;
			_tumba = true;
			if (global.sfx) audio_play_sound(snd_shield_impact, 20, false, 0.8, 0, 1.6);
		break;
		case "hielo":
			efx_hielo_n++;
			efx_hielo_t = EFX_HIELO_T;
			if (efx_hielo_n >= 3) {
				efx_hielo_n = 0;
				efx_hielo_t = 0;
				efx_stun = EFX_CONGELA_T;
				efx_stun_tipo = 3;
				_tumba = true;
				if (global.sfx) audio_play_sound(snd_shield_impact, 20, false, 0.8, 0, 0.7);
			}
		break;
		case "red":
			efx_red = EFX_RED_T;
			_tumba = true;
		break;
		case "red_hab":   // red de la Exploradora (scr_personajes): 2 s quieto
			efx_red = EXPLO_RED_T;
			_tumba = true;
		break;
		case "fuego":
			scr_efx_init2();
			efx_fuego_t = EFX_FUEGO_T;
			efx_fuego_de = _de;
			efx_fuego_quien = _quien;
			efx_fuego_bot = _bot;
		break;
		case "iman":
			var _d = point_direction(x, y, _ax, _ay);
			push_h = lengthdir_x(EFX_IMAN_FUERZA, _d);
			vsp = -3;
			_tumba = true;
			_r.x = _ax;
			_r.y = _ay - 20;
		break;
	}
	_r.soltar = _tumba && has_flag && efx_inm <= 0;
	return _r;
}

/// Tu jugador recibe el golpe con efecto (callback_ReceivedEvent, "hit")
function scr_efx_recibir_jugador(_m) {
	if (!is_struct(_m) || !variable_struct_exists(_m, "ef")) return;
	var _ef = string(_m.ef);
	if (_ef == "") return;
	var _ax = variable_struct_exists(_m, "ax") ? real(_m.ax) : x;
	var _ay = variable_struct_exists(_m, "ay") ? real(_m.ay) : y;
	var _de = variable_struct_exists(_m, "de") ? real(_m.de) : -1;
	var _qn = variable_struct_exists(_m, "killer") ? string(_m.killer) : "";
	var _bt = variable_struct_exists(_m, "bot") ? _m.bot : false;
	var _r = scr_efx_aplicar(_ef, _ax, _ay, _de, _qn, _bt);
	if (_r.soltar) scr_efx_soltar_jugador(_r.x, _r.y);
}

/// Se te cae la bandera por un efecto (igual que con el guante)
function scr_efx_soltar_jugador(_px, _py) {
	has_flag = false;
	var _obj_bandera = (global.myTeam == "AZUL") ? oFlag : oFlag2;
	with (_obj_bandera) {
		has_flag = false;
		portador_instancia = noone;
		x = _px;
		y = _py;
		velocidad_caida = -6;
	}
	with (oOtherPlayer) {
		if (es_bot) continue;
		SendEventToClient(clientId, "flag_dropped", { team: global.myTeam, dropX: _px, dropY: _py });
	}
	fb_toast("TE TUMBARON LA BANDERA", "Quedo en el suelo", FB_ORO);
}

/// Datos del efecto para el mensaje "hit" de una bala (oMyEntity)
function scr_efx_msg(_m) {
	if (!variable_instance_exists(id, "efecto") || efecto == "") return _m;
	_m.ef = efecto;
	var _o = (variable_instance_exists(id, "owner_id") && instance_exists(owner_id)) ? owner_id : id;
	_m.ax = round(_o.x);
	_m.ay = round(_o.y);
	_m.de = (variable_instance_exists(id, "bot_team") && variable_instance_exists(_o, "clientId")) ? _o.clientId : global.clientId;   // quien fue (para la quemadura)
	// Chispazo donde pego
	var _c = scr_efx_color(efecto);
	fx_light(x, y, 40, _c, 14);
	fx_sparks(x, y, direction + 180, 10, false);
	return _m;
}

function scr_efx_color(_ef) {
	switch (_ef) {
		case "zap":   return EFX_COL_ZAP;
		case "hielo": return EFX_COL_HIELO;
		case "red":   return EFX_COL_RED;
		case "red_hab": return EFX_COL_RED;
		case "iman":  return EFX_COL_IMAN;
		case "fuego": return EFX_COL_FUEGO;
		case "bomba_elec": return EFX_COL_ZAP;
		case "bomba_luz":  return c_white;
	}
	return c_white;
}

/// El codigo de efecto que hay que dibujar en un oOtherPlayer (bot del lider o lo que llego por la red)
function scr_efx_vis() {
	if (variable_instance_exists(id, "bot_local") && bot_local) return scr_efx_codigo();
	if (variable_instance_exists(id, "efx_vis")) return efx_vis;
	return 0;
}

/// El color del arma de un oOtherPlayer
function scr_efx_wti() {
	if (variable_instance_exists(id, "bot_local") && bot_local && variable_instance_exists(id, "bot_w") && is_struct(bot_w) && variable_struct_exists(bot_w, "tinte")) return bot_w.tinte;
	if (variable_instance_exists(id, "WTI")) return WTI;
	return c_white;
}

/// Rayitos alrededor de un rectangulo
function __efx_rayos(_x1, _y1, _x2, _y2, _n, _col) {
	draw_set_colour(_col);
	for (var i = 0; i < _n; i++) {
		var _px = random_range(_x1, _x2), _py = random_range(_y1, _y2);
		var _ang = random(360);
		for (var k = 0; k < 3; k++) {
			var _nx = _px + lengthdir_x(6, _ang + random_range(-50, 50));
			var _ny = _py + lengthdir_y(6, _ang + random_range(-50, 50));
			draw_line_width(_px, _py, _nx, _ny, 1.5);
			_px = _nx; _py = _ny;
		}
	}
}

/// Dibuja el efecto encima del personaje (va al final de su Draw)
function scr_efx_draw_cuerpo(_c) {
	if (_c <= 0 || !visible) return;
	var _x1 = bbox_left - 3, _y1 = bbox_top - 3, _x2 = bbox_right + 3, _y2 = bbox_bottom + 1;
	var _t = current_time / 1000;
	switch (_c) {
		case 1: // aturdido (zap)
			gpu_set_blendmode(bm_add);
			draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, EFX_COL_ZAP, 0.55 + 0.25 * sin(_t * 30));
			draw_set_alpha(0.9);
			__efx_rayos(_x1, _y1, _x2, _y2, 4, EFX_COL_ZAP);
			gpu_set_blendmode(bm_normal);
		break;
		case 2: // lento (hielo)
			gpu_set_blendmode(bm_add);
			draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, EFX_COL_HIELO, 0.35);
			gpu_set_blendmode(bm_normal);
			draw_set_alpha(0.8);
			draw_set_colour(EFX_COL_HIELO);
			for (var i = 0; i < 3; i++) {
				var _ax = x + sin(_t * 2 + i * 2.1) * 12, _ay = _y1 + ((_t * 20 + i * 11) mod (_y2 - _y1));
				draw_rectangle(_ax, _ay, _ax + 1, _ay + 1, false);
			}
		break;
		case 3: // congelado
			draw_set_alpha(0.45);
			draw_set_colour(EFX_COL_HIELO);
			draw_rectangle(_x1 - 2, _y1 - 2, _x2 + 2, _y2, false);
			draw_set_alpha(0.9);
			draw_set_colour(c_white);
			draw_rectangle(_x1 - 2, _y1 - 2, _x2 + 2, _y2, true);
			draw_line(_x1 + 2, _y1 + 4, _x1 + 7, _y1 + 12);
			draw_line(_x2 - 3, _y1 + 8, _x2 - 7, _y1 + 18);
		break;
		case 5: // quemandose
			gpu_set_blendmode(bm_add);
			draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, EFX_COL_FUEGO, 0.35 + 0.2 * sin(_t * 20));
			for (var i = 0; i < 4; i++) {
				var _fx = random_range(_x1, _x2), _fy = random_range(_y1, _y1 + (_y2 - _y1) * 0.6);
				draw_set_alpha(0.8);
				draw_set_colour(choose(EFX_COL_FUEGO, make_color_rgb(255, 210, 60)));
				draw_rectangle(_fx, _fy, _fx + 2, _fy + 3, false);
			}
			gpu_set_blendmode(bm_normal);
		break;
		case 4: // atrapado (red)
			draw_set_alpha(0.9);
			draw_set_colour(EFX_COL_RED);
			for (var _xx = _x1 - 2; _xx <= _x2 + 2; _xx += 6) draw_line(_xx, _y1 - 2, _xx + 2, _y2);
			for (var _yy = _y1 - 2; _yy <= _y2; _yy += 6) draw_line(_x1 - 2, _yy, _x2 + 2, _yy + 1);
		break;
	}
	draw_set_alpha(1);
	draw_set_colour(c_white);
}

/// Dibuja la bala de un arma con efecto (oMyEntity y oOtherPlayersEntity)
function scr_efx_bala_draw(_ef, _x, _y, _dir) {
	var _t = current_time / 1000;
	switch (_ef) {
		case "zap":
			gpu_set_blendmode(bm_add);
			draw_set_colour(EFX_COL_ZAP);
			draw_set_alpha(0.35);
			draw_circle(_x, _y, 11 + sin(_t * 25) * 2, false);
			draw_set_alpha(1);
			draw_circle(_x, _y, 5, false);
			__efx_rayos(_x - 8, _y - 8, _x + 8, _y + 8, 3, EFX_COL_ZAP);
			gpu_set_blendmode(bm_normal);
		break;
		case "hielo":
			draw_set_colour(EFX_COL_HIELO);
			draw_line_width(_x, _y, _x - lengthdir_x(10, _dir), _y - lengthdir_y(10, _dir), 3);
			draw_set_colour(c_white);
			draw_line_width(_x, _y, _x - lengthdir_x(5, _dir), _y - lengthdir_y(5, _dir), 1.5);
		break;
		case "red":
		case "red_hab":
			draw_set_colour(EFX_COL_RED);
			var _a = _t * 400;
			for (var i = -1; i <= 1; i++) {
				draw_line(_x + lengthdir_x(9, _a) + lengthdir_x(i * 5, _a + 90), _y + lengthdir_y(9, _a) + lengthdir_y(i * 5, _a + 90),
				          _x - lengthdir_x(9, _a) + lengthdir_x(i * 5, _a + 90), _y - lengthdir_y(9, _a) + lengthdir_y(i * 5, _a + 90));
				draw_line(_x + lengthdir_x(9, _a + 90) + lengthdir_x(i * 5, _a), _y + lengthdir_y(9, _a + 90) + lengthdir_y(i * 5, _a),
				          _x - lengthdir_x(9, _a + 90) + lengthdir_x(i * 5, _a), _y - lengthdir_y(9, _a + 90) + lengthdir_y(i * 5, _a));
			}
		break;
		case "fuego":
			gpu_set_blendmode(bm_add);
			draw_set_alpha(0.7);
			draw_set_colour(EFX_COL_FUEGO);
			draw_circle(_x, _y, 4 + random(3), false);
			draw_set_colour(make_color_rgb(255, 220, 80));
			draw_circle(_x, _y, 2, false);
			gpu_set_blendmode(bm_normal);
		break;
		case "bomba_elec":
		case "bomba_luz":
			draw_set_colour(c_black);
			draw_circle(_x, _y, 6, false);
			draw_set_colour((_ef == "bomba_elec") ? EFX_COL_ZAP : make_color_rgb(255, 250, 200));
			draw_circle(_x, _y, 5, false);
			draw_set_colour(c_white);
			draw_circle(_x + 2, _y - 2, 1.5, false);
			if (_ef == "bomba_elec") { gpu_set_blendmode(bm_add); __efx_rayos(_x - 6, _y - 6, _x + 6, _y + 6, 1, EFX_COL_ZAP); gpu_set_blendmode(bm_normal); }
		break;
		case "iman":
			gpu_set_blendmode(bm_add);
			draw_set_colour(EFX_COL_IMAN);
			var _px = _x, _py = _y;
			for (var k = 1; k <= 6; k++) {
				var _nx = _x - lengthdir_x(k * 6, _dir) + lengthdir_x(sin(_t * 40 + k) * 3, _dir + 90);
				var _ny = _y - lengthdir_y(k * 6, _dir) + lengthdir_y(sin(_t * 40 + k) * 3, _dir + 90);
				draw_set_alpha(1 - k / 7);
				draw_line_width(_px, _py, _nx, _ny, 3);
				_px = _nx; _py = _ny;
			}
			gpu_set_blendmode(bm_normal);
		break;
	}
	draw_set_alpha(1);
	draw_set_colour(c_white);
}

// ======================================================
// ARMAS NUEVAS 2: MACHETE, GRANADA ELECTRICA, GRANADA CEGADORA, LANZALLAMAS, AMETRALLADORA
//   MACHETE: golpe en arco con el doble de alcance que el punetazo (no gasta balas).
//   GRANADA ELECTRICA: se lanza en arco; al explotar aturde 1 s a los rivales cerca (como el Zap)
//                      y si llevan la bandera se les cae.
//   GRANADA CEGADORA: al explotar, a los rivales que la ven se les pone la pantalla blanca 2 s.
//   LANZALLAMAS: chorro corto; deja quemando 2 s (dano poquito a poquito).
//   AMETRALLADORA: 100 balas, pesada (caminas mas lento) y el canon gira un ratito antes de disparar.
// Las de efecto solo salen en linea (como las de antes). La ametralladora sale en todos lados.
// ======================================================
#macro EFX_MACHETE_ALC 64     // alcance del machete (el punetazo es 26)
#macro EFX_BOMBA_R     90     // radio de la granada electrica
#macro EFX_BOMBA_DANO  10
#macro EFX_LUZ_R       170    // radio de la granada cegadora
#macro EFX_CIEGO_T     120    // 2 s de pantalla blanca
#macro EFX_FUEGO_T     120    // 2 s quemandose
#macro EFX_FUEGO_CADA  20     // cada cuantos frames quema
#macro EFX_FUEGO_DANO  3
#macro EFX_COL_FUEGO   make_color_rgb(255, 140, 30)

function scr_efx_init2() {
	if (!variable_instance_exists(id, "efx_fuego_t")) {
		efx_fuego_t = 0;
		efx_fuego_de = -1;
		efx_fuego_quien = "";
		efx_fuego_bot = false;
		efx_ciego_t = 0;
	}
}

function scr_efx_ciego() { scr_efx_init2(); return efx_ciego_t > 0; }

/// Quemadura: un golpe chiquito que pasa por el mismo camino que una bala
function scr_efx_quemar() {
	var _m = { damage: EFX_FUEGO_DANO, killer: efx_fuego_quien, reason: "fuego", bot: efx_fuego_bot };
	if (object_index == oPlayer) callback_ReceivedEvent("hit", _m, efx_fuego_de);
	else if (variable_instance_exists(id, "bot_local") && bot_local) scr_botnet_dano(id, _m, efx_fuego_de);
}

/// Pantalla blanca de la granada cegadora (Draw GUI de oPlayer)
function scr_efx_draw_ciego() {
	scr_efx_init2();
	if (efx_ciego_t <= 0) return;
	draw_set_alpha(min(1, efx_ciego_t / 60) * 0.95);
	draw_set_colour(c_white);
	draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
	draw_set_alpha(1);
}

// ------------------------------------------------------
// MACHETE
// ------------------------------------------------------
function scr_machete_golpe(_w) {
	var _dir = (lengthdir_x(1, weapon.angle) >= 0) ? 1 : -1;
	var _fxx = x + _dir * 34, _fxy = y - 14;
	var _fx = instance_create_layer(_fxx, _fxy, "Instances", oMeleeFX);
	_fx.image_xscale = _dir * 2.2;
	_fx.image_yscale = 2.2;
	_fx.depth = depth - 10;
	if (global.sfx) audio_play_sound(snd_melee, 1, false, 1, 0, 0.8);
	with (oOtherPlayer) if (!es_bot) SendEventToClient(clientId, "fx_machete", { x: round(_fxx), y: round(_fxy), dir: _dir });

	var _px = x, _py = y, _mi = global.myTeam;
	var _dmg = _w.damage * damage_boost;
	var _hits = [];
	with (oOtherPlayer) {
		if (team == _mi || isDead || state == PLAYERSTATE.DEAD || invulnerable || !visible) continue;
		var _dx = (x - _px) * _dir;
		if (_dx < -10 || _dx > EFX_MACHETE_ALC) continue;
		if (abs(y - _py) > 44) continue;
		array_push(_hits, id);
	}
	for (var i = 0; i < array_length(_hits); i++) {
		var _t = _hits[i];
		if (_t.has_shield) {
			instance_create_layer(_t.x, _t.y - 16, "Instances", oShieldSparkFX);
			if (global.sfx) audio_play_sound(snd_shield_impact, 20, false, 2.0);
			continue;
		}
		fx_damage_number(_t.x, _t.bbox_top - 8, _dmg, 0);
		fx_impact_net(_t.x, _t.y - 20, (_dir > 0) ? 180 : 0, 6, false);
		scr_predict_hit(_t, _dmg, 10);
		scr_hit_confirm(_t, false, true);
		SendEventToClient(_t.clientId, "hit", { damage: _dmg, killer: global.myName, reason: "pvp", angle: (_dir > 0) ? 0 : 180 });
	}
	scrCamShake(_w.shake);
}

/// Efecto del machete de otro jugador (callback "fx_machete")
function scr_machete_fx(_x, _y, _dir) {
	var _fx = instance_create_layer(_x, _y, "Instances", oMeleeFX);
	_fx.image_xscale = _dir * 2.2;
	_fx.image_yscale = 2.2;
}

// ------------------------------------------------------
// GRANADAS (electrica y cegadora): van en arco y explotan al chocar o al pasar el tiempo
// ------------------------------------------------------
function scr_efx_es_bomba(_ef) { return _ef == "bomba_elec" || _ef == "bomba_luz"; }

/// Va al principio del Step de oMyEntity si la bala es una granada
function scr_efx_bomba_step() {
	var _eq = variable_instance_exists(id, "bot_team") ? bot_team : global.myTeam;
	var _boom = false;
	if (life > 0) { life--; if (life <= 0) _boom = true; }
	if (place_meeting(x, y, obj_wall)) _boom = true;
	if (vspeed > 0 && place_meeting(x, y, oPlataformaPasable)) _boom = true;
	var _t = instance_place(x, y, oOtherPlayer);
	if (_t != noone && _t.team != _eq && !_t.isDead) _boom = true;
	if (variable_instance_exists(id, "bot_team") && instance_exists(oPlayer)) {
		var _pl = instance_place(x, y, oPlayer);
		if (_pl != noone && _pl.team != _eq && !_pl.isDead) _boom = true;
	}
	if (y > room_height + 60) { instance_destroy(); return; }
	if (_boom) {
		scr_efx_bomba_explota(x, y, efecto, _eq);
		instance_destroy();
	}
}

/// Lo que se ve al explotar (en todas las pantallas)
function scr_efx_bomba_fx(_x, _y, _ef) {
	if (_ef == "bomba_elec") {
		fx_light(_x, _y, 130, EFX_COL_ZAP, 24);
		fx_sparks(_x, _y, 0, 14, false);
		if (global.sfx) audio_play_sound(snd_shield_impact, 20, false, 1, 0, 1.4);
		scrCamShake(4);
	} else {
		fx_light(_x, _y, 240, c_white, 30);
		fx_sparks(_x, _y, 0, 10, true);
		if (global.sfx) audio_play_sound(snd_pearl_explodes, 10, false, 0.6, 0, 1.6);
	}
}

function scr_efx_bomba_explota(_x, _y, _ef, _eq) {
	var _bot = variable_instance_exists(id, "bot_team");
	var _quien = _bot ? owner_name : global.myName;
	var _de = global.clientId;
	if (_bot) _de = (variable_instance_exists(id, "owner_id") && instance_exists(owner_id)) ? owner_id.clientId : BOTNET_ID_BASE;
	scr_efx_bomba_fx(_x, _y, _ef);
	with (oOtherPlayer) if (!es_bot) SendEventToClient(clientId, "fx_bomba", { x: round(_x), y: round(_y), t: _ef });

	// Rivales cerca
	var _l = [];
	with (oOtherPlayer) if (team != _eq && !isDead && visible) array_push(_l, id);
	if (instance_exists(oPlayer)) with (oPlayer) if (team != _eq && !isDead) array_push(_l, id);
	for (var i = 0; i < array_length(_l); i++) {
		var _v = _l[i];
		var _d = point_distance(_x, _y, _v.x, _v.y - 16);
		if (_ef == "bomba_elec") {
			if (_d > EFX_BOMBA_R || _v.invulnerable) continue;
			var _m = { damage: EFX_BOMBA_DANO, killer: _quien, reason: "pvp", angle: point_direction(_x, _y, _v.x, _v.y),
			           bot: _bot, ef: "zap", ax: round(_x), ay: round(_y), de: _de };
			if (_v.object_index == oPlayer) {
				callback_ReceivedEvent("hit", _m, _de);
			} else {
				if (!_bot) {
					fx_damage_number(_v.x, _v.bbox_top - 8, EFX_BOMBA_DANO, 2);
					scr_predict_hit(_v, EFX_BOMBA_DANO, 10);
					scr_hit_confirm(_v, false, false);
				}
				SendEventToClient(_v.clientId, "hit", _m);
			}
		} else {
			if (_d > EFX_LUZ_R) continue;
			if (collision_line(_x, _y, _v.x, _v.y - 16, obj_wall, false, true) != noone) continue;   // detras de una pared no lo ve
			if (_v.object_index == oPlayer) {
				with (oPlayer) { scr_efx_init2(); efx_ciego_t = max(efx_ciego_t, EFX_CIEGO_T); }
			} else {
				SendEventToClient(_v.clientId, "cegar", { t: EFX_CIEGO_T });
			}
		}
	}
}

// ======================================================
// GRANADAS ELECTRICA Y CEGADORA COMO LA NORMAL
// Salen en los packs de granadas del piso (solo en linea). Llevas un solo tipo a la vez:
// si agarras un pack de otro tipo, te quedas con 3 de ese. Se lanzan con clic derecho / GRANADA.
//   granada_tipo (oPlayer): ""  = normal,  "bomba_elec" = electrica,  "bomba_luz" = cegadora
// ======================================================
#macro GRANADA_COL_ELEC make_color_rgb(120, 225, 255)
#macro GRANADA_COL_LUZ  make_color_rgb(255, 250, 200)

/// Color con que se pinta la granada / el pack de ese tipo
function scr_granada_col(_t) {
	if (_t == "bomba_elec") return GRANADA_COL_ELEC;
	if (_t == "bomba_luz") return GRANADA_COL_LUZ;
	return c_white;
}

/// Nombre para el aviso al agarrar el pack
function scr_granada_nombre(_t) {
	if (_t == "bomba_elec") return "GRANADAS ELECTRICAS";
	if (_t == "bomba_luz") return "GRANADAS CEGADORAS";
	return "GRANADAS";
}

/// El lider elige de que tipo es un pack de granadas (la mitad normales)
function scr_granada_tipo_azar() {
	if (!global.ONLINE) return "";
	var _r = random(100);
	if (_r < 50) return "";
	if (_r < 75) return "bomba_elec";
	return "bomba_luz";
}

/// Tu jugador lanza una granada electrica o cegadora (oPlayer Step, clic derecho). Mismo arco que la normal.
function scr_granada_lanzar_efecto(_tipo, _dir) {
	var _gx = x + lengthdir_x(15, _dir);
	var _gy = y - 16 + lengthdir_y(15, _dir);
	var _b = instance_create_layer(_gx, _gy, "Instances", oMyEntity);
	_b.owner_name = global.myName;
	_b.owner_team = global.myTeam;
	_b.owner_id = id;
	// Mismo arco que la granada normal: fuerza 8, un poquito hacia arriba y gravedad 0.22
	var _hx = lengthdir_x(8, _dir);
	var _vy = lengthdir_y(8, _dir) - 2;
	_b.direction = point_direction(0, 0, _hx, _vy);
	_b.image_angle = _b.direction;
	_b.speed = point_distance(0, 0, _hx, _vy);
	_b.gravity = 0.22;
	_b.gravity_direction = 270;
	_b.life = 150;
	_b.damage = (_tipo == "bomba_elec") ? EFX_BOMBA_DANO : 0;
	_b.sprite_index = spr_granada;
	_b.efecto = _tipo;
	_b.image_blend = scr_granada_col(_tipo);
}

// ======================================================
// SEGUNDA ARMA (solo en linea, tu jugador): llevas 2 armas.
//   guns[0] y guns[1]; weapon.index = la que traes en la mano.
//   Agarrar: si hay lugar vacio entra ahi y te la pones; si no, reemplaza la de la mano.
//   Cambiar: E o la rueda del mouse (Q es la habilidad); en el celular tocas el cuadro chico.
//   El cambio tarda un cuarto de segundo y cancela la recarga.
// ======================================================
#macro ARMA_CAMBIO_T 15   // frames sin poder disparar al cambiar (0.25 s)

function scr_slots_dos() {
	// En linea tu oPlayer; en local tu oPlayer_offline (para el EQUIPAMIENTO, scr_armas)
	return (global.ONLINE && object_index == oPlayer) || object_index == oPlayer_offline;
}

function scr_slot_init() {
	if (array_length(guns) < 2) guns[1] = noone;
}

/// Cambia a la otra arma (si tienes otra). Devuelve true si cambio.
function scr_arma_cambiar() {
	if (!scr_slots_dos()) return false;
	scr_slot_init();
	var _o = 1 - weapon.index;
	if (guns[_o] == noone) return false;
	weapon.index = _o;
	reloading = false;
	reload_timer = 0;
	weapon.frequency = max(weapon.frequency, ARMA_CAMBIO_T);
	if (variable_instance_exists(id, "rafaga_quedan")) rafaga_quedan = 0;
	if (variable_instance_exists(id, "giro_t")) giro_t = 0;
	if (variable_instance_exists(id, "rail_carga")) rail_carga = 0;
	if (global.sfx) audio_play_sound(snd_ammo_pickup, 5, false, 0.5, 0, 1.4);
	return true;
}

/// Va en el Step de oPlayer: E, rueda del mouse o tocar el cuadro chico
function scr_arma_cambio_step() {
	if (!scr_slots_dos() || isDead) return;
	var _c = vkey_pressed(ord("E")) || mouse_wheel_up() || mouse_wheel_down();
	if (!_c && touch_mode() && variable_instance_exists(id, "slot2_x1")) {
		for (var d = 0; d < 5; d++) {
			if (!device_mouse_check_button_pressed(d, mb_left)) continue;
			if (point_in_rectangle(device_mouse_x_to_gui(d), device_mouse_y_to_gui(d), slot2_x1, slot2_y1, slot2_x2, slot2_y2)) _c = true;
		}
	}
	if (_c) scr_arma_cambiar();
}

/// En que lugar entra un arma nueva
function scr_slot_para_nueva() {
	if (!scr_slots_dos()) return weapon.index;
	scr_slot_init();
	if (guns[weapon.index] == noone) return weapon.index;
	var _o = 1 - weapon.index;
	if (guns[_o] == noone) return _o;
	return weapon.index;
}

/// En que lugar ya tienes esa misma arma (-1 = en ninguno). Primero la de la mano.
function scr_slot_misma(_nueva) {
	if (!is_struct(_nueva)) return -1;
	var _l = [weapon.index];
	if (scr_slots_dos()) { scr_slot_init(); array_push(_l, 1 - weapon.index); }
	for (var i = 0; i < array_length(_l); i++) {
		var _g = guns[_l[i]];
		if (_g != noone && is_struct(_g) && string(_g.type2) == string(_nueva.type2)) return _l[i];
	}
	return -1;
}

/// Tope de balas guardadas por tipo (el mismo de Collision_oAmmoPack)
function scr_municion_tope(_t) {
	switch (_t) {
		case "gun":    return 120;
		case "smg":    return 240;
		case "escop":  return 180;
		case "shell":  return 40;
		case "sniper": return 15;
	}
	return 999;
}

/// A cual de tus 2 armas le sirve un pack de balas (primero la de la mano). noone = a ninguna.
function scr_arma_para_municion() {
	var _l = [weapon.index];
	if (scr_slots_dos()) { scr_slot_init(); array_push(_l, 1 - weapon.index); }
	for (var i = 0; i < array_length(_l); i++) {
		var _g = guns[_l[i]];
		if (_g == noone || !is_struct(_g)) continue;
		var _t = _g.ammoType;
		if (_t == "" || is_undefined(_t)) continue;
		var _cur = variable_struct_exists(reserve, _t) ? reserve[$ _t] : 0;
		if (_cur >= scr_municion_tope(_t)) continue;
		return _g;
	}
	return noone;
}

// ======================================================
// EQUIPAMIENTO (mezcla): antes de jugar eliges 2 armas (PRINCIPAL y SECUNDARIA).
//   - Se desbloquean por NIVEL y luego se COMPRAN con MONEDAS (las gratis ya son tuyas).
//   - Se MEJORAN hasta 3 estrellas: un poco mas de cargador y recarga mas rapida. El dano NUNCA sube.
//   - Las MONEDAS se ganan jugando (ganar, perder, empatar, contra bots y en local con bots).
//   - En el mapa ya solo salen granadas, municion y las armas fuertes (arriba al centro).
//   Todo se guarda en el aparato (data.ini) y en tu cuenta (Neon) como "equipo".
//   Sirve igual en linea y en local (sin internet).
// ======================================================
#macro EQ_MEJORA_MAX 3
#macro EQ_MAPA_SOLO_FUERTES true   // ponlo en false para que vuelvan a salir todas las armas en el mapa
#macro EQ_PRUEBA false             // PRUEBA: en la pantalla de equipamiento ALT = +1000 monedas y SUPR = borrar todo el equipamiento. Ponlo en false al terminar.

function __eq_item(_id, _nombre, _spr, _lv, _precio) {
	return { id: _id, nombre: _nombre, spr: _spr, lv: _lv, precio: _precio };
}

/// Lista de armas que se pueden equipar (en orden: nivel y precio)
function scr_eq_catalogo() {
	if (variable_global_exists("eq_cat") && is_array(global.eq_cat)) return global.eq_cat;
	global.eq_cat = [
		__eq_item("pistola",     "PISTOLA",        spr_gun,              1,  0),
		__eq_item("g_luger",     "LUGER",          spr_arma_luger,       1,  0),
		__eq_item("smg",         "SMG",            spr_smg,              1,  0),
		__eq_item("g_mp5",       "MP5",            spr_arma_mp5,         1,  0),
		__eq_item("g_glock",     "GLOCK 18",       spr_arma_glock,       3,  150),
		__eq_item("g_silen",     "SILENCIADA",     spr_arma_silenciada,  4,  200),
		__eq_item("g_uzi",       "UZI",            spr_arma_uzi,         5,  250),
		__eq_item("m4",          "M4",             spr_M4,               7,  400),
		__eq_item("g_mp5s",      "MP5 SILENCIADA", spr_arma_mp5s,        8,  450),
		__eq_item("g_mp40",      "MP40",           spr_arma_mp40,        9,  500),
		__eq_item("g_ak47",      "AK-47",          spr_arma_ak47,        10, 600),
		__eq_item("g_carabina",  "CARABINA",       spr_arma_carabina,    11, 650),
		__eq_item("escopeta",    "ESCOPETA",       spr_escopeta,         12, 700),
		__eq_item("g_g36",       "G36",            spr_arma_g36,         13, 750),
		__eq_item("g_recortada", "RECORTADA",      spr_arma_recortada,   14, 800),
		__eq_item("g_scar",      "SCAR",           spr_arma_scar,        15, 900),
		__eq_item("g_thompson",  "THOMPSON",       spr_arma_thompson,    16, 950),
		__eq_item("g_deagle",    "DESERT EAGLE",   spr_arma_deagle,      18, 1100),
		__eq_item("g_fal",       "FAL",            spr_arma_fal,         20, 1200),
		__eq_item("g_revolver",  "REVOLVER",       spr_arma_revolver,    22, 1300)
	];
	return global.eq_cat;
}

function scr_eq_info(_id) {
	var _c = scr_eq_catalogo();
	for (var i = 0; i < array_length(_c); i++) if (_c[i].id == _id) return _c[i];
	return undefined;
}

/// Lo que cuesta subir de _n estrellas a _n + 1
function scr_eq_costo_mejora(_n) {
	switch (_n) { case 0: return 200; case 1: return 400; }
	return 600;
}

/// ¿Ya es tuya? (las gratis siempre)
function __eq_tiene(_id) {
	var _it = scr_eq_info(_id);
	if (is_undefined(_it)) return false;
	if (_it.precio <= 0) return true;
	var _a = global.equipo.armas;
	for (var i = 0; i < array_length(_a); i++) if (_a[i] == _id) return true;
	return false;
}

function scr_eq_init() {
	if (!variable_global_exists("equipo") || !is_struct(global.equipo)) global.equipo = {};
	var _e = global.equipo;
	if (!variable_struct_exists(_e, "monedas")) _e.monedas = 0;
	if (!variable_struct_exists(_e, "armas") || !is_array(_e.armas)) _e.armas = [];
	if (!variable_struct_exists(_e, "mej") || !is_struct(_e.mej)) _e.mej = {};
	if (!variable_struct_exists(_e, "p")) _e.p = "smg";
	if (!variable_struct_exists(_e, "s")) _e.s = "pistola";
	_e.monedas = max(0, floor(real(_e.monedas)));
	if (!__eq_tiene(_e.p)) _e.p = "smg";
	if (!__eq_tiene(_e.s) || _e.s == _e.p) _e.s = (_e.p == "pistola") ? "smg" : "pistola";
}

function scr_eq_tiene(_id) { scr_eq_init(); return __eq_tiene(_id); }

function scr_eq_mejora(_id) {
	scr_eq_init();
	var _m = global.equipo.mej;
	if (!variable_struct_exists(_m, _id)) return 0;
	return clamp(floor(real(_m[$ _id])), 0, EQ_MEJORA_MAX);
}

/// Comprar (sin revisar mas: lo revisa quien lo llama). Guarda.
function scr_eq_comprar(_id) {
	scr_eq_init();
	var _it = scr_eq_info(_id);
	if (is_undefined(_it) || __eq_tiene(_id)) return false;
	if (global.lvl < _it.lv || global.equipo.monedas < _it.precio) return false;
	global.equipo.monedas -= _it.precio;
	array_push(global.equipo.armas, _id);
	scr_xp_dar(40);   // comprar un arma da XP (scr_reloj)
	scr_save_to_local();
	return true;
}

/// Subir una estrella. Guarda.
function scr_eq_mejorar(_id) {
	scr_eq_init();
	if (!__eq_tiene(_id)) return false;
	var _n = scr_eq_mejora(_id);
	if (_n >= EQ_MEJORA_MAX) return false;
	var _c = scr_eq_costo_mejora(_n);
	if (global.equipo.monedas < _c) return false;
	global.equipo.monedas -= _c;
	global.equipo.mej[$ _id] = _n + 1;
	scr_xp_dar((_n == 0) ? 30 : ((_n == 1) ? 50 : 80));   // mejorar da XP: 1, 2 y 3 estrellas (scr_reloj)
	scr_save_to_local();
	return true;
}

/// Ponerla en la casilla 0 (principal) o 1 (secundaria). Si estaba en la otra, se cambian. Guarda.
function scr_eq_equipar(_id, _slot) {
	scr_eq_init();
	if (!__eq_tiene(_id)) return false;
	var _e = global.equipo;
	if (_slot == 0) { if (_e.s == _id) _e.s = _e.p; _e.p = _id; }
	else            { if (_e.p == _id) _e.p = _e.s; _e.s = _id; }
	scr_save_to_local();
	return true;
}

/// Monedas ganadas (no guarda: quien lo llama guarda despues)
function scr_eq_premio(_n) {
	scr_eq_init();
	_n = floor(_n);
	if (_n <= 0) return;
	global.equipo.monedas += _n;
	fb_toast("+" + string(_n) + " MONEDAS", "Usalas en EQUIPMENT", make_color_rgb(255, 212, 71), "star");
}

/// Lo que viene de la cuenta: monedas de la cuenta, armas y mejoras se juntan (no se pierde nada)
function scr_eq_aplicar_cuenta(_q) {
	if (!is_struct(_q)) return;
	scr_eq_init();
	var _e = global.equipo;
	if (variable_struct_exists(_q, "monedas")) _e.monedas = max(0, floor(real(_q.monedas)));
	if (variable_struct_exists(_q, "armas") && is_array(_q.armas)) {
		for (var i = 0; i < array_length(_q.armas); i++) {
			var _id = string(_q.armas[i]);
			if (!is_undefined(scr_eq_info(_id)) && !__eq_tiene(_id)) array_push(_e.armas, _id);
		}
	}
	if (variable_struct_exists(_q, "mej") && is_struct(_q.mej)) {
		var _k = variable_struct_get_names(_q.mej);
		for (var j = 0; j < array_length(_k); j++) {
			if (is_undefined(scr_eq_info(_k[j]))) continue;
			_e.mej[$ _k[j]] = max(scr_eq_mejora(_k[j]), clamp(floor(real(_q.mej[$ _k[j]])), 0, EQ_MEJORA_MAX));
		}
	}
	if (variable_struct_exists(_q, "p") && __eq_tiene(string(_q.p))) _e.p = string(_q.p);
	if (variable_struct_exists(_q, "s") && __eq_tiene(string(_q.s))) _e.s = string(_q.s);
	scr_eq_init();
}

/// Las 4 armas de siempre por si oBrain todavia no existe (en el menu). Mismos numeros que oBrain.
function __eq_vieja(_id) {
	var _rs = room_speed;
	switch (_id) {
		case "pistola":  return { sprite_suelo: spr_gun, sprite: spr_gun, object: oGun, subimage: 0, ammo: 10, maxAmmo: 10, frequency: _rs / 2, type2: "gun", damage: 10, ammoType: "gun", clipSize: 30, reloadTime: _rs * 1.2, index: 0 };
		case "smg":      return { sprite_suelo: spr_smg, sprite: spr_smg, object: oGun, subimage: 0, ammo: 30, maxAmmo: 30, frequency: _rs / 8, type2: "smg", damage: 12, ammoType: "smg", clipSize: 30, reloadTime: _rs * 1.2, index: 0 };
		case "m4":       return { sprite_suelo: spr_M4, sprite: spr_M4, object: oGun, subimage: 0, ammo: 30, maxAmmo: 30, frequency: _rs / 10, type2: "m4", damage: 15, ammoType: "rifle", clipSize: 30, reloadTime: _rs * 1.5, index: 0 };
		case "escopeta": return { sprite_suelo: spr_escopeta, sprite: spr_escopeta, object: oGun, subimage: 0, ammo: 6, maxAmmo: 6, frequency: _rs / 1.2, type2: "escop", damage: 16, pellets: 7, ammoType: "escop", clipSize: 30, reloadTime: _rs * 1.2, index: 0 };
	}
	return undefined;
}

/// El arma original (sin copiar)
function scr_eq_base(_id) {
	if (instance_exists(oBrain)) {
		switch (_id) {
			case "pistola":  return oBrain.weapon_struct_pistola;
			case "smg":      return oBrain.weapon_struct_smg;
			case "m4":       return oBrain.weapon_struct_m4;
			case "escopeta": return oBrain.weapon_struct_escopeta;
		}
	}
	var _v = __eq_vieja(_id);
	if (!is_undefined(_v)) return _v;
	if (!variable_global_exists("armas_nuevas")) scr_armas_init();
	for (var i = 0; i < array_length(global.armas_nuevas); i++) if (global.armas_nuevas[i].type2 == _id) return global.armas_nuevas[i];
	return undefined;
}

/// COPIA del arma lista para usar, con tus mejoras. _con_mejora = false para los bots.
function scr_eq_arma(_id, _con_mejora = true) {
	var _b = scr_eq_base(_id);
	if (is_undefined(_b)) { _id = "pistola"; _b = scr_eq_base(_id); }
	var _w = variable_clone(_b);
	var _n = _con_mejora ? scr_eq_mejora(_id) : 0;
	if (!variable_struct_exists(_w, "reloadTime")) _w.reloadTime = room_speed * 1.2;
	if (_n > 0) {
		_w.maxAmmo += max(1, round(_w.maxAmmo * 0.1 * _n));   // +10% de cargador por estrella (minimo 1 bala)
		_w.reloadTime = round(_w.reloadTime * (1 - 0.08 * _n)); // -8% de recarga por estrella
	}
	_w.ammo = _w.maxAmmo;
	_w.equipada = true;   // las del equipamiento no se tiran al morir (scr_drop_on_death)
	_w.eq_id = _id;
	return _w;
}

/// Balas de reserva al aparecer: 2 cargadores (sin pasar el tope)
function scr_eq_reserva(_w) {
	if (!is_struct(_w)) return;
	var _t = _w.ammoType;
	if (_t == "" || is_undefined(_t)) return;
	var _cur = variable_struct_exists(reserve, _t) ? reserve[$ _t] : 0;
	reserve[$ _t] = max(_cur, min(_w.maxAmmo * 2, scr_municion_tope(_t)));
}

/// Tu jugador aparece con sus 2 armas (oPlayer y oPlayer_offline: Create y Alarm_1)
function scr_eq_dar() {
	scr_eq_init();
	if (array_length(guns) < 2) guns[1] = noone;
	// UN TIRO (scr_reloj): todos con el francotirador y nada mas
	if (scr_modo_tiro()) {
		var _fr = scr_eq_arma("g_franco", false);
		guns[0] = _fr;
		guns[1] = noone;
		weapon.index = 0;
		reloading = false;
		reload_timer = 0;
		reserve[$ _fr.ammoType] = scr_municion_tope(_fr.ammoType);
		return;
	}
	var _p = scr_eq_arma(global.equipo.p);
	var _s = scr_eq_arma(global.equipo.s);
	guns[0] = _p;
	guns[1] = _s;
	weapon.index = 0;
	reloading = false;
	reload_timer = 0;
	scr_eq_reserva(_p);
	scr_eq_reserva(_s);
}

/// Bot de local (oPlayer2_local): un arma de las de siempre al azar (sin mejoras)
function scr_eq_dar_bot_local() {
	var _ids = ["pistola", "smg", "m4", "escopeta"];
	var _w = scr_eq_arma(_ids[irandom(array_length(_ids) - 1)], false);
	guns[0] = _w;
	weapon.index = 0;
	reloading = false;
	reload_timer = 0;
	reserve[$ _w.ammoType] = _w.maxAmmo * 4;
}

/// Bot de sala (en linea): un arma del equipamiento al azar hasta nivel 12 (sin mejoras)
function scr_botnet_equipo_azar() {
	// UN TIRO (scr_reloj): los bots tambien con francotirador (balas sin fin)
	if (scr_modo_tiro()) {
		var _fw = scr_eq_arma("g_franco", false);
		bot_w_src = _fw;
		bot_w = scr_botnet_arma_datos(_fw);
		ammo = bot_w.max;
		bot_cargas = -1;
		reloading = false;
		bot_rafaga = 0;
		WSI = bot_w.spr;
		return;
	}
	var _c = scr_eq_catalogo();
	var _ops = [];
	for (var i = 0; i < array_length(_c); i++) if (_c[i].lv <= 12) array_push(_ops, _c[i].id);
	if (array_length(_ops) == 0) return;
	var _w = scr_eq_arma(_ops[irandom(array_length(_ops) - 1)], false);
	if (!scr_botnet_arma_sirve(_w)) return;
	bot_w_src = _w;
	bot_w = scr_botnet_arma_datos(_w);
	ammo = bot_w.max;
	bot_cargas = 4;    // al acabarse vuelve a la pistola (y puede agarrar las del mapa)
	reloading = false;
	bot_rafaga = 0;
	WSI = bot_w.spr;
}

/// Numeros para las barras (0 a 1): dano, cadencia, cargador, recarga
function scr_eq_stats(_id, _n) {
	var _b = scr_eq_base(_id);
	if (is_undefined(_b)) return [0, 0, 0, 0];
	var _bal = variable_struct_exists(_b, "balas") ? _b.balas : (variable_struct_exists(_b, "pellets") ? _b.pellets : 1);
	var _rt = variable_struct_exists(_b, "reloadTime") ? _b.reloadTime : room_speed * 1.2;
	var _car = _b.maxAmmo;
	if (_n > 0) { _car += max(1, round(_car * 0.1 * _n)); _rt *= (1 - 0.08 * _n); }
	var _fps = game_get_speed(gamespeed_fps);
	return [
		clamp(_b.damage * _bal / 60, 0.05, 1),
		clamp((_fps / max(1, _b.frequency)) / 15, 0.05, 1),
		clamp(_car / 50, 0.05, 1),
		clamp(1 - (_rt / _fps) / 3, 0.05, 1)
	];
}

// ------------------------------------------------------
// PANTALLA DE EQUIPAMIENTO (oMenu: menu_state == "equipo")
// Se dibuja en una "hoja" de 720x405 que se agranda a tu pantalla (PC, celular y HTML5).
// Teclado: W/S elegir, A/D casilla, ENTER comprar/equipar, M mejorar, ESC volver.
// ------------------------------------------------------
#macro EQ_FILA 33
#macro EQ_LISTA_Y 62
#macro EQ_LISTA_FIN 386

function scr_eq_abrir() {
	scr_eq_init();
	global.eq_ui = {
		sel: 0, slot: 0, scroll: 0, abierto_t: 0, drag: false, drag_y: 0,
		fx: "", fx_t: -1, fx_id: "", fx_n0: 0, fx_n1: 0, fx_costo: 0,
		mon_vis: global.equipo.monedas, msg: "", msg_t: 0, parts: [], S: 1, ox: 0, oy: 0
	};
	// Empieza en tu arma principal
	var _c = scr_eq_catalogo();
	for (var i = 0; i < array_length(_c); i++) if (_c[i].id == global.equipo.p) global.eq_ui.sel = i;
	__eq_ver_sel();
}

function __eq_geo() {
	var _q = global.eq_ui;
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	_q.S = min(_gw / 720, _gh / 405);
	_q.ox = (_gw - 720 * _q.S) / 2;
	_q.oy = (_gh - 405 * _q.S) / 2;
}
function __eq_x(_x) { return global.eq_ui.ox + _x * global.eq_ui.S; }
function __eq_y(_y) { return global.eq_ui.oy + _y * global.eq_ui.S; }

/// Que la elegida se vea en la lista
function __eq_ver_sel() {
	var _q = global.eq_ui;
	var _vis = EQ_LISTA_FIN - EQ_LISTA_Y;
	var _top = _q.sel * EQ_FILA;
	if (_top < _q.scroll) _q.scroll = _top;
	if (_top + EQ_FILA > _q.scroll + _vis) _q.scroll = _top + EQ_FILA - _vis;
	__eq_scroll_tope();
}
function __eq_scroll_tope() {
	var _q = global.eq_ui;
	var _max = max(0, array_length(scr_eq_catalogo()) * EQ_FILA - (EQ_LISTA_FIN - EQ_LISTA_Y));
	_q.scroll = clamp(_q.scroll, 0, _max);
}

/// Los botones del arma elegida: [{x1,y1,x2,y2,acc,txt,col,on}]
function __eq_botones() {
	var _q = global.eq_ui;
	var _cat0 = scr_eq_catalogo();
	var _it = _cat0[_q.sel];
	var _x1 = 292, _y1 = 172, _x2 = 686, _y2 = 285, _mid = (_x1 + _x2) / 2;
	var _oro = make_color_rgb(255, 212, 71), _verde = make_color_rgb(78, 220, 140), _azul = make_color_rgb(31, 155, 255);
	var _gris = make_color_rgb(70, 78, 100), _rojo = make_color_rgb(80, 40, 46);
	if (!scr_eq_tiene(_it.id)) {
		if (global.lvl < _it.lv) return [{ x1: _x1, y1: _y1, x2: _x2, y2: _y2, acc: "", txt: "SE ABRE EN NIVEL " + string(_it.lv), col: _rojo, on: false, tc: make_color_rgb(229, 72, 77) }];
		return [{ x1: _x1, y1: _y1, x2: _x2, y2: _y2, acc: "comprar", txt: "COMPRAR  -  " + string(_it.precio), col: _oro, on: true, tc: make_color_rgb(11, 15, 26) }];
	}
	var _n = scr_eq_mejora(_it.id);
	var _b1 = (_n >= EQ_MEJORA_MAX)
		? { x1: _x1, y1: _y1, x2: _mid - 6, y2: _y2, acc: "", txt: "MEJORA MAXIMA", col: _gris, on: false, tc: make_color_rgb(169, 180, 208) }
		: { x1: _x1, y1: _y1, x2: _mid - 6, y2: _y2, acc: "mejorar", txt: "MEJORAR - " + string(scr_eq_costo_mejora(_n)), col: _verde, on: true, tc: make_color_rgb(11, 15, 26) };
	var _ya = (_q.slot == 0) ? (global.equipo.p == _it.id) : (global.equipo.s == _it.id);
	var _b2 = _ya
		? { x1: _mid + 6, y1: _y1, x2: _x2, y2: _y2, acc: "", txt: "EQUIPADA", col: _gris, on: false, tc: make_color_rgb(169, 180, 208) }
		: { x1: _mid + 6, y1: _y1, x2: _x2, y2: _y2, acc: "equipar", txt: "EQUIPAR", col: _azul, on: true, tc: c_white };
	return [_b1, _b2];
}

function __eq_msg(_t) {
	global.eq_ui.msg = _t;
	global.eq_ui.msg_t = 100;
	if (global.sfx) audio_play_sound(snd_empy, 5, false, 0.6);
}

function __eq_chispas(_x, _y, _n, _cols) {
	var _q = global.eq_ui;
	repeat (_n) {
		var _a = random(360), _v = random_range(2, 6);
		array_push(_q.parts, { x: _x, y: _y, vx: lengthdir_x(_v, _a), vy: lengthdir_y(_v, _a) * 0.7 - 1, col: _cols[irandom(array_length(_cols) - 1)], s: random_range(2, 4.5), vida: irandom_range(40, 70), v0: 70 });
	}
}

function __eq_hacer(_acc) {
	var _q = global.eq_ui;
	var _cat0 = scr_eq_catalogo();
	var _it = _cat0[_q.sel];
	var _oro = make_color_rgb(255, 212, 71), _verde = make_color_rgb(78, 220, 140);
	switch (_acc) {
		case "comprar":
			if (global.lvl < _it.lv) { __eq_msg("NECESITAS NIVEL " + string(_it.lv)); break; }
			if (global.equipo.monedas < _it.precio) { __eq_msg("TE FALTAN " + string(_it.precio - global.equipo.monedas) + " MONEDAS"); break; }
			if (scr_eq_comprar(_it.id)) {
				_q.fx = "compra"; _q.fx_t = 0; _q.fx_id = _it.id; _q.fx_costo = _it.precio;
				__eq_chispas(377, 126, 40, [_oro, c_white, make_color_rgb(255, 240, 170)]);
				if (global.sfx) audio_play_sound(snd_levelup, 5, false, 0.8, 0, 1.2);
			}
		break;
		case "mejorar":
			var _n = scr_eq_mejora(_it.id);
			if (_n >= EQ_MEJORA_MAX) { __eq_msg("YA ESTA AL MAXIMO"); break; }
			var _c = scr_eq_costo_mejora(_n);
			if (global.equipo.monedas < _c) { __eq_msg("TE FALTAN " + string(_c - global.equipo.monedas) + " MONEDAS"); break; }
			if (scr_eq_mejorar(_it.id)) {
				_q.fx = "mejora"; _q.fx_t = 0; _q.fx_id = _it.id; _q.fx_n0 = _n; _q.fx_n1 = _n + 1; _q.fx_costo = _c;
				__eq_chispas(377, 126, 46, [_oro, c_white, _verde, make_color_rgb(255, 240, 170)]);
				if (global.sfx) audio_play_sound(snd_levelup, 5, false, 0.9);
			}
		break;
		case "equipar":
			if (scr_eq_equipar(_it.id, _q.slot)) {
				_q.fx = "equipa"; _q.fx_t = 0; _q.fx_id = _it.id;
				if (global.sfx) audio_play_sound(snd_ammo_pickup, 5, false, 0.8, 0, 1.3);
			}
		break;
	}
}

/// Step de oMenu cuando menu_state == "equipo"
function scr_eq_step() {
	if (!variable_global_exists("eq_ui") || !is_struct(global.eq_ui)) scr_eq_abrir();
	scr_eq_init();
	__eq_geo();
	var _q = global.eq_ui;
	var _cat = scr_eq_catalogo();
	var _n = array_length(_cat);
	_q.abierto_t++;

	// Animaciones
	if (_q.fx_t >= 0) { _q.fx_t++; if (_q.fx_t > 150) { _q.fx_t = -1; _q.fx = ""; } }
	_q.mon_vis = lerp(_q.mon_vis, global.equipo.monedas, 0.1);
	if (abs(_q.mon_vis - global.equipo.monedas) < 1) _q.mon_vis = global.equipo.monedas;
	if (_q.msg_t > 0) _q.msg_t--;
	for (var i = array_length(_q.parts) - 1; i >= 0; i--) {
		var _p = _q.parts[i];
		_p.x += _p.vx; _p.y += _p.vy; _p.vy += 0.12; _p.vx *= 0.97; _p.vida -= 1;
		if (_p.vida <= 0) array_delete(_q.parts, i, 1);
	}

	// Los primeros frames no (el mismo ENTER o toque que la abrio)
	if (_q.abierto_t <= 5) return;

	if (vkey_pressed(vk_escape)) { menu_state = "main"; menu_delay = 5; return; }

	// Teclado
	var _mv = vkey_pressed(ord("S")) - vkey_pressed(ord("W"));
	if (_mv != 0) {
		_q.sel = clamp(_q.sel + _mv, 0, _n - 1);
		__eq_ver_sel();
		if (global.sfx) audio_play_sound(snd_scroll, 5, false, 0.4);
	}
	var _lr = vkey_pressed(ord("D")) - vkey_pressed(ord("A"));
	if (_lr != 0) _q.slot = (_lr > 0) ? 1 : 0;
	if (vkey_pressed(vk_enter)) __eq_hacer(scr_eq_tiene(_cat[_q.sel].id) ? "equipar" : "comprar");
	if (keyboard_check_pressed(ord("M"))) __eq_hacer("mejorar");

	// PRUEBA: ALT = +1000 monedas (solo en esta pantalla y solo con EQ_PRUEBA en true)
	if (EQ_PRUEBA && keyboard_check_pressed(vk_alt)) {
		global.equipo.monedas += 1000;
		scr_save_to_local();
		__eq_chispas(520, 30, 24, [make_color_rgb(255, 212, 71), c_white]);
		if (global.sfx) audio_play_sound(snd_ammo_pickup, 5, false, 0.8, 0, 1.5);
	}
	// PRUEBA: SUPR (Delete) = borrar monedas, armas compradas y mejoras (en el aparato y en tu cuenta)
	if (EQ_PRUEBA && keyboard_check_pressed(vk_delete)) {
		global.equipo = { monedas: 0, armas: [], mej: {}, p: "smg", s: "pistola" };
		scr_eq_init();
		scr_save_to_local();   // tambien manda el equipamiento vacio a tu cuenta
		_q.mon_vis = 0;
		_q.fx = ""; _q.fx_t = -1; _q.parts = [];
		_q.sel = 0; _q.scroll = 0;
		__eq_msg("EQUIPAMIENTO BORRADO");
	}

	// Rueda del mouse en la lista
	var _rueda = mouse_wheel_down() - mouse_wheel_up();
	if (_rueda != 0) { _q.scroll += _rueda * EQ_FILA; __eq_scroll_tope(); }

	// Toques y clics (en coordenadas de la hoja)
	var _px = (device_mouse_x_to_gui(0) - _q.ox) / _q.S;
	var _py = (device_mouse_y_to_gui(0) - _q.oy) / _q.S;
	if (device_mouse_check_button_pressed(0, mb_left)) {
		if (point_in_rectangle(_px, _py, 610, 8, 712, 36)) { menu_state = "main"; menu_delay = 5; return; }   // VOLVER
		if (point_in_rectangle(_px, _py, 12, 54, 262, EQ_LISTA_FIN + 4)) {
			var _f = floor((_py - EQ_LISTA_Y + _q.scroll) / EQ_FILA);
			if (_f >= 0 && _f < _n && _py >= EQ_LISTA_Y) {
				if (_f != _q.sel && global.sfx) audio_play_sound(snd_scroll, 5, false, 0.4);
				_q.sel = _f;
			}
			_q.drag = true;
			_q.drag_y = _py;
		}
		var _sw = (720 - 286) / 2;
		for (var k = 0; k < 2; k++) {
			var _sx1 = 274 + k * (_sw + 6);
			if (point_in_rectangle(_px, _py, _sx1, 311, _sx1 + _sw - 6, EQ_LISTA_FIN + 4)) _q.slot = k;
		}
		var _bs = __eq_botones();
		for (var b = 0; b < array_length(_bs); b++) {
			var _bt = _bs[b];
			if (_bt.acc != "" && point_in_rectangle(_px, _py, _bt.x1, _bt.y1, _bt.x2, _bt.y2)) __eq_hacer(_bt.acc);
		}
	}
	if (_q.drag) {
		if (device_mouse_check_button(0, mb_left)) {
			_q.scroll -= (_py - _q.drag_y);
			_q.drag_y = _py;
			__eq_scroll_tope();
		} else _q.drag = false;
	}
}

// --- dibujo ---
function __eq_rect(_x1, _y1, _x2, _y2, _r, _col, _a, _borde = false) {
	draw_set_color(_col);
	draw_set_alpha(_a);
	var _S = global.eq_ui.S;
	draw_roundrect_ext(__eq_x(_x1), __eq_y(_y1), __eq_x(_x2), __eq_y(_y2), _r * _S, _r * _S, _borde);
	draw_set_alpha(1);
}

/// Panel con sombra y borde oscuro (estetica del menu nuevo)
function __eq_caja(_x1, _y1, _x2, _y2, _r, _col) {
	__eq_rect(_x1, _y1 + 5, _x2, _y2 + 5, _r, c_black, 0.45);
	__eq_rect(_x1, _y1, _x2, _y2, _r, _col, 1);
	__eq_rect(_x1, _y1, _x2, _y2, _r, make_color_rgb(11, 15, 26), 1, true);
}
/// Boton con relieve (sombra, brillo arriba y borde oscuro)
function __eq_boton(_x1, _y1, _x2, _y2, _r, _col) {
	__eq_rect(_x1, _y1 + 5, _x2, _y2 + 5, _r, merge_colour(_col, c_black, 0.55), 1);
	__eq_rect(_x1, _y1, _x2, _y2, _r, _col, 1);
	__eq_rect(_x1 + 5, _y1 + 4, _x2 - 5, _y1 + (_y2 - _y1) * 0.42, _r * 0.6, merge_colour(_col, c_white, 0.25), 1);
	__eq_rect(_x1, _y1, _x2, _y2, _r, make_color_rgb(11, 15, 26), 1, true);
}

function __eq_txt(_x, _y, _s, _px, _col, _ha, _a = 1, _font = fnt_menu) {
	draw_set_font(_font);
	draw_set_halign(_ha);
	draw_set_valign(fa_middle);
	draw_set_color(_col);
	draw_set_alpha(_a);
	var _k = (_px * global.eq_ui.S) / max(1, string_height("A"));
	draw_text_transformed(__eq_x(_x), __eq_y(_y), _s, _k, _k, 0);
	draw_set_alpha(1);
}

/// Sprite centrado en (_cx,_cy) que quepa en _w x _h. _blanco = brillo blanco encima (0 a 1)
function __eq_spr(_spr, _cx, _cy, _w, _h, _a = 1, _blanco = 0) {
	var _sw = sprite_get_width(_spr), _sh = sprite_get_height(_spr);
	var _k = min(_w / _sw, _h / _sh) * global.eq_ui.S;
	var _x = __eq_x(_cx) - (_sw / 2 - sprite_get_xoffset(_spr)) * _k;
	var _y = __eq_y(_cy) - (_sh / 2 - sprite_get_yoffset(_spr)) * _k;
	draw_sprite_ext(_spr, 0, _x, _y, _k, _k, 0, c_white, _a);
	if (_blanco > 0) {
		gpu_set_blendmode(bm_add);
		repeat (2) draw_sprite_ext(_spr, 0, _x, _y, _k, _k, 0, c_white, _blanco);
		gpu_set_blendmode(bm_normal);
	}
}

function __eq_estrella(_cx, _cy, _r, _col, _a = 1) {
	var _S = global.eq_ui.S;
	var _x = __eq_x(_cx), _y = __eq_y(_cy);
	draw_set_color(_col);
	draw_set_alpha(_a);
	draw_primitive_begin(pr_trianglefan);
	draw_vertex(_x, _y);
	for (var j = 0; j <= 10; j++) {
		var _rr = ((j mod 2) == 0 ? _r : _r * 0.45) * _S;
		var _ang = 90 + j * 36;
		draw_vertex(_x + lengthdir_x(_rr, _ang), _y + lengthdir_y(_rr, _ang));
	}
	draw_primitive_end();
	draw_set_alpha(1);
}

function __eq_moneda(_cx, _cy, _r) {
	var _S = global.eq_ui.S;
	draw_set_color(make_color_rgb(255, 212, 71));
	draw_circle(__eq_x(_cx), __eq_y(_cy), _r * _S, false);
	draw_set_color(make_color_rgb(214, 160, 30));
	draw_circle(__eq_x(_cx), __eq_y(_cy), _r * 0.55 * _S, false);
}

function __eq_ease(_x) { _x = clamp(_x, 0, 1); return 1 - power(1 - _x, 3); }
function __eq_back(_x) { _x = clamp(_x, 0, 1); var _c = 1.7; return 1 + (_c + 1) * power(_x - 1, 3) + _c * power(_x - 1, 2); }

/// Draw GUI de oMenu cuando menu_state == "equipo"
function scr_eq_draw() {
	if (!variable_global_exists("eq_ui") || !is_struct(global.eq_ui)) scr_eq_abrir();
	scr_eq_init();
	__eq_geo();
	var _q = global.eq_ui;
	var _cat = scr_eq_catalogo();
	var _n = array_length(_cat);
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	var _tinta = make_color_rgb(11, 15, 26), _panel = make_color_rgb(20, 24, 50), _caja = make_color_rgb(150, 160, 185);
	var _oro = make_color_rgb(255, 212, 71), _azul = make_color_rgb(31, 155, 255), _gris = make_color_rgb(169, 180, 208);
	var _verde = make_color_rgb(78, 220, 140), _rojo = make_color_rgb(229, 72, 77), _apag = make_color_rgb(60, 66, 86);
	var _fx = _q.fx, _t = _q.fx_t;

	// Fondo (toda la pantalla) y barra de arriba (estetica del menu nuevo)
	if (MN_NUEVO) __mn_fondo_wh(_gw, _gh);
	else { draw_set_color(make_color_rgb(16, 20, 34)); draw_rectangle(0, 0, _gw, _gh, false); }
	draw_set_color(_tinta);
	draw_set_alpha(0.75);
	draw_rectangle(0, 0, _gw, __eq_y(44), false);
	draw_set_alpha(1);
	__eq_txt(18, 22, "EQUIPAMIENTO", 20, c_white, fa_left);
	__eq_txt(452, 22, "NV " + string(global.lvl), 15, _azul, fa_left);
	__eq_moneda(512, 22, 8);
	__eq_txt(526, 22, string(round(_q.mon_vis)), 15, _oro, fa_left);
	if ((_fx == "mejora" || _fx == "compra") && _t >= 6 && _t < 60) {
		var _ft = (_t - 6) / 54;
		__eq_txt(526, 40 - 10 * __eq_ease(_ft), "-" + string(_q.fx_costo), 11, _rojo, fa_left, 1 - _ft);
	}
	__eq_boton(610, 8, 712, 36, 6, make_color_rgb(44, 54, 110));
	__eq_txt(661, 22, "VOLVER", 12, c_white, fa_center);

	// --- LISTA ---
	__eq_caja(12, 54, 262, EQ_LISTA_FIN + 4, 10, _panel);
	for (var i = 0; i < _n; i++) {
		var _it = _cat[i];
		var _y = EQ_LISTA_Y + i * EQ_FILA - _q.scroll;
		if (_y < EQ_LISTA_Y - 1 || _y + 29 > EQ_LISTA_FIN + 1) continue;
		var _mia = scr_eq_tiene(_it.id);
		if (i == _q.sel) {
			__eq_rect(18, _y, 256, _y + 29, 6, make_color_rgb(40, 60, 100), 1);
			__eq_rect(18, _y, 256, _y + 29, 6, _azul, 1, true);
		}
		__eq_rect(24, _y + 3, 74, _y + 26, 4, _caja, _mia ? 1 : 0.55);
		__eq_spr(_it.spr, 49, _y + 14.5, 44, 17, _mia ? 1 : 0.5);
		__eq_txt(84, _y + 15, _it.nombre, 12, _mia ? c_white : _gris, fa_left);
		if (_mia) {
			// Estrellitas de mejora y marca de equipada
			var _nm = scr_eq_mejora(_it.id);
			for (var s = 0; s < _nm; s++) __eq_estrella(222 + s * 11, _y + 15, 4.5, _oro);
			if (global.equipo.p == _it.id || global.equipo.s == _it.id) __eq_txt(250, _y + 15, (global.equipo.p == _it.id) ? "P" : "S", 11, _azul, fa_right);
		} else if (global.lvl < _it.lv) {
			__eq_txt(248, _y + 15, "NV " + string(_it.lv), 11, _rojo, fa_right);
		} else {
			__eq_moneda(212, _y + 15, 6);
			__eq_txt(248, _y + 15, string(_it.precio), 11, _oro, fa_right);
		}
	}
	// Barrita de scroll
	var _tot = _n * EQ_FILA, _vis = EQ_LISTA_FIN - EQ_LISTA_Y;
	if (_tot > _vis) {
		var _bh = _vis * _vis / _tot;
		var _by = EQ_LISTA_Y + (_vis - _bh) * (_q.scroll / (_tot - _vis));
		__eq_rect(258, _by, 261, _by + _bh, 2, _gris, 0.4);
	}

	// --- DETALLE DEL ARMA ---
	var _sel = _cat[_q.sel];
	var _mia2 = scr_eq_tiene(_sel.id);
	var _nmej = scr_eq_mejora(_sel.id);
	var _es_fx = (_q.fx_id == _sel.id && _t >= 0);
	__eq_caja(274, 54, 708, 301, 10, _panel);
	__eq_txt(292, 74, _sel.nombre, 22, c_white, fa_left);
	// Estrellas (la nueva salta con un aro)
	for (var k = 0; k < EQ_MEJORA_MAX; k++) {
		var _sx = 634 + k * 26;
		var _llena = (k < _nmej);
		if (_es_fx && _fx == "mejora" && k == _q.fx_n1 - 1) {
			__eq_estrella(_sx, 74, 11, _apag);
			if (_t >= 18) __eq_estrella(_sx, 74, 11 * __eq_back((_t - 18) / 21), _oro);
			if (_t >= 18 && _t < 96) {
				var _rp = (_t - 18) / 78;
				draw_set_color(_oro);
				draw_set_alpha(1 - _rp);
				draw_circle(__eq_x(_sx), __eq_y(74), (10 + 30 * __eq_ease(_rp)) * _q.S, true);
				draw_set_alpha(1);
			}
		} else __eq_estrella(_sx, 74, 11, _llena ? _oro : _apag);
	}
	// Caja del arma: brilla y salta al mejorar o comprar
	var _glow = (_es_fx && (_fx == "mejora" || _fx == "compra")) ? max(0, 1 - _t / 54) : 0;
	__eq_rect(292, 94, 462, 158, 8, merge_colour(_caja, c_white, _glow * 0.6), _mia2 ? 1 : 0.6);
	if (_es_fx && (_fx == "mejora" || _fx == "compra") && _t < 72) __eq_rect(292, 94, 462, 158, 8, _oro, 1, true);
	var _pop = (_es_fx && _t >= 0 && _t < 30 && (_fx == "mejora" || _fx == "compra")) ? 1 + 0.35 * sin(pi * _t / 30) : 1;
	var _bl = (_es_fx && (_fx == "mejora" || _fx == "compra")) ? max(0, 1 - _t / 21) : 0;
	__eq_spr(_sel.spr, 377, 126, 140 * _pop, 44 * _pop, _mia2 ? 1 : 0.55, _bl);
	// Onda alrededor del arma
	if (_es_fx && (_fx == "mejora" || _fx == "compra") && _t < 36) {
		var _rq = _t / 36;
		draw_set_color(make_color_rgb(255, 240, 170));
		draw_set_alpha(0.8 * (1 - _rq));
		var _rr = (20 + 120 * __eq_ease(_rq)) * _q.S;
		draw_ellipse(__eq_x(377) - _rr, __eq_y(126) - _rr * 0.7, __eq_x(377) + _rr, __eq_y(126) + _rr * 0.7, true);
		draw_set_alpha(1);
	}
	// Barras
	var _st1 = scr_eq_stats(_sel.id, _nmej);
	var _st0 = (_es_fx && _fx == "mejora") ? scr_eq_stats(_sel.id, _q.fx_n0) : _st1;
	var _nom = ["DANO", "CADENCIA", "CARGADOR", "RECARGA"];
	var _sube = (_es_fx && _fx == "mejora") ? __eq_ease((_t - 24) / 30) : 1;
	for (var b = 0; b < 4; b++) {
		var _yy = 102 + b * 16;
		__eq_txt(476, _yy, _nom[b], 9, _gris, fa_left, 1, fnt_small);
		__eq_rect(556, _yy - 4, 686, _yy + 4, 3, make_color_rgb(40, 46, 66), 1);
		var _v = lerp(_st0[b], _st1[b], _sube);
		var _cb = (b >= 2 && _es_fx && _fx == "mejora" && _t >= 24 && _t < 100) ? _verde : _azul;
		__eq_rect(556, _yy - 4, 556 + 130 * _v, _yy + 4, 3, _cb, 1);
		if (b >= 2 && _nmej > 0) __eq_txt(690, _yy, "+", 11, _verde, fa_left);
	}
	// Botones
	var _bs = __eq_botones();
	for (var j = 0; j < array_length(_bs); j++) {
		var _bt = _bs[j];
		__eq_boton(_bt.x1, _bt.y1, _bt.x2, _bt.y2, 10, _bt.col);
		__eq_txt((_bt.x1 + _bt.x2) / 2, (_bt.y1 + _bt.y2) / 2, _bt.txt, (array_length(_bs) == 1) ? 15 : 13, _bt.tc, fa_center);
	}
	// Cartel de la mejora / compra
	if (_es_fx && (_fx == "mejora" || _fx == "compra") && _t >= 21 && _t < 132) {
		var _cp = _t - 21;
		var _sc = (_cp < 18) ? __eq_back(_cp / 18) : 1;
		var _ca = (_t < 114) ? 1 : 1 - (_t - 114) / 18;
		var _ww = 115 * _sc, _hh = 20 * _sc;
		__eq_rect(377 - _ww, 186 - _hh, 377 + _ww, 186 + _hh, 10, _tinta, 0.92 * _ca);
		__eq_rect(377 - _ww, 186 - _hh, 377 + _ww, 186 + _hh, 10, _oro, _ca, true);
		var _txt = (_fx == "mejora") ? (_sel.nombre + "  MEJORA  " + string(_q.fx_n1) + "/" + string(EQ_MEJORA_MAX)) : (_sel.nombre + "  ES TUYA!");
		__eq_txt(377, 186, _txt, 15 * _sc, _oro, fa_center, _ca);
	}
	// Aviso (te faltan monedas, etc.)
	if (_q.msg_t > 0) {
		var _ma = min(1, _q.msg_t / 20);
		__eq_rect(300, 228, 678, 256, 8, _tinta, 0.92 * _ma);
		__eq_rect(300, 228, 678, 256, 8, _rojo, _ma, true);
		__eq_txt(489, 242, _q.msg, 13, _rojo, fa_center, _ma);
	}

	// --- TUS 2 CASILLAS ---
	var _sw = (720 - 286) / 2;
	var _ids = [global.equipo.p, global.equipo.s];
	var _labs = ["PRINCIPAL", "SECUNDARIA"];
	for (var m = 0; m < 2; m++) {
		var _sx1 = 274 + m * (_sw + 6), _sx2 = _sx1 + _sw - 6;
		var _act = (_q.slot == m);
		__eq_caja(_sx1, 311, _sx2, EQ_LISTA_FIN + 4, 10, _panel);
		__eq_rect(_sx1, 311, _sx2, EQ_LISTA_FIN + 4, 10, _act ? _azul : make_color_rgb(60, 70, 100), 1, true);
		if (_fx == "equipa" && _t < 24 && _act) __eq_rect(_sx1, 311, _sx2, EQ_LISTA_FIN + 4, 10, c_white, 0.35 * (1 - _t / 24));
		__eq_txt(_sx1 + 14, 327, _labs[m], 11, _act ? _azul : _gris, fa_left);
		var _ii = scr_eq_info(_ids[m]);
		if (!is_undefined(_ii)) {
			__eq_txt(_sx1 + 14, 355, _ii.nombre, (string_length(_ii.nombre) > 9) ? 13 : 17, c_white, fa_left);
			__eq_rect(_sx2 - 100, 329, _sx2 - 12, 379, 6, _caja, 1);
			__eq_spr(_ii.spr, _sx2 - 56, 354, 80, 34);
			var _ns = scr_eq_mejora(_ii.id);
			for (var s2 = 0; s2 < _ns; s2++) __eq_estrella(_sx1 + 20 + s2 * 13, 376, 5, _oro);
		}
		if (_act) __eq_txt(_sx2 - 108, 327, "ELIGIENDO", 9, _azul, fa_right, 1, fnt_small);
	}

	// Chispas
	for (var p = 0; p < array_length(_q.parts); p++) {
		var _pp = _q.parts[p];
		draw_set_color(_pp.col);
		draw_set_alpha(clamp(_pp.vida / 40, 0, 1));
		var _ps = _pp.s * _q.S;
		draw_rectangle(__eq_x(_pp.x), __eq_y(_pp.y), __eq_x(_pp.x) + _ps, __eq_y(_pp.y) + _ps, false);
	}
	draw_set_alpha(1);

	// Ayuda (solo con teclado)
	if (!touch_mode()) __eq_txt(360, 397, "W/S ELEGIR    A/D CASILLA    ENTER COMPRAR/EQUIPAR    M MEJORAR    ESC VOLVER", 8, _gris, fa_center, 0.6, fnt_small);

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
