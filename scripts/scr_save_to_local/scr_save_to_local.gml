function scr_save_to_local() {
    // Abrimos el archivo local
    ini_open("data.ini");
    
    // --- SECCIÓN: PERFIL ---
    ini_write_string("Perfil", "version", string(global.save_version));
    ini_write_string("Perfil", "name", string(global.myName));
    ini_write_real("Perfil", "registrado", global.registrado); 
	ini_write_string("Perfil", "id_friend", global.miFriendTag);

    // --- SECCIÓN: STATS ---
    ini_write_real("Stats", "lvl", global.lvl);
    ini_write_real("Stats", "xp", global.xp);
    ini_write_real("Stats", "wins", global.wins);
    ini_write_real("Stats", "flags", global.flags_captured);
    ini_write_string("Stats", "rank", string(global.rank));
	ini_write_real("Stats", "returned", global.flags_returned); // <--- NUEVO
    ini_write_real("Stats", "kills", global.kills);            // <--- NUEVO
	ini_write_real("Stats", "losses", global.losses);
	ini_write_string("Social", "miFriendTag", global.miFriendTag);

	// GUARDAR AMIGOS EN ARCHIVO APARTE
    var _file = file_text_open_write("amigos_data.json");
    var _json = json_stringify(global.lista_amigos);
    file_text_write_string(_file, _json);
    file_text_close(_file);
    
    show_debug_message(">>>> ARCHIVO GUARDADO: " + _json);

    // Guardar y cerrar
    ini_close();
    
    show_debug_message(">>> Datos guardados en data.ini");
}