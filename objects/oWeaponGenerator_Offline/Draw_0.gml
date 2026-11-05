// Anillo en el piso mientras vuelve a salir un arma
if (!instance_exists(my_item)) scr_spawn_anillo(x, y, timer, timer_max, scr_spawn_color("weapon", nivel), nivel == 3);
