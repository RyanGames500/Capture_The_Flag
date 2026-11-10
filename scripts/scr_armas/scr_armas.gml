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
	return global.ONLINE && object_index == oPlayer;
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
