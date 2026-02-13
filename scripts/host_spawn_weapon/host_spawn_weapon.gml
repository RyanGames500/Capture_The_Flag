function host_spawn_weapon(_obj_weapon_pickup, _x, _y, _weaponStruct)
{
    if (!oBrain.AmIPseudoHost) return noone; // Usamos return para consistencia

    // 1. Validación de seguridad
    if (_weaponStruct == noone || !is_struct(_weaponStruct)) {
        show_debug_message("!!! ERROR: Intentaste spawnear un arma con struct inválido");
        return noone;
    }

    if (!variable_global_exists("next_weapon_uid")) global.next_weapon_uid = 1;
    var uid = global.next_weapon_uid++;
    
    // 2. Crear la instancia
    var w = instance_create_depth(_x, _y, 1, _obj_weapon_pickup);
    w.net_uid = uid;
    w.weapon  = _weaponStruct;
    w.taken = false;
    
    // Asignar sprite de forma segura
    if (variable_struct_exists(_weaponStruct, "sprite_suelo")) {
        w.sprite_index = _weaponStruct.sprite_suelo;
    }

    // 3. DIFUSIÓN: Avisar a TODOS los clientes (para que los 4 vean el arma)
    with(oOtherPlayer) {
        SendEventToClient(clientId, "spawn_weapon_pickup", {
            uid: uid,
            x: _x,
            y: _y,
            weapon: _weaponStruct
        });
    }

    // 4. EL FIX MAESTRO: Devolver la instancia para que el oBrain no crashee
    return w; 
}