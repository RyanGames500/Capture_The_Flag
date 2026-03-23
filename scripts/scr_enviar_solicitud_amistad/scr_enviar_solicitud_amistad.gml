function scr_enviar_solicitud_amistad(_tag_destino) {
    // 1. Obtenemos NUESTRA info (el que envía)
    var mi_id_largo = string(gmda_getPlayerid());
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
    SetSimpleData("solicitudes", string(_tag_destino), _data);
    
    // 4. Feedback visual
    mensaje_texto = "Solicitud enviada al Tag: " + string(_tag_destino) + "!";
    mensaje_alpha = 3;
    
    show_debug_message(">>> NUBE: Solicitud mandada al destino: " + string(_tag_destino));
}