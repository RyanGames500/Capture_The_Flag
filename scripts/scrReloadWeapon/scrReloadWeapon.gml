function scrReloadWeapon()
{
    if (guns[weapon.index] == noone) exit;

    var w = guns[weapon.index];
    if (!is_struct(w)) exit;

    if (reloading) exit;

    // cargador lleno
    if (w.ammo >= w.maxAmmo) exit;

    var t = w.ammoType;

    // no hay reserva
    if (!variable_struct_exists(reserve, t)) exit;
    if (reserve[$ t] <= 0) exit;

    // iniciar recarga
    reloading = true;
    reload_timer = round(w.reloadTime * scr_pj_recarga_mult());   // Asalto recarga más rápido (scr_personajes)
	reload_max   = reload_timer;


    if (global.sfx) audio_play_sound(snd_reload, 1, false);
}
