function scr_save_to_cloud() {
	
	var _status = gmda_status();
    if (_status) {
        // Creamos el mapa siguiendo tu ejemplo
        var gmd_savemap = ds_map_create();
        
        // --- DATOS BÁSICOS ---
        ds_map_add(gmd_savemap, "version", string(global.save_version));
        ds_map_add(gmd_savemap, "name", string(global.myName));
        
        // --- LA VARIABLE DE CONTROL (El Switch) ---
        // Esto le dice a la nube: "Este jugador ya pasó el registro"
        ds_map_add(gmd_savemap, "registrado", string(global.registrado)); // Lo enviamos como string "1" (true)

        // --- ESTADÍSTICAS DEL PERFIL ---
        ds_map_add(gmd_savemap, "lvl", string(global.lvl));
        ds_map_add(gmd_savemap, "xp", string(global.xp));
        ds_map_add(gmd_savemap, "wins", string(global.wins));
        ds_map_add(gmd_savemap, "flags", string(global.flags_captured));
        ds_map_add(gmd_savemap, "rank", string(global.rank));
		ds_map_add(gmd_savemap, "kills", string(global.kills));
        ds_map_add(gmd_savemap, "returned", string(global.flags_returned));
		ds_map_add(gmd_savemap, "losses", string(global.losses));
		ds_map_add(gmd_savemap, "copas", string(global.copas));

        // Enviar al servidor
        gmda_sendgamesave(gmd_savemap); 
        
        // Limpiar memoria
        ds_map_destroy(gmd_savemap);
        
        show_debug_message(">>> [NUBE] Sincronización completa enviada.");
    }
}