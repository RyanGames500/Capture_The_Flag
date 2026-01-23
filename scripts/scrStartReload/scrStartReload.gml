function scrStartReload(_player)
{
    // _player = instancia del jugador (oPlayer)
    if (!instance_exists(_player)) return;

    with (_player)
    {
        if (reloading) return;
        if (guns[weapon.index] == noone) return;

        var w = guns[weapon.index];

        // defaults por si faltan
        if (!variable_struct_exists(w, "ammoType"))  w.ammoType = "generic";
        if (!variable_struct_exists(w, "reloadTime")) w.reloadTime = room_speed; // 1s

        var t = w.ammoType;

        var res = 0;
        if (variable_struct_exists(reserve, t)) res = reserve[$ t];
        if (res <= 0) return;

        if (w.ammo >= w.maxAmmo) return;

        reloading = true;
        reload_timer = w.reloadTime;
    }
}
