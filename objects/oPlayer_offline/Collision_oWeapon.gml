// --- Colisión del Player con objgun ---
// Con 2 armas (EQUIPAMIENTO, scr_armas): igual que en linea.
//   Si ya traes esa misma arma: se rellena (solo si esta vacia).
//   Si no: entra en el lugar vacio o reemplaza la de la mano.

// 1. Verificamos que el objeto tenga un arma asignada
if (is_struct(other.weapon)) {

    // 2. Copia del arma del suelo (para no compartir la misma)
    var _copia_para_mi = variable_clone(other.weapon);

    // 3. ¿Ya la traes?
    var _sm = scr_slot_misma(_copia_para_mi);
    if (_sm != -1) {
        if (guns[_sm].ammo > 0) exit;   // la dejas en el suelo
        guns[_sm].ammo = min(guns[_sm].ammo + _copia_para_mi.ammo, guns[_sm].maxAmmo);
    } else {
        var _sl = scr_slot_para_nueva();
        if (_sl != weapon.index) { weapon.index = _sl; reloading = false; reload_timer = 0; }
        guns[weapon.index] = _copia_para_mi;
    }

    // 4. Feedback y borrar el objeto del suelo
    if (global.sfx) audio_play_sound(snd_ammo_pickup, 10, false);
    instance_destroy(other);
}
