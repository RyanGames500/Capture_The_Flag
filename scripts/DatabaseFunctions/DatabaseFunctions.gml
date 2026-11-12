function SetSimpleData(collectionName, documentName, mapStruct){
	//format for sending info to server 
		var Buffer = buffer_create(1, buffer_grow, 1)
	
		//WHAT DATA 
		var data = ds_map_create();
		
		data[? "clientId"] = global.clientId;
		data[? "c"] = collectionName;
		data[? "d"] = documentName;
		data[? "m"] = json_stringify(mapStruct);
		ds_map_add(data,"eventName","set_simple_data");
		buffer_write(Buffer, buffer_text, EC(string(json_encode(data))))
		network_send_raw(oBrain.socket, Buffer, buffer_tell(Buffer),network_send_text)
		buffer_delete(Buffer)
		ds_map_destroy(data)

}


function ReadSimpleData(collectionName, documentName){
	
	var readId = int64( string(current_time) +string(floor(random(10000))))
	//format for sending info to server 
		var Buffer = buffer_create(1, buffer_grow, 1)
	
		//WHAT DATA 
		var data = ds_map_create();
		
		data[? "clientId"] = global.clientId;
		data[? "c"] = collectionName;
		data[? "d"] = documentName;
		data[? "readId"] = readId;

		ds_map_add(data,"eventName","read_simple_data");
		buffer_write(Buffer, buffer_text, EC(string(json_encode(data))))
		network_send_raw(oBrain.socket, Buffer, buffer_tell(Buffer),network_send_text)
		buffer_delete(Buffer)
		ds_map_destroy(data)
		
		
		return readId;

}


function DeleteSimpleData(collectionName, documentName){
	//format for sending info to server 
		var Buffer = buffer_create(1, buffer_grow, 1)
	
		//WHAT DATA 
		var data = ds_map_create();
		
		data[? "clientId"] = global.clientId;
		data[? "c"] = collectionName;
		data[? "d"] = documentName;

		ds_map_add(data,"eventName","delete_simple_data");
		buffer_write(Buffer, buffer_text, EC(string(json_encode(data))))
		network_send_raw(oBrain.socket, Buffer, buffer_tell(Buffer),network_send_text)
		buffer_delete(Buffer)
		ds_map_destroy(data)

}

function GetDatabaseSummary(){
	//format for sending info to server 
		var Buffer = buffer_create(1, buffer_grow, 1)
	
		//WHAT DATA 
		var data = ds_map_create();
		
		data[? "clientId"] = global.clientId;


		ds_map_add(data,"eventName","get_db_summary");
		buffer_write(Buffer, buffer_text, EC(string(json_encode(data))))
		network_send_raw(oBrain.socket, Buffer, buffer_tell(Buffer),network_send_text)
		buffer_delete(Buffer)
		ds_map_destroy(data)



}


// ======================================================
// CUENTAS (usuario + contrasena) - el servidor las guarda en Neon (ctf-server, cuentas.js)
// - Se puede jugar como INVITADO igual que antes (y el modo local contra bots no necesita cuenta).
// - Primera vez que abres el juego: sale la pantalla de cuentas (ENTRAR / CREAR CUENTA / INVITADO).
// - "Recordarme": se guarda solo un token en cuenta.ini (nunca la contrasena).
//   En HTML5 el .ini queda guardado en el navegador.
// - Al crear la cuenta se manda el progreso que ya tienes en el aparato (no se pierde nada).
// - Al entrar, lo de la cuenta reemplaza lo del aparato. Cada vez que el juego guarda
//   (scr_save_to_local) tambien se guarda en la cuenta.
// - Gamdato y SetSimpleData siguen igual (conviven).
// El servidor contesta { eventName: "cuenta", accion, ok, err, usuario, perfil, token } (oBrain Other_68)
// ======================================================
#macro CUENTA_INI       "cuenta.ini"
#macro CUENTA_ESPERA_MAX 600   // 10 s esperando al servidor y se avisa

function scr_cuenta_init() {
	if (variable_global_exists("cuenta") && is_struct(global.cuenta)) return;
	ini_open(CUENTA_INI);
	var _tk = ini_read_string("Cuenta", "token", "");
	var _us = ini_read_string("Cuenta", "usuario", "");
	ini_close();
	global.cuenta = {
		usuario: _us, token: _tk, entrado: false, recordar: true,
		esperando: "", esp_t: 0, msg: "", msg_rojo: false,
		ui: false, desde_menu: false, tab: 0, campo: 0, u: _us, p: "", p2: "",
		inicio_hecho: false, ya_entro: false, chip: [0, 0, 0, 0], franja: [0, 0, 0, 0], cursor: 0
	};
}

/// ¿Entraste a una cuenta?
function scr_cuenta_activa() {
	return variable_global_exists("cuenta") && is_struct(global.cuenta) && global.cuenta.entrado;
}

/// ¿Hay conexion con el servidor?
function scr_cuenta_conectado() {
	return instance_exists(oBrain) && variable_global_exists("clientId") && global.clientId >= 0;
}

/// Manda un pedido de cuenta al servidor (mismo formato que SetSimpleData)
function scr_cuenta_enviar(_ev, _s) {
	if (!scr_cuenta_conectado()) return false;
	var _b = buffer_create(1, buffer_grow, 1);
	var _m = ds_map_create();
	var _k = variable_struct_get_names(_s);
	for (var i = 0; i < array_length(_k); i++) _m[? _k[i]] = _s[$ _k[i]];
	ds_map_add(_m, "eventName", _ev);
	buffer_write(_b, buffer_text, EC(string(json_encode(_m))));
	network_send_raw(oBrain.socket, _b, buffer_tell(_b), network_send_text);
	buffer_delete(_b);
	ds_map_destroy(_m);
	return true;
}

/// El perfil que se guarda en la cuenta (lo mismo que ya guarda el juego)
function scr_cuenta_perfil() {
	return {
		nombre: string(global.myName),
		lvl: global.lvl, xp: global.xp, wins: global.wins, losses: global.losses, kills: global.kills,
		flags: global.flags_captured, returned: global.flags_returned,
		copas: variable_global_exists("copas") ? global.copas : 0,
		rank: string(global.rank),
		friend_tag: string(global.miFriendTag),
		amigos: (variable_global_exists("lista_amigos") && is_array(global.lista_amigos)) ? global.lista_amigos : [],
		logros: (variable_global_exists("logros") && is_array(global.logros)) ? global.logros : [],
		// INVENTARIO (icono, skin puesta y desbloqueables)
		avatar: variable_global_exists("avatar_id") ? global.avatar_id : 0,
		skin: scr_inv_skin(),
		desbloqueados: scr_inv_lista()
	};
}

function __cuenta_dato(_p, _k, _def) {
	return variable_struct_exists(_p, _k) ? _p[$ _k] : _def;
}

/// Pone en el juego lo que viene de la cuenta
function scr_cuenta_aplicar(_json) {
	if (!is_string(_json) || _json == "") return false;
	var _p;
	try { _p = json_parse(_json); } catch (_e) { return false; }
	if (!is_struct(_p)) return false;
	var _n = string(__cuenta_dato(_p, "nombre", ""));
	if (_n != "") global.myName = _n;
	global.lvl            = real(__cuenta_dato(_p, "lvl", 1));
	global.xp             = real(__cuenta_dato(_p, "xp", 0));
	global.wins           = real(__cuenta_dato(_p, "wins", 0));
	global.losses         = real(__cuenta_dato(_p, "losses", 0));
	global.kills          = real(__cuenta_dato(_p, "kills", 0));
	global.flags_captured = real(__cuenta_dato(_p, "flags", 0));
	global.flags_returned = real(__cuenta_dato(_p, "returned", 0));
	global.copas          = real(__cuenta_dato(_p, "copas", 0));
	global.rank           = string(__cuenta_dato(_p, "rank", "RECLUTA"));
	var _tag = string(__cuenta_dato(_p, "friend_tag", ""));
	if (_tag != "" && _tag != "0") global.miFriendTag = _tag;
	var _am = __cuenta_dato(_p, "amigos", undefined);
	if (is_array(_am)) global.lista_amigos = _am;
	// INVENTARIO: icono y skin de la cuenta; los desbloqueables se juntan con los del aparato
	if (variable_struct_exists(_p, "avatar")) global.avatar_id = real(_p.avatar);
	if (variable_struct_exists(_p, "skin")) global.skin_actual = string(_p.skin);
	var _db = __cuenta_dato(_p, "desbloqueados", undefined);
	if (is_array(_db)) for (var k = 0; k < array_length(_db); k++) scr_inv_agregar(string(_db[k]));
	// Logros: se juntan los de la cuenta con los del aparato (no se pierde ninguno)
	var _lg = __cuenta_dato(_p, "logros", undefined);
	if (is_array(_lg)) {
		scr_logros_init();
		for (var i = 0; i < array_length(_lg); i++) if (!scr_logro_tiene(_lg[i])) array_push(global.logros, string(_lg[i]));
	}
	return true;
}

/// Guarda (o borra) el token de "Recordarme" en el aparato
function scr_cuenta_guardar_token(_recordar) {
	var _c = global.cuenta;
	ini_open(CUENTA_INI);
	ini_write_string("Cuenta", "token", _recordar ? _c.token : "");
	ini_write_string("Cuenta", "usuario", _c.usuario);
	ini_close();
}

/// Al conectar (o reconectar) con el servidor: si hay token, se entra solo
function scr_cuenta_al_conectar() {
	scr_cuenta_init();
	var _c = global.cuenta;
	if (_c.token == "") return;
	_c.esperando = "token";
	_c.esp_t = 0;
	scr_cuenta_enviar("cuenta_token", { tk: _c.token });
}

/// Guarda el progreso en la cuenta (lo llama scr_save_to_local)
function scr_cuenta_guardar() {
	if (!scr_cuenta_activa()) return;
	scr_cuenta_enviar("cuenta_guardar", { perfil: json_stringify(scr_cuenta_perfil()) });
}

/// Cerrar sesion en este aparato (el progreso se queda en el aparato como invitado)
function scr_cuenta_salir() {
	scr_cuenta_init();
	var _c = global.cuenta;
	if (_c.token != "") scr_cuenta_enviar("cuenta_salir", { tk: _c.token });
	_c.entrado = false;
	_c.ya_entro = false;
	_c.token = "";
	scr_cuenta_guardar_token(false);
	show_debug_message(">>> CUENTA: sesion cerrada");
}

/// Texto del error (ASCII)
function scr_cuenta_error_txt(_e) {
	if (string_copy(_e, 1, 6) == "espera") {
		var _s = real(string_digits(_e));
		return "DEMASIADOS INTENTOS. ESPERA " + string(max(1, ceil(_s / 60))) + " MIN";
	}
	switch (_e) {
		case "usuario_invalido":            return "USUARIO: 3 A 16 LETRAS, NUMEROS O _";
		case "clave_muy_corta":             return "LA CONTRASENA DEBE TENER 6 O MAS";
		case "clave_muy_larga":             return "CONTRASENA DEMASIADO LARGA";
		case "usuario_ya_existe":           return "ESE USUARIO YA EXISTE";
		case "usuario_o_clave_incorrectos": return "USUARIO O CONTRASENA INCORRECTOS";
		case "demasiados_pedidos":          return "ESPERA UN MOMENTO Y PRUEBA OTRA VEZ";
		case "sesion_vencida":              return "TU SESION SE VENCIO, ENTRA OTRA VEZ";
	}
	return "NO SE PUDO CONECTAR CON LAS CUENTAS";
}

/// Respuesta del servidor (oBrain Other_68, case "cuenta")
function scr_cuenta_recibir(_d) {
	try {
		scr_cuenta_init();
		var _c = global.cuenta;
		var _acc = string(__cuenta_dato(_d, "accion", ""));
		var _ok  = real(__cuenta_dato(_d, "ok", 0)) == 1;
		var _err = string(__cuenta_dato(_d, "err", ""));

		if (_acc == "guardar") {
			// Se perdio la sesion (reconexion): se vuelve a entrar con el token y se guarda otra vez
			if (!_ok && _err == "no_has_entrado" && _c.token != "") { _c.entrado = false; scr_cuenta_al_conectar(); }
			return;
		}
		if (_acc == "salir") return;
		if (_acc != "crear" && _acc != "entrar" && _acc != "token") return;

		_c.esperando = "";
		if (_ok) {
			var _era_nuevo = (global.registrado == 0);
			_c.entrado = true;
			_c.usuario = string(__cuenta_dato(_d, "usuario", _c.u));
			_c.token   = string(__cuenta_dato(_d, "token", ""));
			// Al crear, la cuenta ya tiene lo tuyo. Si se reconecto a media sesion (token otra vez),
			// lo del aparato es lo mas nuevo: no se pisa, se manda a la cuenta.
			var _ya = _c.ya_entro;
			_c.ya_entro = true;
			if (_acc == "entrar" || (_acc == "token" && !_ya)) scr_cuenta_aplicar(__cuenta_dato(_d, "perfil", ""));
			if (_acc != "token") scr_cuenta_guardar_token(_c.recordar);
			global.registrado = 1;
			if (!variable_global_exists("miFriendTag") || string(global.miFriendTag) == "" || string(global.miFriendTag) == "0") {
				global.miFriendTag = scr_generar_id_amigo();
			}
			_c.ui = false;
			_c.p = ""; _c.p2 = ""; _c.campo = 0; _c.msg = "";
			if (touch_mode()) keyboard_virtual_hide();
			scr_save_to_local();   // copia en el aparato (y se guarda en la cuenta)
			if (scr_cuenta_conectado()) scr_sincronizar_nube();   // tu ficha para los amigos
			show_debug_message(">>> CUENTA: entraste como " + _c.usuario + " (" + _acc + ")");
		} else {
			if (_acc == "token") {
				// El "Recordarme" ya no sirve: se borra. Si es la primera vez, se muestra la pantalla
				_c.token = "";
				scr_cuenta_guardar_token(false);
				if (global.registrado == 0) { _c.ui = true; _c.msg = scr_cuenta_error_txt(_err); _c.msg_rojo = true; }
			} else {
				_c.msg = scr_cuenta_error_txt(_err);
				_c.msg_rojo = true;
			}
		}
	} catch (_e) { show_debug_message("[Cuenta] error: " + string(_e)); }
}

// ------------------------------------------------------
// PANTALLA DE CUENTAS (opcion A): pestanas ENTRAR / CREAR CUENTA, e INVITADO abajo
// ------------------------------------------------------

/// Abrir la pantalla desde el menu (chip de arriba o PERFIL). _tab: 0 entrar, 1 crear
function scr_cuenta_abrir(_tab) {
	scr_cuenta_init();
	var _c = global.cuenta;
	_c.ui = true; _c.desde_menu = true; _c.tab = _tab; _c.campo = 0; _c.msg = ""; _c.p = ""; _c.p2 = "";
	keyboard_string = "";
}

/// Medidas de todo (las usan el Step y el Draw)
function scr_cuenta_ui_geo() {
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	var _u = clamp(min(_gw / 1280, _gh / 720), 0.6, 1.6);
	var _c = global.cuenta;
	var _pw = 440 * _u, _px = _gw / 2 - _pw / 2;
	var _y = 140 * _u;
	var _g = { u: _u, gw: _gw, gh: _gh, px: _px, pw: _pw, r: [] };
	var _tw = (_pw - 10 * _u) / 2;
	array_push(_g.r, { id: "tab0", x1: _px, y1: _y, x2: _px + _tw, y2: _y + 40 * _u });
	array_push(_g.r, { id: "tab1", x1: _px + _tw + 10 * _u, y1: _y, x2: _px + _pw, y2: _y + 40 * _u });
	_y += 56 * _u;
	array_push(_g.r, { id: "u", x1: _px, y1: _y, x2: _px + _pw, y2: _y + 50 * _u });
	_y += 58 * _u;
	array_push(_g.r, { id: "p", x1: _px, y1: _y, x2: _px + _pw, y2: _y + 50 * _u });
	if (_c.tab == 1) {
		_y += 58 * _u;
		array_push(_g.r, { id: "p2", x1: _px, y1: _y, x2: _px + _pw, y2: _y + 50 * _u });
	}
	_y += 64 * _u;
	array_push(_g.r, { id: "rec", x1: _px, y1: _y, x2: _px + _pw * 0.75, y2: _y + 30 * _u });
	_y += 42 * _u;
	array_push(_g.r, { id: "ok", x1: _px, y1: _y, x2: _px + _pw, y2: _y + 52 * _u });
	_y += (_c.tab == 1) ? 86 * _u : 64 * _u;
	_g.info_y = _y - 18 * _u;
	array_push(_g.r, { id: "inv", x1: _px + _pw * 0.12, y1: _y, x2: _px + _pw * 0.88, y2: _y + 44 * _u });
	_y += 58 * _u;
	_g.msg_y = _y;
	return _g;
}

function __cuenta_rect(_g, _id) {
	for (var i = 0; i < array_length(_g.r); i++) if (_g.r[i].id == _id) return _g.r[i];
	return undefined;
}

/// Solo letras, numeros y _ (usuario) o ASCII visible (contrasena)
function __cuenta_filtrar(_t, _usuario) {
	var _o = "";
	for (var i = 1; i <= string_length(_t); i++) {
		var _ch = string_char_at(_t, i);
		var _o2 = ord(_ch);
		if (_usuario) {
			if ((_o2 >= 48 && _o2 <= 57) || (_o2 >= 65 && _o2 <= 90) || (_o2 >= 97 && _o2 <= 122) || _ch == "_") _o += _ch;
		} else if (_o2 >= 32 && _o2 <= 126) _o += _ch;
	}
	return string_copy(_o, 1, _usuario ? 16 : 64);
}

function __cuenta_campo(_n) {
	var _c = global.cuenta;
	_c.campo = _n;
	keyboard_string = (_n == 1) ? _c.u : ((_n == 2) ? _c.p : ((_n == 3) ? _c.p2 : ""));
	if (_n > 0 && touch_mode()) keyboard_virtual_show(kbv_type_default, kbv_returnkey_done, kbv_autocapitalize_none, false);
}

function __cuenta_mandar() {
	var _c = global.cuenta;
	if (_c.esperando != "") return;
	_c.msg_rojo = true;
	if (!scr_cuenta_conectado()) { _c.msg = "SIN CONEXION CON EL SERVIDOR, ESPERA UN MOMENTO"; return; }
	if (string_length(_c.u) < 3) { _c.msg = "USUARIO: 3 A 16 LETRAS, NUMEROS O _"; return; }
	if (string_length(_c.p) < 6) { _c.msg = "LA CONTRASENA DEBE TENER 6 O MAS"; return; }
	if (_c.tab == 1 && _c.p != _c.p2) { _c.msg = "LAS CONTRASENAS NO SON IGUALES"; return; }
	_c.msg_rojo = false;
	_c.esp_t = 0;
	if (_c.tab == 0) {
		_c.esperando = "entrar";
		_c.msg = "ENTRANDO...";
		scr_cuenta_enviar("cuenta_entrar", { u: _c.u, p: _c.p });
	} else {
		// Lo que ya tienes en el aparato se pasa a la cuenta
		if (global.registrado == 0 || string(global.myName) == "" || global.myName == "Cargando...") global.myName = _c.u;
		if (!variable_global_exists("miFriendTag") || string(global.miFriendTag) == "" || string(global.miFriendTag) == "0") {
			global.miFriendTag = scr_generar_id_amigo();
		}
		_c.esperando = "crear";
		_c.msg = "CREANDO CUENTA...";
		scr_cuenta_enviar("cuenta_crear", { u: _c.u, p: _c.p, perfil: json_stringify(scr_cuenta_perfil()) });
	}
	if (touch_mode()) keyboard_virtual_hide();
}

function __cuenta_cerrar_ui() {
	var _c = global.cuenta;
	_c.ui = false; _c.campo = 0; _c.p = ""; _c.p2 = ""; _c.msg = "";
	keyboard_string = "";
	if (touch_mode()) keyboard_virtual_hide();
}

/// Va al principio del Step de oMenu. Devuelve true si la pantalla de cuentas (o un toque suyo) tomo el control.
function scr_cuenta_menu_step() {
	scr_cuenta_init();
	var _c = global.cuenta;
	if (!_c.inicio_hecho) {
		_c.inicio_hecho = true;
		// Primera vez (sin nombre todavia): pantalla de cuentas
		if (global.registrado == 0 && !_c.entrado) { _c.ui = true; _c.desde_menu = false; }
	}
	if (_c.esperando != "") {
		_c.esp_t++;
		if (_c.esp_t > CUENTA_ESPERA_MAX) { _c.esperando = ""; _c.msg = "EL SERVIDOR NO RESPONDE, PRUEBA OTRA VEZ"; _c.msg_rojo = true; }
	}

	if (!_c.ui) {
		// Chip del menu principal y franja de PERFIL
		if (device_mouse_check_button_pressed(0, mb_left)) {
			var _mx = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
			if (menu_state == "main" && point_in_rectangle(_mx, _my, _c.chip[0], _c.chip[1], _c.chip[2], _c.chip[3])) {
				if (!_c.entrado) { scr_cuenta_abrir(0); return true; }
				menu_state = "profile";   // con cuenta: el chip te lleva a tu perfil
				return true;
			}
			if (menu_state == "profile" && point_in_rectangle(_mx, _my, _c.franja[0], _c.franja[1], _c.franja[2], _c.franja[3])) {
				if (_c.entrado) scr_cuenta_salir();
				else scr_cuenta_abrir(1);
				return true;
			}
		}
		return false;
	}

	// --- Pantalla de cuentas ---
	var _g = scr_cuenta_ui_geo();
	if (_c.campo > 0 && _c.esperando == "") {
		var _t = __cuenta_filtrar(keyboard_string, _c.campo == 1);
		if (_t != keyboard_string) keyboard_string = _t;
		if (_c.campo == 1) _c.u = _t;
		else if (_c.campo == 2) _c.p = _t;
		else _c.p2 = _t;
	}
	if (keyboard_check_pressed(vk_tab)) {
		var _max = (_c.tab == 1) ? 3 : 2;
		__cuenta_campo((_c.campo mod _max) + 1);
	}
	if (keyboard_check_pressed(vk_enter)) {
		var _max2 = (_c.tab == 1) ? 3 : 2;
		if (_c.campo > 0 && _c.campo < _max2 && ((_c.campo == 1 && _c.p == "") || (_c.campo == 2 && _c.tab == 1 && _c.p2 == ""))) __cuenta_campo(_c.campo + 1);
		else __cuenta_mandar();
	}
	if (keyboard_check_pressed(vk_escape)) {
		if (_c.campo > 0) { _c.campo = 0; if (touch_mode()) keyboard_virtual_hide(); }
		else if (_c.desde_menu) __cuenta_cerrar_ui();
	}
	if (device_mouse_check_button_pressed(0, mb_left) && _c.esperando == "") {
		var _mx2 = device_mouse_x_to_gui(0), _my2 = device_mouse_y_to_gui(0);
		var _toco = "";
		for (var i = 0; i < array_length(_g.r); i++) {
			var _r = _g.r[i];
			if (point_in_rectangle(_mx2, _my2, _r.x1, _r.y1, _r.x2, _r.y2)) { _toco = _r.id; break; }
		}
		switch (_toco) {
			case "tab0": _c.tab = 0; _c.msg = ""; __cuenta_campo(0); break;
			case "tab1": _c.tab = 1; _c.msg = ""; __cuenta_campo(0); break;
			case "u":    __cuenta_campo(1); break;
			case "p":    __cuenta_campo(2); break;
			case "p2":   __cuenta_campo(3); break;
			case "rec":  _c.recordar = !_c.recordar; break;
			case "ok":   __cuenta_mandar(); break;
			case "inv":  __cuenta_cerrar_ui(); break;   // INVITADO (primera vez) o VOLVER (desde el menu)
			default:     if (_c.campo > 0) { _c.campo = 0; if (touch_mode()) keyboard_virtual_hide(); }
		}
	}
	return true;
}

/// Va al principio del Draw GUI de oMenu. Devuelve true si se dibujo la pantalla de cuentas.
function scr_cuenta_ui_draw() {
	if (!variable_global_exists("cuenta") || !is_struct(global.cuenta) || !global.cuenta.ui) return false;
	var _c = global.cuenta;
	var _g = scr_cuenta_ui_geo();
	var _u = _g.u;
	var _tinta = make_color_rgb(11, 15, 26), _azul = make_color_rgb(31, 155, 255);
	var _gris = make_color_rgb(169, 180, 208), _oro = make_color_rgb(255, 212, 71);
	var _rojo = make_color_rgb(255, 107, 122), _verde = make_color_rgb(78, 255, 145);
	var _s = 10 * _u;
	_c.cursor++;

	ctf_ui_fondo(_g.gw, _g.gh);
	ctf_ui_header(_g.gw, "CAPTURE THE FLAG", "TU CUENTA", _u);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);

	for (var i = 0; i < array_length(_g.r); i++) {
		var _r = _g.r[i];
		var _w = _r.x2 - _r.x1, _h = _r.y2 - _r.y1;
		var _cy = (_r.y1 + _r.y2) / 2;
		switch (_r.id) {
			case "tab0":
			case "tab1":
				var _sel = (_c.tab == ((_r.id == "tab0") ? 0 : 1));
				ctf_ui_para(_r.x1, _r.y1, _w, _h, _s, _tinta, 0.9, false);
				if (_sel) ctf_ui_para(_r.x1, _r.y1, _w, _h, _s, _azul, 0.15, false);
				ctf_ui_para(_r.x1, _r.y1, _w, _h, _s, _sel ? _azul : _gris, _sel ? 1 : 0.3, true);
				draw_set_font(fnt_menu);
				draw_set_color(_sel ? c_white : _gris);
				draw_text_transformed((_r.x1 + _r.x2) / 2, _cy, (_r.id == "tab0") ? "ENTRAR" : "CREAR CUENTA", 0.6 * _u, 0.6 * _u, 0);
			break;
			case "u":
			case "p":
			case "p2":
				var _n = (_r.id == "u") ? 1 : ((_r.id == "p") ? 2 : 3);
				var _act = (_c.campo == _n);
				var _val = (_n == 1) ? _c.u : ((_n == 2) ? _c.p : _c.p2);
				ctf_ui_para(_r.x1, _r.y1, _w, _h, _s, _tinta, 0.92, false);
				ctf_ui_para(_r.x1, _r.y1, _w, _h, _s, _act ? _azul : _gris, _act ? 1 : 0.35, true);
				draw_set_halign(fa_left);
				draw_set_font(fnt_small);
				draw_set_color(_gris);
				draw_set_alpha(0.7);
				var _lab = (_n == 1) ? "USUARIO" : ((_n == 2) ? "CONTRASENA" : "REPETIR CONTRASENA");
				draw_text_transformed(_r.x1 + 22 * _u, _r.y1 + 12 * _u, _lab, 0.5 * _u, 0.5 * _u, 0);
				draw_set_alpha(1);
				draw_set_font(fnt_menu);
				draw_set_color(c_white);
				var _show = (_n == 1) ? _val : string_repeat("*", string_length(_val));
				if (_act && (_c.cursor mod 40 < 20)) _show += "|";
				draw_text_transformed(_r.x1 + 22 * _u, _r.y1 + 32 * _u, _show, 0.7 * _u, 0.7 * _u, 0);
				draw_set_halign(fa_center);
			break;
			case "rec":
				var _bx = _r.x1 + 6 * _u, _bs = 20 * _u;
				draw_set_color(_c.recordar ? _verde : _gris);
				draw_rectangle(_bx, _cy - _bs / 2, _bx + _bs, _cy + _bs / 2, !_c.recordar);
				if (_c.recordar) { draw_set_color(_tinta); draw_line_width(_bx + 4 * _u, _cy, _bx + 8 * _u, _cy + 5 * _u, 2 * _u); draw_line_width(_bx + 8 * _u, _cy + 5 * _u, _bx + 16 * _u, _cy - 5 * _u, 2 * _u); }
				draw_set_halign(fa_left);
				draw_set_font(fnt_small);
				draw_set_color(c_white);
				draw_text_transformed(_bx + _bs + 10 * _u, _cy, "RECORDARME EN ESTE APARATO", 0.6 * _u, 0.6 * _u, 0);
				draw_set_halign(fa_center);
			break;
			case "ok":
				var _ocupado = (_c.esperando != "");
				ctf_ui_para(_r.x1, _r.y1, _w, _h, _s, _tinta, 0.9, false);
				ctf_ui_para(_r.x1, _r.y1, _w, _h, _s, _azul, _ocupado ? 0.06 : 0.18, false);
				ctf_ui_para(_r.x1, _r.y1, _w, _h, _s, _azul, 1, true);
				ctf_ui_para(_r.x1, _r.y1, _s + 3, _h, _s, _azul, 1, false);
				draw_set_font(fnt_menu);
				draw_set_color(_ocupado ? _gris : c_white);
				draw_text_transformed((_r.x1 + _r.x2) / 2, _cy, (_c.tab == 0) ? "ENTRAR  >" : "CREAR CUENTA  >", 0.7 * _u, 0.7 * _u, 0);
			break;
			case "inv":
				ctf_ui_para(_r.x1, _r.y1, _w, _h, _s, _tinta, 0.85, false);
				ctf_ui_para(_r.x1, _r.y1, _w, _h, _s, _gris, 0.3, true);
				draw_set_font(fnt_menu);
				draw_set_color(_gris);
				draw_text_transformed((_r.x1 + _r.x2) / 2, _cy, _c.desde_menu ? "< VOLVER" : "JUGAR COMO INVITADO", 0.55 * _u, 0.55 * _u, 0);
			break;
		}
	}

	// Al crear: aviso de que tu progreso se pasa a la cuenta
	if (_c.tab == 1 && (global.lvl > 1 || global.wins > 0 || (variable_global_exists("copas") && global.copas > 0))) {
		draw_set_font(fnt_small);
		draw_set_color(_verde);
		draw_text_transformed(_g.gw / 2, _g.info_y, "TU PROGRESO DE ESTE APARATO SE PASA A LA CUENTA (LVL " + string(global.lvl) + ", " + string(variable_global_exists("copas") ? global.copas : 0) + " COPAS)", 0.5 * _u, 0.5 * _u, 0);
	}

	// Mensaje (error en rojo, lo demas en dorado)
	var _m = _c.msg;
	if (_m == "" && !scr_cuenta_conectado()) _m = "CONECTANDO CON EL SERVIDOR...";
	if (_m == "" && _c.esperando == "token") _m = "ENTRANDO...";
	if (_m != "") {
		draw_set_font(fnt_small);
		draw_set_color((_c.msg_rojo && _c.msg != "") ? _rojo : _oro);
		draw_text_transformed(_g.gw / 2, _g.msg_y, _m, 0.65 * _u, 0.65 * _u, 0);
	}
	if (!touch_mode()) ctf_ui_hint(_g.gw / 2, _g.gh - 34 * _u, "[TAB] CAMBIAR CAMPO     [ENTER] ACEPTAR" + (_c.desde_menu ? "     [ESC] VOLVER" : ""), _u);

	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	return true;
}

/// Chip del menu principal (arriba, en la barra, a la izquierda del ping)
function scr_cuenta_chip_draw(_u, _hud_h) {
	scr_cuenta_init();
	var _c = global.cuenta;
	var _gw = display_get_gui_width();
	var _txt = _c.entrado ? ("CUENTA: " + string_upper(_c.usuario)) : "INVITADO  -  ENTRAR  >";
	draw_set_font(fnt_small);
	var _sc = 0.6 * _u;
	var _w = string_width(_txt) * _sc + 36 * _u;
	var _h = 30 * _u;
	var _x2 = _gw - 180 * _u, _x1 = _x2 - _w;
	var _y1 = _hud_h / 2 - _h / 2;
	var _col = _c.entrado ? make_color_rgb(78, 255, 145) : make_color_rgb(169, 180, 208);
	ctf_ui_para(_x1, _y1, _w, _h, 8 * _u, make_color_rgb(11, 15, 26), 0.9, false);
	ctf_ui_para(_x1, _y1, _w, _h, 8 * _u, _col, _c.entrado ? 0.9 : 0.4, true);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(_col);
	draw_text_transformed(_x1 + _w / 2, _y1 + _h / 2, _txt, _sc, _sc, 0);
	_c.chip = [_x1, _y1, _x2, _y1 + _h];
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
}

/// Franja de la cuenta en PERFIL (arriba a la derecha, debajo del ping)
function scr_cuenta_franja_draw() {
	scr_cuenta_init();
	var _c = global.cuenta;
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	var _u = clamp(min(_gw / 1280, _gh / 720), 0.6, 1.6);
	var _txt = _c.entrado ? ("CUENTA: " + string_upper(_c.usuario) + "    CERRAR SESION  >") : "INVITADO: CREA UNA CUENTA PARA NO PERDER TU PROGRESO  >";
	draw_set_font(fnt_small);
	var _sc = 0.55 * _u;
	var _w = string_width(_txt) * _sc + 40 * _u;
	var _h = 32 * _u;
	var _x2 = _gw - 20 * _u, _x1 = _x2 - _w;
	var _y1 = 56 * _u;
	var _col = _c.entrado ? make_color_rgb(255, 107, 122) : make_color_rgb(255, 212, 71);
	ctf_ui_para(_x1, _y1, _w, _h, 8 * _u, make_color_rgb(11, 15, 26), 0.9, false);
	ctf_ui_para(_x1, _y1, _w, _h, 8 * _u, _col, 0.6, true);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(_c.entrado ? c_white : _col);
	draw_text_transformed(_x1 + _w / 2, _y1 + _h / 2, _txt, _sc, _sc, 0);
	_c.franja = [_x1, _y1, _x2, _y1 + _h];
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
}


// ======================================================
// LOGROS (los mismos 10 de siempre: nombres, descripciones e iconos)
// Ahora los guarda el juego: en tu cuenta (Neon) y en el aparato (data.ini).
// Solo se ganan EN LINEA. Se revisan cada vez que el juego guarda, y las rachas al hacer una baja.
// Aviso: el mismo "ACHIEVEMENT UNLOCKED" de siempre (achievement_got_effect).
// Version puente: si tenias logros en Gamdato, se pasan una sola vez (scr_logros_importar_gamdato).
// ======================================================
function scr_logros_def() {
	if (variable_global_exists("logros_def")) return global.logros_def;
	global.logros_def = [
		{ ide: "EDfBTkqW", name: "Exterminador",       descrip: "Elimina a 50 enemigos en total.",                value: "1",  t: "kills",    v: 50 },
		{ ide: "bQlLwO0e", name: "Conquistador",       descrip: "Consigue 10 victorias para tu equipo.",          value: "2",  t: "wins",     v: 10 },
		{ ide: "Mgt4bwuS", name: "Centinela",          descrip: "Recupera tu bandera 10 veces fuera de la base.", value: "3",  t: "returned", v: 10 },
		{ ide: "wpMbRYcU", name: "Capturador",         descrip: "Agarra la bandera enemiga 10 veces.",            value: "4",  t: "captured", v: 10 },
		{ ide: "lJjtqUBp", name: "Estratega",          descrip: "Consigue una racha de 5 bajas sin morir.",       value: "5",  t: "racha",    v: 5 },
		{ ide: "K4ynEN93", name: "Segador de Almas",   descrip: "Elimina a 500 enemigos en total.",               value: "6",  t: "kills",    v: 500 },
		{ ide: "54FbyQ8N", name: "Leyenda Viva",       descrip: "Consigue 100 victorias totales.",                value: "7",  t: "wins",     v: 100 },
		{ ide: "Y8c81dy3", name: "Guardian Eterno",    descrip: "Recupera tu bandera 50 veces.",                  value: "8",  t: "returned", v: 50 },
		{ ide: "Zm9IBCfG", name: "Infiltrado Real",    descrip: "Captura la bandera enemiga 200 veces.",          value: "9",  t: "captured", v: 200 },
		{ ide: "JkLFQ8yq", name: "Fantasma del Campo", descrip: "Elimina a 15 enemigos sin ser derrotado.",       value: "10", t: "racha",    v: 15 }
	];
	return global.logros_def;
}

function scr_logros_init() {
	if (!variable_global_exists("logros") || !is_array(global.logros)) global.logros = [];
	if (!variable_global_exists("logro_racha")) global.logro_racha = 0;
}

/// La lista con la misma forma que daba Gamdato (para las pantallas de LOGROS y PERFIL). Se hace una sola vez.
function scr_logros_lista_map() {
	if (variable_global_exists("logros_mapa") && ds_exists(global.logros_mapa, ds_type_map)) return global.logros_mapa;
	var _d = scr_logros_def();
	var _m = ds_map_create();
	for (var i = 0; i < array_length(_d); i++) {
		var _e = ds_map_create();
		_e[? "name"] = _d[i].name;
		_e[? "descrip"] = _d[i].descrip;
		_e[? "value"] = _d[i].value;
		_e[? "ide"] = _d[i].ide;
		ds_map_add_map(_m, string(i + 1), _e);
	}
	global.logros_mapa = _m;
	return _m;
}

/// Datos de un logro (para el aviso). -1 si no existe.
function scr_logro_info(_ide) {
	var _m = scr_logros_lista_map();
	for (var i = 1; i <= ds_map_size(_m); i++) {
		var _e = _m[? string(i)];
		if (!is_undefined(_e) && _e[? "ide"] == _ide) return _e;
	}
	return -1;
}

/// ¿Ya tienes ese logro?
function scr_logro_tiene(_ide) {
	scr_logros_init();
	for (var i = 0; i < array_length(global.logros); i++) if (global.logros[i] == _ide) return true;
	return false;
}

function __logros_valor(_t) {
	switch (_t) {
		case "kills":    return global.kills;
		case "wins":     return global.wins;
		case "returned": return global.flags_returned;
		case "captured": return global.flags_captured;
		case "racha":    return global.logro_racha;
	}
	return 0;
}

/// Revisa si ganaste algun logro (solo en linea). Devuelve true si hubo alguno nuevo.
function scr_logros_revisar() {
	scr_logros_init();
	if (!variable_global_exists("ONLINE") || !global.ONLINE) return false;
	var _d = scr_logros_def();
	var _nuevo = false;
	for (var i = 0; i < array_length(_d); i++) {
		if (scr_logro_tiene(_d[i].ide)) continue;
		if (__logros_valor(_d[i].t) >= _d[i].v) {
			array_push(global.logros, _d[i].ide);
			_nuevo = true;
			scr_logro_aviso(_d[i].ide);
			show_debug_message(">>> LOGRO: " + _d[i].name);
		}
	}
	return _nuevo;
}

/// El mismo aviso de siempre (arriba a la derecha)
function scr_logro_aviso(_ide) {
	try {
		var _fx = instance_create_depth(0, 0, -9999, achievement_got_effect);
		_fx.ach_id = _ide;
	} catch (_e) {}
}

/// Hiciste una baja (callback_ReceivedMessage): sube la racha y se revisan los logros de racha
function scr_logros_baja() {
	scr_logros_init();
	global.logro_racha++;
	if (scr_logros_revisar()) scr_save_to_local();
}

/// Te eliminaron (oPlayer Step): la racha vuelve a 0
function scr_logros_racha_reset() {
	scr_logros_init();
	global.logro_racha = 0;
}

/// VERSION PUENTE: los logros que ya tenias en Gamdato se pasan una sola vez (GamdatoController Step).
/// Espera 5 segundos con Gamdato listo para que haya bajado tu lista.
function scr_logros_importar_gamdato() {
	// Gamdato se quito del juego: ya no hay nada que pasar
}

// ======================================================
// AMIGOS EN LINEA (el servidor sabe quien esta conectado)
// ======================================================
/// oMenu Alarm_2 (cada 5 s): digo mi Friend Tag y pregunto cuales de mis amigos estan conectados
function scr_amigos_online_pedir() {
	if (!scr_cuenta_conectado()) return;
	if (variable_global_exists("miFriendTag") && string(global.miFriendTag) != "" && string(global.miFriendTag) != "0") {
		scr_cuenta_enviar("soy", { tag: string(global.miFriendTag) });
	}
	if (!variable_global_exists("lista_amigos") || !is_array(global.lista_amigos) || array_length(global.lista_amigos) == 0) return;
	var _tags = [];
	for (var i = 0; i < array_length(global.lista_amigos); i++) {
		var _a = global.lista_amigos[i];
		if (is_struct(_a) && variable_struct_exists(_a, "tag")) array_push(_tags, string_upper(string(_a.tag)));
	}
	scr_cuenta_enviar("amigos_online", { tags: json_stringify(_tags) });
}

/// Respuesta del servidor (oBrain Other_68, case "amigos_online")
function scr_amigos_online_recibir(_d) {
	try {
		var _on = json_parse(string(_d.on));
		if (!is_array(_on) || !is_array(global.lista_amigos)) return;
		for (var i = 0; i < array_length(global.lista_amigos); i++) {
			var _a = global.lista_amigos[i];
			if (!is_struct(_a) || !variable_struct_exists(_a, "tag")) continue;
			var _t = string_upper(string(_a.tag));
			var _si = false;
			for (var k = 0; k < array_length(_on); k++) if (_on[k] == _t) { _si = true; break; }
			_a.online = _si;
		}
	} catch (_e) {}
}


// ======================================================
// RANKING (opcion A): las 20 cuentas con mas copas (las saca el servidor de Neon)
// Los 3 primeros en oro, plata y bronce; tu fila resaltada en verde.
// ======================================================
function scr_ranking_init() {
	if (variable_global_exists("ranking") && is_struct(global.ranking)) return;
	global.ranking = { lista: [], yo: "", estado: "", scroll: 0, scroll_obj: 0, t: 0, drag_y: 0, abierto_t: 0 };
}

/// Al entrar a la pantalla: se pide al servidor
function scr_ranking_abrir() {
	scr_ranking_init();
	var _r = global.ranking;
	_r.scroll = 0; _r.scroll_obj = 0; _r.t = 0; _r.abierto_t = 0;
	if (scr_cuenta_enviar("ranking", {})) _r.estado = "cargando";
	else _r.estado = "sin_conexion";
}

/// Respuesta del servidor (oBrain Other_68, case "ranking")
function scr_ranking_recibir(_d) {
	scr_ranking_init();
	var _r = global.ranking;
	try {
		var _l = json_parse(string(_d.lista));
		_r.lista = is_array(_l) ? _l : [];
		_r.yo = variable_struct_exists(_d, "yo") ? string_lower(string(_d.yo)) : "";
		_r.estado = (real(_d.ok) == 1) ? "listo" : "error";
	} catch (_e) { _r.estado = "error"; }
}

/// Step de oMenu cuando menu_state == "ranking"
function scr_ranking_step() {
	scr_ranking_init();
	var _r = global.ranking;
	_r.abierto_t++;
	// (los primeros frames no, para que el mismo ENTER que la abrio no la cierre)
	if (_r.abierto_t > 5 && (vkey_pressed(vk_escape) || vkey_pressed(vk_enter))) { menu_state = "main"; return; }
	if (_r.estado == "cargando") {
		_r.t++;
		if (_r.t > 600) _r.estado = "error";   // 10 s sin respuesta
	}
	var _u = clamp(min(display_get_gui_width() / 1280, display_get_gui_height() / 720), 0.6, 1.6);
	var _mov = (mouse_wheel_down() - mouse_wheel_up()) * 50 * _u + (vkey(vk_down) - vkey(vk_up)) * 10 * _u;
	var _my = device_mouse_y_to_gui(0);
	if (device_mouse_check_button(0, mb_left) && !device_mouse_check_button_pressed(0, mb_left)) _mov -= _my - _r.drag_y;
	_r.drag_y = _my;
	var _fila = 52 * _u;
	var _vis = display_get_gui_height() - 230 * _u;
	var _max = max(0, array_length(_r.lista) * _fila - _vis);
	_r.scroll_obj = clamp(_r.scroll_obj + _mov, 0, _max);
	_r.scroll = lerp(_r.scroll, _r.scroll_obj, 0.2);
}

/// Draw GUI de oMenu cuando menu_state == "ranking"
function scr_ranking_draw() {
	scr_ranking_init();
	var _r = global.ranking;
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	var _u = clamp(min(_gw / 1280, _gh / 720), 0.6, 1.6);
	var _tinta = make_color_rgb(11, 15, 26), _gris = make_color_rgb(169, 180, 208);
	var _oro = make_color_rgb(255, 212, 71), _plata = make_color_rgb(207, 211, 224), _bronce = make_color_rgb(205, 127, 50);
	var _verde = make_color_rgb(78, 255, 145);

	ctf_ui_fondo(_gw, _gh);
	var _y0 = ctf_ui_header(_gw, "RANKING", "LAS CUENTAS CON MAS COPAS", _u) + 6 * _u;

	draw_set_valign(fa_middle);
	var _n = array_length(_r.lista);
	if (_n == 0) {
		draw_set_halign(fa_center);
		draw_set_font(fnt_menu);
		draw_set_color(_gris);
		var _m = "CARGANDO...";
		if (_r.estado == "sin_conexion") _m = "SIN CONEXION CON EL SERVIDOR";
		else if (_r.estado == "error") _m = "NO SE PUDO CARGAR EL RANKING";
		else if (_r.estado == "listo") _m = "TODAVIA NO HAY CUENTAS EN EL RANKING";
		draw_text_transformed(_gw / 2, _gh / 2, _m, 0.7 * _u, 0.7 * _u, 0);
	}

	var _w = 640 * _u, _x1 = _gw / 2 - _w / 2;
	var _fila = 52 * _u, _h = 42 * _u, _s = 10 * _u;
	var _top = _y0, _bot = _gh - 70 * _u;
	var _yo_pos = -1;
	for (var i = 0; i < _n; i++) {
		var _e = _r.lista[i];
		var _es_yo = (_r.yo != "" && variable_struct_exists(_e, "u") && string_lower(string(_e.u)) == _r.yo);
		if (_es_yo) _yo_pos = i;
		var _y = _top + i * _fila - _r.scroll;
		if (_y < _top - 2 || _y + _h > _bot) continue;
		var _col = (i == 0) ? _oro : ((i == 1) ? _plata : ((i == 2) ? _bronce : _gris));
		ctf_ui_para(_x1, _y, _w, _h, _s, _tinta, 0.9, false);
		if (_es_yo) {
			ctf_ui_para(_x1, _y, _w, _h, _s, _verde, 0.08, false);
			ctf_ui_para(_x1, _y, _w, _h, _s, _verde, 1, true);
			ctf_ui_para(_x1, _y, _s + 4, _h, _s, _verde, 1, false);
		} else {
			ctf_ui_para(_x1, _y, _w, _h, _s, _col, (i < 3) ? 0.9 : 0.25, true);
		}
		var _cy = _y + _h / 2;
		draw_set_font(fnt_menu);
		draw_set_halign(fa_left);
		draw_set_color((i < 3) ? _col : _gris);
		draw_text_transformed(_x1 + 26 * _u, _cy, string(i + 1), 0.75 * _u, 0.75 * _u, 0);
		draw_set_color(_es_yo ? _verde : c_white);
		var _nom = string_upper(string(variable_struct_exists(_e, "n") ? _e.n : "?"));
		if (_es_yo) _nom += " (TU)";
		draw_text_transformed(_x1 + 70 * _u, _cy, ctf_ui_fit(_nom, _w * 0.45, 0.65 * _u), 0.65 * _u, 0.65 * _u, 0);
		draw_set_halign(fa_right);
		draw_set_font(fnt_small);
		draw_set_color(_gris);
		draw_text_transformed(_x1 + _w - 170 * _u, _cy, "LVL " + string(variable_struct_exists(_e, "lvl") ? _e.lvl : 1), 0.6 * _u, 0.6 * _u, 0);
		draw_set_font(fnt_menu);
		draw_set_color(_oro);
		draw_text_transformed(_x1 + _w - 26 * _u, _cy, string(variable_struct_exists(_e, "c") ? _e.c : 0) + " COPAS", 0.6 * _u, 0.6 * _u, 0);
	}

	// Si tienes cuenta y no estas en el top 20, se dice abajo
	if (_n > 0 && _yo_pos == -1) {
		draw_set_halign(fa_center);
		draw_set_font(fnt_small);
		draw_set_color(_gris);
		var _txt = scr_cuenta_activa() ? ("TU: " + string(global.copas) + " COPAS (FUERA DEL TOP 20)") : "CREA UNA CUENTA PARA SALIR EN EL RANKING";
		draw_text_transformed(_gw / 2, _gh - 56 * _u, _txt, 0.6 * _u, 0.6 * _u, 0);
	}
	ctf_ui_hint(_gw / 2, _gh - 30 * _u, "[ESC] O [ENTER] PARA VOLVER", _u);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
}

// ------------------------------------------------------
// PRUEBA DEL AVISO DE LOGRO: F9 muestra el aviso (uno distinto cada vez) SIN darte el logro.
// Cuando ya no lo necesites, pon LOGROS_PRUEBA en false.
// ------------------------------------------------------
#macro LOGROS_PRUEBA false   // ponlo en true para volver a probar el aviso con F9

function scr_logros_prueba_step() {
	if (!LOGROS_PRUEBA || !keyboard_check_pressed(vk_f9)) return;
	var _d = scr_logros_def();
	if (!variable_global_exists("logros_prueba_i")) global.logros_prueba_i = 0;
	var _ide = _d[global.logros_prueba_i mod array_length(_d)].ide;
	global.logros_prueba_i++;
	with (achievement_got_effect) instance_destroy();   // que no se encimen
	scr_logro_aviso(_ide);
	show_debug_message(">>> PRUEBA: aviso del logro " + _ide + " (no se guarda)");
}


// ======================================================
// BUZON (opcion A): hasta 5 solicitudes de amistad en lista, cada una con ACEPTAR / RECHAZAR.
// El servidor las guarda en lista (solicitud_nueva / solicitud_quitar); el juego las lee como siempre
// (oMenu Alarm_3 -> ReadSimpleData("solicitudes", tu tag) -> callback_ReadSimpleData).
// Las funciones de pantalla se llaman desde oMenu (usan sus variables).
// ======================================================

/// Mandar una solicitud (scr_enviar_solicitud_amistad)
function scr_buzon_enviar(_tag, _data) {
	return scr_cuenta_enviar("solicitud_nueva", { para: string_upper(string(_tag)), m: json_stringify(_data) });
}

/// Llega lo que hay en tu buzon (callback_ReadSimpleData). _lista = array de solicitudes
function scr_buzon_recibir(_lista) {
	if (!instance_exists(oMenu)) return;
	var _ok = [];
	if (is_array(_lista)) {
		for (var i = 0; i < array_length(_lista); i++) {
			var _s = _lista[i];
			if (is_struct(_s) && variable_struct_exists(_s, "desde_tag")) array_push(_ok, _s);
		}
	}
	with (oMenu) {
		buzon_lista = _ok;
		if (!variable_instance_exists(id, "buzon_sel")) buzon_sel = 0;
		buzon_sel = clamp(buzon_sel, 0, max(0, array_length(_ok) - 1));
		hay_solicitud_pendiente = (array_length(_ok) > 0);
		datos_solicitud_recibida = hay_solicitud_pendiente ? _ok[buzon_sel] : -1;
	}
}

/// Quita la solicitud elegida (al aceptar o rechazar). Va en el scope de oMenu.
function scr_buzon_quitar_sel() {
	if (!variable_instance_exists(id, "buzon_lista") || !is_array(buzon_lista) || array_length(buzon_lista) == 0) return;
	buzon_sel = clamp(buzon_sel, 0, array_length(buzon_lista) - 1);
	var _s = buzon_lista[buzon_sel];
	scr_cuenta_enviar("solicitud_quitar", { yo: string(global.miFriendTag), de: string(_s.desde_tag) });
	array_delete(buzon_lista, buzon_sel, 1);
	buzon_sel = clamp(buzon_sel, 0, max(0, array_length(buzon_lista) - 1));
	hay_solicitud_pendiente = (array_length(buzon_lista) > 0);
	datos_solicitud_recibida = hay_solicitud_pendiente ? buzon_lista[buzon_sel] : -1;
}

/// Step de oMenu en el buzon: W/S elegir, Y aceptar, N rechazar
function scr_buzon_step() {
	if (!variable_instance_exists(id, "buzon_lista") || !is_array(buzon_lista)) buzon_lista = [];
	if (!variable_instance_exists(id, "buzon_sel")) buzon_sel = 0;
	var _n = array_length(buzon_lista);
	if (_n == 0) { hay_solicitud_pendiente = false; return; }
	var _mov = (vkey_pressed(ord("S")) || vkey_pressed(vk_down)) - (vkey_pressed(ord("W")) || vkey_pressed(vk_up));
	buzon_sel = clamp(buzon_sel + _mov, 0, _n - 1);
	datos_solicitud_recibida = buzon_lista[buzon_sel];
	hay_solicitud_pendiente = true;
	if (vkey_pressed(ord("Y"))) {
		var _nom = string(datos_solicitud_recibida.desde_nombre);
		scr_aceptar_solicitud();   // la agrega y la quita del buzon
		mensaje_texto = "Ahora eres amigo de " + _nom + "!";
		mensaje_alpha = 3;
	} else if (vkey_pressed(ord("N"))) {
		scr_buzon_quitar_sel();
		show_debug_message(">>> Solicitud rechazada.");
	}
}

/// Draw GUI de oMenu en el buzon
function scr_buzon_draw(_u, _gw, _gh) {
	if (!variable_instance_exists(id, "buzon_lista") || !is_array(buzon_lista)) buzon_lista = [];
	if (!variable_instance_exists(id, "buzon_sel")) buzon_sel = 0;
	var _tinta = make_color_rgb(11, 15, 26), _azul = make_color_rgb(31, 155, 255), _gris = make_color_rgb(169, 180, 208);
	var _verde = make_color_rgb(78, 255, 145), _rojo = make_color_rgb(255, 42, 58), _oro = make_color_rgb(255, 212, 71);
	var _n = array_length(buzon_lista);
	ctf_ui_fondo(_gw, _gh);
	var _y0 = ctf_ui_header(_gw, "BUZON", "SOLICITUDES DE AMISTAD (" + string(_n) + "/5)", _u) + 10 * _u;
	draw_set_valign(fa_middle);
	if (_n == 0) {
		draw_set_halign(fa_center);
		draw_set_font(fnt_menu);
		draw_set_color(_gris); draw_set_alpha(0.5);
		draw_text_transformed(_gw / 2, _gh / 2, "NO HAY MENSAJES NUEVOS", 0.8 * _u, 0.8 * _u, 0);
		draw_set_alpha(1);
	}
	var _w = 620 * _u, _h = 50 * _u, _s = 10 * _u, _x1 = _gw / 2 - _w / 2;
	var _bw = 120 * _u, _bh = 32 * _u;
	for (var i = 0; i < _n; i++) {
		var _e = buzon_lista[i];
		var _y = _y0 + i * (_h + 10 * _u);
		var _cy = _y + _h / 2;
		var _sel = (i == buzon_sel);
		ctf_ui_para(_x1, _y, _w, _h, _s, _tinta, 0.9, false);
		if (_sel) ctf_ui_para(_x1, _y, _w, _h, _s, _azul, 0.12, false);
		ctf_ui_para(_x1, _y, _w, _h, _s, _sel ? _azul : _gris, _sel ? 1 : 0.3, true);
		if (_sel) ctf_ui_para(_x1, _y, _s + 4, _h, _s, _azul, 1, false);
		// Nombre y tag
		draw_set_halign(fa_left);
		draw_set_font(fnt_menu);
		draw_set_color(c_white);
		var _nom = string_upper(string(variable_struct_exists(_e, "desde_nombre") ? _e.desde_nombre : "?"));
		draw_text_transformed(_x1 + 30 * _u, _cy, ctf_ui_fit(_nom, _w - 2 * _bw - 90 * _u, 0.65 * _u), 0.65 * _u, 0.65 * _u, 0);
		draw_set_font(fnt_small);
		// Botones
		var _ax = _x1 + _w - 2 * _bw - 30 * _u, _rx = _x1 + _w - _bw - 18 * _u, _by = _cy - _bh / 2;
		ctf_ui_para(_ax, _by, _bw, _bh, 8 * _u, _verde, 0.1, false);
		ctf_ui_para(_ax, _by, _bw, _bh, 8 * _u, _verde, 0.7, true);
		ctf_ui_para(_rx, _by, _bw, _bh, 8 * _u, _rojo, 0.1, false);
		ctf_ui_para(_rx, _by, _bw, _bh, 8 * _u, _rojo, 0.7, true);
		draw_set_halign(fa_center);
		draw_set_color(_verde);
		draw_text_transformed(_ax + _bw / 2, _cy, "ACEPTAR", 0.6 * _u, 0.6 * _u, 0);
		draw_set_color(_rojo);
		draw_text_transformed(_rx + _bw / 2, _cy, "RECHAZAR", 0.6 * _u, 0.6 * _u, 0);
		// Toques: la fila la elige; los botones la eligen y aceptan / rechazan
		ui_tap_add(_x1, _y, _ax - 6 * _u, _y + _h, -1, -1, { tipo: "buzon", i: i });
		ui_tap_add(_ax, _by, _ax + _bw, _by + _bh, -1, ord("Y"), { tipo: "buzon", i: i });
		ui_tap_add(_rx, _by, _rx + _bw, _by + _bh, -1, ord("N"), { tipo: "buzon", i: i });
	}
	ctf_ui_hint(_gw / 2, _gh - 34 * _u, (_n > 0) ? "[W/S] ELEGIR     [Y] ACEPTAR     [N] RECHAZAR     [ESC] VOLVER" : "[ESC] VOLVER", _u);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
}

// ======================================================
// INVENTARIO: tu icono, la skin que llevas puesta y todo lo que desbloqueas.
// Se guarda en el aparato (data.ini) y en tu cuenta (Neon), y viaja a cualquier celular.
// Para cosas nuevas (skins, iconos, lo que sea) solo inventas un codigo, por ejemplo "skin_ninja":
//   scr_desbloquear("skin_ninja");          // lo das (y se guarda solo)
//   scr_tiene_desbloqueado("skin_ninja");   // true / false
//   scr_skin_poner("skin_ninja");           // te la pones (y se guarda solo)
//   scr_inv_skin();                         // la que llevas puesta ("" = ninguna)
// Codigos: letras, numeros, _ o - (hasta 32). El servidor no hay que tocarlo.
// ======================================================
function scr_inv_init() {
	if (!variable_global_exists("desbloqueados") || !is_array(global.desbloqueados)) global.desbloqueados = [];
	if (!variable_global_exists("skin_actual")) global.skin_actual = "";
	if (!variable_global_exists("avatar_id")) global.avatar_id = 0;
}

function scr_inv_lista() { scr_inv_init(); return global.desbloqueados; }
function scr_inv_skin()  { scr_inv_init(); return string(global.skin_actual); }

function scr_tiene_desbloqueado(_cod) {
	scr_inv_init();
	for (var i = 0; i < array_length(global.desbloqueados); i++) if (global.desbloqueados[i] == _cod) return true;
	return false;
}

/// Lo agrega a la lista (sin guardar). Devuelve true si era nuevo.
function scr_inv_agregar(_cod) {
	scr_inv_init();
	_cod = string(_cod);
	if (_cod == "" || scr_tiene_desbloqueado(_cod)) return false;
	array_push(global.desbloqueados, _cod);
	return true;
}

/// Desbloquear algo y guardarlo (aparato + cuenta)
function scr_desbloquear(_cod) {
	if (scr_inv_agregar(_cod)) scr_save_to_local();
}

/// Ponerte una skin (o "" para ninguna) y guardarlo
function scr_skin_poner(_cod) {
	scr_inv_init();
	global.skin_actual = string(_cod);
	scr_save_to_local();
}
