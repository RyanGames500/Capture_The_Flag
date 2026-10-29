function callback_ReadSimpleData(readId, data) {
     if (!instance_exists(oMenu)) return;
    // --- 1. SI EL DOCUMENTO NO EXISTE (data == -1) ---
    if (data == -1) {
        if (oMenu.estado_busqueda == "buscando") {
            show_debug_message(">>> CALLBACK: NO EXISTE COMO ID, PROBANDO POR NOMBRE...");
            oMenu.request_datos_rival = ReadSimpleData("busqueda_nombres", oMenu.ultimo_intento_busqueda);
            oMenu.estado_busqueda = "buscando_nombre"; 
        } 
        else if (oMenu.estado_busqueda == "buscando_nombre" || oMenu.estado_busqueda == "buscando_perfil_final") {
            oMenu.estado_busqueda = "error";
            oMenu.mensaje_texto = "Jugador no encontrado!"; 
            oMenu.mensaje_alpha = 3;
            oMenu.search_timer = 0;
        }
        return; 
    }    

    // --- 2. SI HAY DATOS (ÉXITO) ---
    
    // A. ¿ES UNA SOLICITUD DE AMISTAD?
    if (variable_struct_exists(data, "desde_id")) {
        show_debug_message(">>> CALLBACK: ¡SOLICITUD DE AMISTAD DETECTADA!");
        oMenu.datos_solicitud_recibida = data;
        oMenu.hay_solicitud_pendiente = true;
    } 
    
    // B. ¿ES UN RESULTADO DE BÚSQUEDA POR NOMBRE?
    else if (variable_struct_exists(data, "playerID")) {
        show_debug_message(">>> CALLBACK: ID ENCONTRADO, BUSCANDO PERFIL...");
        oMenu.request_datos_rival = ReadSimpleData("perfiles", string(data.playerID));
        oMenu.estado_busqueda = "buscando_perfil_final";
    } 
    
    // C. ¿ES EL PERFIL FINAL DE UN JUGADOR?
    else if (variable_struct_exists(data, "nombre")) {
        show_debug_message(">>> CALLBACK: PERFIL LOCALIZADO CON ÉXITO.");
        oMenu.datos_busqueda_resultado = data;
        oMenu.estado_busqueda = "encontrado";
        oMenu.mensaje_texto = "Jugador localizado!";
        oMenu.mensaje_alpha = 2;
        oMenu.search_timer = 0;
    }

    // D. ¿ES UN DUELO? (CORREGIDO PARA LA VENTANA PRO)
    else if (variable_struct_exists(data, "es_duelo")) {
        show_debug_message(">>> CALLBACK: ¡RETO DE DUELO RECIBIDO!");
        
        // En lugar de show_question, activamos el dibujo y el timer
        oMenu.datos_reto = data;
        oMenu.mostrando_reto = true;
        oMenu.reto_timer = 600; // 10 segundos para responder
    }

    // E. ¿ALGUIEN NOS CONFIRMÓ LA AMISTAD?
    if (variable_struct_exists(data, "quien_acepto_tag") || variable_struct_exists(data, "es_confirmacion")) {
        var _tag_nuevo = data.quien_acepto_tag;
        var _nom_nuevo = data.quien_acepto_nombre;
        
        var _ya_lo_tengo = false;
        for (var i = 0; i < array_length(global.lista_amigos); i++) {
            if (global.lista_amigos[i].tag == _tag_nuevo) {
                _ya_lo_tengo = true;
                break;
            }
        }

        if (!_ya_lo_tengo) {
            var _nuevo = {
                nombre: _nom_nuevo,
                tag: _tag_nuevo,
                id_largo: data.quien_acepto_id
            };
            array_push(global.lista_amigos, _nuevo);
            
            scr_save_to_local();
            SetSimpleData("amigos", string(global.miFriendTag), { lista: global.lista_amigos });
            
            oMenu.mensaje_texto = "¡" + _nom_nuevo + " aceptó tu solicitud!";
            oMenu.mensaje_alpha = 3;
        }
        DeleteSimpleData("confirmaciones", global.miFriendTag);
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