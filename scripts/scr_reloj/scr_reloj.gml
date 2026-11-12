// ======================================================
// RELOJ DE PARTIDA Y AJUSTES DE LA SALA (solo en línea)
//   global.match_tiempo   segundos de partida (0 = SIN LIMITE)
//   global.match_mapa     0 = NIVEL 1, 1 = NIVEL 2, 2 = NIVEL 3, 3 = ALEATORIO
//   global.match_banderas banderas para ganar (1 a 5)
// El reloj lo lleva el líder y lo manda a todos cada segundo ("sync_reloj").
// Si se acaba empatado: MUERTE SUBITA, la siguiente bandera gana.
// ======================================================
#macro RELOJ_ROJO 30   // últimos segundos en rojo

/// Valores de partida rápida: 5 minutos, mapa aleatorio, 3 banderas.
function scr_ajustes_default() {
	global.match_tiempo   = 300;
	global.match_mapa     = MAPA_ALEATORIO;
	global.match_banderas = 3;
}

function scr_ajustes_tiempos() { return [180, 300, 480, 600, 0]; }

/// Texto de cada ajuste para la sala de espera.
function scr_ajustes_texto(_fila) {
	switch (_fila) {
		case 0: return (global.match_tiempo <= 0) ? "SIN LIMITE" : string(global.match_tiempo div 60) + " MIN";
		case 1: return (global.match_mapa == MAPA_ALEATORIO) ? "ALEATORIO" : "NIVEL " + string(global.match_mapa + 1);
		case 2: return string(global.match_banderas);
	}
	return "";
}

/// Cambia un ajuste (_dir = -1 o 1). Lo usa el líder en la sala de espera.
function scr_ajustes_cambiar(_fila, _dir) {
	switch (_fila) {
		case 0:
			var _ts = scr_ajustes_tiempos();
			var _i = 1;
			for (var k = 0; k < array_length(_ts); k++) if (_ts[k] == global.match_tiempo) _i = k;
			_i = (_i + _dir + array_length(_ts)) mod array_length(_ts);
			global.match_tiempo = _ts[_i];
		break;
		case 1: global.match_mapa = (global.match_mapa + _dir + scr_mapa_total() + 1) mod (scr_mapa_total() + 1); break; // niveles + ALEATORIO
		case 2: global.match_banderas = clamp(global.match_banderas + _dir, 1, 5); break;
	}
}

// ------------------------------------------------------
// MODOS DE JUEGO (tarjetas del menu nuevo). global.match_modo:
//   0 CLASICO, 1 BANDERA BOMBA, 2 GRAVEDAD LOCA, 3 UN TIRO, 4 REY DE LA BANDERA, 5 PISO DE LAVA
// Lo elige quien busca partida o el lider de la sala, y viaja con los ajustes ("mo").
// ------------------------------------------------------
#macro MODO_TIRO 3

function scr_modo() {
	return (variable_global_exists("match_modo") && is_numeric(global.match_modo)) ? global.match_modo : 0;
}
function scr_modo_nombre() {
	switch (scr_modo()) {
		case 1: return "BANDERA BOMBA";
		case 2: return "GRAVEDAD LOCA";
		case 3: return "UN TIRO";
		case 4: return "REY DE LA BANDERA";
		case 5: return "PISO DE LAVA";
	}
	return "CLASICO";
}
/// UN TIRO: todos con francotirador y 1 de vida (solo en linea)
function scr_modo_tiro() { return global.ONLINE && scr_modo() == MODO_TIRO; }

function scr_ajustes_struct() {
	var _s = { t: global.match_tiempo, m: global.match_mapa, b: global.match_banderas, mo: scr_modo() };
	// En la sala de espera el lider tambien manda los equipos (parejos, scr_objetivo)
	if (room == rm_menu && instance_exists(oBrain) && oBrain.AmIPseudoHost) _s.eq = scr_sala_equipos_calc();
	return _s;
}

/// Aplica los ajustes que mandó el líder (revisa que vengan bien).
function scr_ajustes_aplicar(_s) {
	if (!is_struct(_s)) return;
	if (variable_struct_exists(_s, "t") && is_numeric(_s.t)) global.match_tiempo   = max(0, round(_s.t));
	if (variable_struct_exists(_s, "m") && is_numeric(_s.m)) global.match_mapa     = clamp(round(_s.m), 0, MAPA_ALEATORIO);
	if (variable_struct_exists(_s, "b") && is_numeric(_s.b)) global.match_banderas = clamp(round(_s.b), 1, 5);
	if (variable_struct_exists(_s, "mo") && is_numeric(_s.mo)) global.match_modo = clamp(round(_s.mo), 0, 5);   // modo de juego
	if (variable_struct_exists(_s, "eq")) scr_sala_equipos_aplicar(_s.eq);   // equipos que repartio el lider
}

/// El líder les manda los ajustes a todos los de la sala.
function scr_ajustes_enviar() {
	var _s = scr_ajustes_struct();
	with (oOtherPlayer) SendEventToClient(clientId, "sync_ajustes", _s);
}

// ------------------------------------------------------
// MAPAS EN LINEA
//   Para agregar un nivel nuevo: ponlo en scr_mapa_lista() y sube MAPA_ALEATORIO en 1.
// ------------------------------------------------------
#macro MAPA_ALEATORIO 3   // = cantidad de niveles en la lista

function scr_mapa_lista() { return [rm_stage1, rm_stage2, rm_stage3]; }
function scr_mapa_total() { return array_length(scr_mapa_lista()); }

/// Room del mapa elegido.
function scr_mapa_room(_m) {
	var _l = scr_mapa_lista();
	if (!is_numeric(_m) || _m < 0 || _m >= array_length(_l)) _m = 0;
	return _l[_m];
}

/// Mapa sacado de un texto (nombre de sala). Todos los que tienen el mismo texto sacan
/// el mismo mapa, sin mandarse mensajes y sin tocar el random del juego.
function scr_mapa_desde_codigo(_txt) {
	_txt = string(_txt);
	var _h = 0;
	for (var i = 1; i <= string_length(_txt); i++) _h = (_h * 31 + ord(string_char_at(_txt, i))) mod 1000003;
	return _h mod scr_mapa_total();
}

/// Solo el líder: si está en ALEATORIO, elige uno ya. Devuelve el room.
function scr_mapa_resolver() {
	if (global.match_mapa == MAPA_ALEATORIO || global.match_mapa < 0 || global.match_mapa >= scr_mapa_total()) {
		global.match_mapa = irandom(scr_mapa_total() - 1);
	}
	return scr_mapa_room(global.match_mapa);
}

/// Banderas para ganar: en línea las de la sala, en local las del menú local.
function scr_banderas_para_ganar() {
	if (global.ONLINE) return variable_global_exists("match_banderas") ? global.match_banderas : 3;
	return variable_global_exists("off_flags") ? global.off_flags : 3;
}

// ------------------------------------------------------
// RELOJ (variables en oBrain: reloj_seg, reloj_frames, reloj_fin)
//   reloj_seg = -1  todavía no empieza (o no hay límite)
// ------------------------------------------------------
function scr_reloj_reset() {
	reloj_seg = -1;
	reloj_frames = 0;
	reloj_fin = false;
	ms_seg = -1;        // muerte subita: segundos que quedan (-1 = no hay)
	ms_frames = 0;
	ms_aviso_t = 0;     // aviso grande de MUERTE SUBITA (opcion B)
	ms_aviso_hecho = false;
}

/// Va en el Step de oBrain.
function scr_reloj_step() {
	if (!global.ONLINE || room == rm_menu) {
		if (reloj_seg != -1 || reloj_fin) scr_reloj_reset();
		return;
	}
	if (global.game_over) return;
	scr_ms_aviso_step();                                      // aviso grande de MUERTE SUBITA (lo ve cada uno)
	if (global.match_tiempo <= 0) return;                     // SIN LIMITE
	if (!intro_disparada || instance_exists(oIntroVersus)) return;   // empieza cuando termina la intro
	if (!AmIPseudoHost) return;                               // los invitados solo muestran lo que manda el líder

	if (reloj_seg < 0) {
		reloj_seg = global.match_tiempo;
		reloj_frames = 0;
		scr_reloj_enviar();
	}
	if (reloj_fin) {
		// MUERTE SUBITA: si van empatados, 60 segundos para que alguien anote. Si nadie anota: EMPATE
		if (!variable_instance_exists(id, "ms_seg")) { ms_seg = -1; ms_frames = 0; }
		if (global.puntos_azul != global.puntos_rojo) return;
		if (ms_seg < 0) {
			ms_seg = MUERTE_SUBITA_SEG;
			ms_frames = 0;
			scr_reloj_enviar();
			return;
		}
		ms_frames += 1;
		if (ms_frames >= room_speed && ms_seg > 0) {
			ms_frames = 0;
			ms_seg = max(0, ms_seg - 1);
			scr_reloj_enviar();
		}
		return;
	}

	reloj_frames += 1;
	if (reloj_frames >= room_speed) {
		reloj_frames = 0;
		reloj_seg = max(0, reloj_seg - 1);
		if (reloj_seg == 0) reloj_fin = true;
		scr_reloj_enviar();
	}
}

function scr_reloj_enviar() {
	var _s = { s: reloj_seg, ms: (variable_instance_exists(id, "ms_seg") ? ms_seg : -1) };
	with (oOtherPlayer) SendEventToClient(clientId, "sync_reloj", _s);
}

/// ¿Se dibuja el reloj? (en línea, con límite y ya empezado)
function scr_reloj_visible() {
	if (!instance_exists(oBrain)) return false;
	return global.ONLINE && room != rm_menu && oBrain.reloj_seg >= 0;
}

/// Reloj debajo del marcador. Va en el Draw GUI de oBrain (centro x, y).
function scr_reloj_draw(_cx, _cy) {
	if (!scr_reloj_visible()) return;
	var _empate = (global.puntos_azul == global.puntos_rojo);
	var _txt, _col, _s = 1;

	if (reloj_fin && _empate) {
		_txt = "MUERTE SUBITA " + scr_muerte_subita_txt();
		_col = ((current_time div 300) mod 2 == 0) ? c_red : c_yellow;
	} else {
		var _m = reloj_seg div 60;
		var _sg = reloj_seg mod 60;
		_txt = string(_m) + ":" + ((_sg < 10) ? "0" : "") + string(_sg);
		_col = c_white;
		if (reloj_seg <= RELOJ_ROJO) {
			_col = c_red;
			_s = 1 + 0.08 * max(0, 1 - (current_time mod 1000) / 200);   // pequeño latido
		}
	}

	draw_set_font(fnt_menu);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _w = string_width(_txt) * 0.8 + 34;
	draw_set_alpha(0.7);
	draw_set_colour(c_black);
	draw_roundrect_ext(_cx - _w/2, _cy - 16, _cx + _w/2, _cy + 16, 14, 14, false);
	draw_set_alpha(1);
	draw_text_transformed_color(_cx + 2, _cy + 2, _txt, 0.8 * _s, 0.8 * _s, 0, c_black, c_black, c_black, c_black, 1);
	draw_text_transformed_color(_cx, _cy, _txt, 0.8 * _s, 0.8 * _s, 0, _col, _col, _col, _col, 1);

	draw_set_colour(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

/// Altura del cuadro AJUSTES DE LA PARTIDA en la sala de espera (debajo de los nombres).
function scr_ajustes_panel_y() {
	var _mitad = max(1, global.max_players_allowed / 2);
	return 200 + _mitad * 80 + 4;
}

/// Cuadro AJUSTES DE LA PARTIDA. Va en el Draw GUI de oMenu (sala de espera).
/// (Las flechas < > quedan en las mismas posiciones que lee el Step para el clic/toque)
function scr_ajustes_draw(_soy_lider, _sel) {
	var _tinta = make_color_rgb(11, 15, 26);
	var _azul  = make_color_rgb(31, 155, 255);
	var _oro   = make_color_rgb(255, 212, 71);
	var _gris  = make_color_rgb(169, 180, 208);

	var _cx = display_get_gui_width() / 2;
	var _y0 = scr_ajustes_panel_y();
	var _x1 = _cx - 300, _x2 = _cx + 300;

	ctf_ui_panel(_x1, _y0, _x2, _y0 + 156, _azul);

	draw_set_font(fnt_small);
	draw_set_valign(fa_middle);
	draw_set_halign(fa_left);
	draw_set_colour(_azul);
	draw_rectangle(_x1 + 16, _y0 + 12, _x1 + 18, _y0 + 24, false);
	draw_set_colour(_gris);
	draw_set_alpha(0.7);
	draw_text_transformed(_x1 + 28, _y0 + 18, "MODO: " + scr_modo_nombre() + (_soy_lider ? "   -   AJUSTES DE LA PARTIDA" : "   -   AJUSTES (LOS ELIGE EL LIDER)"), 0.6, 0.6, 0);
	draw_set_alpha(1);

	var _nom = ["TIEMPO", "MAPA", "BANDERAS PARA GANAR"];
	for (var f = 0; f < 3; f++) {
		var _fy = _y0 + 48 + f * 34;
		var _on = _soy_lider && (_sel == f);
		if (_on) {
			ctf_ui_para(_x1 + 10, _fy - 15, 580, 30, 8, _azul, 0.12, false);
			ctf_ui_para(_x1 + 10, _fy - 15, 580, 30, 8, _azul, 0.8, true);
		}
		draw_set_font(fnt_small);
		draw_set_halign(fa_left);
		draw_set_colour(_on ? _azul : _gris);
		draw_text_transformed(_x1 + 28, _fy, _nom[f], 0.65, 0.65, 0);

		draw_set_font(fnt_menu);
		draw_set_halign(fa_center);
		draw_set_colour(_oro);
		draw_text_transformed(_cx + 120, _fy, scr_ajustes_texto(f), 0.7, 0.7, 0);
		if (_soy_lider) {
			draw_set_colour(_on ? _azul : _gris);
			draw_set_alpha(_on ? 1 : 0.5);
			draw_text_transformed(_cx + 10, _fy, "<", 0.8, 0.8, 0);
			draw_text_transformed(_cx + 230, _fy, ">", 0.8, 0.8, 0);
			draw_set_alpha(1);
		}
	}
	if (_soy_lider) {
		draw_set_font(fnt_small);
		draw_set_halign(fa_center);
		draw_set_colour(_gris);
		draw_set_alpha(0.5);
		draw_text_transformed(_cx, _y0 + 140, touch_mode() ? "TOCA < > PARA CAMBIAR" : "[W/S] ELEGIR     [A/D] CAMBIAR", 0.55, 0.55, 0);
		draw_set_alpha(1);
	}

	draw_set_colour(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

// ------------------------------------------------------
// BOT EN PARTIDA RAPIDA
//   Partida rápida: el servidor te deja en la cola "auto_matchmake_N" (pantalla BUSCANDO RIVAL)
//   hasta que haya rival. Si en unos segundos (al azar entre BOT_ESPERA_MIN y BOT_ESPERA_MAX)
//   no hay, juegas contra un bot en un mapa al azar (versión offline del nivel).
//   El bot se ve como un jugador: nombre al azar, elige personaje, intro VS y usa su habilidad.
//   Da menos copas y XP.
// ------------------------------------------------------
#macro BOT_ESPERA_MIN 8
#macro BOT_ESPERA_MAX 20

/// Rooms offline de cada mapa (mismo orden que scr_mapa_lista)
function scr_bot_rooms() { return [rm_stage1_offline, rm_stage2_offline, rm_stage3_offline]; }

/// ¿Estoy en la cola de partida rápida esperando rival?
function scr_bot_esperando() {
	return global.ONLINE && room == rm_menu && instance_exists(oMenu) && oMenu.menu_state == "connecting"
		&& variable_global_exists("roomId") && string_pos("auto_matchmake", string(global.roomId)) == 1;
}

/// Partida rapida sin rival: juegas contra el MISMO bot de las salas privadas (scr_objetivo).
/// Sales de la cola a tu propia sala (nadie mas entra) y, cuando el servidor confirma
/// (callback_LeaveRoom -> scr_botq_arrancar), vas al mapa en linea con un bot rival.
/// Si el servidor no contesta en 3 s, se usa el bot viejo de siempre (scr_bot_empezar_viejo).
#macro BOTQ_ESPERA 180

function scr_bot_empezar() {
	if (!variable_global_exists("botq_pendiente")) global.botq_pendiente = false;
	if (global.botq_pendiente) {
		// Ya pedimos salir de la cola: esperando al servidor
		global.botq_espera--;
		if (global.botq_espera <= 0) {
			global.botq_pendiente = false;
			scr_bot_empezar_viejo();
		}
		return;
	}
	scr_ajustes_default();
	global.match_mapa = irandom(scr_mapa_total() - 1);   // mapa al azar
	scr_bot_rival_nuevo();                              // nombre de persona y personaje del rival
	global.botq_pendiente = true;
	global.botq_espera = BOTQ_ESPERA;
	LeaveRoom();
}

/// ¿Estoy jugando la partida rapida contra el bot nuevo?
function scr_botq_activa() {
	return variable_global_exists("botq") && global.botq;
}

/// El servidor ya me dejo solo en mi sala: arranca la partida con el bot (callback_LeaveRoom)
function scr_botq_arrancar() {
	global.botq_pendiente = false;
	global.botq = true;
	global.bot_partida = false;
	global.serverTeam = "AZUL";
	global.myTeam = "AZUL";
	with (oBrain) {
		AmIPseudoHost = true;
		pseudoHostClientId = global.clientId;
		intro_disparada   = false;
		timer_intro       = 60 * 60;
		bot_espera        = 0;
		puntos_procesados = false;
		victory_alpha     = 0;
		victory_index     = 0;
		abandono_activo   = false;
		abandono_check    = -1;
	}
	global.puntos_azul = 0;
	global.puntos_rojo = 0;
	global.winner_team = 0;
	global.game_over   = false;
	global.pausa       = false;
	global.mi_listo    = false;
	// Los rivales (y tus aliados en 2 VS 2 o mas): bots de sala privada, con nombre de persona (sin "BOT")
	var _tam = variable_global_exists("qp_tam") ? clamp(global.qp_tam, 1, 4) : 1;
	global.max_players_allowed = _tam * 2;
	global.botnet_defs = [{ i: BOTNET_ID_BASE - 4, n: global.bot_nombre, t: "ROJO", r: (_tam >= 3) ? "defensa" : "ataque", h: true, pj: global.bot_pj }];
	var _usados = [global.bot_nombre, global.myName];
	var _k = 1;
	for (var _e = 0; _e < 2; _e++) {
		var _cuantos = (_e == 0) ? (_tam - 1) : (_tam - 1);   // aliados que faltan / rivales que faltan (el primer rival ya esta)
		var _eq = (_e == 0) ? "AZUL" : "ROJO";
		for (var _j = 0; _j < _cuantos; _j++) {
			scr_bot_rival_nuevo();
			var _nom = global.bot_nombre;
			for (var _u = 0; _u < array_length(_usados); _u++) if (_usados[_u] == _nom) _nom += string(_k);
			array_push(_usados, _nom);
			var _rol = (_eq == "AZUL" && _j == 0 && _tam >= 3) ? "defensa" : "ataque";
			array_push(global.botnet_defs, { i: BOTNET_ID_BASE - 4 - _k, n: _nom, t: _eq, r: _rol, h: true, pj: irandom(3) });
			_k++;
		}
	}
	room_goto(scr_mapa_room(global.match_mapa));
}

/// Empieza la partida contra el bot VIEJO (partida offline). Solo si el servidor no contesta.
function scr_bot_empezar_viejo() {
	var _l = scr_bot_rooms();
	scr_ajustes_default();
	var _m = irandom(array_length(_l) - 1);   // mapa al azar
	global.match_mapa = _m;

	global.bot_partida = true;
	LeaveRoom();                 // salir de la cola: el servidor ya no te empareja con nadie
	global.ONLINE = false;       // la partida contra el bot corre como la offline

	global.off_flags   = variable_global_exists("match_banderas") ? global.match_banderas : 3;
	global.puntos_azul = 0;
	global.puntos_rojo = 0;
	global.winner_team = 0;
	global.game_over   = false;
	global.pausa       = false;
	global.mi_listo    = false;  // eliges personaje igual que en línea
	scr_bot_rival_nuevo();       // nombre y personaje del rival
	with (oBrain) {
		intro_disparada   = false;
		timer_intro       = 60 * 60;
		bot_espera        = 0;
		bot_elige_t       = irandom_range(3, 9) * room_speed;   // lo que tarda el rival en elegir
		bot_cambia_t      = 0;
		puntos_procesados = false;
		victory_alpha     = 0;
		victory_index     = 0;
		abandono_activo   = false;
		abandono_check    = -1;
	}
	room_goto(_l[_m]);
}

/// Copas y XP contra el bot (menos que contra una persona)
function scr_bot_premio(_gane) {
	scr_eq_premio(_gane ? 30 : 10);   // monedas (scr_armas, EQUIPAMIENTO)
	if (_gane) {
		global.wins  += 1;
		global.xp    += 20;
		global.copas += 10;
	} else {
		global.losses += 1;
		global.xp     += 5;
		global.copas   = max(0, global.copas - 5);
	}
	while (global.xp >= 100) { global.lvl += 1; global.xp -= 100; }
	scr_save_to_local();
	scr_save_to_cloud();
}

/// Salir de la partida contra el bot. _buscar = true vuelve a buscar rival de una.
function scr_bot_salir(_buscar) {
	global.bot_partida  = false;
	global.botq         = false;   // tambien sirve para la partida contra el bot nuevo
	global.botq_pendiente = false;
	global.bot_rebuscar = _buscar;
	global.ONLINE       = true;
	global.game_over    = false;
	global.pausa        = false;
	global.puntos_azul  = 0;
	global.puntos_rojo  = 0;
	global.winner_team  = 0;
	// OJO: intro_disparada y mi_listo se quedan como están. Si se ponen en false aquí,
	// el mismo ENTER que eligió el botón crea un oPlayer antes de cambiar de room.
	// Se reinician solos al entrar a la siguiente sala (changed_room).
	with (oBrain) {
		puntos_procesados = false;
		victory_alpha     = 0;
		victory_index     = 0;
	}
	room_goto(rm_menu);
}

/// Nombre y personaje al azar para el rival
function scr_bot_rival_nuevo() {
	var _n = ["Kevin_GT", "DaniPro", "xSniperx", "ElChamo", "Lucas07", "SofiGG", "Mateo_RD", "ValeYT",
	          "Santi2010", "Nico_exe", "TomiMX", "Fer_21", "IsaPlays", "Bruno777", "Mia_ctf", "JuanPi",
	          "Rodri_Z", "Camilo", "AleGamer", "Pablito", "Gabo_CR", "Tincho", "Lalo_99", "Emi_pro",
	          "Rafa_YT", "JoseLuis", "Andy_09", "Maxi_ctf", "Kiko", "Leo_GG","ELRUBIUS_OMG"];
	var _nom = _n[irandom(array_length(_n) - 1)];
	if (random(1) < 0.4) _nom += string(irandom_range(1, 99));
	if (variable_global_exists("myName") && _nom == global.myName) _nom += "_";
	global.bot_nombre   = _nom;
	global.bot_pj       = irandom(3);
	global.bot_pj_vista = irandom(3);   // el que "está viendo" mientras elige
	global.bot_listo    = false;
}

/// ¿Quietos? (contra el bot: mientras eligen personaje y durante la intro VS)
function scr_bot_congelado() {
	return variable_global_exists("bot_partida") && global.bot_partida && instance_exists(oBrain)
		&& (!oBrain.intro_disparada || instance_exists(oIntroVersus));
}

/// Selección de personaje contra el bot (en el Step de oBrain). Igual que en línea:
/// el rival cambia de personaje un rato y luego queda listo. Cuando los dos están listos
/// (o se acaba el tiempo) empieza la intro VS.
function scr_bot_selec_step() {
	if (!global.bot_partida || room == rm_menu || intro_disparada) exit;

	if (!global.bot_listo) {
		bot_cambia_t--;
		if (bot_cambia_t <= 0) {
			bot_cambia_t = irandom_range(20, 50);
			global.bot_pj_vista = irandom(3);
		}
		bot_elige_t--;
		if (bot_elige_t <= 0) {
			global.bot_listo = true;
			global.bot_pj_vista = global.bot_pj;
		}
	}

	if (timer_intro > 0) timer_intro--;
	if ((global.mi_listo && global.bot_listo) || timer_intro <= 0) {
		global.mi_listo     = true;
		global.bot_listo    = true;
		global.bot_pj_vista = global.bot_pj;
		timer_intro = -1;
		intro_disparada = true;
		with (oPlayer_offline) scr_bot_pj_jugador();
		scr_trigger_intro(global.myName, global.bot_nombre);
	}
}

/// Sprites de cada personaje (los mismos que en línea)
function scr_bot_sprites(_c) {
	switch (_c) {
		case 1:  spr_idle = spr_miguel_idle;   spr_walk = spr_miguel_walk;   spr_dead = spr_miguel_dead;   break;
		case 2:  spr_idle = spr_marina_idle;   spr_walk = spr_marina_walk;   spr_dead = spr_marina_dead;   break;
		case 3:  spr_idle = spr_sargento_idle; spr_walk = spr_sargento_walk; spr_dead = spr_sargento_dead; break;
		default: spr_idle = spr_player_idle;   spr_walk = spr_player_walk;   spr_dead = spr_player_dead;   break;
	}
}

/// Tu personaje contra el bot (oPlayer_offline): stats, habilidad y sprites del que elegiste
function scr_bot_pj_jugador() {
	mi_clase = clamp(global.pj_selected, 0, 3);
	scr_pj_aplicar();              // vida, velocidad, salto y habilidad (scr_personajes)
	scr_bot_sprites(mi_clase);
	vida_visual = health;
	hab_hp_prev = health;
}

/// Personaje del bot (oPlayer2_local)
function scr_bot_pj_bot() {
	mi_clase    = clamp(global.bot_pj, 0, 3);
	pj          = scr_pj_datos(mi_clase);
	walksp_base = pj.vel;
	jumpsp      = pj.salto;
	hp_max      = pj.vida;
	max_hp      = hp_max;
	hp          = hp_max;
	old_hp      = hp;
	melee_damage = 20 + ((mi_clase == 1) ? TANQUE_GOLPE_EXTRA : 0);   // PASIVA TANQUE (scr_personajes)
	playerName  = global.bot_nombre;
	Name        = playerName;
	scr_bot_sprites(mi_clase);
	scr_bot_hab_reset();
}

/// Limpia la habilidad del bot (al aparecer y al reaparecer)
function scr_bot_hab_reset() {
	hab_cd        = irandom_range(60, 180);
	hab_cor_t     = 0;
	hab_dash_t    = 0;
	hab_dash_vis  = 0;
	hab_sin_danio = 0;
	hab_regen_acc = 0;
	hab_hp_prev   = hp;
}

/// Habilidad y pasivas del bot (Step de oPlayer2_local)
function scr_bot_hab_step() {
	if (!variable_instance_exists(id, "mi_clase")) exit;
	var _fps = game_get_speed(gamespeed_fps);

	// Daño que le llegó desde el frame pasado: el impulso lo esquiva, la coraza lo baja a la mitad
	if (hp < hab_hp_prev && !isDead) {
		var _perdio = hab_hp_prev - hp;
		if (hab_dash_t > 0) hp = hab_hp_prev;
		else if (hab_cor_t > 0) hp += _perdio * (1 - HAB_CORAZA_DANO);
		hab_sin_danio = 0;
	}

	if (hab_cd > 0) hab_cd--;
	if (hab_dash_t > 0) hab_dash_t--;
	if (hab_dash_vis > 0) hab_dash_vis--;
	if (hab_cor_t > 0) hab_cor_t--;
	hab_sin_danio++;

	if (isDead || state == PLAYER2.DEAD) {
		hab_cor_t = 0; hab_dash_t = 0; hab_dash_vis = 0;
		hab_hp_prev = hp;
		exit;
	}

	// PASIVA SARGENTO: si no le pegan en 5 s, se cura solo
	if (mi_clase == 3 && hab_sin_danio > SARG_REGEN_ESPERA && hp < hp_max) {
		hab_regen_acc += SARG_REGEN / _fps;
		if (hab_regen_acc >= 1) {
			var _c = floor(hab_regen_acc);
			hab_regen_acc -= _c;
			hp = min(hp_max, hp + _c);
		}
	}

	// USAR LA HABILIDAD (como lo haría una persona)
	if (hab_cd <= 0) {
		var _dist = 99999;
		if (instance_exists(oPlayer_offline)) {
			var _p = instance_find(oPlayer_offline, 0);
			if (!_p.isDead) _dist = point_distance(x, y, _p.x, _p.y);
		}
		var _usar = false;
		switch (mi_clase) {
			case 0: // ASALTO: impulso para escapar con la bandera o para entrar a pelear
				if ((has_flag && _dist < 260) || (_dist < 200 && random(1) < 0.05)) {
					var _dir = sign(hsp);
					if (_dir == 0) _dir = sign(image_xscale);
					if (_dir == 0) _dir = 1;
					push_h = _dir * HAB_DASH_FUERZA;
					if (vsp > 0) vsp = 0;
					hab_dash_t = HAB_DASH_INVUL;
					hab_dash_vis = 18;
					fx_dust(x, bbox_bottom, 8, -_dir);
					if (global.sfx) audio_play_sound(snd_melee, 5, false, 1, 0, 1.4);
					_usar = true;
				}
			break;
			case 1: // TANQUE: coraza cuando ya le pegaron y tiene al rival cerca
				if (hp < hp_max * 0.75 && _dist < 350) {
					hab_cor_t = HAB_CORAZA_T;
					if (global.sfx) audio_play_sound(snd_shield_impact, 5, false, 1, 0, 0.6);
					_usar = true;
				}
			break;
			case 3: // SARGENTO: botiquín cuando está herido (se cura 30 al instante)
				if (hp < hp_max * 0.5) {
					hp = min(hp_max, hp + SARG_CURA);
					repeat (4) instance_create_layer(x + random_range(-14, 14), y - random_range(4, 30), "Instances", oHealFX);
					if (global.sfx) audio_play_sound(snd_ammo_pickup, 5, false, 1, 0, 0.8);
					_usar = true;
				}
			break;
			// 2 EXPLORADORA: solo sus pasivas (más rápida, carga mejor la bandera)
		}
		hab_cd = _usar ? round(pj.cd * _fps) : 10;   // si no la usó, lo vuelve a pensar en un ratito
	}

	hab_hp_prev = hp;
}

/// Botiquín contra el bot (Step de oBotiquin): cura al de su equipo, sea tu jugador o el bot
function scr_bot_botiquin() {
	var _b = id;
	var _fps = game_get_speed(gamespeed_fps);
	var _curo = noone;

	if (team == global.myTeam) {
		with (oPlayer_offline) {
			if (!isDead && point_distance(_b.x, _b.y, x, y - 20) <= HAB_BOTI_RADIO + 10
			&& variable_instance_exists(id, "max_health") && health < max_health) {
				_b.acc += HAB_BOTI_CURA / _fps;
				if (_b.acc >= 1) {
					var _c = floor(_b.acc);
					_b.acc -= _c;
					health = min(max_health, health + _c);
				}
				_curo = id;
			}
		}
	} else {
		with (oPlayer2_local) {
			if (team == _b.team && !isDead && point_distance(_b.x, _b.y, x, y - 20) <= HAB_BOTI_RADIO + 10 && hp < hp_max) {
				_b.acc += HAB_BOTI_CURA / _fps;
				if (_b.acc >= 1) {
					var _c = floor(_b.acc);
					_b.acc -= _c;
					hp = min(hp_max, hp + _c);
				}
				_curo = id;
			}
		}
	}

	if (_curo != noone) {
		fx_cd--;
		if (fx_cd <= 0) {
			fx_cd = 20;
			instance_create_layer(_curo.x + random_range(-14, 14), _curo.y - random_range(4, 30), "Instances", oHealFX);
		}
	}
}

// ------------------------------------------------------
// MUERTE SUBITA Y EMPATE
// Se acaba el tiempo empatados -> 60 segundos de muerte subita (la siguiente bandera gana).
// Si nadie anota, la partida termina en EMPATE (winner_team = 3): nadie gana ni pierde.
// ------------------------------------------------------
#macro MUERTE_SUBITA_SEG 60

/// Ya se acabaron los segundos de muerte subita? (lo usa el lider)
function scr_muerte_subita_acabo() {
	if (!instance_exists(oBrain)) return false;
	return variable_instance_exists(oBrain, "ms_seg") && oBrain.ms_seg == 0;
}

/// "0:45" de la muerte subita (vacio si todavia no llega el dato)
function scr_muerte_subita_txt() {
	if (!instance_exists(oBrain) || !variable_instance_exists(oBrain, "ms_seg") || oBrain.ms_seg < 0) return "";
	var _s = oBrain.ms_seg;
	return string(_s div 60) + ":" + (((_s mod 60) < 10) ? "0" : "") + string(_s mod 60);
}

/// Quien gana por banderas: 0 nadie, 1 rojo, 2 azul.
/// Si los dos llegan al limite a la vez y van iguales, nadie todavia (se sigue jugando).
function scr_ganador_por_banderas(_lim) {
	var _r = (global.puntos_rojo >= _lim);
	var _a = (global.puntos_azul >= _lim);
	if (_r && !_a) return 1;
	if (_a && !_r) return 2;
	if (_a && _r && global.puntos_rojo != global.puntos_azul) return (global.puntos_rojo > global.puntos_azul) ? 1 : 2;
	return 0;
}

// ------------------------------------------------------
// AVISO GRANDE DE MUERTE SUBITA (opcion B): el texto cae de golpe, rebota,
// la pantalla tiembla y los bordes laten en rojo. Dura ~2.6 s. Cada pantalla lo hace sola.
// ------------------------------------------------------
#macro MS_AVISO_FRAMES 156   // 2.6 segundos a 60 fps

function scr_ms_aviso_step() {
	if (!variable_instance_exists(id, "ms_aviso_t")) { ms_aviso_t = 0; ms_aviso_hecho = false; }
	if (ms_aviso_t > 0) ms_aviso_t--;
	var _entra = reloj_fin && (global.puntos_azul == global.puntos_rojo) && !global.game_over;
	if (_entra && !ms_aviso_hecho) {
		ms_aviso_hecho = true;
		ms_aviso_t = MS_AVISO_FRAMES;
		scrCamShake(6);
	}
}

/// Va en el Draw GUI de oBrain
function scr_ms_aviso_draw() {
	if (!variable_instance_exists(id, "ms_aviso_t") || ms_aviso_t <= 0 || global.game_over) return;
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	var _p = 1 - ms_aviso_t / MS_AVISO_FRAMES;   // 0 -> 1
	var _rojo = make_color_rgb(229, 72, 77);

	// Bordes rojos que laten
	var _va;
	if (_p < 0.1) _va = _p / 0.1;
	else if (_p < 0.85) _va = 0.65 + 0.35 * abs(sin(current_time / 160));
	else _va = 0.65 * (1 - (_p - 0.85) / 0.15);
	var _g = min(_gw, _gh) * 0.12;   // grosor del borde
	draw_set_color(_rojo);
	for (var k = 0; k < 24; k++) {
		var _i = k * _g / 24;
		draw_set_alpha(_va * 0.55 * power(1 - k / 24, 2));
		draw_rectangle(_i, _i, _gw - _i, _gh - _i, true);
		draw_rectangle(_i + 1, _i + 1, _gw - _i - 1, _gh - _i - 1, true);
	}

	// Texto: cae de golpe desde grande, rebota y al final crece y se desvanece
	var _sc, _a;
	if (_p < 0.12) { var _e = 1 - power(1 - _p / 0.12, 3); _sc = 3 - 2.1 * _e; _a = _p / 0.12; }
	else if (_p < 0.18) { _sc = 0.9 + 0.15 * ((_p - 0.12) / 0.06); _a = 1; }
	else if (_p < 0.24) { _sc = 1.05 - 0.05 * ((_p - 0.18) / 0.06); _a = 1; }
	else if (_p < 0.85) { _sc = 1; _a = 1; }
	else { var _q = (_p - 0.85) / 0.15; _sc = 1 + 0.4 * _q; _a = 1 - _q; }

	draw_set_font(fnt_menu);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _t = "MUERTE SUBITA!";
	var _base = (_gw * 0.7) / max(1, string_width(_t));   // que ocupe ~70% del ancho
	var _s = _base * _sc;
	var _cx = _gw / 2, _cy = _gh / 2 - _gh * 0.04;
	draw_set_alpha(_a);
	draw_set_color(c_black);
	draw_text_transformed(_cx + 4, _cy + 4, _t, _s, _s, 0);
	draw_set_color(c_white);
	for (var o = 0; o < 4; o++) draw_text_transformed(_cx + ((o < 2) ? -2 : 2), _cy + ((o mod 2 == 0) ? -2 : 2), _t, _s, _s, 0);
	draw_set_color(_rojo);
	draw_text_transformed(_cx, _cy, _t, _s, _s, 0);

	if (_p > 0.12) {
		var _t2 = "LA SIGUIENTE BANDERA GANA";
		var _s2 = _s * 0.4;
		var _cy2 = _cy + string_height(_t) * _s * 0.6;
		draw_set_color(c_black);
		draw_text_transformed(_cx + 2, _cy2 + 2, _t2, _s2, _s2, 0);
		draw_set_color(c_white);
		draw_text_transformed(_cx, _cy2, _t2, _s2, _s2, 0);
	}

	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

// ======================================================
// MODO BANDERA BOMBA (solo en linea)
//   Cuando una bandera sale de su base empieza una cuenta de BOMBA_SEG segundos.
//   Si llega a 0 y alguien la lleva: explota y ese jugador cae. Si esta en el suelo: explota y vuelve a su base.
//   Vuelve a la cuenta completa cuando la bandera regresa a su base (anotan o la devuelven).
//   Pasarla: tocas a un aliado mientras la llevas y se la pasas (la cuenta sigue).
// Cada juego lleva su propia cuenta (todos ven la bandera igual), cada uno revisa a su jugador
// y el lider a sus bots.
// ======================================================
#macro MODO_BOMBA 1
#macro BOMBA_SEG 15        // segundos que aguanta la bomba fuera de su base
#macro BOMBA_PASE_CD 45    // frames despues de agarrarla en que no se puede pasar (para no devolverla al instante)
#macro BOMBA_NO_COGER 90   // frames que el que la paso no la puede volver a agarrar

function scr_modo_bomba() { return global.ONLINE && scr_modo() == MODO_BOMBA; }

function __bomba_full() { return BOMBA_SEG * game_get_speed(gamespeed_fps); }

/// oBrain Step: cuenta de las dos banderas y la explosion
function scr_bomba_step() {
	if (!scr_modo_bomba() || room == rm_menu || global.game_over) return;
	if (!variable_global_exists("bomba_t") || !is_array(global.bomba_t)) global.bomba_t = [__bomba_full(), __bomba_full()];
	var _fps = game_get_speed(gamespeed_fps);
	var _objs = [oFlag, oFlag2];
	for (var i = 0; i < 2; i++) {
		if (!instance_exists(_objs[i])) continue;
		var _f = instance_find(_objs[i], 0);
		if (!_f.has_flag && abs(_f.x - _f.spawnX) < 1) { global.bomba_t[i] = __bomba_full(); continue; }   // en su base
		global.bomba_t[i] = max(0, global.bomba_t[i] - 1);
		var _t = global.bomba_t[i];
		// Pitido en los ultimos 3 segundos
		if (_t > 0 && _t <= 3 * _fps && (_t mod _fps) == 0 && global.sfx) audio_play_sound(snd_hitmarker, 5, false, 0.6, 0, 1.6);
		if (_t > 0) continue;
		if (_f.has_flag) {
			// La lleva alguien: explota (cada juego revisa a su jugador; el lider a sus bots)
			var _p = _f.portador_instancia;
			if (!instance_exists(_p)) continue;
			if (_p.object_index == oPlayer) {
				with (_p) {
					if (!isDead && health > 0) {
						instance_create_layer(x, y - 16, "Instances", oExplosionFX);
						scrCamShake(12);
						if (global.sfx) audio_play_sound(sndMissileExplode, 10, false);
						health = 0;
					}
				}
			} else if (variable_instance_exists(_p, "es_bot") && _p.es_bot && variable_instance_exists(_p, "bot_local") && _p.bot_local) {
				with (_p) {
					if (!isDead && hp > 0) {
						instance_create_layer(x, y - 16, "Instances", oExplosionFX);
						if (global.sfx && scr_botnet_se_ve(x, y)) audio_play_sound(sndMissileExplode, 10, false);
						last_reason = "bomba"; last_killer = ""; last_killer_id = -1;
						hp = 0;
					}
				}
			}
		} else {
			// En el suelo: explota y vuelve a su base
			instance_create_layer(_f.x, _f.y - 10, "Instances", oExplosionFX);
			scrCamShake(6);
			if (global.sfx) audio_play_sound(sndMissileExplode, 10, false, 0.7);
			with (_f) { x = spawnX; y = spawnY; velocidad_caida = 0; has_flag = false; portador_instancia = noone; sprite_index = spr_suela; }
			if (i == 0) global.bandera_roja_robada = false; else global.bandera_azul_robada = false;
			global.bomba_t[i] = __bomba_full();
		}
	}
}

/// oPlayer Step (cada frame): tiempos y pasar la bomba a un aliado tocandolo
function scr_bomba_jugador_step() {
	if (!variable_instance_exists(id, "bomba_pase_cd")) { bomba_pase_cd = 0; bomba_no_coger = 0; bomba_tenia = false; }
	if (bomba_pase_cd > 0) bomba_pase_cd--;
	if (bomba_no_coger > 0) bomba_no_coger--;
	if (has_flag && !bomba_tenia) bomba_pase_cd = BOMBA_PASE_CD;   // la acabo de agarrar
	bomba_tenia = has_flag;
	if (!scr_modo_bomba() || !has_flag || isDead || bomba_pase_cd > 0) return;
	var _aliado = noone;
	var _yo = id;
	with (oOtherPlayer) {
		if (team != global.myTeam || state == PLAYERSTATE.DEAD || !visible) continue;
		if (variable_instance_exists(id, "has_flag") && has_flag) continue;
		if (point_distance(x, y, _yo.x, _yo.y) < 26) { _aliado = id; break; }
	}
	if (_aliado == noone) return;
	// Se la paso: la suelto donde estoy y el aliado la agarra al tocarla
	has_flag = false;
	bomba_tenia = false;
	bomba_no_coger = BOMBA_NO_COGER;
	var _ban = (global.myTeam == "AZUL") ? oFlag : oFlag2;
	var _dx = _aliado.x, _dy = _aliado.y;
	with (_ban) { has_flag = false; portador_instancia = noone; x = _dx; y = _dy; velocidad_caida = 0; sprite_index = spr_suela; }
	if (instance_exists(oOtherPlayer)) {
		with (oOtherPlayer) { if (!es_bot) SendEventToClient(clientId, "flag_dropped", { team: global.myTeam, dropX: _dx, dropY: _dy }); }
	}
	fb_toast("PASASTE LA BOMBA", "Corre a tu base!", FB_ORO);
}

/// ¿Todavia no la puedo volver a agarrar? (el que la acaba de pasar)
function scr_bomba_no_coger() {
	return scr_modo_bomba() && variable_instance_exists(id, "bomba_no_coger") && bomba_no_coger > 0;
}

/// oBrain Draw GUI: la cuenta encima de cada bandera que salio de su base
function scr_bomba_draw() {
	if (!scr_modo_bomba() || room == rm_menu || global.game_over) return;
	if (!variable_global_exists("bomba_t") || !is_array(global.bomba_t)) return;
	var _cam = view_camera[0];
	var _cvx = camera_get_view_x(_cam), _cvy = camera_get_view_y(_cam);
	var _kx = display_get_gui_width() / max(1, camera_get_view_width(_cam));
	var _ky = display_get_gui_height() / max(1, camera_get_view_height(_cam));
	var _u = clamp(min(display_get_gui_width() / 1280, display_get_gui_height() / 720), 0.6, 1.6);
	var _fps = game_get_speed(gamespeed_fps);
	var _objs = [oFlag, oFlag2];
	for (var i = 0; i < 2; i++) {
		if (!instance_exists(_objs[i])) continue;
		var _f = instance_find(_objs[i], 0);
		if (!_f.has_flag && abs(_f.x - _f.spawnX) < 1) continue;
		var _wx = _f.x, _wy = _f.y - 40;
		if (_f.has_flag && instance_exists(_f.portador_instancia)) { _wx = _f.portador_instancia.x; _wy = _f.portador_instancia.y - 70; }
		var _gx = (_wx - _cvx) * _kx, _gy = (_wy - _cvy) * _ky;
		var _seg = ceil(global.bomba_t[i] / _fps);
		var _urge = (_seg <= 3);
		var _late = _urge && ((current_time div 150) mod 2 == 0);
		var _r = (18 + (_urge ? 3 : 0)) * _u;
		draw_set_alpha(0.5); draw_set_color(c_black);
		draw_circle(_gx, _gy + 3 * _u, _r, false);
		draw_set_alpha(1);
		draw_set_color(_late ? make_color_rgb(229, 72, 77) : make_color_rgb(20, 24, 50));
		draw_circle(_gx, _gy, _r, false);
		draw_set_color(make_color_rgb(11, 15, 26));
		draw_circle(_gx, _gy, _r, true);
		// arco que se vacia
		var _p = clamp(global.bomba_t[i] / __bomba_full(), 0, 1);
		draw_set_color(_urge ? make_color_rgb(255, 120, 60) : make_color_rgb(255, 212, 71));
		var _n = max(2, ceil(32 * _p));
		var _ax = _gx, _ay = _gy - _r + 3 * _u;
		for (var k = 1; k <= _n; k++) {
			var _ang = 90 - 360 * _p * (k / _n);
			var _nx = _gx + lengthdir_x(_r - 3 * _u, _ang), _ny = _gy + lengthdir_y(_r - 3 * _u, _ang);
			draw_line_width(_ax, _ay, _nx, _ny, 3 * _u);
			_ax = _nx; _ay = _ny;
		}
		draw_set_font(fnt_menu); draw_set_halign(fa_center); draw_set_valign(fa_middle);
		draw_set_color(c_white);
		draw_text_transformed(_gx, _gy + 1, string(_seg), 0.7 * _u, 0.7 * _u, 0);
	}
	draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white);
}

// ======================================================
// MODO GRAVEDAD LOCA (solo en linea)
//   Cada GRAV_SEG segundos la gravedad se voltea: todos caen al techo (y luego vuelven al piso).
//   El giro lo decide el lider y se lo manda a todos ("sync_grav"); los demas solo cuentan para
//   mostrar el tiempo y esperan su aviso para voltear (asi nadie se voltea antes que los demas).
//   Si el lider se va, el nuevo lider sigue desde donde iba su cuenta.
//   Las banderas que estan en su base no se mueven; las que estan sueltas si caen al techo.
// ======================================================
#macro MODO_GRAVEDAD 2
#macro GRAV_SEG 30      // segundos entre cada giro
#macro GRAV_AVISO 3     // segundos antes del giro en que sale el aviso grande

function scr_modo_grav() { return global.ONLINE && scr_modo() == MODO_GRAVEDAD; }

/// 1 = normal (hacia abajo), -1 = al reves (hacia el techo)
function scr_grav_dir() {
	if (!scr_modo_grav() || room == rm_menu || !variable_global_exists("grav_dir")) return 1;
	return global.grav_dir;
}

function scr_grav_reset() {
	global.grav_dir = 1;
	global.grav_seg = GRAV_SEG;
	global.grav_frames = 0;
	global.grav_banner_t = 0;
	global.grav_flash = 0;
	global.grav_obj = false;   // los objetos del mapa empiezan a caer desde el primer giro
}

/// oBrain Step: la cuenta del giro
function scr_grav_step() {
	if (!variable_global_exists("grav_dir")) scr_grav_reset();
	if (!scr_modo_grav() || room == rm_menu) {
		if (global.grav_dir != 1 || global.grav_seg != GRAV_SEG) scr_grav_reset();
		return;
	}
	if (global.grav_banner_t > 0) global.grav_banner_t--;
	if (global.grav_flash > 0) global.grav_flash = max(0, global.grav_flash - 1 / (room_speed * 0.45));
	if (global.grav_obj) scr_grav_objetos();   // barriles, armas, municion y poderes caen hacia donde va la gravedad
	if (global.game_over) return;
	if (!intro_disparada || instance_exists(oIntroVersus)) {   // empieza cuando termina la intro (y cada partida empieza normal)
		if (global.grav_dir != 1 || global.grav_seg != GRAV_SEG) scr_grav_reset();
		return;
	}
	global.grav_frames++;
	if (global.grav_frames < room_speed) return;
	global.grav_frames = 0;
	if (global.grav_seg > 0) global.grav_seg--;
	// Pitido en los ultimos segundos
	if (global.grav_seg > 0 && global.grav_seg <= GRAV_AVISO && global.sfx) audio_play_sound(snd_hitmarker, 5, false, 0.6, 0, 1.3);
	if (!AmIPseudoHost) return;   // los demas esperan el aviso del lider
	if (global.grav_seg <= 0) scr_grav_poner(-global.grav_dir, GRAV_SEG);
	scr_grav_enviar();
}

function scr_grav_enviar() {
	var _s = { d: global.grav_dir, s: global.grav_seg };
	with (oOtherPlayer) { if (!es_bot) SendEventToClient(clientId, "sync_grav", _s); }
}

/// Cambia la gravedad (el lider al girar, o los demas cuando llega "sync_grav")
function scr_grav_poner(_dir, _seg) {
	_dir = (_dir < 0) ? -1 : 1;
	if (!variable_global_exists("grav_dir")) scr_grav_reset();
	global.grav_seg = max(0, _seg);
	if (_dir == global.grav_dir) return;
	global.grav_dir = _dir;
	global.grav_banner_t = room_speed * 2;
	global.grav_flash = 1;      // destello blanco en toda la pantalla
	global.grav_obj = true;
	scrCamShake(8);
	if (global.sfx) audio_play_sound(snd_powerdown, 8, false, 1, 0, (_dir < 0) ? 0.8 : 1.25);
}

/// Llamar en el Step de cada jugador (tu jugador y los bots que mueves) antes de moverse:
/// voltea el muñeco (y su figura de choque) cuando cambia la gravedad.
function scr_grav_voltear() {
	var _g = scr_grav_dir();
	if (image_yscale == 0 || sign(image_yscale) == _g) return;
	image_yscale = -image_yscale;
	// Que no quede metido en una pared al voltearse (la figura no es exactamente pareja)
	var _k = 0;
	while (place_meeting(x, y, obj_wall) && _k < 8) { y += _g; _k++; }
}

/// ¿Estoy parado en el techo? (gravedad al reves: pared o la parte de abajo de una plataforma)
function scr_grav_en_techo() {
	if (place_meeting(x, y - 1, obj_wall)) return true;
	var _pl = instance_place(x, y - 1, oPlataformaPasable);
	return (_pl != noone && bbox_top > _pl.bbox_bottom - 2);
}

/// Al reves: las plataformas que se atraviesan te detienen por abajo. Devuelve true si aterrizaste.
function scr_grav_plataforma_techo() {
	if (vsp >= 0) return false;
	var _pl = instance_place(x, y + vsp, oPlataformaPasable);
	if (_pl == noone || bbox_top < _pl.bbox_bottom + vsp) return false;
	y = _pl.bbox_bottom + 1 + (y - bbox_top);
	vsp = 0;
	return true;
}

/// Donde estan los pies (para el polvo al saltar o caer)
function scr_grav_pies() { return (image_yscale < 0) ? bbox_top : bbox_bottom; }

/// 1 si el muñeco esta normal, -1 si esta de cabeza (para dibujar barra, nombre y brazo)
function scr_grav_signo() { return (image_yscale < 0) ? -1 : 1; }

/// Bots con la gravedad al reves: su mapa de caminos esta hecho para caer hacia abajo, asi que
/// aqui solo caminan hacia donde iban y saltan cuando chocan con una pared (o de vez en cuando).
function scr_grav_bot_teclas() {
	var _m = key_right - key_left;
	if (_m == 0) _m = (image_xscale >= 0) ? 1 : -1;
	key_jump = place_meeting(x + _m * 8, y, obj_wall) || (irandom(60) == 0);
	key_left = (_m < 0);
	key_right = (_m > 0);
	nav_quiere_pad = false;
}

/// oBrain Draw GUI: cuanto falta para el giro y el aviso grande
function scr_grav_draw() {
	if (!scr_modo_grav() || room == rm_menu || global.game_over) return;
	if (!variable_global_exists("grav_dir")) return;
	if (!intro_disparada || instance_exists(oIntroVersus)) return;
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	var _u = clamp(min(_gw / 1280, _gh / 720), 0.6, 1.6);
	// Destello blanco al girar (se desvanece en medio segundo)
	if (variable_global_exists("grav_flash") && global.grav_flash > 0) {
		draw_set_alpha(0.9 * global.grav_flash);
		draw_set_color(c_white);
		draw_rectangle(0, 0, _gw, _gh, false);
		draw_set_alpha(1);
	}
	var _seg = global.grav_seg;
	var _urge = (_seg <= GRAV_AVISO);
	draw_set_font(fnt_menu);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);

	// Chip debajo del marcador: GIRO EN 12
	var _cx = _gw / 2, _cy = 104 * _u;
	var _txt = "GIRO EN " + string(_seg);
	var _w = string_width(_txt) * 0.5 * _u + 44 * _u;
	var _col = _urge ? (((current_time div 200) mod 2 == 0) ? make_color_rgb(229, 72, 77) : make_color_rgb(255, 212, 71)) : make_color_rgb(160, 90, 255);
	draw_set_alpha(0.55); draw_set_color(c_black);
	draw_roundrect_ext(_cx - _w / 2, _cy - 13 * _u + 3 * _u, _cx + _w / 2, _cy + 13 * _u + 3 * _u, 12 * _u, 12 * _u, false);
	draw_set_alpha(1); draw_set_color(make_color_rgb(20, 24, 50));
	draw_roundrect_ext(_cx - _w / 2, _cy - 13 * _u, _cx + _w / 2, _cy + 13 * _u, 12 * _u, 12 * _u, false);
	draw_set_color(_col);
	draw_roundrect_ext(_cx - _w / 2, _cy - 13 * _u, _cx + _w / 2, _cy + 13 * _u, 12 * _u, 12 * _u, true);
	// flechita: hacia donde vas a caer despues del giro
	var _ax = _cx - _w / 2 + 16 * _u, _ad = -global.grav_dir;   // -1 = vas a caer hacia arriba
	draw_triangle(_ax - 6 * _u, _cy - 3 * _u * _ad, _ax + 6 * _u, _cy - 3 * _u * _ad, _ax, _cy + 7 * _u * _ad, false);
	draw_set_color(c_white);
	draw_text_transformed(_cx + 8 * _u, _cy + 1, _txt, 0.5 * _u, 0.5 * _u, 0);

	// Aviso grande: los ultimos segundos y justo despues del giro
	var _big = "", _bc = c_white;
	if (global.grav_banner_t > 0) {
		_big = (global.grav_dir < 0) ? "GRAVEDAD AL REVES!" : "GRAVEDAD NORMAL!";
		_bc = ((current_time div 150) mod 2 == 0) ? make_color_rgb(255, 212, 71) : c_white;
	} else if (_urge && _seg > 0) {
		_big = "LA GRAVEDAD SE VOLTEA EN " + string(_seg);
		_bc = make_color_rgb(255, 212, 71);
	}
	if (_big != "") {
		var _by = _gh * 0.3;
		var _bs = 0.9 * _u;
		draw_text_transformed_color(_cx + 3 * _u, _by + 3 * _u, _big, _bs, _bs, 0, c_black, c_black, c_black, c_black, 0.8);
		draw_text_transformed_color(_cx, _by, _big, _bs, _bs, 0, _bc, _bc, _bc, _bc, 1);
	}
	draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white); draw_set_alpha(1);
}

/// Los objetos sueltos del mapa caen hacia donde va la gravedad (oBrain Step, solo GRAVEDAD LOCA).
/// Cada pantalla los mueve igual: todos se voltean al mismo tiempo y caen derechito.
function scr_grav_objetos() {
	with (oExplosiveBarrel) scr_grav_objeto();   // tambien los barriles chiquitos (son hijos)
	with (oGun) { if (!taken) scr_grav_objeto(); }
	with (oAmmoPack) { if (!variable_instance_exists(id, "taken") || !taken) scr_grav_objeto(); }
	with (oPowerupPickup) { if (!variable_instance_exists(id, "taken") || !taken) scr_grav_objeto(); }
}

/// Un objeto cae (con la instancia): se para en paredes y plataformas, en el piso o en el techo.
function scr_grav_objeto() {
	if (!variable_instance_exists(id, "grav_vy")) grav_vy = 0;
	var _g = global.grav_dir;
	if (place_meeting(x, y, obj_wall)) { grav_vy = 0; return; }   // metido en una pared: no se mueve
	// ¿Ya esta apoyado?
	var _apoyo = place_meeting(x, y + _g, obj_wall);
	if (!_apoyo && !place_meeting(x, y, oPlataformaPasable)) {
		var _pl = instance_place(x, y + _g, oPlataformaPasable);
		if (_pl != noone) _apoyo = (_g > 0) ? (bbox_bottom <= _pl.bbox_top + 1) : (bbox_top >= _pl.bbox_bottom - 1);
	}
	if (_apoyo) { grav_vy = 0; return; }
	grav_vy = clamp(grav_vy + 0.4 * _g, -12, 12);
	var _s = sign(grav_vy);
	if (_s == 0) return;
	if (place_meeting(x, y + grav_vy, obj_wall)) {
		var _k = 0;
		while (!place_meeting(x, y + _s, obj_wall) && _k < 16) { y += _s; _k++; }
		grav_vy = 0;
		return;
	}
	if (!place_meeting(x, y, oPlataformaPasable)) {
		var _p2 = instance_place(x, y + grav_vy, oPlataformaPasable);
		if (_p2 != noone) {
			if (_s > 0 && bbox_bottom <= _p2.bbox_top) { y = _p2.bbox_top - 1 - (bbox_bottom - y); grav_vy = 0; return; }
			if (_s < 0 && bbox_top >= _p2.bbox_bottom) { y = _p2.bbox_bottom + 1 + (y - bbox_top); grav_vy = 0; return; }
		}
	}
	y += grav_vy;
	// Por si un mapa no tuviera techo o piso: que no se vaya para siempre
	if (y < -100 || y > room_height + 100) { y = clamp(y, -100, room_height + 100); grav_vy = 0; }
}

// ======================================================
// MODO REY DE LA BANDERA (solo en linea)
//   No hay banderas que robar: hay una ZONA en el centro del mapa con una bandera blanca.
//   El equipo que esta solo en la zona (sin rivales adentro) va llenando su barra.
//   Si hay de los dos equipos adentro, la zona esta EN DISPUTA y nadie suma.
//   Gana el primero que llega a 100%. Si se acaba el tiempo, gana el que lleve mas (igual = EMPATE).
//   Lo cuenta el lider y se lo manda a todos ("sync_rey").
// ======================================================
#macro MODO_REY 4
#macro REY_SEG 60          // segundos dentro de la zona (sin rivales) para llegar a 100%
#macro REY_ANCHO 90        // mitad del ancho de la zona
#macro REY_ALTO 100        // alto de la zona (desde el piso hacia arriba)

function scr_modo_rey() { return global.ONLINE && scr_modo() == MODO_REY; }

function scr_rey_reset() {
	global.rey_a = 0;      // azul (0 a 100)
	global.rey_r = 0;      // rojo (0 a 100)
	global.rey_c = 0;      // quien tiene la zona: 0 nadie, 1 AZUL, 2 ROJO, 3 en disputa
	global.rey_envio = 0;
}

/// Donde va la zona: en el centro del mapa, sobre el primer piso o plataforma de la mitad para abajo.
/// Todos la calculan igual (mismo mapa = misma zona).
function scr_rey_zona() {
	if (variable_global_exists("rey_room") && global.rey_room == room) return;
	global.rey_room = room;
	var _cx = room_width / 2;
	var _sy = room_height - 160;
	for (var _y = room_height * 0.5; _y < room_height; _y += 2) {
		if (collision_point(_cx, _y, obj_wall, false, true) != noone || collision_point(_cx, _y, oPlataformaPasable, false, true) != noone) { _sy = _y; break; }
	}
	global.rey_x = _cx;
	global.rey_y = _sy;
}

function scr_rey_dentro(_x, _y) {
	return point_in_rectangle(_x, _y, global.rey_x - REY_ANCHO, global.rey_y - REY_ALTO, global.rey_x + REY_ANCHO, global.rey_y + 6);
}

/// oBrain Step
function scr_rey_step() {
	if (!scr_modo_rey() || room == rm_menu) return;
	scr_rey_zona();
	if (!variable_global_exists("rey_a")) scr_rey_reset();
	if (global.game_over) return;
	if (!intro_disparada || instance_exists(oIntroVersus)) {   // cada partida empieza en 0
		if (global.rey_a != 0 || global.rey_r != 0 || global.rey_c != 0) scr_rey_reset();
		return;
	}
	if (!AmIPseudoHost) return;   // los demas solo muestran lo que manda el lider
	// Quien esta en la zona (vivos)
	var _na = 0, _nr = 0;
	with (oPlayer) {
		if (!isDead && state != PLAYERSTATE.DEAD && visible && scr_rey_dentro(x, y)) { if (global.myTeam == "AZUL") _na++; else _nr++; }
	}
	with (oOtherPlayer) {
		if (team == "" || state == PLAYERSTATE.DEAD || !visible) continue;
		if (variable_instance_exists(id, "isDead") && isDead) continue;
		if (!scr_rey_dentro(x, y)) continue;
		if (team == "AZUL") _na++; else if (team == "ROJO") _nr++;
	}
	var _c = 0;
	if (_na > 0 && _nr == 0) _c = 1;
	else if (_nr > 0 && _na == 0) _c = 2;
	else if (_na > 0 && _nr > 0) _c = 3;
	var _paso = 100 / (REY_SEG * room_speed);
	if (_c == 1) global.rey_a = min(100, global.rey_a + _paso);
	if (_c == 2) global.rey_r = min(100, global.rey_r + _paso);
	if (_c != global.rey_c) { scr_rey_cambio(_c); global.rey_envio = 0; }
	global.rey_envio--;
	if (global.rey_envio <= 0) {
		global.rey_envio = 10;   // 6 veces por segundo
		var _m = { a: global.rey_a, r: global.rey_r, c: global.rey_c };
		with (oOtherPlayer) { if (!es_bot) SendEventToClient(clientId, "sync_rey", _m); }
	}
}

/// Cambio de quien tiene la zona (sonidito si la toma alguien)
function scr_rey_cambio(_c) {
	global.rey_c = _c;
	if (!global.sfx) return;
	var _mio = (global.myTeam == "AZUL") ? 1 : 2;
	if (_c == _mio) audio_play_sound(snd_grab, 6, false, 0.9, 0, 1.3);
	else if (_c == 1 || _c == 2) audio_play_sound(snd_grab, 6, false, 0.9, 0, 0.7);
}

/// El lider: ¿ya gano alguien? (1 ROJO, 2 AZUL, 3 EMPATE, 0 todavia)
function scr_rey_ganador() {
	if (!variable_global_exists("rey_a")) return 0;
	if (global.rey_a >= 100 && global.rey_a > global.rey_r) return 2;
	if (global.rey_r >= 100 && global.rey_r > global.rey_a) return 1;
	if (oBrain.reloj_fin) {
		if (floor(global.rey_a) != floor(global.rey_r)) return (global.rey_r > global.rey_a) ? 1 : 2;
		return 3;
	}
	return 0;
}

function __rey_col(_c) {
	switch (_c) {
		case 1: return make_color_rgb(31, 155, 255);
		case 2: return make_color_rgb(229, 72, 77);
		case 3: return make_color_rgb(255, 212, 71);
	}
	return c_white;
}

/// La zona en el mapa (Draw de oFlag; las banderas normales no se dibujan en este modo)
function scr_rey_draw_zona() {
	if (!variable_global_exists("rey_x")) return;
	var _c = variable_global_exists("rey_c") ? global.rey_c : 0;
	var _col = __rey_col(_c);
	var _x1 = global.rey_x - REY_ANCHO, _x2 = global.rey_x + REY_ANCHO;
	var _y1 = global.rey_y - REY_ALTO, _y2 = global.rey_y;
	var _pul = 0.5 + 0.5 * sin(current_time / 250);
	// Relleno que sube desde el piso
	draw_set_alpha(0.12 + 0.06 * _pul);
	draw_rectangle_colour(_x1, _y1, _x2, _y2, _col, _col, _col, _col, false);
	draw_set_alpha(0.35);
	draw_rectangle_colour(_x1, _y2 - 18, _x2, _y2, _col, _col, _col, _col, false);
	// Borde
	draw_set_alpha(0.6 + 0.4 * _pul);
	draw_set_color(_col);
	draw_line_width(_x1, _y1, _x1, _y2, 3);
	draw_line_width(_x2, _y1, _x2, _y2, 3);
	draw_line_width(_x1, _y2, _x2, _y2, 4);
	// Esquinitas arriba
	draw_line_width(_x1, _y1, _x1 + 16, _y1, 3);
	draw_line_width(_x2 - 16, _y1, _x2, _y1, 3);
	draw_set_alpha(1);
	// Bandera blanca en el centro (ondea)
	var _px = global.rey_x, _pb = _y2, _pt = _y2 - 64;
	draw_set_color(make_color_rgb(220, 220, 230));
	draw_line_width(_px, _pb, _px, _pt, 3);
	var _o = sin(current_time / 180) * 4;
	var _fc = (_c == 0) ? c_white : _col;
	draw_set_color(_fc);
	draw_triangle(_px + 1, _pt, _px + 30, _pt + 9 + _o, _px + 1, _pt + 20, false);
	draw_set_color(c_white);
}

/// Marcador de arriba en este modo (reemplaza al de las banderas). _mx centro, _y arriba.
function scr_rey_draw_marcador(_mx, _y) {
	if (!variable_global_exists("rey_a")) return;
	var _h = 64, _wb = 210, _gap = 70;
	var _cy = _y + _h / 2;
	var _total = _wb * 2 + _gap * 2 + 20;
	var _x0 = _mx - _total / 2;
	draw_set_alpha(0.55); draw_set_color(c_black);
	draw_roundrect_ext(_x0, _y + 6, _x0 + _total, _y + _h + 6, 20, 20, false);
	draw_set_alpha(1); draw_set_color(make_color_rgb(20, 24, 50));
	draw_roundrect_ext(_x0, _y, _x0 + _total, _y + _h, 20, 20, false);
	draw_set_color(make_color_rgb(11, 15, 26));
	draw_roundrect_ext(_x0, _y, _x0 + _total, _y + _h, 20, 20, true);
	var _azul = make_color_rgb(31, 155, 255), _rojo = make_color_rgb(229, 72, 77);
	// Barras: azul se llena hacia el centro desde la izquierda, roja desde la derecha
	var _by1 = _cy - 4, _by2 = _cy + 14;
	var _ax1 = _x0 + 14, _ax2 = _ax1 + _wb;
	var _rx2 = _x0 + _total - 14, _rx1 = _rx2 - _wb;
	draw_set_color(make_color_rgb(40, 46, 66));
	draw_roundrect_ext(_ax1, _by1, _ax2, _by2, 8, 8, false);
	draw_roundrect_ext(_rx1, _by1, _rx2, _by2, 8, 8, false);
	var _pa = clamp(global.rey_a / 100, 0, 1), _pr = clamp(global.rey_r / 100, 0, 1);
	draw_set_color(_azul);
	if (_pa > 0.02) draw_roundrect_ext(_ax1, _by1, _ax1 + _wb * _pa, _by2, 8, 8, false);
	draw_set_color(_rojo);
	if (_pr > 0.02) draw_roundrect_ext(_rx2 - _wb * _pr, _by1, _rx2, _by2, 8, 8, false);
	// Brillo en la barra del que tiene la zona
	var _brillo = 0.25 + 0.25 * sin(current_time / 120);
	if (global.rey_c == 1 && _pa > 0.02) { draw_set_alpha(_brillo); draw_set_color(c_white); draw_roundrect_ext(_ax1, _by1, _ax1 + _wb * _pa, _by2, 8, 8, false); draw_set_alpha(1); }
	if (global.rey_c == 2 && _pr > 0.02) { draw_set_alpha(_brillo); draw_set_color(c_white); draw_roundrect_ext(_rx2 - _wb * _pr, _by1, _rx2, _by2, 8, 8, false); draw_set_alpha(1); }
	// Textos
	draw_set_font(fnt_menu); draw_set_valign(fa_middle);
	draw_set_halign(fa_left);  draw_set_color(_azul);
	draw_text_transformed(_ax1 + 4, _y + 14, "AZUL " + string(floor(global.rey_a)) + "%", 0.45, 0.45, 0);
	draw_set_halign(fa_right); draw_set_color(_rojo);
	draw_text_transformed(_rx2 - 4, _y + 14, string(floor(global.rey_r)) + "% ROJO", 0.45, 0.45, 0);
	// Centro: reloj (o corona)
	draw_set_halign(fa_center); draw_set_color(c_white);
	var _txt = "REY";
	if (scr_reloj_visible()) {
		var _m = oBrain.reloj_seg div 60, _s = oBrain.reloj_seg mod 60;
		_txt = string(_m) + ":" + ((_s < 10) ? "0" : "") + string(_s);
	}
	draw_text_transformed(_mx, _cy + 2, _txt, 0.6, 0.6, 0);
	// Debajo: quien tiene la zona
	var _est = "ZONA LIBRE", _ec = c_white;
	switch (global.rey_c) {
		case 1: _est = "AZUL TIENE LA ZONA"; _ec = _azul; break;
		case 2: _est = "ROJO TIENE LA ZONA"; _ec = _rojo; break;
		case 3: _est = "ZONA EN DISPUTA"; _ec = ((current_time div 250) mod 2 == 0) ? make_color_rgb(255, 212, 71) : c_white; break;
	}
	draw_set_color(c_black);
	draw_text_transformed(_mx + 2, _y + _h + 20, _est, 0.5, 0.5, 0);
	draw_set_color(_ec);
	draw_text_transformed(_mx, _y + _h + 18, _est, 0.5, 0.5, 0);
	draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white); draw_set_alpha(1);
}

// ======================================================
// MODO PISO DE LAVA (solo en linea)
//   Captura la bandera normal, pero la lava sube en oleadas:
//   CALMA (abajo, en el piso)  ->  SUBE (sube LAVA_ALTO pixeles)  ->  SE QUEDA arriba  ->  BAJA.
//   Tocar la lava = eliminado. Las bases quedan bajo la lava un rato: hay que esperar o apurarse.
//   Si reapareces y tu base esta bajo la lava, sales en el lugar seguro mas cercano.
//   Una bandera que cae en la lava regresa sola a su base.
//   El lider lleva la cuenta y la manda a todos ("sync_lava"); todos calculan la altura igual.
// ======================================================
#macro MODO_LAVA 5
#macro LAVA_CALMA 20    // segundos con la lava abajo
#macro LAVA_SUBE 10     // segundos subiendo
#macro LAVA_ARRIBA 8    // segundos arriba
#macro LAVA_BAJA 6      // segundos bajando
#macro LAVA_ALTO 280    // cuanto sube (pixeles sobre el piso)
#macro LAVA_AVISO 3     // segundos antes de subir en que sale el aviso

function scr_modo_lava() { return global.ONLINE && scr_modo() == MODO_LAVA; }

function scr_lava_reset() {
	global.lava_c = 0;          // frames del ciclo
	global.lava_envio = 0;
	global.lava_y = 99999;
	global.lava_fx = [];        // salpicaduras
	global.lava_flash = 0;      // destello naranja (solo si caes tu)
	global.lava_msg_t = 0;      // letrero TE QUEMASTE EN LA LAVA
}

/// Donde esta el piso del mapa (lo mas bajo donde se puede parar); todos lo calculan igual
function scr_lava_piso() {
	if (variable_global_exists("lava_room") && global.lava_room == room) return global.lava_piso;
	global.lava_room = room;
	var _p = room_height;
	var _cx = room_width / 2;
	// Piso: el primer muro que hay bajando desde la mitad, revisando varias columnas (el mas bajo)
	var _mejor = -1;
	for (var _i = 1; _i <= 7; _i++) {
		var _x = room_width * _i / 8;
		for (var _y = room_height * 0.5; _y < room_height; _y += 2) {
			if (collision_point(_x, _y, obj_wall, false, true) != noone) { _mejor = max(_mejor, _y); break; }
		}
	}
	if (_mejor > 0) _p = _mejor;
	global.lava_piso = _p;
	return _p;
}

function __lava_total() { return (LAVA_CALMA + LAVA_SUBE + LAVA_ARRIBA + LAVA_BAJA) * room_speed; }

/// Altura de la lava (0 = abajo, 1 = arriba) segun el ciclo
function scr_lava_nivel() {
	var _f = room_speed;
	var _c = global.lava_c mod __lava_total();
	var _a = LAVA_CALMA * _f, _b = _a + LAVA_SUBE * _f, _d = _b + LAVA_ARRIBA * _f;
	if (_c < _a) return 0;
	if (_c < _b) { var _p = (_c - _a) / (LAVA_SUBE * _f); return _p * _p * (3 - 2 * _p); }
	if (_c < _d) return 1;
	var _q = (_c - _d) / (LAVA_BAJA * _f);
	return 1 - _q * _q * (3 - 2 * _q);
}

/// 0 calma, 1 subiendo, 2 arriba, 3 bajando; y segundos que faltan para el siguiente cambio
function scr_lava_fase() {
	var _f = room_speed;
	var _c = global.lava_c mod __lava_total();
	var _a = LAVA_CALMA * _f, _b = _a + LAVA_SUBE * _f, _d = _b + LAVA_ARRIBA * _f, _e = __lava_total();
	if (_c < _a) return { f: 0, s: ceil((_a - _c) / _f) };
	if (_c < _b) return { f: 1, s: ceil((_b - _c) / _f) };
	if (_c < _d) return { f: 2, s: ceil((_d - _c) / _f) };
	return { f: 3, s: ceil((_e - _c) / _f) };
}

/// oBrain Step
function scr_lava_step() {
	if (!scr_modo_lava() || room == rm_menu) return;
	if (!variable_global_exists("lava_c")) scr_lava_reset();
	var _piso = scr_lava_piso();
	if (!intro_disparada || instance_exists(oIntroVersus)) {   // cada partida empieza con la lava abajo
		if (global.lava_c != 0) scr_lava_reset();
		global.lava_y = _piso + 6;
		return;
	}
	if (!global.game_over) {
		var _antes = scr_lava_fase().f;
		global.lava_c++;
		var _f = scr_lava_fase();
		// Pitido antes de subir y aviso al empezar a subir
		if (_f.f == 0 && _f.s <= LAVA_AVISO && (global.lava_c mod room_speed) == 0 && global.sfx) audio_play_sound(snd_hitmarker, 5, false, 0.6, 0, 0.8);
		if (_antes == 0 && _f.f == 1) { scrCamShake(6); if (global.sfx) audio_play_sound(sndMissileExplode, 6, false, 0.5, 0, 0.6); }
		if (AmIPseudoHost) {
			global.lava_envio--;
			if (global.lava_envio <= 0) {
				global.lava_envio = room_speed;   // una vez por segundo
				var _m = { c: global.lava_c };
				with (oOtherPlayer) { if (!es_bot) SendEventToClient(clientId, "sync_lava", _m); }
			}
		}
	}
	// Ondita encima, igual en todas las pantallas
	global.lava_y = _piso + 6 - LAVA_ALTO * scr_lava_nivel();
	// Salpicaduras (las ve cada pantalla sola)
	if (!variable_global_exists("lava_fx")) { global.lava_fx = []; global.lava_flash = 0; global.lava_msg_t = 0; }
	for (var _i = array_length(global.lava_fx) - 1; _i >= 0; _i--) {
		global.lava_fx[_i].t += 1;
		if (global.lava_fx[_i].t > room_speed * 1.6) array_delete(global.lava_fx, _i, 1);
	}
	if (global.lava_flash > 0) global.lava_flash = max(0, global.lava_flash - 1 / (room_speed * 0.35));
	if (global.lava_msg_t > 0) global.lava_msg_t--;
	if (global.game_over) return;
	var _ly = global.lava_y;
	// ¿Alguien acaba de caer en la lava? (tu, las personas y los bots): salpica
	with (oPlayer) scr_lava_chapuzon(_ly, true);
	with (oOtherPlayer) scr_lava_chapuzon(_ly, false);

	// Tu jugador
	with (oPlayer) {
		if (!isDead && state != PLAYERSTATE.DEAD && health > 0 && bbox_bottom > _ly + 8) {
			death_reason = "lava";
			last_killer = "";
			health = 0;
			if (global.sfx) audio_play_sound(sndMissileExplode, 8, false, 0.6, 0, 1.4);
			fx_dust(x, _ly, 14, 0);
		}
	}
	// Los bots que muevo yo
	with (oOtherPlayer) {
		if (!bot_local || isDead || hp <= 0) continue;
		if (bbox_bottom > _ly + 8) {
			last_reason = "lava";
			last_killer = "";
			last_killer_id = -1;
			hp = 0;
		}
	}
	// Bandera en la lava: regresa a su base
	with (oFlag) {
		if (!has_flag && y > _ly && x != spawnX) { x = spawnX; y = spawnY; velocidad_caida = 0; portador_instancia = noone; global.bandera_roja_robada = false; }
	}
	with (oFlag2) {
		if (!has_flag && y > _ly && x != spawnX) { x = spawnX; y = spawnY; velocidad_caida = 0; portador_instancia = noone; global.bandera_azul_robada = false; }
	}
}

/// Con la instancia de un jugador: salpica cuando entra a la lava y lo pinta de quemado
function scr_lava_chapuzon(_ly, _yo) {
	if (!variable_instance_exists(id, "lava_in")) { lava_in = false; lava_tinte = false; }
	var _dentro = visible && bbox_bottom > _ly + 8;
	if (_dentro && !lava_in) {
		lava_in = true;
		scr_lava_salpicar(x, _ly);
		image_blend = make_color_rgb(90, 25, 10);   // quemado
		lava_tinte = true;
		if (_yo) { global.lava_flash = 1; global.lava_msg_t = room_speed * 2; }
		else if (global.sfx) audio_play_sound(sndMissileExplode, 4, false, 0.35, 0, 1.6);
	} else if (!_dentro && lava_in) {
		lava_in = false;
	}
	// Ya reaparecio: vuelve a su color
	if (lava_tinte && !_dentro && visible && state != PLAYERSTATE.DEAD) { image_blend = c_white; lava_tinte = false; }
}

/// Una salpicadura en la superficie de la lava (x del mundo)
function scr_lava_salpicar(_x, _ly) {
	var _g = [], _c = [];
	repeat (16) array_push(_g, [random_range(-4, 4), random_range(-9, -4), random_range(3, 6)]);
	repeat (18) array_push(_c, [random_range(-2, 2), random_range(-5, -2), random(0.6)]);
	array_push(global.lava_fx, { x: _x, y: _ly, t: 0, g: _g, c: _c });
	if (array_length(global.lava_fx) > 12) array_delete(global.lava_fx, 0, 1);
}

/// Llega "sync_lava" del lider
function scr_lava_sync(_c) {
	if (!variable_global_exists("lava_c")) scr_lava_reset();
	global.lava_c = max(0, _c);
}

/// Al reaparecer (con la instancia): si mi base esta bajo la lava, al lugar seguro mas cercano
function scr_lava_reubicar() {
	if (!scr_modo_lava() || !variable_global_exists("lava_y")) return;
	// Peor caso: la lava puede llegar arriba mientras reapareces; buscamos algo por encima de lo mas alto
	var _limite = min(global.lava_y, scr_lava_piso() + 6 - LAVA_ALTO) - 50;
	if (bbox_bottom < _limite) return;
	var _mejor = noone, _bd = 999999, _yo = id;
	with (oSpawnPoint) {
		if (y > _limite) continue;
		var _d = abs(x - _yo.x) + abs(y - _yo.y) * 0.5;
		if (_d < _bd) { _bd = _d; _mejor = id; }
	}
	if (_mejor == noone) return;
	x = _mejor.x;
	y = _mejor.y;
	var _n = 0;
	while (place_meeting(x, y, obj_wall) && _n < 300) { y -= 1; _n++; }
	if (variable_instance_exists(id, "latest_x")) latest_x = x;
	if (variable_instance_exists(id, "latest_y")) latest_y = y;
	if (variable_instance_exists(id, "net_x")) { net_x = x; net_y = y; }
}

/// oBrain Draw GUI (antes del marcador): la lava encima del mapa, y el aviso
function scr_lava_draw() {
	if (!scr_modo_lava() || room == rm_menu || !variable_global_exists("lava_y")) return;
	var _cam = view_camera[0];
	var _cvx = camera_get_view_x(_cam), _cvy = camera_get_view_y(_cam);
	var _cvw = max(1, camera_get_view_width(_cam)), _cvh = max(1, camera_get_view_height(_cam));
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	var _kx = _gw / _cvw, _ky = _gh / _cvh;
	var _ly = (global.lava_y - _cvy) * _ky;   // arriba de la lava en la pantalla
	if (_ly < _gh + 20) {
		var _t = current_time / 1000;
		var _naranja = make_color_rgb(255, 130, 40), _rojo = make_color_rgb(200, 40, 20), _amar = make_color_rgb(255, 212, 71);
		// Cuerpo de la lava
		draw_set_alpha(0.92);
		draw_rectangle_colour(0, _ly + 6, _gw, _gh, _naranja, _naranja, _rojo, _rojo, false);
		// Olas encima
		var _paso = 16;
		for (var _x = 0; _x < _gw + _paso; _x += _paso) {
			var _wx = (_x / _kx) + _cvx;   // x del mundo: las olas no se mueven con la camara
			var _a = sin(_wx * 0.04 + _t * 3) * 4 + sin(_wx * 0.013 - _t * 2) * 3;
			var _b = sin((_wx + _paso / _kx) * 0.04 + _t * 3) * 4 + sin((_wx + _paso / _kx) * 0.013 - _t * 2) * 3;
			draw_set_color(_naranja);
			draw_triangle(_x, _ly + _a, _x + _paso, _ly + _b, _x, _ly + 8, false);
			draw_triangle(_x + _paso, _ly + _b, _x + _paso, _ly + 8, _x, _ly + 8, false);
		}
		// Brillo en la orilla
		draw_set_alpha(0.8);
		draw_set_color(_amar);
		draw_line_width(0, _ly + 2, _gw, _ly + 2, 2);
		// Burbujas
		draw_set_alpha(0.7);
		for (var _i = 0; _i < 14; _i++) {
			var _bx = ((_i * 173 + _t * 20 * (1 + (_i mod 3))) mod (_gw + 40)) - 20;
			var _ciclo = frac(_t * 0.6 + _i * 0.37);
			var _by = _ly + 10 + (1 - _ciclo) * 50;
			draw_circle(_bx, _by, (2 + (_i mod 3)) * (1 - _ciclo * 0.5), false);
		}
		draw_set_alpha(1);
		// Calor: brillo arriba de la lava
		draw_set_alpha(0.18);
		draw_rectangle_colour(0, _ly - 40, _gw, _ly, c_black, c_black, _naranja, _naranja, false);
		draw_set_alpha(1);
	}

	// Salpicaduras: anillos, gotas, chispas y humo
	if (variable_global_exists("lava_fx")) {
		var _naranja2 = make_color_rgb(255, 130, 40), _amar2 = make_color_rgb(255, 212, 71);
		for (var _i = 0; _i < array_length(global.lava_fx); _i++) {
			var _s = global.lava_fx[_i];
			var _dt = _s.t / room_speed;             // segundos desde que cayo
			var _sx = (_s.x - _cvx) * _kx;
			var _sy = (_s.y - _cvy) * _ky;
			if (_sx < -150 || _sx > _gw + 150 || _sy < -150 || _sy > _gh + 150) continue;
			// Anillos en la superficie
			for (var _k = 0; _k < 2; _k++) {
				var _r = (_dt * 90 - _k * 25) * _kx;
				if (_r <= 0 || _r >= 120 * _kx) continue;
				var _a = 1 - _r / (120 * _kx);
				draw_set_alpha(0.9);
				draw_set_color(merge_colour(_naranja2, _amar2, _a));
				draw_ellipse(_sx - _r, _sy - _r * 0.18, _sx + _r, _sy + _r * 0.18, true);
				draw_ellipse(_sx - _r + 1, _sy - _r * 0.18 + 1, _sx + _r - 1, _sy + _r * 0.18 - 1, true);
			}
			// Humo
			for (var _k = 0; _k < 5; _k++) {
				var _tt = _dt - _k * 0.12;
				if (_tt <= 0 || _tt >= 1.6) continue;
				var _hx = _sx + sin(_k * 2.1) * 14 * _kx, _hy = _sy - (12 + _tt * 55) * _ky;
				draw_set_alpha(0.55 * (1 - _tt / 1.6));
				draw_set_color(make_color_rgb(90, 90, 95));
				draw_circle(_hx, _hy, (8 + _tt * 14) * _kx, false);
			}
			// Gotas de lava que saltan y caen
			if (_dt < 1.4) {
				for (var _k = 0; _k < array_length(_s.g); _k++) {
					var _gg = _s.g[_k];
					var _f = _dt * 30;
					var _gx = _sx + _gg[0] * _f * _kx;
					var _gy = _sy + (_gg[1] * _f + 0.5 * 20 * _f * _f / 30) * _ky;
					if (_gy > _sy + 4 * _ky) continue;
					draw_set_alpha(1);
					draw_set_color(_amar2);
					draw_circle(_gx, _gy, (_gg[2] + 1) * _kx, false);
					draw_set_color(_naranja2);
					draw_circle(_gx, _gy, _gg[2] * _kx, false);
				}
			}
			// Chispas
			for (var _k = 0; _k < array_length(_s.c); _k++) {
				var _cc = _s.c[_k];
				var _tt = _dt - _cc[2];
				if (_tt <= 0 || _tt >= 1.2) continue;
				var _a2 = 1 - _tt / 1.2;
				draw_set_alpha(_a2);
				draw_set_color(make_color_rgb(255, 150 + floor(100 * _a2), floor(60 * _a2)));
				var _px = _sx + _cc[0] * _tt * 40 * _kx, _py = _sy + (-10 + _cc[1] * _tt * 40) * _ky;
				draw_rectangle(_px - 1.5 * _kx, _py - 1.5 * _kx, _px + 1.5 * _kx, _py + 1.5 * _kx, false);
			}
		}
		draw_set_alpha(1);
		// Destello naranja y letrero (solo si caiste tu)
		if (global.lava_flash > 0) {
			draw_set_alpha(0.45 * global.lava_flash);
			draw_set_color(make_color_rgb(255, 120, 30));
			draw_rectangle(0, 0, _gw, _gh, false);
			draw_set_alpha(1);
		}
		if (global.lava_msg_t > 0) {
			var _u2 = clamp(min(_gw / 1280, _gh / 720), 0.6, 1.6);
			draw_set_font(fnt_menu); draw_set_halign(fa_center); draw_set_valign(fa_middle);
			draw_text_transformed_color(_gw / 2 + 3 * _u2, _gh * 0.22 + 3 * _u2, "TE QUEMASTE EN LA LAVA", 0.8 * _u2, 0.8 * _u2, 0, c_black, c_black, c_black, c_black, 0.8);
			draw_text_transformed_color(_gw / 2, _gh * 0.22, "TE QUEMASTE EN LA LAVA", 0.8 * _u2, 0.8 * _u2, 0, _amar2, _amar2, _amar2, _amar2, 1);
			draw_set_halign(fa_left); draw_set_valign(fa_top);
		}
		draw_set_color(c_white);
	}

	// Chip y aviso (debajo del marcador)
	if (global.game_over || !intro_disparada || instance_exists(oIntroVersus)) { draw_set_color(c_white); return; }
	var _u = clamp(min(_gw / 1280, _gh / 720), 0.6, 1.6);
	var _fa = scr_lava_fase();
	var _txt = "", _col = make_color_rgb(255, 130, 40);
	switch (_fa.f) {
		case 0: _txt = "LAVA SUBE EN " + string(_fa.s); break;
		case 1: _txt = "LA LAVA SUBE!"; _col = make_color_rgb(229, 72, 77); break;
		case 2: _txt = "LAVA BAJA EN " + string(_fa.s); break;
		case 3: _txt = "LA LAVA BAJA"; _col = make_color_rgb(78, 220, 140); break;
	}
	draw_set_font(fnt_menu); draw_set_halign(fa_center); draw_set_valign(fa_middle);
	var _cx = _gw / 2, _cy = 104 * _u;
	var _w = string_width(_txt) * 0.5 * _u + 30 * _u;
	draw_set_alpha(0.55); draw_set_color(c_black);
	draw_roundrect_ext(_cx - _w / 2, _cy - 10 * _u, _cx + _w / 2, _cy + 16 * _u, 12 * _u, 12 * _u, false);
	draw_set_alpha(1); draw_set_color(make_color_rgb(20, 24, 50));
	draw_roundrect_ext(_cx - _w / 2, _cy - 13 * _u, _cx + _w / 2, _cy + 13 * _u, 12 * _u, 12 * _u, false);
	draw_set_color(_col);
	draw_roundrect_ext(_cx - _w / 2, _cy - 13 * _u, _cx + _w / 2, _cy + 13 * _u, 12 * _u, 12 * _u, true);
	draw_set_color(c_white);
	draw_text_transformed(_cx, _cy + 1, _txt, 0.5 * _u, 0.5 * _u, 0);
	// Aviso grande antes de subir y al empezar a subir
	var _big = "";
	if (_fa.f == 0 && _fa.s <= LAVA_AVISO) _big = "LA LAVA SUBE EN " + string(_fa.s);
	else if (_fa.f == 1 && _fa.s > LAVA_SUBE - 2) _big = "LA LAVA SUBE! A LO ALTO!";
	if (_big != "") {
		var _bc = ((current_time div 150) mod 2 == 0) ? make_color_rgb(255, 130, 40) : make_color_rgb(255, 212, 71);
		var _by = _gh * 0.3, _bs = 0.9 * _u;
		draw_text_transformed_color(_cx + 3 * _u, _by + 3 * _u, _big, _bs, _bs, 0, c_black, c_black, c_black, c_black, 0.8);
		draw_text_transformed_color(_cx, _by, _big, _bs, _bs, 0, _bc, _bc, _bc, _bc, 1);
	}
	draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white); draw_set_alpha(1);
}
