// Anillo en el piso mientras vuelve a salir algo
if (!ocupado && !instance_exists(my_item)) scr_spawn_anillo(x, y, timer, timer_max, scr_spawn_color((tipo_spawn == 2) ? "powerup" : "ammo", 0), false);
