// --- LÓGICA DE BANDERA ROJA (oFlag) ---

if (global.ONLINE == false) {
    // --- MODO OFFLINE ---
if (!has_flag) {
        sprite_index = spr_suela; 
        image_xscale = 1;
        depth = -y;
        
        // 1. Aplicar gravedad si no hay suelo (Pared o Plataforma)
        var on_wall = place_meeting(x, y + 1, obj_wall);
        var plat = instance_place(x, y + 1, oPlataformaPasable);
        var on_platform = (plat != noone && bbox_bottom <= plat.bbox_top + 1);

        if (!on_wall && !on_platform) {
            velocidad_caida += gravedad;
        }

        // 2. Colisión con Paredes Sólidas (obj_wall)
        if (place_meeting(x, y + velocidad_caida, obj_wall)) {
            while (!place_meeting(x, y + sign(velocidad_caida), obj_wall)) y += sign(velocidad_caida);
            velocidad_caida = 0;
        }
        
        // 3. Colisión con Plataformas Traspasables (oPlataformaPasable)
        if (velocidad_caida > 0) {
            var plat_below = instance_place(x, y + velocidad_caida, oPlataformaPasable);
            if (plat_below != noone) {
                // Solo colisionar si la bandera viene desde arriba
                if (bbox_bottom <= plat_below.bbox_top) {
                    y = plat_below.bbox_top - (bbox_bottom - y);
                    velocidad_caida = 0;
                }
            }
        }

        y += velocidad_caida;
        
    } else {
        // --- SEGUIMIENTO Y VISUALS ---
        if (instance_exists(oPlayer_offline)) {
            x = oPlayer_offline.x;
            y = oPlayer_offline.y - 16;
            image_xscale = oPlayer_offline.image_xscale; // Que mire a donde mira el player
            sprite_index = spr_mano; // ¡IMPORTANTE! Cambiar al sprite de "portando"
            depth = oPlayer_offline.depth - 1; // Que se vea por delante
            
            // Si el jugador muere en offline, soltamos la bandera
            if (variable_instance_exists(oPlayer_offline, "isDead") && oPlayer_offline.isDead) {
                has_flag = false;
                oPlayer_offline.has_flag = false;
            }
        } else {
            has_flag = false;
        }
        velocidad_caida = 0; 
    }
}
else {
    // --- MODO ONLINE ---
    if (has_flag) {
        // SEGUIMIENTO: Si alguien la lleva, seguir al portador asignado por el ID
        if (portador_instancia != noone && instance_exists(portador_instancia) && portador_instancia.state != PLAYERSTATE.DEAD) {
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
        // 1. Aplicar gravedad si no hay suelo (Pared o Plataforma)
        var on_wall = place_meeting(x, y + 1, obj_wall);
        var plat = instance_place(x, y + 1, oPlataformaPasable);
        var on_platform = (plat != noone && bbox_bottom <= plat.bbox_top + 1);

        if (!on_wall && !on_platform) {
            velocidad_caida += gravedad;
        }

        // 2. Colisión con Paredes Sólidas (obj_wall)
        if (place_meeting(x, y + velocidad_caida, obj_wall)) {
            while (!place_meeting(x, y + sign(velocidad_caida), obj_wall)) y += sign(velocidad_caida);
            velocidad_caida = 0;
        }
        
        // 3. Colisión con Plataformas Traspasables (oPlataformaPasable)
        if (velocidad_caida > 0) {
            var plat_below = instance_place(x, y + velocidad_caida, oPlataformaPasable);
            if (plat_below != noone) {
                // Solo colisionar si la bandera viene desde arriba
                if (bbox_bottom <= plat_below.bbox_top) {
                    y = plat_below.bbox_top - (bbox_bottom - y);
                    velocidad_caida = 0;
                }
            }
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