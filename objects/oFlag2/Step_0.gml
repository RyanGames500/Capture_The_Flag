// --- LÓGICA DE BANDERA AZUL (oFlag2) ---

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
        if (instance_exists(oPlayer2_local)) {
            x = oPlayer2_local.x;
            y = oPlayer2_local.y - 16;
            image_xscale = oPlayer2_local.image_xscale; // Que mire a donde mira el player
            sprite_index = spr_mano; // ¡IMPORTANTE! Cambiar al sprite de "portando"
            depth = oPlayer2_local.depth + 1; // Va en la espalda (detras del personaje)
            
            // Si el jugador muere en offline, soltamos la bandera
            if (variable_instance_exists(oPlayer2_local, "isDead") && oPlayer2_local.isDead) {
                has_flag = false;
                oPlayer2_local.has_flag = false;
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
        // SEGUIMIENTO: Seguir al portador (Aliado o Enemigo)
        if (portador_instancia != noone && instance_exists(portador_instancia) && portador_instancia.state != PLAYERSTATE.DEAD) {
            x = portador_instancia.x;
            y = portador_instancia.y - 16 * ((portador_instancia.image_yscale < 0) ? -1 : 1);   // GRAVEDAD LOCA: de cabeza va abajo
            image_xscale = portador_instancia.image_xscale;
            sprite_index = spr_mano;
            depth = portador_instancia.depth + 1;
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

        // La bandera cae igual en TODAS las pantallas (antes solo en la del host, y en las
        // demás se quedaba flotando donde la soltaron). Su posición inicial llega por los
        // eventos "flag_dropped" y "sync_score", y desde ahí cada quien la deja caer.
        // GRAVEDAD LOCA: al reves, la bandera suelta cae hacia el techo (la que esta en su base no se mueve) (scr_reloj)
        var _fg = scr_grav_dir();
        if (_fg < 0 && x == spawnX) _fg = 1;
        if (_fg < 0) {
            var _tw = place_meeting(x, y - 1, obj_wall);
            var _tp = instance_place(x, y - 1, oPlataformaPasable);
            if (!_tw && !(_tp != noone && bbox_top > _tp.bbox_bottom - 2)) velocidad_caida -= gravedad;
            if (place_meeting(x, y + velocidad_caida, obj_wall)) {
                while (!place_meeting(x, y + sign(velocidad_caida), obj_wall)) y += sign(velocidad_caida);
                velocidad_caida = 0;
            }
            if (velocidad_caida < 0) {
                var _pa = instance_place(x, y + velocidad_caida, oPlataformaPasable);
                if (_pa != noone && bbox_top >= _pa.bbox_bottom + velocidad_caida) { y = _pa.bbox_bottom + 1 + (y - bbox_top); velocidad_caida = 0; }
            }
            y += velocidad_caida;
        } else
        {
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
        }
    }
}