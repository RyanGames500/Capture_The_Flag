// Anillo en el piso mientras vuelve a salir algo (lo ven todos igual)
if (!ocupado) scr_spawn_anillo(x, y, cooldown, cooldown_max, scr_spawn_color(tipo_spawn, nivel), (tipo_spawn == "weapon" && nivel == 3));
