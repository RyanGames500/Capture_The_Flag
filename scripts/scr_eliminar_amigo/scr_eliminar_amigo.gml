function scr_eliminar_amigo(_indice) {
    // 1. Obtenemos el nombre para el mensaje de confirmación
    var _nombre = global.lista_amigos[_indice].nombre;
    
    // 2. Lo borramos del array
    array_delete(global.lista_amigos, _indice, 1);
    
    // 3. Sincronizamos TODO
    scr_save_to_local(); // Guarda el JSON sin ese amigo en tu PC
    scr_save_to_cloud(); // Sube el nuevo Base64 a la nube de Gamdato
    
    show_debug_message(">>> Amigo " + _nombre + " eliminado con éxito.");
}