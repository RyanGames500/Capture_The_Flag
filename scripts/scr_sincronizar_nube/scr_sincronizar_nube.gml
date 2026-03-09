function scr_sincronizar_nube() {
    var ID_PLAYER = gmda_getPlayerid();
    
    // 0. ASEGURARNOS DE TENER UN FRIEND TAG (Solo se genera una vez)
    // Si no tienes la variable global.miFriendTag, la generamos
    if (!variable_global_exists("miFriendTag") || global.miFriendTag == "") {
        global.miFriendTag = scr_generar_id_amigo(); 
        // Nota: Deberías guardar este tag también en tu archivo local (.ini o .json)
    }

    // 1. CONSTRUIMOS EL PERFIL COMPLETO
    var miPerfilCompleto = {
        nombre: global.myName,
        friend_tag: global.miFriendTag, // <--- Este es tu nuevo ID público
        ID: ID_PLAYER,                   // <--- Este es tu ID de Gamdato (interno)
        lvl: global.lvl,
        xp: global.xp,
        wins: global.wins,
        losses: global.losses,
        kills: global.kills,
        flags: global.flags_captured,
        returned: global.flags_returned,
        rank: global.rank,
        copas: global.copas,
        ultima_conexion: date_current_datetime()
    }

    // 2. ENVIAMOS EL PERFIL (Documento = FRIEND_TAG)
    // Ahora la gente te buscará por el código de 6 letras
    global.request_registro = SetSimpleData("perfiles", string(global.miFriendTag), miPerfilCompleto);

    // 3. OPCIONAL: SEGUIR TENIENDO BUSQUEDA POR NOMBRE
    // Por si alguien quiere buscarte por "Ryan" en vez del código
    var indiceNombre = {
        playerID: global.miFriendTag // Apuntamos al ID corto para que sea el estándar
    }
    SetSimpleData("busqueda_nombres", global.myName, indiceNombre);
    
    show_debug_message(">>> NUBE: Perfil sincronizado con Tag: " + string(global.miFriendTag));
}