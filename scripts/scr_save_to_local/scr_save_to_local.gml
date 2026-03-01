function scr_save_to_local() {
    // Abrimos el archivo local
    ini_open("data.ini");
    
    // --- SECCIÓN: PERFIL ---
    ini_write_string("Perfil", "version", string(global.save_version));
    ini_write_string("Perfil", "name", string(global.myName));
    ini_write_real("Perfil", "registrado", global.registrado); 

    // --- SECCIÓN: STATS ---
    ini_write_real("Stats", "lvl", global.lvl);
    ini_write_real("Stats", "xp", global.xp);
    ini_write_real("Stats", "wins", global.wins);
    ini_write_real("Stats", "flags", global.flags_captured);
    ini_write_string("Stats", "rank", string(global.rank));
	ini_write_real("Stats", "returned", global.flags_returned); // <--- NUEVO
    ini_write_real("Stats", "kills", global.kills);            // <--- NUEVO
	ini_write_real("Stats", "losses", global.losses);

    // Guardar y cerrar
    ini_close();
    
    show_debug_message(">>> Datos guardados en data.ini");
}