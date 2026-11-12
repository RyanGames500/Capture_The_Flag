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

function scr_ajustes_struct() {
	var _s = { t: global.match_tiempo, m: global.match_mapa, b: global.match_banderas };
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
	draw_text_transformed(_x1 + 28, _y0 + 18, _soy_lider ? "AJUSTES DE LA PARTIDA" : "AJUSTES DE LA PARTIDA (LOS ELIGE EL LIDER)", 0.6, 0.6, 0);
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
	// El rival: un bot de sala privada, con nombre de persona (sin "BOT")
	global.botnet_defs = [{ i: BOTNET_ID_BASE - 4, n: global.bot_nombre, t: "ROJO", r: "ataque", h: true, pj: global.bot_pj }];
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
