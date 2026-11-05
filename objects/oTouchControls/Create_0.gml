/// @description Controles táctiles (solo en celular)
__touch_init();
owner   = array_create(5, -1);   // qué control tiene cada dedo
mv_bx = 0; mv_by = 0; mv_ox = 0; mv_oy = 0;   // stick de moverse
am_bx = 0; am_by = 0; am_ox = 0; am_oy = 0;   // stick de apuntar
mv_on = false;
mv_up = false;   // stick izquierdo hacia arriba = saltar
am_on = false;
emote_open = false;
kb_open = false;
mode = "game";
