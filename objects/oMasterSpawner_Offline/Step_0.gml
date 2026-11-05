// 1. Revisar si el item que creamos sigue ahí
if (!instance_exists(my_item)) {
    ocupado = false;
} else {
    ocupado = true;
}

// 2. Si está libre, contar para el respawn
if (!ocupado) {
    if (timer > 0) {
        timer--;
    } else {
        // --- MOMENTO DE GENERAR ---
        var _obj_a_crear = noone;
        var _es_municion = false;
        var _es_powerup = false;
        var _es_granada = false;

        // 3. DECIDIR QUÉ CREAR
        switch(tipo_spawn) {
            case 0: if (mezcla && random(100) < 25) _es_granada = true; else _es_municion = true; break;
            case 1: _es_granada  = true; break;
            case 2: _es_powerup  = true; break;
        }

        // --- LÓGICA DE CREACIÓN ---
        if (_es_municion) {
            my_item = instance_create_layer(x, y, "Instances", oAmmoPack);
            with(my_item) {
                // Elegir un tipo de bala al azar de las que soporta tu juego
                var _tipos = ["gun", "smg", "escop", "shell"];
                ammoType = _tipos[irandom(array_length(_tipos)-1)];
                amount = 20; // Cantidad de balas
                spawn_id = other.id;
            }
        }
        
        if (_es_granada) {
            my_item = instance_create_layer(x, y, "Instances", oAmmoPack);
            with(my_item) {
                is_grenade_pack = true;
                amount = 3;
                sprite_index = spr_granada; // Asegúrate de tener este sprite
                spawn_id = other.id;
				image_xscale=1.5;
				image_yscale=1.5;
            }
        }

        if (_es_powerup) {
            my_item = instance_create_layer(x, y, "Instances", oPowerupPickup);
            with(my_item) {
                tipo = scr_poder_al_azar(other.nivel);   // los de la base / los del centro (scr_armas)
                duration = 600;
                amount = 50; // Para el heal
                spawn_id = other.id;
            }
        }

        // Cuánto tarda en volver cuando lo agarren (8 s munición, 18 s poderes, ±20%)
        timer = scr_spawn_frames((tipo_spawn == 2) ? "powerup" : "ammo", nivel);
        timer_max = timer;
    }
}