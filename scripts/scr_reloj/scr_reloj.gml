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
		case 6: return "DUELO POR PUNTOS";
		case 7: return "TODOS CONTRA TODOS";
		case 8: return "JEFE GIGANTE";
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
	if (variable_struct_exists(_s, "mo") && is_numeric(_s.mo)) global.match_modo = clamp(round(_s.mo), 0, 8);   // modo de juego (antes llegaba hasta 5 y los invitados no veian DUELO ni TODOS)
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
	if (scr_modo_duelo()) return DUELO_META;   // DUELO POR PUNTOS: bajas para ganar
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
#macro BOTQ_ESPERA 480   // 8 s (antes 3: si el servidor tardaba un poquito te mandaba al bot viejo)

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
		scr_xp_dar(15);
		global.copas += 10;
	} else {
		global.losses += 1;
		scr_xp_dar(5);
		global.copas   = max(0, global.copas - 5);
	}
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
	global.botnet_defs  = [];      // los bots de esa partida ya no van (antes se quedaban para la siguiente)
	global.botnet_partida = false;
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
	var _entra = reloj_fin && (global.puntos_azul == global.puntos_rojo) && !global.game_over && !scr_modo_jefe();   // JEFE: sin muerte subita
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
#macro BOMBA_SEG 13        // segundos que aguanta la bomba fuera de su base
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
	// La bandera del rey: tu bandera grande pintada de dorado (spr_flag_rey), al doble de tamano
	var _px = global.rey_x;
	var _fk = 2;
	var _fh = sprite_get_height(spr_flag_rey) * _fk;
	var _bob = -3 - 3 * sin(current_time / 400);
	gpu_set_blendmode(bm_add);
	draw_set_alpha(0.25 + 0.08 * sin(current_time / 330));
	draw_set_color(make_color_rgb(255, 212, 71));
	draw_circle(_px, _y2 - _fh * 0.55, _fh * 0.45, false);
	draw_set_alpha(1);
	gpu_set_blendmode(bm_normal);
	draw_sprite_ext(spr_flag_rey, (current_time div 125) mod sprite_get_number(spr_flag_rey), _px,
		_y2 - (sprite_get_height(spr_flag_rey) - sprite_get_yoffset(spr_flag_rey)) * _fk + _bob, _fk, _fk, 0, c_white, 1);
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

// ======================================================
// MODO DUELO POR PUNTOS (solo en linea)
//   Sin banderas: AZUL contra ROJO y cada baja le da 1 punto al otro equipo
//   (tambien si alguien se cae, se quema o lo aplasta una prensa).
//   Gana el primero que llega a DUELO_META, o el que lleve mas al acabarse el tiempo
//   (si van iguales: MUERTE SUBITA, la siguiente baja gana). Usa los mismos puntos del marcador.
//   Cada pantalla ve las bajas sola (para el "+1"); los puntos los cuenta el lider ("sync_duelo").
// ======================================================
#macro MODO_DUELO 6
#macro MODO_TODOS 7        // TODOS CONTRA TODOS (todavia no esta listo)
#macro DUELO_META 20       // bajas para ganar

function scr_modo_duelo() { return global.ONLINE && scr_modo() == MODO_DUELO; }

/// Modos donde no hay banderas que robar (se esconden y no se pueden agarrar)
function scr_modo_sin_banderas() {
	if (!global.ONLINE) return false;
	var _m = scr_modo();
	return (_m == MODO_REY || _m == MODO_DUELO || _m == MODO_TODOS || _m == MODO_JEFE);
}

/// oBrain Step
function scr_duelo_step() {
	if (!scr_modo_duelo() || room == rm_menu) return;
	if (!variable_global_exists("duelo_fx")) { global.duelo_fx = []; global.duelo_envio = 0; }
	for (var _i = array_length(global.duelo_fx) - 1; _i >= 0; _i--) {
		global.duelo_fx[_i].t += 1;
		if (global.duelo_fx[_i].t > room_speed * 1.2) array_delete(global.duelo_fx, _i, 1);
	}
	if (global.game_over) return;
	if (!intro_disparada || instance_exists(oIntroVersus)) {
		with (oPlayer) duelo_muerto = true;          // los que ya estaban muertos no cuentan al empezar
		global.duelo_ult_x = room_width / 2;         // sin bajas todavia: la camara iria al centro
		global.duelo_ult_y = room_height / 2;
		with (oOtherPlayer) duelo_muerto = true;
		return;
	}
	var _cambio = false;
	with (oPlayer) { if (scr_duelo_baja(isDead || state == PLAYERSTATE.DEAD, global.myTeam)) _cambio = true; }
	with (oOtherPlayer) {
		var _m = (state == PLAYERSTATE.DEAD) || (variable_instance_exists(id, "isDead") && isDead);
		if (scr_duelo_baja(_m, team)) _cambio = true;
	}
	if (!AmIPseudoHost) return;
	global.duelo_envio--;
	if (_cambio || global.duelo_envio <= 0) {
		global.duelo_envio = room_speed * 2;   // y cada 2 segundos por si acaso
		var _s = { a: global.puntos_azul, r: global.puntos_rojo };
		with (oOtherPlayer) { if (!es_bot) SendEventToClient(clientId, "sync_duelo", _s); }
	}
}

/// Con la instancia de un jugador: ¿acaba de caer? Devuelve true si el lider sumo un punto.
function scr_duelo_baja(_muerto, _team) {
	if (!variable_instance_exists(id, "duelo_muerto")) { duelo_muerto = _muerto; return false; }
	var _sumo = false;
	if (_muerto && !duelo_muerto && (_team == "AZUL" || _team == "ROJO")) {
		var _gana = (_team == "AZUL") ? "ROJO" : "AZUL";
		array_push(global.duelo_fx, { x: x, y: y - 30, t: 0, c: _gana });
		global.duelo_ult_x = x;   // donde fue la ultima baja (ahi va la camara al ganar)
		global.duelo_ult_y = y;
		if (oBrain.AmIPseudoHost) {
			if (_gana == "AZUL") { global.puntos_azul++; oBrain.marcador_escala_azul = 3; }
			else { global.puntos_rojo++; oBrain.marcador_escala_rojo = 3; }
			_sumo = true;
		}
	}
	duelo_muerto = _muerto;
	return _sumo;
}

/// Llega "sync_duelo" del lider
function scr_duelo_sync(_a, _r) {
	if (_a > global.puntos_azul) oBrain.marcador_escala_azul = 3;
	if (_r > global.puntos_rojo) oBrain.marcador_escala_rojo = 3;
	global.puntos_azul = _a;
	global.puntos_rojo = _r;
}

/// oBrain Draw GUI: los "+1" donde cayo cada uno
function scr_duelo_draw() {
	if (!scr_modo_duelo() || room == rm_menu || !variable_global_exists("duelo_fx")) return;
	var _cam = view_camera[0];
	var _cvx = camera_get_view_x(_cam), _cvy = camera_get_view_y(_cam);
	var _kx = display_get_gui_width() / max(1, camera_get_view_width(_cam));
	var _ky = display_get_gui_height() / max(1, camera_get_view_height(_cam));
	var _u = clamp(min(display_get_gui_width() / 1280, display_get_gui_height() / 720), 0.6, 1.6);
	draw_set_font(fnt_menu); draw_set_halign(fa_center); draw_set_valign(fa_middle);
	for (var _i = 0; _i < array_length(global.duelo_fx); _i++) {
		var _f = global.duelo_fx[_i];
		var _p = _f.t / (room_speed * 1.2);
		var _gx = (_f.x - _cvx) * _kx, _gy = (_f.y - _cvy) * _ky - _p * 40 * _u;
		var _col = (_f.c == "AZUL") ? make_color_rgb(31, 155, 255) : make_color_rgb(229, 72, 77);
		var _sc = (0.9 + 0.4 * max(0, 1 - _p * 4)) * _u;
		var _a = 1 - max(0, _p - 0.6) / 0.4;
		draw_text_transformed_color(_gx + 2, _gy + 2, "+1", _sc, _sc, 0, c_black, c_black, c_black, c_black, _a * 0.8);
		draw_text_transformed_color(_gx, _gy, "+1", _sc, _sc, 0, _col, _col, _col, _col, _a);
	}
	draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white);
}

/// Marcador de arriba en este modo: bajas de cada equipo, reloj y la meta. _mx centro, _y arriba.
function scr_duelo_draw_marcador(_mx, _y) {
	var _h = 64, _tot = 430;
	var _x0 = _mx - _tot / 2;
	draw_set_alpha(0.55); draw_set_color(c_black);
	draw_roundrect_ext(_x0, _y + 6, _x0 + _tot, _y + _h + 6, 20, 20, false);
	draw_set_alpha(1); draw_set_color(make_color_rgb(20, 24, 50));
	draw_roundrect_ext(_x0, _y, _x0 + _tot, _y + _h, 20, 20, false);
	draw_set_color(make_color_rgb(11, 15, 26));
	draw_roundrect_ext(_x0, _y, _x0 + _tot, _y + _h, 20, 20, true);
	// Cajas de cada equipo
	draw_set_color(make_color_rgb(20, 70, 130));
	draw_roundrect_ext(_x0 + 8, _y + 6, _x0 + 150, _y + _h - 6, 14, 14, false);
	draw_set_color(make_color_rgb(120, 30, 40));
	draw_roundrect_ext(_x0 + _tot - 150, _y + 6, _x0 + _tot - 8, _y + _h - 6, 14, 14, false);
	draw_set_font(fnt_menu); draw_set_halign(fa_center); draw_set_valign(fa_middle);
	var _sa = 0.75 * clamp(oBrain.marcador_escala_azul / 1.6, 1, 2);
	var _sr = 0.75 * clamp(oBrain.marcador_escala_rojo / 1.6, 1, 2);
	var _ax = _x0 + 79, _rx = _x0 + _tot - 79;
	draw_text_transformed_color(_ax + 2, _y + 28 + 2, string(global.puntos_azul), _sa, _sa, 0, c_black, c_black, c_black, c_black, 0.6);
	draw_text_transformed_color(_ax, _y + 28, string(global.puntos_azul), _sa, _sa, 0, c_white, c_white, c_white, c_white, 1);
	draw_text_transformed_color(_rx + 2, _y + 28 + 2, string(global.puntos_rojo), _sr, _sr, 0, c_black, c_black, c_black, c_black, 0.6);
	draw_text_transformed_color(_rx, _y + 28, string(global.puntos_rojo), _sr, _sr, 0, c_white, c_white, c_white, c_white, 1);
	draw_set_color(make_color_rgb(160, 200, 255));
	draw_text_transformed(_ax, _y + 52, "BAJAS", 0.3, 0.3, 0);
	draw_set_color(make_color_rgb(255, 170, 170));
	draw_text_transformed(_rx, _y + 52, "BAJAS", 0.3, 0.3, 0);
	// Centro: reloj y meta
	var _txt = "VS", _sub = "META " + string(DUELO_META), _sc = c_white;
	if (scr_reloj_visible()) {
		if (oBrain.reloj_fin && global.puntos_azul == global.puntos_rojo) {
			_txt = scr_muerte_subita_txt();
			_sub = "MUERTE SUBITA";
			_sc = ((current_time div 300) mod 2 == 0) ? c_red : c_yellow;
		} else {
			var _m = oBrain.reloj_seg div 60, _s = oBrain.reloj_seg mod 60;
			_txt = string(_m) + ":" + ((_s < 10) ? "0" : "") + string(_s);
			if (oBrain.reloj_seg <= RELOJ_ROJO) _sc = c_red;
		}
	}
	draw_set_color(_sc);
	draw_text_transformed(_mx, _y + 26, _txt, 0.55, 0.55, 0);
	draw_set_color(make_color_rgb(255, 212, 71));
	draw_text_transformed(_mx, _y + 48, _sub, 0.32, 0.32, 0);
	// Barritas hacia la meta
	var _ba = clamp(global.puntos_azul / DUELO_META, 0, 1), _br = clamp(global.puntos_rojo / DUELO_META, 0, 1);
	var _mitad = (_tot - 40) / 2;
	draw_set_color(make_color_rgb(31, 155, 255));
	if (_ba > 0) draw_rectangle(_x0 + 20, _y + _h + 12, _x0 + 20 + _mitad * _ba, _y + _h + 16, false);
	draw_set_color(make_color_rgb(229, 72, 77));
	if (_br > 0) draw_rectangle(_x0 + _tot - 20 - _mitad * _br, _y + _h + 12, _x0 + _tot - 20, _y + _h + 16, false);
	draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white); draw_set_alpha(1);
}

// ======================================================
// MODO TODOS CONTRA TODOS (solo en linea)
//   Cada quien por su cuenta: cada jugador es su propio "equipo" ("J" + su numero; los bots "B" + numero),
//   asi todo lo que ya revisa "es de otro equipo" (balas, golpes, bots) sirve para todos contra todos.
//   El que elimina suma 1 baja. Gana el primero en TODOS_META, o el que lleve mas al acabarse el tiempo.
//   Reapareces en un punto al azar lejos de los demas. Lo cuenta el lider ("sync_todos").
//   Para el premio: el que gano cuenta como equipo 2 en su pantalla y los demas como perdedores.
// ======================================================
#macro TODOS_META 10       // bajas para ganar

function scr_modo_todos() { return global.ONLINE && scr_modo() == MODO_TODOS; }

/// Mi "equipo" en este modo
function scr_todos_mi_eq() { return "J" + string(global.clientId); }

/// Color de cada jugador (igual en todas las pantallas)
function scr_todos_color(_t) {
	var _cols = [make_color_rgb(31, 155, 255), make_color_rgb(229, 72, 77), make_color_rgb(78, 220, 140), make_color_rgb(255, 212, 71),
	             make_color_rgb(160, 90, 255), make_color_rgb(255, 130, 40), make_color_rgb(240, 90, 170), make_color_rgb(80, 220, 255)];
	_t = string(_t);
	var _n = real("0" + string_digits(_t));
	if (string_char_at(_t, 1) == "B") _n += 4;
	return _cols[abs(floor(_n)) mod 8];
}

function scr_todos_reset() {
	global.todos_pts = {};          // equipo -> bajas (lo lleva el lider)
	global.todos_lista = [];        // [[equipo, nombre, bajas], ...] ordenada (la que se dibuja)
	global.todos_envio = 0;
	global.todos_ev = 0;            // contador de bajas (para el "+1" en todas las pantallas)
	global.todos_ev_visto = 0;
	global.todos_fx = [];
	global.todos_win = "";
	global.todos_win_n = "";
	global.todos_ult_x = room_width / 2;
	global.todos_ult_y = room_height / 2;
}

/// Equipo de un jugador por su nombre (para saber a quien darle la baja)
function scr_todos_eq_de(_nombre) {
	_nombre = string(_nombre);
	if (_nombre == "") return "";
	if (_nombre == string(global.myName)) return scr_todos_mi_eq();
	var _r = "";
	with (oOtherPlayer) { if (string(Name) == _nombre && team != "") { _r = team; break; } }
	return _r;
}

/// El lider: alguien cayo (_killer = nombre del que lo elimino). Suma la baja y avisa.
function scr_todos_baja(_killer, _x, _y) {
	if (!variable_global_exists("todos_pts")) scr_todos_reset();
	var _k = scr_todos_eq_de(_killer);
	global.todos_ev++;
	global.todos_ult_x = _x;
	global.todos_ult_y = _y;
	global.todos_k = _k;
	if (_k != "") global.todos_pts[$ _k] = (variable_struct_exists(global.todos_pts, _k) ? global.todos_pts[$ _k] : 0) + 1;
	global.todos_envio = 0;   // mandar ya
}

/// La lista ordenada con todos los que estan en la partida (el lider la arma)
function scr_todos_armar_lista() {
	if (!variable_global_exists("todos_pts")) scr_todos_reset();
	var _l = [];
	var _me = scr_todos_mi_eq();
	array_push(_l, [_me, string(global.myName), variable_struct_exists(global.todos_pts, _me) ? global.todos_pts[$ _me] : 0]);
	with (oOtherPlayer) {
		if (team == "") continue;
		array_push(_l, [team, string(Name), variable_struct_exists(global.todos_pts, team) ? global.todos_pts[$ team] : 0]);
	}
	array_sort(_l, function(_a, _b) { return _b[2] - _a[2]; });
	return _l;
}

/// oBrain Step
function scr_todos_step() {
	if (!scr_modo_todos() || room == rm_menu) return;
	if (!variable_global_exists("todos_pts")) scr_todos_reset();
	// Cada quien es su propio equipo (se revisa siempre por si algo lo cambia)
	var _me = scr_todos_mi_eq();
	global.myTeam = _me;
	global.serverTeam = _me;
	with (oPlayer) team = _me;
	// "+1" y su vida
	for (var _i = array_length(global.todos_fx) - 1; _i >= 0; _i--) {
		global.todos_fx[_i].t += 1;
		if (global.todos_fx[_i].t > room_speed * 1.2) array_delete(global.todos_fx, _i, 1);
	}
	if (!intro_disparada || instance_exists(oIntroVersus)) {   // cada partida empieza en 0
		if (global.todos_ev != 0 || array_length(global.todos_lista) > 0) scr_todos_reset();
		with (oOtherPlayer) todos_muerto = true;
		return;
	}
	if (global.game_over) return;
	if (!AmIPseudoHost) return;
	// Los bots que muevo yo: cuando caen, la baja es del que les pego al final
	with (oOtherPlayer) {
		if (!bot_local) continue;
		if (!variable_instance_exists(id, "todos_muerto")) todos_muerto = isDead;
		if (isDead && !todos_muerto) scr_todos_baja(last_killer, x, y);
		todos_muerto = isDead;
	}
	global.todos_envio--;
	if (global.todos_envio <= 0) {
		global.todos_envio = room_speed;   // una vez por segundo (y en cuanto hay una baja)
		global.todos_lista = scr_todos_armar_lista();
		var _m = { l: global.todos_lista, e: global.todos_ev, x: global.todos_ult_x, y: global.todos_ult_y, k: (variable_global_exists("todos_k") ? global.todos_k : "") };
		with (oOtherPlayer) { if (!es_bot) SendEventToClient(clientId, "sync_todos", _m); }
		scr_todos_ver_baja(global.todos_ev, global.todos_ult_x, global.todos_ult_y, _m.k);
	}
}

/// Llega "sync_todos" (o el lider lo procesa): la lista y, si hubo baja nueva, el "+1"
function scr_todos_sync(_m) {
	if (!variable_global_exists("todos_pts")) scr_todos_reset();
	if (variable_struct_exists(_m, "l") && is_array(_m.l)) global.todos_lista = _m.l;
	if (variable_struct_exists(_m, "e") && variable_struct_exists(_m, "x") && variable_struct_exists(_m, "y")) {
		global.todos_ult_x = _m.x;
		global.todos_ult_y = _m.y;
		scr_todos_ver_baja(_m.e, _m.x, _m.y, variable_struct_exists(_m, "k") ? string(_m.k) : "");
	}
}

function scr_todos_ver_baja(_e, _x, _y, _k) {
	if (_e <= global.todos_ev_visto) return;
	global.todos_ev_visto = _e;
	if (_k == "") return;
	array_push(global.todos_fx, { x: _x, y: _y - 30, t: 0, c: scr_todos_color(_k) });
	if (_k == scr_todos_mi_eq()) oBrain.marcador_escala_azul = 3;   // mi numero da un saltito
}

/// Mis bajas y mi lugar (1 = primero)
function scr_todos_mio() {
	var _me = scr_todos_mi_eq();
	var _l = global.todos_lista;
	for (var _i = 0; _i < array_length(_l); _i++) if (_l[_i][0] == _me) return [_l[_i][2], _i + 1];
	return [0, max(1, array_length(_l))];
}

/// El lider: ¿ya gano alguien? Devuelve 2 si gane yo, 1 si gano otro, 0 todavia.
function scr_todos_ganador() {
	// Solo en el mapa y con la partida ya empezada (en la busqueda todavia no hay tabla)
	if (room == rm_menu || !variable_global_exists("todos_pts") || !oBrain.intro_disparada || instance_exists(oIntroVersus)) return 0;
	var _l = scr_todos_armar_lista();
	if (array_length(_l) == 0) return 0;
	var _top = _l[0];
	var _fin = oBrain.reloj_fin;
	if (_top[2] < TODOS_META && !_fin) return 0;
	global.todos_lista = _l;
	global.todos_win = _top[0];
	global.todos_win_n = _top[1];
	return (_top[0] == scr_todos_mi_eq()) ? 2 : 1;
}

/// Donde reaparecer: un punto del mapa lejos de los demas (con la instancia)
function scr_todos_spawn() {
	var _yo = id;
	var _mejor = noone, _bd = -1;
	with (oSpawnPoint) {
		var _d = 999999;
		var _sx = x, _sy = y;
		with (oPlayer) if (id != _yo && !isDead) _d = min(_d, point_distance(x, y, _sx, _sy));
		with (oOtherPlayer) if (id != _yo && visible && state != PLAYERSTATE.DEAD) _d = min(_d, point_distance(x, y, _sx, _sy));
		_d += random(120);   // un poco al azar
		if (_d > _bd) { _bd = _d; _mejor = id; }
	}
	if (_mejor == noone) return false;
	x = _mejor.x;
	y = _mejor.y;
	var _n = 0;
	while (place_meeting(x, y, obj_wall) && _n < 300) { y -= 1; _n++; }
	return true;
}

/// oBrain Draw GUI: marcador (mis bajas, reloj, mi lugar), tabla a la derecha y los "+1"
function scr_todos_draw() {
	if (!scr_modo_todos() || room == rm_menu || !variable_global_exists("todos_lista")) return;
	var _gw = display_get_gui_width();
	var _mx = _gw / 2, _y = 14, _h = 64, _w = 300;
	var _x0 = _mx - _w / 2;
	var _mio = scr_todos_mio();
	var _mic = scr_todos_color(scr_todos_mi_eq());
	draw_set_alpha(0.55); draw_set_color(c_black);
	draw_roundrect_ext(_x0, _y + 6, _x0 + _w, _y + _h + 6, 20, 20, false);
	draw_set_alpha(1); draw_set_color(make_color_rgb(20, 24, 50));
	draw_roundrect_ext(_x0, _y, _x0 + _w, _y + _h, 20, 20, false);
	draw_set_color(make_color_rgb(11, 15, 26));
	draw_roundrect_ext(_x0, _y, _x0 + _w, _y + _h, 20, 20, true);
	draw_set_font(fnt_menu); draw_set_halign(fa_center); draw_set_valign(fa_middle);
	var _sa = 0.75 * clamp(oBrain.marcador_escala_azul / 1.6, 1, 2);
	draw_text_transformed_color(_mx - 92, _y + 26, string(_mio[0]), _sa, _sa, 0, c_black, c_black, c_black, c_black, 0.6);
	draw_text_transformed_color(_mx - 94, _y + 24, string(_mio[0]), _sa, _sa, 0, _mic, _mic, _mic, _mic, 1);
	draw_set_color(make_color_rgb(169, 180, 208));
	draw_text_transformed(_mx - 94, _y + 52, "MIS BAJAS", 0.28, 0.28, 0);
	draw_text_transformed(_mx + 94, _y + 52, "LUGAR", 0.28, 0.28, 0);
	var _lug = _mio[1];
	var _lt = (_lug == 1) ? "1ER" : ((_lug == 2) ? "2DO" : ((_lug == 3) ? "3ER" : string(_lug) + "TO"));
	var _lc = (_lug == 1) ? make_color_rgb(255, 212, 71) : c_white;
	draw_text_transformed_color(_mx + 94, _y + 24, _lt, 0.6, 0.6, 0, _lc, _lc, _lc, _lc, 1);
	var _txt = "VS", _sub = "META " + string(TODOS_META), _sc = c_white;
	if (scr_reloj_visible()) {
		var _m = oBrain.reloj_seg div 60, _s = oBrain.reloj_seg mod 60;
		_txt = string(_m) + ":" + ((_s < 10) ? "0" : "") + string(_s);
		if (oBrain.reloj_seg <= RELOJ_ROJO) _sc = c_red;
	}
	draw_set_color(_sc);
	draw_text_transformed(_mx, _y + 24, _txt, 0.5, 0.5, 0);
	draw_set_color(make_color_rgb(255, 212, 71));
	draw_text_transformed(_mx, _y + 46, _sub, 0.3, 0.3, 0);

	// Tabla (los 5 primeros; tu siempre se ve). Crece con la pantalla para que se lean los nombres.
	var _l = global.todos_lista;
	var _me = scr_todos_mi_eq();
	var _n = min(5, array_length(_l));
	var _uu = clamp(min(_gw / 1280, display_get_gui_height() / 720), 0.8, 2);
	var _tw = 290 * _uu, _tx = _gw - _tw - 14 * _uu, _ty = 140 * _uu, _rh = 34 * _uu, _cab = 34 * _uu;
	var _yo_fuera = (_mio[1] > 5);
	var _th = _cab + _n * _rh + (_yo_fuera ? _rh + 6 * _uu : 0) + 6 * _uu;
	draw_set_alpha(0.8); draw_set_color(make_color_rgb(10, 12, 30));
	draw_roundrect_ext(_tx, _ty, _tx + _tw, _ty + _th, 14 * _uu, 14 * _uu, false);
	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_set_color(make_color_rgb(255, 212, 71));
	draw_text_transformed(_tx + _tw / 2, _ty + _cab / 2, "TABLA", 0.5 * _uu, 0.5 * _uu, 0);
	for (var _i = 0; _i < _n + (_yo_fuera ? 1 : 0); _i++) {
		var _k = (_i < _n) ? _i : (_mio[1] - 1);
		var _e = _l[_k];
		var _ry = _ty + _cab + _i * _rh + ((_i >= _n) ? 6 * _uu : 0);
		var _rc = _ry + _rh / 2;
		if (_e[0] == _me) { draw_set_color(make_color_rgb(40, 52, 110)); draw_roundrect_ext(_tx + 6 * _uu, _ry + 2 * _uu, _tx + _tw - 6 * _uu, _ry + _rh - 2 * _uu, 8 * _uu, 8 * _uu, false); }
		draw_set_halign(fa_center);
		draw_set_color((_k == 0) ? make_color_rgb(255, 212, 71) : make_color_rgb(169, 180, 208));
		draw_text_transformed(_tx + 22 * _uu, _rc, string(_k + 1), 0.5 * _uu, 0.5 * _uu, 0);
		draw_set_color(scr_todos_color(_e[0]));
		draw_roundrect_ext(_tx + 40 * _uu, _rc - 8 * _uu, _tx + 56 * _uu, _rc + 8 * _uu, 4 * _uu, 4 * _uu, false);
		draw_set_halign(fa_left); draw_set_color(c_white);
		draw_text_transformed(_tx + 66 * _uu, _rc, string_upper(string_copy(string(_e[1]), 1, 12)), 0.45 * _uu, 0.45 * _uu, 0);
		draw_set_halign(fa_right);
		draw_text_transformed(_tx + _tw - 16 * _uu, _rc, string(_e[2]), 0.55 * _uu, 0.55 * _uu, 0);
	}

	// Los "+1"
	var _cam = view_camera[0];
	var _cvx = camera_get_view_x(_cam), _cvy = camera_get_view_y(_cam);
	var _kx = _gw / max(1, camera_get_view_width(_cam));
	var _ky = display_get_gui_height() / max(1, camera_get_view_height(_cam));
	var _u = clamp(min(_gw / 1280, display_get_gui_height() / 720), 0.6, 1.6);
	draw_set_halign(fa_center);
	for (var _i = 0; _i < array_length(global.todos_fx); _i++) {
		var _f = global.todos_fx[_i];
		var _p = _f.t / (room_speed * 1.2);
		var _gx = (_f.x - _cvx) * _kx, _gy = (_f.y - _cvy) * _ky - _p * 40 * _u;
		var _sc2 = (0.9 + 0.4 * max(0, 1 - _p * 4)) * _u;
		var _a = 1 - max(0, _p - 0.6) / 0.4;
		draw_text_transformed_color(_gx + 2, _gy + 2, "+1", _sc2, _sc2, 0, c_black, c_black, c_black, c_black, _a * 0.8);
		draw_text_transformed_color(_gx, _gy, "+1", _sc2, _sc2, 0, _f.c, _f.c, _f.c, _f.c, _a);
	}
	draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white); draw_set_alpha(1);
}

/// Podio de los 3 primeros (durante el festejo del final). _e = frames que lleva, _fin = 1 -> 0 al salir
function scr_todos_draw_podio(_e, _fin) {
	var _l = global.todos_lista;
	if (array_length(_l) == 0) return;
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	var _u = clamp(min(_gw / 1280, _gh / 720), 0.6, 1.6);
	var _p = clamp(_e / 45, 0, 1);
	_p = 1 - power(1 - _p, 3);
	draw_set_font(fnt_menu); draw_set_halign(fa_center); draw_set_valign(fa_middle);
	draw_set_alpha(0.55 * _fin); draw_set_color(c_black);
	draw_rectangle(0, 0, _gw, _gh, false);
	draw_set_alpha(_fin);
	var _cx = _gw / 2, _base = _gh * 0.78;
	var _t = "GANA " + string_upper(string(_l[0][1])) + "!";
	draw_text_transformed_color(_cx + 3 * _u, _gh * 0.16 + 3 * _u, _t, 1.1 * _u, 1.1 * _u, 0, c_black, c_black, c_black, c_black, _fin);
	draw_text_transformed_color(_cx, _gh * 0.16, _t, 1.1 * _u, 1.1 * _u, 0, make_color_rgb(255, 212, 71), make_color_rgb(255, 212, 71), make_color_rgb(255, 212, 71), make_color_rgb(255, 212, 71), _fin);
	// lugares: [indice en la lista, x, alto, color]
	var _pz = [[1, _cx - 220 * _u, 150, make_color_rgb(190, 195, 210)], [0, _cx, 220, make_color_rgb(255, 212, 71)], [2, _cx + 220 * _u, 110, make_color_rgb(205, 127, 50)]];
	for (var _i = 0; _i < 3; _i++) {
		var _k = _pz[_i][0];
		if (_k >= array_length(_l)) continue;
		var _x = _pz[_i][1], _hh = _pz[_i][2] * _u * _p, _top = _base - _hh, _w = 90 * _u;
		draw_set_color(_pz[_i][3]);
		draw_rectangle(_x - _w, _top, _x + _w, _base, false);
		draw_set_color(make_color_rgb(11, 15, 26));
		draw_rectangle(_x - _w, _top, _x + _w, _base, true);
		draw_set_color(c_white);
		if (_hh > 40 * _u) draw_text_transformed(_x, _top + 30 * _u, string(_k + 1), 1.1 * _u, 1.1 * _u, 0);
		// muñequito con su color
		var _c = scr_todos_color(_l[_k][0]);
		draw_set_color(_c);
		draw_roundrect_ext(_x - 16 * _u, _top - 52 * _u, _x + 16 * _u, _top - 4 * _u, 8 * _u, 8 * _u, false);
		draw_set_color(c_white);
		draw_rectangle(_x + 3 * _u, _top - 42 * _u, _x + 11 * _u, _top - 34 * _u, false);
		draw_text_transformed(_x, _top - 84 * _u, string_upper(string_copy(string(_l[_k][1]), 1, 12)), 0.45 * _u, 0.45 * _u, 0);
		draw_set_color(make_color_rgb(169, 180, 208));
		draw_text_transformed(_x, _top - 64 * _u, string(_l[_k][2]) + " bajas", 0.32 * _u, 0.32 * _u, 0);
	}
	draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white); draw_set_alpha(1);
}

/// La mision de la intro segun el modo: [linea 1, linea 2, linea 3, con bandera]
function scr_mision_lineas(_rival, _mio) {
	switch (scr_modo()) {
		case MODO_REY:   return ["DOMINA LA ZONA", "DEL CENTRO DEL MAPA", "LLENA TU BARRA PRIMERO", false];
		case MODO_DUELO: return ["ELIMINA A LOS RIVALES", "CADA BAJA SUMA 1", "PRIMERO EN " + string(DUELO_META) + " BAJAS GANA", false];
		case MODO_TODOS: return ["ELIMINA A TODOS", "CADA QUIEN POR SU CUENTA", "PRIMERO EN " + string(TODOS_META) + " BAJAS GANA", false];
		case MODO_JEFE:  return ["DERROTA AL JEFE", "TODOS JUNTOS CONTRA EL", "ANTES DE QUE SE ACABE EL TIEMPO", false];
	}
	return ["ROBA LA BANDERA " + _rival, "Y LLEVALA A TU BASE " + _mio, "PRIMERO EN 3 BANDERAS GANA", true];
}

// ======================================================
// NIVEL DEL JUGADOR
//   Cada nivel pide un poco mas: 100 XP para el 2, y 30 mas por cada nivel (nivel 10 = 340 XP).
//   La XP se da con scr_xp_dar: si subes de nivel se guarda para mostrar la pantalla de
//   SUBISTE DE NIVEL al estar fuera de la partida (global.lvl_pendiente).
// ======================================================
function scr_xp_necesaria(_lvl) { return 100 + 30 * (max(1, _lvl) - 1); }

function scr_xp_dar(_n) {
	if (!variable_global_exists("lvl_pendiente")) global.lvl_pendiente = 0;
	global.xp += _n;
	while (global.xp >= scr_xp_necesaria(global.lvl)) {
		global.xp -= scr_xp_necesaria(global.lvl);
		global.lvl += 1;
		global.lvl_pendiente += 1;
	}
}

// ======================================================
// REINICIAR TU PROGRESO (solo para pruebas)
//   Con DEV_REINICIAR en true: en el menu principal aprieta CTRL + SUPR y tu cuenta vuelve a
//   nivel 1 (XP, victorias, derrotas, bajas, banderas, copas, monedas, armas, mejoras y logros).
//   Se queda tu nombre y tus amigos. Ponlo en false antes de publicar el juego.
// ======================================================
#macro DEV_REINICIAR false

function scr_dev_reiniciar_step() {
	if (!DEV_REINICIAR || room != rm_menu) return;
	if (!(keyboard_check(vk_control) && keyboard_check_pressed(vk_delete))) return;
	global.lvl = 1;
	global.xp = 0;
	global.lvl_pendiente = 0;
	global.wins = 0;
	global.losses = 0;
	global.kills = 0;
	global.flags_captured = 0;
	global.flags_returned = 0;
	global.copas = 0;
	global.rank = "RECLUTA";
	global.logros = [];
	global.equipo = {};
	scr_eq_init();   // monedas en 0 y las armas de inicio (scr_armas)
	scr_save_to_local();
	scr_cuenta_guardar();   // tambien en tu cuenta (DatabaseFunctions)
	if (global.sfx) audio_play_sound(snd_powerdown, 5, false);
	show_message_async("PROGRESO REINICIADO: vuelves a nivel 1.");
}


// ======================================================
// MODO JEFE GIGANTE (solo en linea)  -  match_modo 8
//   Todos los jugadores (y los bots) van en el MISMO equipo (AZUL) contra un Sargento gigante.
//   El LIDER mueve al jefe y decide sus ataques; a los demas les manda como va ("jefe_sync").
//   Cada pantalla revisa si SUS balas le pegan al jefe y se lo avisa al lider ("jefe_hit").
//   Los golpes del jefe ("jefe_golpe") y la lluvia de fuego ("jefe_fuego") los revisa cada
//   pantalla con su propio jugador; el lider ademas con los bots.
//   Fases: 1 camina y da punetazos. 2 (menos de 66%) ademas salta y cae con PISOTON.
//          3 (menos de 33%) FURIA: mas rapido, pega mas seguido y llueve fuego.
//   Ganan los jugadores si lo matan. Si se acaba el tiempo o caen todos a la vez, gana el jefe.
//   Lo dibuja oJefe (Draw) y la barra de vida va en el Draw GUI de oBrain.
// ======================================================
#macro MODO_JEFE 8
#macro JEFE_ESC 3.5            // que tan grande se ve (el Sargento x3.5)
#macro JEFE_ANCHO 34           // mitad del ancho de su cuerpo (para las balas)
#macro JEFE_ALTO 140           // alto de su cuerpo (para las balas)
#macro JEFE_PIE_ANCHO 18       // para caminar solo cuentan sus piernas: asi no se atora con techos y escalones
#macro JEFE_PIE_ALTO 56
#macro JEFE_VIDA_BASE 1500     // vida = base + esto por cada jugador (personas y bots)
#macro JEFE_VIDA_POR 1100
#macro JEFE_PUNO 35            // dano del punetazo
#macro JEFE_PISOTON 30         // dano del pisoton
#macro JEFE_EMBESTIDA 30       // dano de la embestida (fase 2 y 3)
#macro JEFE_FUEGO 15           // dano de cada bola de fuego
#macro JEFE_BARRIL 4           // un barril le hace su dano x4
#macro JEFE_NOMBRE "EL SARGENTO GIGANTE"
#macro JEFE_KILLER "EL JEFE"

function scr_modo_jefe() { return global.ONLINE && scr_modo() == MODO_JEFE; }

function scr_jefe_reset() {
	var _x = room_width * 0.75, _y = room_height * 0.5;
	var _b = instance_find(obj_base_red, 0);
	if (_b != noone) { _x = _b.x; _y = _b.y; }
	global.jefe = { x: _x, y: _y, hs: 0, vs: 0, f: -1, hp: 1, hpmax: 1, st: 0, tm: 0, listo: false,
		cd_puno: 0, cd_salto: room_speed * 4, cd_fuego: room_speed * 6, obj: noone, obj_t: 0,
		fase: 1, fase_vista: 1, banner_t: 0, banner_txt: "", flash: 0, anim: 0, envio: 0,
		piso: false, atorado: 0, fuego: [], ondas: [], nx: _x, ny: _y, cuarto: room,
		pisoton: false, todos_t: 0, muerto_t: 0, fase_ia: 1,
		flash_cd: 0, choco: false, cd_emb: room_speed * 3, emb_pego: false, lejos_t: 0, gx: _x, gy: _y, emb_n: 0 };
	__jefe_desatorar();
}

/// Si quedo metido en un muro, lo sube hasta que quede libre
function __jefe_desatorar() {
	var J = global.jefe;
	var _n = 0;
	while (__jefe_choca(J.x, J.y) && _n < 500) { J.y -= 2; _n++; }
	J.nx = J.x; J.ny = J.y;
}

/// Su cuerpo en (_x, _y = los pies) choca con un muro?
function __jefe_choca(_x, _y) {
	return collision_rectangle(_x - JEFE_PIE_ANCHO, _y - JEFE_PIE_ALTO, _x + JEFE_PIE_ANCHO, _y - 2, obj_wall, false, true) != noone;
}

/// Hay piso justo debajo de sus pies? (muro, o plataforma que se atraviesa si viene de arriba)
function __jefe_piso_en(_x, _y) {
	if (collision_rectangle(_x - JEFE_PIE_ANCHO, _y, _x + JEFE_PIE_ANCHO, _y + 1, obj_wall, false, true) != noone) return true;
	var _p = collision_rectangle(_x - JEFE_PIE_ANCHO, _y, _x + JEFE_PIE_ANCHO, _y + 1, oPlataformaPasable, false, true);
	return (_p != noone && _y <= _p.bbox_top + 1);
}

function __jefe_fase_de(_hp, _max) {
	var _r = _hp / max(1, _max);
	if (_r > 0.66) return 1;
	if (_r > 0.33) return 2;
	return 3;
}

/// Un jugador (persona o bot) esta vivo y se puede atacar?
function __jefe_vivo(_i) {
	if (!instance_exists(_i)) return false;
	if (_i.object_index == oPlayer) return !_i.isDead && _i.state != PLAYERSTATE.DEAD;
	if (variable_instance_exists(_i, "isDead") && _i.isDead) return false;
	return _i.visible && _i.state != PLAYERSTATE.DEAD;
}

function __jefe_vivos() {
	var _l = [];
	with (oPlayer) if (__jefe_vivo(id)) array_push(_l, id);
	with (oOtherPlayer) if (__jefe_vivo(id)) array_push(_l, id);
	return _l;
}

/// A quien va a perseguir: casi siempre al mas cercano, a veces a otro (para que nadie se quede tranquilo)
function __jefe_elegir(_l) {
	var _n = array_length(_l);
	if (_n == 0) return noone;
	if (_n > 1 && random(1) < 0.3) return _l[irandom(_n - 1)];
	var J = global.jefe;
	var _m = noone, _md = 999999;
	for (var i = 0; i < _n; i++) {
		var _d = point_distance(J.x, J.y, _l[i].x, _l[i].y);
		if (_d < _md) { _md = _d; _m = _l[i]; }
	}
	return _m;
}

function __jefe_vel(_fase) {
	if (_fase >= 3) return 3.4;
	if (_fase == 2) return 2.6;
	return 2.0;
}

function __jefe_espera_puno(_fase) { return (_fase >= 3) ? 14 : 20; }

/// Destello blanco cortito al recibir balas (no se queda blanco con las rafagas)
function __jefe_flash() {
	var J = global.jefe;
	if (J.flash_cd > 0) return;
	J.flash = 3;
	J.flash_cd = 9;
}

/// oBrain Step (todos): equipos, el jefe (lo mueve el lider), el fuego y la animacion
function scr_jefe_step() {
	if (!scr_modo_jefe() || room == rm_menu) return;
	if (!variable_global_exists("jefe") || global.jefe.cuarto != room) scr_jefe_reset();
	var J = global.jefe;
	if (!instance_exists(oJefe)) {
		// Un poquito detras de los jugadores (en su misma capa)
		var _ly = layer_get_id("Instances");
		instance_create_depth(0, 0, (_ly != -1) ? layer_get_depth(_ly) + 5 : 10, oJefe);
	}

	// Todos en el mismo equipo (se revisa siempre, por si algo lo cambia)
	global.myTeam = "AZUL";
	global.serverTeam = "AZUL";
	with (oPlayer) team = "AZUL";
	with (oOtherPlayer) { team = "AZUL"; lobby_team = "AZUL"; thisPlayerTeam = "AZUL"; }

	J.anim += 1;
	if (J.flash > 0) J.flash -= 1;
	if (J.flash_cd > 0) J.flash_cd -= 1;
	// EMBESTIDA: si te toca mientras corre, te avienta (cada pantalla con su jugador; el lider con los bots)
	if (J.st == 7 && J.tm >= 20) __jefe_embestida_toca();
	else J.emb_pego = false;
	if (J.banner_t > 0) J.banner_t -= 1;
	for (var _i = array_length(J.ondas) - 1; _i >= 0; _i--) {
		J.ondas[_i].t += 1;
		if (J.ondas[_i].t > 30) array_delete(J.ondas, _i, 1);
	}

	// Antes de que termine la intro: el jefe espera en la base roja con toda la vida
	if (!intro_disparada || instance_exists(oIntroVersus)) {
		if (J.listo || J.st != 0) scr_jefe_reset();
		return;
	}

	// Fase (la ve cada quien con la vida): aviso grande al cambiar
	var _fase = __jefe_fase_de(J.hp, J.hpmax);
	J.fase = _fase;
	if (J.listo && J.st != 5 && _fase > J.fase_vista) {
		J.fase_vista = _fase;
		J.banner_t = room_speed * 1.6;
		J.banner_txt = (_fase == 2) ? "FASE 2: SE ENOJO!" : "FASE 3: FURIA!";
		scrCamShake(10);
	}

	// Explosiones cuando cae
	if (J.st == 5) {
		J.muerto_t += 1;
		if (J.muerto_t mod 12 == 1 && J.muerto_t < 96) {
			var _e = instance_create_layer(J.x + random_range(-50, 50), J.y - random_range(20, JEFE_ALTO), "Weapons", oExplosionFX);
			_e.sprite_index = spr_explode;
			_e.image_index = 0;
			_e.image_xscale = random_range(1.8, 2.6);
			_e.image_yscale = _e.image_xscale;
			scrCamShake(8);
			if (global.sfx) audio_play_sound(sndMissileExplode, 10, false, 0.7, 0, random_range(0.8, 1.1));
		}
	}

	// Lluvia de fuego (cada pantalla la mueve igual)
	scr_jefe_fuego_step();

	if (AmIPseudoHost) {
		if (!J.listo) {
			// Empieza la pelea: la vida depende de cuantos son
			var _n = 1 + instance_number(oOtherPlayer);
			J.hpmax = JEFE_VIDA_BASE + JEFE_VIDA_POR * _n;
			J.hp = J.hpmax;
			J.listo = true;
			J.fase_vista = 1;
		}
		if (!global.game_over) scr_jefe_ia();
		scr_jefe_fisica();
		// Todos caidos a la vez
		if (array_length(__jefe_vivos()) == 0 && J.st != 5) J.todos_t += 1; else J.todos_t = 0;
		J.envio -= 1;
		if (J.envio <= 0) {
			J.envio = 4;
			var _m = { x: round(J.x), y: round(J.y), h: J.hp, m: J.hpmax, s: J.st, t: J.tm, f: J.f };
			with (oOtherPlayer) if (!es_bot) SendEventToClient(clientId, "jefe_sync", _m);
		}
	} else {
		// Los demas: se acerca suave a donde dice el lider
		if (point_distance(J.x, J.y, J.nx, J.ny) > 220) { J.x = J.nx; J.y = J.ny; }
		J.x = lerp(J.x, J.nx, 0.35);
		J.y = lerp(J.y, J.ny, 0.35);
		J.tm += 1;
	}
}

/// Llega "jefe_sync" del lider
function scr_jefe_sync(_m) {
	if (!scr_modo_jefe() || room == rm_menu || !is_struct(_m)) return;
	if (!variable_global_exists("jefe") || global.jefe.cuarto != room) scr_jefe_reset();
	var J = global.jefe;
	if (variable_struct_exists(_m, "x")) J.nx = real(_m.x);
	if (variable_struct_exists(_m, "y")) J.ny = real(_m.y);
	if (variable_struct_exists(_m, "m")) J.hpmax = max(1, real(_m.m));
	if (variable_struct_exists(_m, "h")) {
		var _h = real(_m.h);
		if (J.listo && _h < J.hp) __jefe_flash();   // alguien mas le pego
		J.hp = _h;
	}
	if (variable_struct_exists(_m, "s")) {
		var _s = real(_m.s);
		if (_s != J.st) { J.st = _s; J.tm = 0; }
	}
	if (variable_struct_exists(_m, "t")) J.tm = real(_m.t);
	if (variable_struct_exists(_m, "f")) J.f = (real(_m.f) >= 0) ? 1 : -1;
	J.listo = true;
}

/// El lider: que hace el jefe
function scr_jefe_ia() {
	var J = global.jefe;
	var _fps = room_speed;
	if (J.cd_puno > 0) J.cd_puno -= 1;
	if (J.cd_salto > 0) J.cd_salto -= 1;
	if (J.cd_fuego > 0) J.cd_fuego -= 1;
	if (J.cd_emb > 0) J.cd_emb -= 1;
	J.tm += 1;

	if (J.st == 5) { J.hs = 0; return; }
	// Cambio de fase: se para y ruge un momento
	if (J.fase > J.fase_ia && (J.st == 0 || J.st == 1) && J.piso) {
		J.fase_ia = J.fase;
		J.st = 4; J.tm = 0; J.hs = 0;
		J.cd_salto = min(J.cd_salto, room_speed);   // y luego luego estrena su ataque nuevo
		J.cd_fuego = min(J.cd_fuego, room_speed);
	}

	var _vivos = __jefe_vivos();
	J.obj_t -= 1;
	if (!__jefe_vivo(J.obj) || J.obj_t <= 0) {
		J.obj = __jefe_elegir(_vivos);
		J.obj_t = _fps * random_range(2.5, 4);
	}
	var _hay = __jefe_vivo(J.obj);
	var _tx = _hay ? J.obj.x : J.x;
	var _ty = _hay ? J.obj.y : J.y;
	var _dx = _tx - J.x;
	// Si lleva rato lejos de todos (otro piso, otro lado del mapa), los va a buscar
	if (_hay && point_distance(J.x, J.y, _tx, _ty) > 480) J.lejos_t += 1; else J.lejos_t = 0;

	switch (J.st) {
		case 0:   // camina hacia su objetivo
			if (!_hay) { J.hs = 0; break; }
			// Atorado o muy lejos: SALTO GIGANTE. Sale de la pantalla y cae encima de su objetivo
			if (J.atorado > 45 || J.lejos_t > _fps * 5) {
				J.st = 6; J.tm = 0; J.hs = 0; J.vs = 0;
				J.gx = _tx; J.gy = _ty;
				J.atorado = 0; J.lejos_t = 0;
				break;
			}
			if (abs(_dx) > 8) J.f = sign(_dx);
			J.hs = (abs(_dx) > 50) ? J.f * __jefe_vel(J.fase) : 0;
			// FURIA: lluvia de fuego cada tanto
			if (J.fase >= 3 && J.cd_fuego <= 0 && J.piso) {
				J.st = 3; J.tm = 0; J.hs = 0;
				J.cd_fuego = _fps * 6;
				break;
			}
			// EMBESTIDA (fase 2 y 3): si esta en su mismo piso y lejos, corre hacia el
			if (J.fase >= 2 && J.cd_emb <= 0 && J.piso && abs(_dx) > 180 && abs(_dx) < 520 && abs(_ty - J.y) < 70) {
				J.st = 7; J.tm = 0; J.hs = 0;
				J.emb_n += 1;
				J.f = (_dx >= 0) ? 1 : -1;
				J.cd_emb = round(_fps * ((J.fase >= 3) ? 4 : 6));
				break;
			}
			// Punetazo si lo tiene enfrente
			if (abs(_dx) < 110 && abs(_ty - J.y) < 100 && J.cd_puno <= 0 && J.piso) {
				J.st = 1; J.tm = 0; J.hs = 0;
				J.f = (_dx >= 0) ? 1 : -1;
				break;
			}
			// Salto: para alcanzarlo si esta arriba o si se atoro; en fase 2 y 3 cae con PISOTON
			var _arriba = (_ty < J.y - 100);
			var _pisa = (J.fase >= 2 && abs(_dx) < 420);
			if (J.piso && J.cd_salto <= 0 && (_arriba || J.atorado > 10 || _pisa)) {
				J.st = 2; J.tm = 0;
				J.vs = _arriba ? -16.5 : -14;
				J.hs = clamp(_dx / 60, -7, 7);
				if (J.hs != 0) J.f = sign(J.hs);
				J.pisoton = (J.fase >= 2);
				J.cd_salto = round(_fps * ((J.fase >= 3) ? 3 : ((J.fase == 2) ? 4 : 2.5)));
				J.atorado = 0;
				J.piso = false;
			}
		break;

		case 1:   // punetazo: se echa para atras y pega
			J.hs = 0;
			var _w = __jefe_espera_puno(J.fase);
			if (J.tm == _w) __jefe_golpe("p");
			if (J.tm >= _w + 16) { J.st = 0; J.tm = 0; J.cd_puno = round(_fps * ((J.fase >= 3) ? 0.7 : 1.1)); }
		break;

		case 2:   // en el aire
			if (J.tm > 5 && J.piso) {
				if (J.pisoton) __jefe_golpe("s");
				J.st = 0; J.tm = 0; J.hs = 0;
			}
		break;

		case 3:   // ruge y llueve fuego
			J.hs = 0;
			if (J.tm == 20) __jefe_lanzar_fuego();
			if (J.tm >= 50) { J.st = 0; J.tm = 0; }
		break;

		case 4:   // ruge porque cambio de fase
			J.hs = 0;
			if (J.tm >= 45) { J.st = 0; J.tm = 0; }
		break;

		case 6:   // salto gigante (lo mueve scr_jefe_fisica)
			J.hs = 0;
		break;

		case 7:   // embestida: se agacha (con aviso) y corre de frente
			if (J.tm < 20) J.hs = 0;
			else {
				J.hs = J.f * ((J.fase >= 3) ? 10 : 8.5);
				if (J.tm > 22 && J.choco) { J.hs = 0; J.st = 0; J.tm = 0; scrCamShake(8); }   // se estrello con un muro
				else if (J.tm >= 20 + 45) { J.hs = 0; J.st = 0; J.tm = 0; }
			}
		break;
	}
}

/// El lider: lo mueve con gravedad y choques
function scr_jefe_fisica() {
	var J = global.jefe;
	J.choco = false;
	if (J.st == 6) { __jefe_salto_gigante(); return; }
	// De lado
	if (J.hs != 0) {
		var _nx = J.x + J.hs;
		if (!__jefe_choca(_nx, J.y)) J.x = _nx;
		else {
			var _s = sign(J.hs);
			var _k = 0;
			while (!__jefe_choca(J.x + _s, J.y) && _k < 10) { J.x += _s; _k++; }
			if (J.st == 0) J.atorado += 1;
			J.hs = 0;
			J.choco = true;
		}
	} else if (J.st == 0) {
		J.atorado = 0;
	}
	J.x = clamp(J.x, JEFE_ANCHO, room_width - JEFE_ANCHO);
	// Arriba y abajo
	J.piso = __jefe_piso_en(J.x, J.y) && J.vs >= 0;
	if (J.piso) {
		J.vs = 0;
	} else {
		J.vs = min(J.vs + 0.5, 14);
		if (J.vs > 0) {
			repeat (ceil(J.vs)) {
				if (__jefe_piso_en(J.x, J.y)) { J.vs = 0; J.piso = true; break; }
				J.y += 1;
			}
		} else {
			repeat (ceil(-J.vs)) {
				if (__jefe_choca(J.x, J.y - 1)) { J.vs = 0; break; }
				J.y -= 1;
			}
		}
	}
	// Se cayo del mapa: vuelve a la base roja
	if (J.y > room_height + 150) {
		var _b = instance_find(obj_base_red, 0);
		J.x = (_b != noone) ? _b.x : room_width * 0.75;
		J.y = (_b != noone) ? _b.y : room_height * 0.5;
		J.vs = 0;
		__jefe_desatorar();
	}
}

/// El lider: SALTO GIGANTE (estado 6). Sube y sale de la pantalla atravesando todo,
/// aparece arriba de su objetivo y cae hasta el primer piso libre cerca de el.
function __jefe_salto_gigante() {
	var J = global.jefe;
	if (J.tm <= 25) {
		J.y -= 20;                                       // se va para arriba
	} else if (J.tm == 26) {
		J.x = clamp(J.gx, JEFE_ANCHO, room_width - JEFE_ANCHO);
		J.y = J.gy - 520;                                // arriba de donde estaba su objetivo
		J.vs = 4;
	} else {
		J.vs = min(J.vs + 0.6, 16);
		repeat (ceil(J.vs)) {
			J.y += 1;
			// Cae en el primer piso que este cerca de su objetivo (y donde quepa)
			if (J.y >= J.gy - 60 && __jefe_piso_en(J.x, J.y) && !__jefe_choca(J.x, J.y)) {
				J.vs = 0; J.piso = true;
				if (J.fase >= 2) __jefe_golpe("s");            // en fase 2 y 3 cae con PISOTON
				else { scrCamShake(10); }
				J.st = 0; J.tm = 0;
				J.cd_salto = round(room_speed * 2);
				return;
			}
		}
		// No encontro piso (se fue al vacio): de regreso a la base roja
		if (J.y > room_height + 150) {
			var _b = instance_find(obj_base_red, 0);
			J.x = (_b != noone) ? _b.x : room_width * 0.75;
			J.y = (_b != noone) ? _b.y : room_height * 0.5;
			J.vs = 0; J.st = 0; J.tm = 0;
			__jefe_desatorar();
		}
	}
}

/// Todas las pantallas: la EMBESTIDA toca a tu jugador (y a los bots, si soy el lider). Una vez por embestida.
function __jefe_embestida_toca() {
	var J = global.jefe;
	var _l = J.x - JEFE_ANCHO - 10, _r = J.x + JEFE_ANCHO + 10, _t = J.y - JEFE_ALTO, _b = J.y + 5;
	var _ang = (J.f > 0) ? 30 : 150;
	if (!J.emb_pego) {
		var _yo = noone;
		with (oPlayer) if (!isDead && !invulnerable && point_in_rectangle(x, y - 20, _l, _t, _r, _b)) _yo = id;
		if (_yo != noone) {
			J.emb_pego = true;
			scrCamShake(10);
			callback_ReceivedEvent("hit", { damage: JEFE_EMBESTIDA, killer: JEFE_KILLER, reason: "explosion", angle: _ang, bot: true }, -1);
		}
	}
	if (instance_exists(oBrain) && oBrain.AmIPseudoHost) {
		with (oOtherPlayer) {
			if (!es_bot || !bot_local || isDead) continue;
			if (variable_instance_exists(id, "jefe_emb") && jefe_emb == J.emb_n) continue;   // ya le pego esta embestida
			if (!point_in_rectangle(x, y - 20, _l, _t, _r, _b)) continue;
			jefe_emb = J.emb_n;
			scr_botnet_dano(id, { damage: JEFE_EMBESTIDA, killer: JEFE_KILLER, reason: "explosion", angle: _ang }, -1);
		}
	}
}

/// El lider: un ataque pega AHORITA. Le avisa a todos y lo revisa el tambien.
function __jefe_golpe(_k) {
	var J = global.jefe;
	var _m = { k: _k, x: round(J.x), y: round(J.y), f: J.f };
	with (oOtherPlayer) if (!es_bot) SendEventToClient(clientId, "jefe_golpe", _m);
	scr_jefe_impacto(_m);
}

/// Todas las pantallas: el golpe del jefe (efecto y, si te alcanza, dano a tu jugador)
function scr_jefe_impacto(_m) {
	if (!scr_modo_jefe() || room == rm_menu || !is_struct(_m) || !variable_global_exists("jefe")) return;
	if (!variable_struct_exists(_m, "k") || !variable_struct_exists(_m, "x") || !variable_struct_exists(_m, "y")) return;
	var _x = real(_m.x), _y = real(_m.y);
	var _f = (variable_struct_exists(_m, "f") && real(_m.f) < 0) ? -1 : 1;
	if (_m.k == "p") {
		var _fx = instance_create_layer(_x + _f * 80, _y - 70, "Instances", oMeleeFX);
		_fx.image_xscale = 3 * _f;
		_fx.image_yscale = 3;
		scrCamShake(8);
		if (global.sfx) audio_play_sound(snd_melee, 10, false, 1, 0, 0.6);
		var _l = (_f > 0) ? _x : _x - 150;
		var _r = (_f > 0) ? _x + 150 : _x;
		__jefe_pega_area(_l, _y - 170, _r, _y + 10, JEFE_PUNO, (_f > 0) ? 35 : 145);
	} else if (_m.k == "s") {
		array_push(global.jefe.ondas, { x: _x, y: _y, t: 0 });
		scrCamShake(16);
		if (global.sfx) audio_play_sound(sndMissileExplode, 10, false, 0.8, 0, 0.6);
		__jefe_pega_area(_x - 230, _y - 90, _x + 230, _y + 20, JEFE_PISOTON, -1);
	}
}

/// A quien le toca el golpe: tu jugador (en cada pantalla) y los bots (solo el lider)
function __jefe_pega_area(_l, _t, _r, _b, _dmg, _ang) {
	var _jx = global.jefe.x;
	var _yo = noone;
	with (oPlayer) if (!isDead && !invulnerable && point_in_rectangle(x, y - 20, _l, _t, _r, _b)) _yo = id;
	if (_yo != noone) {
		var _a = (_ang >= 0) ? _ang : ((_yo.x >= _jx) ? 40 : 140);
		callback_ReceivedEvent("hit", { damage: _dmg, killer: JEFE_KILLER, reason: "explosion", angle: _a, bot: true }, -1);
	}
	if (instance_exists(oBrain) && oBrain.AmIPseudoHost) {
		with (oOtherPlayer) {
			if (!es_bot || !bot_local || isDead) continue;
			if (!point_in_rectangle(x, y - 20, _l, _t, _r, _b)) continue;
			var _a2 = (_ang >= 0) ? _ang : ((x >= _jx) ? 40 : 140);
			scr_botnet_dano(id, { damage: _dmg, killer: JEFE_KILLER, reason: "explosion", angle: _a2 }, -1);
		}
	}
}

/// El lider: bolas de fuego encima de cada jugador y algunas al azar
function __jefe_lanzar_fuego() {
	var _l = [];
	var _vivos = __jefe_vivos();
	for (var i = 0; i < array_length(_vivos); i++) {
		var _p = _vivos[i];
		repeat (3) array_push(_l, [round(_p.x + random_range(-150, 150)), round(_p.y - 460), irandom(55)]);
	}
	repeat (4) array_push(_l, [round(random_range(60, room_width - 60)), round(global.jefe.y - 520), irandom(60)]);
	var _m = { l: _l };
	with (oOtherPlayer) if (!es_bot) SendEventToClient(clientId, "jefe_fuego", _m);
	scr_jefe_fuego_recibir(_m);
	scrCamShake(6);
}

/// Llega "jefe_fuego" (o lo lanza el lider): cada bola con su x, su altura y su retraso
function scr_jefe_fuego_recibir(_m) {
	if (!scr_modo_jefe() || room == rm_menu || !is_struct(_m) || !variable_global_exists("jefe")) return;
	if (!variable_struct_exists(_m, "l") || !is_array(_m.l)) return;
	for (var i = 0; i < array_length(_m.l); i++) {
		var _a = _m.l[i];
		if (!is_array(_a) || array_length(_a) < 3) continue;
		array_push(global.jefe.fuego, { x: real(_a[0]), y: max(-300, real(_a[1])), d: real(_a[2]), vs: 2, pego: false });
	}
}

function scr_jefe_fuego_step() {
	var J = global.jefe;
	for (var i = array_length(J.fuego) - 1; i >= 0; i--) {
		var _b = J.fuego[i];
		if (_b.d > 0) { _b.d -= 1; continue; }
		_b.vs = min(_b.vs + 0.25, 9);
		_b.y += _b.vs;
		var _fin = (_b.y > room_height + 60)
		        || collision_point(_b.x, _b.y, obj_wall, false, true) != noone
		        || collision_point(_b.x, _b.y, oPlataformaPasable, false, true) != noone;
		// Le cae a tu jugador
		if (!_b.pego && __jefe_fuego_toca(_b.x, _b.y, 28)) { _b.pego = true; _fin = true; }
		if (_fin) {
			var _e = instance_create_layer(_b.x, _b.y, "Weapons", oExplosionFX);
			_e.sprite_index = spr_explode2;
			_e.image_index = 0;
			_e.image_xscale = 1.4;
			_e.image_yscale = 1.4;
			if (!_b.pego) __jefe_fuego_toca(_b.x, _b.y, 50);   // salpica al caer
			array_delete(J.fuego, i, 1);
		}
	}
}

/// La bola en (_x, _y) toca a tu jugador (o a un bot, si soy el lider)? Hace el dano. Devuelve si toco a alguien.
function __jefe_fuego_toca(_x, _y, _rad) {
	var _toco = false;
	var _yo = noone;
	with (oPlayer) if (!isDead && !invulnerable && point_distance(x, y - 20, _x, _y) < _rad) _yo = id;
	if (_yo != noone) {
		_toco = true;
		callback_ReceivedEvent("hit", { damage: JEFE_FUEGO, killer: JEFE_KILLER, reason: "explosion", angle: (_yo.x >= _x) ? 60 : 120, bot: true }, -1);
	}
	if (instance_exists(oBrain) && oBrain.AmIPseudoHost) {
		with (oOtherPlayer) {
			if (!es_bot || !bot_local || isDead) continue;
			if (point_distance(x, y - 20, _x, _y) >= _rad) continue;
			_toco = true;
			scr_botnet_dano(id, { damage: JEFE_FUEGO, killer: JEFE_KILLER, reason: "explosion", angle: (x >= _x) ? 60 : 120 }, -1);
		}
	}
	return _toco;
}

/// Le bajas vida al jefe (tu bala, tu barril o la bala de un bot en el lider)
function scr_jefe_danar(_d) {
	if (!variable_global_exists("jefe")) return;
	var J = global.jefe;
	if (!J.listo || J.st == 5 || global.game_over || _d <= 0) return;
	__jefe_flash();
	if (oBrain.AmIPseudoHost) {
		__jefe_restar(_d);
	} else {
		var _h = oBrain.pseudoHostClientId;
		if (is_numeric(_h) && _h >= 0 && _h != global.clientId) SendEventToClient(_h, "jefe_hit", { d: _d });
	}
}

/// El lider le baja la vida (le llega "jefe_hit" o fue el)
function __jefe_restar(_d) {
	var J = global.jefe;
	if (!J.listo || J.st == 5 || global.game_over) return;
	J.hp = max(0, J.hp - max(0, _d));
	__jefe_flash();
	if (J.hp <= 0) {
		J.st = 5; J.tm = 0; J.hs = 0; J.vs = 0;
		J.envio = 0;   // que todos lo vean caer ya
	}
}

/// Con una bala (oMyEntity): si le pega al jefe hace el dano y devuelve true (la bala ya se resolvio)
function scr_jefe_bala() {
	if (!variable_global_exists("jefe")) return false;
	var J = global.jefe;
	if (!J.listo || J.st == 5 || global.game_over) return false;
	var _box = variable_instance_exists(id, "is_box") && is_box;
	if ((_box || variable_instance_exists(id, "atraviesa")) && variable_instance_exists(id, "jefe_pegado") && jefe_pegado) return false;
	var _l = J.x - JEFE_ANCHO, _t = J.y - JEFE_ALTO, _r = J.x + JEFE_ANCHO, _b = J.y;
	var _dentro = point_in_rectangle(x, y, _l, _t, _r, _b);
	if (!_dentro && !_box && speed > 0) {
		_dentro = point_in_rectangle(x + hspeed * 0.5, y + vspeed * 0.5, _l, _t, _r, _b)
		       || point_in_rectangle(x + hspeed, y + vspeed, _l, _t, _r, _b);
	}
	if (!_dentro) return false;

	var _bot_bala = variable_instance_exists(id, "bot_team");
	var _granada = variable_instance_exists(id, "is_granada") && is_granada;
	var _d = damage;
	scr_jefe_danar(_d);
	if (!_bot_bala) {
		fx_damage_number(x, y - 10, _d, is_rocket ? 2 : 0);
		global.hm_timer = HM_FRAMES;
		global.hm_type = 0;
		if (global.sfx) audio_play_sound(snd_hitmarker, 30, false, 0.9);
	}
	fx_impact_net(x, y, direction + 180, is_rocket ? 4 : 8, is_rocket);

	if (is_rocket || _granada) {
		// Solo el efecto (la explosion normal tambien lastima a los de cerca, y aqui todos son del mismo equipo)
		var _ef = instance_create_layer(x, y, "Weapons", oExplosionFX);
		if (_granada) _ef.sprite_index = spr_explode2;
		scrCamShake(_granada ? 8 : 12);
		if (global.sfx) audio_play_sound(snd_pearl_explodes, 10, false);
	}

	if (_box) { jefe_pegado = true; estado = -1; return true; }
	if (variable_instance_exists(id, "atraviesa") && atraviesa > 1) { atraviesa -= 1; jefe_pegado = true; return true; }
	instance_destroy();
	return true;
}

/// Explosion de un barril cerca del jefe (la revisa el que lo hizo explotar)
function scr_jefe_explosion(_x, _y, _rad, _dmg) {
	if (!scr_modo_jefe() || !variable_global_exists("jefe")) return;
	var J = global.jefe;
	var _cx = clamp(_x, J.x - JEFE_ANCHO, J.x + JEFE_ANCHO);
	var _cy = clamp(_y, J.y - JEFE_ALTO, J.y);
	if (point_distance(_x, _y, _cx, _cy) > _rad) return;
	scr_jefe_danar(_dmg);
	fx_damage_number(J.x, J.y - JEFE_ALTO - 10, _dmg, 2);
}

/// El lider: quien gano. 2 = los jugadores (AZUL), 1 = el jefe, 0 = todavia
function scr_jefe_ganador() {
	if (room == rm_menu || !variable_global_exists("jefe") || global.jefe.cuarto != room) return 0;
	if (!oBrain.intro_disparada || instance_exists(oIntroVersus)) return 0;
	var J = global.jefe;
	if (!J.listo) return 0;
	if (J.st == 5) return (J.tm >= room_speed * 1.5) ? 2 : 0;   // espera a que caiga
	if (oBrain.reloj_fin) return 1;                               // se acabo el tiempo
	if (J.todos_t > room_speed * 0.5) return 1;                   // cayeron todos a la vez
	return 0;
}

/// Un bot (con su instancia) en este modo: se pone de lado del jefe a buena distancia y le dispara
function scr_jefe_bot_pensar() {
	if (!variable_global_exists("jefe")) return;
	var J = global.jefe;
	if (!J.listo || J.st == 5) {
		weapon.angle = (image_xscale > 0) ? 0 : 180;
		return;
	}
	var _jx = J.x, _jy = J.y - JEFE_ALTO * 0.5;
	var _lado = (x < J.x) ? -1 : 1;
	var _tx = clamp(J.x + _lado * 230, 40, room_width - 40);
	if (abs(x - _tx) > 30 || abs(y - J.y) > 120) scr_bot_nav_move(_tx, J.y);
	var _d = point_distance(x, y, _jx, _jy);
	var _veo = (_d < BOTNET_VISTA + 200) && (collision_line(x, y - 16, _jx, _jy, obj_wall, false, true) == noone);
	if (_veo && !has_flag) {
		bot_error = lerp(bot_error, random_range(-7, 7), 0.15);
		weapon.angle = point_direction(x, y - 18, _jx, _jy) + bot_error;
		if (hsp == 0) image_xscale = (_jx >= x) ? 1.5 : -1.5;
		if (!reloading && ammo > 0 && weapon.frequency <= 0 && bot_rafaga <= 0 && random(100) < 35) scr_botnet_disparar();
	} else {
		weapon.angle = (image_xscale > 0) ? 0 : 180;
	}
	if (!reloading && ammo <= 0) scr_botnet_recargar();
}

/// oJefe Draw: el jefe, sus ondas y el fuego (en el mundo)
function scr_jefe_draw() {
	if (!scr_modo_jefe() || room == rm_menu || !variable_global_exists("jefe")) return;
	var J = global.jefe;

	// Ondas del pisoton
	for (var i = 0; i < array_length(J.ondas); i++) {
		var _o = J.ondas[i];
		var _p = _o.t / 30;
		var _rr = 40 + 230 * _p;
		draw_set_alpha(1 - _p);
		draw_set_color(make_color_rgb(255, 240, 200));
		draw_ellipse(_o.x - _rr, _o.y - _rr * 0.12, _o.x + _rr, _o.y + _rr * 0.12, true);
		draw_ellipse(_o.x - _rr + 3, _o.y - _rr * 0.12 + 2, _o.x + _rr - 3, _o.y + _rr * 0.12 - 2, true);
	}
	draw_set_alpha(1);

	// Bolas de fuego
	for (var j = 0; j < array_length(J.fuego); j++) {
		var _b = J.fuego[j];
		if (_b.d > 0) continue;
		draw_set_color(make_color_rgb(255, 120, 40));
		for (var k = 1; k <= 3; k++) {
			draw_set_alpha(0.35 - k * 0.08);
			draw_circle(_b.x, _b.y - k * 9, 8 - k, false);
		}
		draw_set_alpha(1);
		draw_set_color(make_color_rgb(255, 90, 40));
		draw_circle(_b.x, _b.y, 8, false);
		draw_set_color(make_color_rgb(255, 220, 120));
		draw_circle(_b.x, _b.y, 4, false);
	}
	draw_set_color(c_white);

	// El jefe
	var _spr = spr_sargento_idle, _img = 0;
	var _off = 0;
	var _alpha = 1;
	switch (J.st) {
		case 0:
			if (abs(J.hs) > 0.1 || (point_distance(J.x, 0, J.nx, 0) > 1 && !oBrain.AmIPseudoHost)) {
				_spr = spr_sargento_walk;
				_img = (J.anim div ((J.fase >= 3) ? 5 : 8)) mod sprite_get_number(spr_sargento_walk);
			}
		break;
		case 1:
			_spr = spr_sargento_walk;
			_img = 2 mod sprite_get_number(spr_sargento_walk);
			var _w = __jefe_espera_puno(J.fase);
			if (J.tm < _w) _off = -10 * (J.tm / _w);
			else _off = 30 * max(0, 1 - (J.tm - _w) / 14);
		break;
		case 2:
		case 6:
			_spr = spr_sargento_walk;
			_img = 1 mod sprite_get_number(spr_sargento_walk);
		break;
		case 7:
			_spr = spr_sargento_walk;
			if (J.tm < 20) { _img = 0; _off = -12 * (J.tm / 20); }                          // se agacha para tomar impulso
			else _img = (J.anim div 3) mod sprite_get_number(spr_sargento_walk);             // corre
		break;
		case 3:
		case 4:
			_spr = spr_sargento_hit;
			_img = (J.anim div 6) mod sprite_get_number(spr_sargento_hit);
		break;
		case 5:
			_spr = spr_sargento_dead;
			_img = min(J.muerto_t div 8, sprite_get_number(spr_sargento_dead) - 1);
			_alpha = clamp(1 - (J.muerto_t - 70) / 40, 0, 1);
		break;
	}
	var _dx = J.x + J.f * _off;
	var _dy = J.y - (sprite_get_height(_spr) - sprite_get_yoffset(_spr)) * JEFE_ESC;
	if (J.st == 0 && abs(J.hs) < 0.1) _dy += sin(J.anim * 0.1) * 2;
	var _xs = JEFE_ESC * J.f, _ys = JEFE_ESC;

	// FURIA: brilla en rojo
	if (J.fase >= 3 && J.st != 5) {
		gpu_set_blendmode(bm_add);
		draw_sprite_ext(_spr, _img, _dx, _dy, _xs * 1.08, _ys * 1.05, 0, c_red, 0.25 + 0.15 * sin(J.anim * 0.3));
		gpu_set_blendmode(bm_normal);
	}
	draw_sprite_ext(_spr, _img, _dx, _dy, _xs, _ys, 0, make_color_rgb(255, 150, 165), _alpha);
	// Golpe: un destello blanco cortito encima (no lo tapa todo)
	if (J.flash > 0 && J.st != 5) {
		gpu_set_fog(true, c_white, 0, 0);
		draw_sprite_ext(_spr, _img, _dx, _dy, _xs, _ys, 0, c_white, 0.55 * _alpha);
		gpu_set_fog(false, c_white, 0, 0);
	}

	// Aviso "!" antes de pegar o de lanzar fuego
	var _aviso = (J.st == 1 && J.tm < __jefe_espera_puno(J.fase)) || (J.st == 3 && J.tm < 20) || (J.st == 7 && J.tm < 20);
	if (_aviso) {
		draw_set_font(fnt_menu);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		var _sc = 0.9 + 0.15 * sin(J.anim * 0.5);
		draw_text_transformed_color(J.x + 2, J.y - JEFE_ALTO - 28 + 2, "!", _sc, _sc, 0, c_black, c_black, c_black, c_black, 0.7);
		draw_text_transformed_color(J.x, J.y - JEFE_ALTO - 28, "!", _sc, _sc, 0, c_red, c_red, c_yellow, c_yellow, 1);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	}
	draw_set_color(c_white);
	draw_set_alpha(1);
}

/// oBrain Draw GUI: barra de vida del jefe, reloj y el aviso de fase
function scr_jefe_draw_gui(_mx, _y) {
	if (!scr_modo_jefe() || room == rm_menu || !variable_global_exists("jefe")) return;
	var J = global.jefe;
	var _w = 440, _h = 58;
	var _x0 = _mx - _w / 2;
	draw_set_alpha(0.55); draw_set_color(c_black);
	draw_roundrect_ext(_x0, _y + 6, _x0 + _w, _y + _h + 6, 20, 20, false);
	draw_set_alpha(1); draw_set_color(make_color_rgb(17, 20, 29));
	draw_roundrect_ext(_x0, _y, _x0 + _w, _y + _h, 20, 20, false);
	draw_set_font(fnt_menu); draw_set_halign(fa_center); draw_set_valign(fa_middle);
	draw_text_transformed_color(_mx + 1, _y + 16 + 1, JEFE_NOMBRE, 0.36, 0.36, 0, c_black, c_black, c_black, c_black, 0.7);
	draw_text_transformed_color(_mx, _y + 16, JEFE_NOMBRE, 0.36, 0.36, 0, c_white, c_white, c_white, c_white, 1);
	// Barra
	var _bx0 = _x0 + 16, _bx1 = _x0 + _w - 46, _by0 = _y + 31, _by1 = _y + 45;
	draw_set_color(make_color_rgb(60, 20, 25));
	draw_rectangle(_bx0, _by0, _bx1, _by1, false);
	var _r = clamp(J.hp / max(1, J.hpmax), 0, 1);
	var _col = make_color_rgb(229, 72, 77);
	if (J.fase >= 3) _col = ((current_time div 120) mod 2 == 0) ? make_color_rgb(255, 60, 60) : make_color_rgb(255, 200, 60);
	draw_set_color(_col);
	if (_r > 0) draw_rectangle(_bx0, _by0, _bx0 + (_bx1 - _bx0) * _r, _by1, false);
	draw_set_color(c_white);
	for (var i = 1; i <= 2; i++) {
		var _mk = _bx0 + (_bx1 - _bx0) * (i / 3);
		draw_line_width(_mk, _by0 - 2, _mk, _by1 + 2, 2);
	}
	draw_set_color(make_color_rgb(242, 182, 50));
	draw_text_transformed(_x0 + _w - 24, (_by0 + _by1) / 2, "F" + string(J.fase), 0.36, 0.36, 0);
	draw_set_color(c_white);
	// Reloj abajo
	scr_reloj_draw(_mx, _y + _h + 24);

	// Aviso de fase
	if (J.banner_t > 0) {
		var _gw = display_get_gui_width(), _gh = display_get_gui_height();
		var _tot = room_speed * 1.6;
		var _p = 1 - J.banner_t / _tot;
		var _off = 0;
		if (_p < 0.15) _off = -_gw * (1 - _p / 0.15);
		else if (_p > 0.85) _off = _gw * ((_p - 0.85) / 0.15);
		var _cy = _gh * 0.42;
		draw_set_alpha(0.9); draw_set_color(make_color_rgb(17, 20, 29));
		draw_rectangle(_off, _cy - 40, _gw + _off, _cy + 40, false);
		draw_set_alpha(1);
		var _tc = (J.fase >= 3) ? make_color_rgb(255, 80, 80) : make_color_rgb(242, 182, 50);
		draw_text_transformed_color(_gw / 2 + _off + 3, _cy + 3, J.banner_txt, 0.9, 0.9, 0, c_black, c_black, c_black, c_black, 0.8);
		draw_text_transformed_color(_gw / 2 + _off, _cy, J.banner_txt, 0.9, 0.9, 0, _tc, _tc, _tc, _tc, 1);
	}
	draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white); draw_set_alpha(1);
}
