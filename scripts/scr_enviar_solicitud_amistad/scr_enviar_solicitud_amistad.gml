function scr_enviar_solicitud_amistad(_tag_destino) {
    _tag_destino = string_upper(string_trim(string(_tag_destino)));   // los ID siempre en mayusculas
    // No te puedes mandar solicitud a ti mismo
    if (string_upper(string(_tag_destino)) == string_upper(string(global.miFriendTag))) {
        mensaje_texto = "NO TE PUEDES AGREGAR A TI MISMO";
        mensaje_alpha = 3;
        return;
    }
    // 1. Obtenemos NUESTRA info (el que envía)
    var mi_id_largo = string(global.miFriendTag);   // antes era el ID de Gamdato; ahora tu Friend Tag
    var mi_nombre = global.myName;
    var mi_tag = string(global.miFriendTag); // Tu Tag de 6 letras
    
    // 2. Creamos la estructura con toda la info necesaria
    // Añadimos "desde_tag" para que el otro sepa cómo responderte
    var _data = {
        desde_id: mi_id_largo,
        desde_nombre: mi_nombre,
        desde_tag: mi_tag, 
        fecha: date_datetime_string(date_current_datetime()),
        estado: "pendiente"
    };

    // 3. GUARDAR EN LA NUBE
    // El documento AHORA es el Tag de 6 letras del amigo (ej: "7S7IIW")
    // Se agrega a su buzon (lista de hasta 5) en el servidor (DatabaseFunctions, BUZON)
    if (!scr_buzon_enviar(_tag_destino, _data)) {   // sin conexion no sale: avisamos en vez de fingir
        mensaje_texto = "SIN CONEXION: NO SE PUDO ENVIAR";
        mensaje_alpha = 3;
        return;
    }
    
    // 4. Feedback visual
    mensaje_texto = "Solicitud enviada al Tag: " + string(_tag_destino) + "!";
    mensaje_alpha = 3;
    
    show_debug_message(">>> NUBE: Solicitud mandada al destino: " + string(_tag_destino));
}