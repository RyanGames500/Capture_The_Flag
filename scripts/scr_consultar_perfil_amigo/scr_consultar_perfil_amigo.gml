function scr_consultar_perfil_amigo(_indice) {
    var _tag_amigo = global.lista_amigos[_indice].tag;
    
    show_debug_message(">>> Buscando perfil de: " + _tag_amigo);
    
    // Usamos GetSimpleData para traer la info de la carpeta "perfiles"
    // El "documento" es el Tag del amigo
    GetSimpleData("perfiles", string(_tag_amigo)); 
    
    // NOTA: La respuesta llegará al evento Async Social de Gamdato
    // bajo el caso: gmd_resp_getsimpledata
}