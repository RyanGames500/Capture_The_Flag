


// --- DENTRO DE ALARMA 4 (o donde llames a ReadSimpleData) ---

// 1. Verificamos que oBrain exista y tenga el socket listo
if (instance_exists(oBrain)) {
    if (variable_instance_exists(oBrain, "socket") && oBrain.socket != -1) {
        
var mi_tag_actual = string(global.miFriendTag);
// Tu ficha publica (para que te encuentren por tu ID): una vez cada vez que abres el juego
if (!variable_global_exists("perfil_publicado") || !global.perfil_publicado) {
    if (mi_tag_actual != "" && mi_tag_actual != "0" && scr_cuenta_conectado()) { scr_sincronizar_nube(); global.perfil_publicado = true; }
}
show_debug_message("--- TEST DE BUSQUEDA ---");
show_debug_message("Buscando en colección: solicitudes");
show_debug_message("Buscando documento: " + mi_tag_actual);
request_solicitud = ReadSimpleData("solicitudes", mi_tag_actual);
ReadSimpleData("duelo_pendiente", global.miFriendTag);
alarm[3] = 600; // Se repite cada 10 segundos (60 frames * 10)
        
    } else {
        // Si no está listo, esperamos un poco más y reintentamos
        alarm[3] = 10; 
        show_debug_message(">>> Socket no listo, reintentando Alarma 4...");
    }
}