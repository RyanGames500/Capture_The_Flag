
if (oBrain.AmIPseudoHost) { 
    if (can_spawn && instance_number(oGun) < 5) {
        
        // Ajusta estos valores al tamaño de tu mapa visible
        // Por ejemplo, si tu mapa es de 640x480:
        var _x = irandom_range(100, 540); 
        var _y = irandom_range(100, 380);
        
        // Verificamos que no haya una pared ahí (opcional)
        if (!position_meeting(_x, _y, obj_wall)) { 
            
            var _inst = instance_create_layer(_x, _y, "Instances", oGun);
            
            // Log para debug (esto saldrá en la consola abajo)
            show_debug_message("Arma creada en: " + string(_x) + "," + string(_y));

            with(oOtherPlayer) {
                var weaponData = {
                    _x: _x,
                    _y: _y,
                    _type: _inst.object_index 
                };
                SendEventToClient(id.clientId, "spawn_weapon", weaponData);
            }
            
            can_spawn = false;
            alarm[0] = tiempo_respawn;
        }
    }
}