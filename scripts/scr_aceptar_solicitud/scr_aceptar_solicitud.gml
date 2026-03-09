function scr_aceptar_solicitud() {
    if (hay_solicitud_pendiente) {
        // 1. OBTENEMOS LOS DATOS
        var nombre_amigo = datos_solicitud_recibida.desde_nombre;
        var id_amigo = datos_solicitud_recibida.desde_id; 
        var tag_amigo = datos_solicitud_recibida.desde_tag; 
        
        // 2. BORRAMOS LA SOLICITUD DE LA NUBE (Ya no es necesaria)
        DeleteSimpleData("solicitudes", string(global.miFriendTag));
        
        // 3. LO AÑADIMOS A NUESTRA LISTA LOCAL
        var ya_es_amigo = false;
        for (var i = 0; i < array_length(global.lista_amigos); i++) {
            if (global.lista_amigos[i].id_largo == id_amigo) ya_es_amigo = true;
        }
        
        if (!ya_es_amigo) {
            var nuevo_amigo = {
                nombre: nombre_amigo,
                tag: tag_amigo,
                id_largo: id_amigo
            }
            array_push(global.lista_amigos, nuevo_amigo);
            
            // --- AQUÍ CREAMOS/ACTUALIZAMOS LA COLECCIÓN "amigos" EN ROCKET ---
            // Preparamos el struct que contiene el array de amigos actualizado
            var _data_amigos = {
                lista: global.lista_amigos
            };

            // Enviamos a la colección "amigos", el documento es TU Tag
            // Usamos tu SetSimpleData que ya maneja el json_stringify internamente
            SetSimpleData("amigos", string(global.miFriendTag), _data_amigos);
            
            // También le dejamos la confirmación al otro para que sea mutuo
            var _confirmacion = {
                quien_acepto_nombre: global.myName,
                quien_acepto_tag: global.miFriendTag,
                quien_acepto_id: string(gmda_getPlayerid())
            };
            SetSimpleData("confirmaciones", string(tag_amigo), _confirmacion);

            // Guardados extra
            scr_save_to_local();
            scr_save_to_cloud(); // Tu guardado general de stats
        }

        // 4. LIMPIAMOS
        hay_solicitud_pendiente = false;
        datos_solicitud_recibida = -1;
        
        mensaje_texto = "¡Ahora eres amigo de " + nombre_amigo + "!";
        mensaje_alpha = 3;
        
        show_debug_message(">>> ROCKET: Colección 'amigos' actualizada para: " + string(global.miFriendTag));
    }
}