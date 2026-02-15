// --- LÓGICA DE BANDERA AZUL (oFlag2) ---

if (global.ONLINE == false) {
    // --- MODO OFFLINE ---
    if (!has_flag) {
        if (!place_meeting(x, y + 1, obj_wall)) velocidad_caida += 0.5;
        if (place_meeting(x, y + velocidad_caida, obj_wall)) {
            while (!place_meeting(x, y + sign(velocidad_caida), obj_wall)) y += sign(velocidad_caida);
            velocidad_caida = 0;
        }
        y += velocidad_caida;
    } else {
        if (instance_exists(oPlayer2_local)) {
            x = oPlayer2_local.x;
            y = oPlayer2_local.y - 16;
        }
        velocidad_caida = 0; 
    }
} 
else {
    // --- MODO ONLINE ---
    if (has_flag) {
        // SEGUIMIENTO: Seguir al portador (Aliado o Enemigo)
        if (portador_instancia != noone && instance_exists(portador_instancia)) {
            x = portador_instancia.x;
            y = portador_instancia.y - 16;
            image_xscale = portador_instancia.image_xscale;
            sprite_index = spr_mano;
            depth = portador_instancia.depth - 1;
        } else {
            has_flag = false;
            portador_instancia = noone;
        }
    } 
    else {
        // BANDERA EN EL SUELO
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

            // Publicar posición para los clientes (Usando variable distinta a la roja)
            global.sharedProperties._flagAzulX = x;
            global.sharedProperties._flagAzulY = y;
        } 
        else {
            // El Cliente copia al Host
            if (variable_instance_exists(id, "SP")) {
                x = SP._flagAzulX;
                y = SP._flagAzulY;
            }
        }
    }
}