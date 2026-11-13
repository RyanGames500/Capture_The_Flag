/// @description Dibuja al JEFE GIGANTE (scr_reloj)
if (!scr_modo_jefe() || room == rm_menu) { instance_destroy(); exit; }
scr_jefe_draw();
