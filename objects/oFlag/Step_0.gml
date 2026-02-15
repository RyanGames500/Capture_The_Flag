// --- LÓGICA DE BANDERA ROJA (oFlag) ---

if (global.ONLINE == false) {
    // --- MODO OFFLINE ---
    if (!has_flag) {
        if (!place_meeting(x, y + 1, obj_wall)) velocidad_caida += gravedad;
        if (place_meeting(x, y + velocidad_caida, obj_wall)) {
            while (!place_meeting(x, y + sign(velocidad_caida), obj_wall)) y += sign(velocidad_caida);
            velocidad_caida = 0;
        }
        y += velocidad_caida;
    } else {
        // En offline usualmente sigue a oPlayer_local
        if (instance_exists(oPlayer_local)) {
            x = oPlayer_local.x;
            y = oPlayer_local.y - 16;
        }
        velocidad_caida = 0; 
    }
} 
else {
    // --- MODO ONLINE ---
    if (has_flag) {
        // SEGUIMIENTO: Si alguien la lleva, seguir al portador asignado por el ID
        if (portador_instancia != noone && instance_exists(portador_instancia)) {
            x = portador_instancia.x;
            y = portador_instancia.y - 16;
            image_xscale = portador_instancia.image_xscale;
            sprite_index = spr_mano;
            depth = portador_instancia.depth - 1;
        } else {
            // Seguridad por si el portador sale de la partida o muere
            has_flag = false;
            portador_instancia = noone;
        }
    } 
    else {
        // BANDERA EN EL SUELO: El Host manda, el Cliente obedece
        sprite_index = spr_suela;
        image_xscale = 1;
        depth = -y;

        if (oBrain.AmIPseudoHost) {
            // Físicas del Host
            if (!place_meeting(x, y + 1, obj_wall)) {
                velocidad_caida += gravedad;
                if (place_meeting(x, y + velocidad_caida, obj_wall)) {
                    while (!place_meeting(x, y + sign(velocidad_caida), obj_wall)) y += sign(velocidad_caida);
                    velocidad_caida = 0;
                }
            } else {
                velocidad_caida = 0;
            }
            y += velocidad_caida;

            // Publicar posición para los clientes
            global.sharedProperties._flagX = x;
            global.sharedProperties._flagY = y;
        } 
        else {
            // El Cliente copia la posición que el Host envía en el struct SP
            if (variable_instance_exists(id, "SP")) {
                x = SP._flagX;
                y = SP._flagY;
            }
        }
    }
}