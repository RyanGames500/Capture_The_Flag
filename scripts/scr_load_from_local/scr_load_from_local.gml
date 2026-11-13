function scr_load_from_local() {
    if (file_exists("data.ini")) {
        ini_open("data.ini");
        
        // --- PERFIL ---
        global.save_version = ini_read_string("Perfil", "version", "1.0");
        global.myName       = ini_read_string("Perfil", "name", "Soldado");
        global.registrado   = ini_read_real("Perfil", "registrado", 0);
		global.miFriendTag  = ini_read_string("Perfil", "id_friend", 0)

        // --- STATS ---
        global.lvl            = ini_read_real("Stats", "lvl", 1);
        global.xp             = ini_read_real("Stats", "xp", 0);
        global.wins           = ini_read_real("Stats", "wins", 0);
        global.flags_captured = ini_read_real("Stats", "flags", 0);
        global.flags_returned = ini_read_real("Stats", "returned", 0);
        global.kills          = ini_read_real("Stats", "kills", 0);
        global.rank           = ini_read_string("Stats", "rank", "RECLUTA");
		global.losses		  = ini_read_real("Stats", "losses", 0);
		// Copas (antes solo venian de Gamdato). Si no estan guardadas aqui, se deja lo que habia.
		if (ini_key_exists("Stats", "copas")) global.copas = ini_read_real("Stats", "copas", 0);
		global.miFriendTag = ini_read_string("Social", "miFriendTag", "");
		// Logros (DatabaseFunctions, LOGROS)
		try { global.logros = json_parse(ini_read_string("Logros", "lista", "[]")); } catch (_e) { global.logros = []; }
		if (!is_array(global.logros)) global.logros = [];
		// Inventario: icono, skin puesta y desbloqueables (DatabaseFunctions, INVENTARIO)
		global.avatar_id   = ini_read_real("Inventario", "avatar", variable_global_exists("avatar_id") ? global.avatar_id : 0);
		global.skin_actual = ini_read_string("Inventario", "skin", "");
		try { global.desbloqueados = json_parse(ini_read_string("Inventario", "desbloqueados", "[]")); } catch (_e2) { global.desbloqueados = []; }
		if (!is_array(global.desbloqueados)) global.desbloqueados = [];
		// Equipamiento (scr_armas, EQUIPAMIENTO)
		try { global.equipo = json_parse(ini_read_string("Equipo", "datos", "{}")); } catch (_e3) { global.equipo = {}; }
		if (!is_struct(global.equipo)) global.equipo = {};
		scr_eq_init();

	// CARGAR AMIGOS DESDE EL ARCHIVO APARTE
    if (file_exists("amigos_data.json")) {
        var _file = file_text_open_read("amigos_data.json");
        var _json = file_text_read_string(_file);
        file_text_close(_file);
        
        if (_json != "") {
            global.lista_amigos = json_parse(_json);
        }
    }

        ini_close();
        show_debug_message(">>> [LOCAL] Carga completa. Usuario: " + global.myName);
        return true;
    }
    show_debug_message(">>> [LOCAL] No existe data.ini, se usarán valores iniciales.");
    return false;
}