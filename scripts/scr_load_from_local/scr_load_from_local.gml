function scr_load_from_local() {
    if (file_exists("data.ini")) {
        ini_open("data.ini");
        
        // --- PERFIL ---
        global.save_version = ini_read_string("Perfil", "version", "1.0");
        global.myName       = ini_read_string("Perfil", "name", "Soldado");
        global.registrado   = ini_read_real("Perfil", "registrado", 0);

        // --- STATS ---
        global.lvl            = ini_read_real("Stats", "lvl", 1);
        global.xp             = ini_read_real("Stats", "xp", 0);
        global.wins           = ini_read_real("Stats", "wins", 0);
        global.flags_captured = ini_read_real("Stats", "flags", 0);
        global.flags_returned = ini_read_real("Stats", "returned", 0);
        global.kills          = ini_read_real("Stats", "kills", 0);
        global.rank           = ini_read_string("Stats", "rank", "RECLUTA");
		global.losses		  = ini_read_real("Stats", "losses", 0);

        ini_close();
        show_debug_message(">>> [LOCAL] Carga completa. Usuario: " + global.myName);
        return true;
    }
    show_debug_message(">>> [LOCAL] No existe data.ini, se usarán valores iniciales.");
    return false;
}