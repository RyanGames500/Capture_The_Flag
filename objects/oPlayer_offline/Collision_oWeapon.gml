// --- Colisión del Player con objgun ---

// 1. Verificamos que el objeto tenga un arma asignada
if (is_struct(other.weapon)) {
    
    // 2. Usamos el método de copia manual que ya probamos que sirve
    var _struct_suelo = other.weapon;
    var _copia_para_mi = {}; 
    
    var names = variable_struct_get_names(_struct_suelo);
    for (var i = 0; i < array_length(names); i++) {
        var _val = variable_struct_get(_struct_suelo, names[i]);
        variable_struct_set(_copia_para_mi, names[i], _val);
    }
    
    // 3. EQUIPAR: Usamos el .index que viene dentro de la estructura de oBrain
    // Si la estructura dice index: 0 (pistola), se guarda en guns[0]
    // Si dice index: 1 (m4), se guarda en guns[1]
    guns[_copia_para_mi.index] = _copia_para_mi;
    
    // 4. Feedback y borrar el objeto del suelo
    if (global.sfx) audio_play_sound(snd_ammo_pickup, 10, false);
    instance_destroy(other);
}