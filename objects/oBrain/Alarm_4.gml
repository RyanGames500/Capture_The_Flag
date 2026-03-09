var mi_tag_actual = string(global.miFriendTag);
show_debug_message("--- TEST DE BUSQUEDA ---");
show_debug_message("Buscando en colección: solicitudes");
show_debug_message("Buscando documento: " + mi_tag_actual);
oMenu.request_solicitud = ReadSimpleData("solicitudes", mi_tag_actual);
alarm[4] = 600; // Se repite cada 10 segundos (60 frames * 10)