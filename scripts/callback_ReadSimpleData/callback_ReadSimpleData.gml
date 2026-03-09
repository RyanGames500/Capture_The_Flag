function callback_ReadSimpleData(readId, data) {
    // --- 1. SI EL DOCUMENTO NO EXISTE (data == -1) ---
    if (data == -1) {
        if (oMenu.estado_busqueda == "buscando") {
            // No estaba por ID, intentamos por NOMBRE
            show_debug_message(">>> CALLBACK: NO EXISTE COMO ID, PROBANDO POR NOMBRE...");
            oMenu.request_datos_rival = ReadSimpleData("busqueda_nombres", oMenu.ultimo_intento_busqueda);
            oMenu.estado_busqueda = "buscando_nombre"; 
        } 
        else if (oMenu.estado_busqueda == "buscando_nombre" || oMenu.estado_busqueda == "buscando_perfil_final") {
            // Falló la búsqueda de jugador
            oMenu.estado_busqueda = "error";
            oMenu.mensaje_texto = "Jugador no encontrado!"; 
            oMenu.mensaje_alpha = 3;
            oMenu.search_timer = 0;
        }
        // Nota: Si es una solicitud de buzón y no existe, simplemente no hacemos nada
        return; 
    }    

    // --- 2. SI HAY DATOS (ÉXITO) ---
    // Chequeamos qué tipo de "paquete" es analizando sus variables internas
    
    // A. ¿ES UNA SOLICITUD DE AMISTAD? (Tiene 'desde_id')
    if (variable_struct_exists(data, "desde_id")) {
        show_debug_message(">>> CALLBACK: ¡SOLICITUD DE AMISTAD DETECTADA!");
        oMenu.datos_solicitud_recibida = data;
        oMenu.hay_solicitud_pendiente = true;
    } 
    
    // B. ¿ES UN RESULTADO DE BÚSQUEDA POR NOMBRE? (Tiene 'playerID')
    else if (variable_struct_exists(data, "playerID")) {
        show_debug_message(">>> CALLBACK: ID ENCONTRADO, BUSCANDO PERFIL...");
        oMenu.request_datos_rival = ReadSimpleData("perfiles", string(data.playerID));
        oMenu.estado_busqueda = "buscando_perfil_final";
    } 
    
    // C. ¿ES EL PERFIL FINAL DE UN JUGADOR? (Tiene 'nombre')
    else if (variable_struct_exists(data, "nombre")) {
        show_debug_message(">>> CALLBACK: PERFIL LOCALIZADO CON ÉXITO.");
        oMenu.datos_busqueda_resultado = data;
        oMenu.estado_busqueda = "encontrado";
        oMenu.mensaje_texto = "Jugador localizado!";
        oMenu.mensaje_alpha = 2;
        oMenu.search_timer = 0;
    }
}


/*
function callback_ReadSimpleData(readId,data){
	
	//if data is -1, the read failed, The Document was not found!
	//check the location(collection + document name) onceagain
	if(data == -1){
		show_message("failed read")
	}
	

	
	//the document is a struct in the variable data
	show_message("read id "+string(readId)+" : "+string(data))

}