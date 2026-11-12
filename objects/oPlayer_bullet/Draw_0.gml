// Red de la Exploradora y otras con efecto: su propio dibujo (scr_armas)
if (variable_instance_exists(id, "efecto") && efecto != "") { scr_efx_bala_draw(efecto, x, y, direction); exit; }
// Estela de la bala (scr_mira). Los cohetes y granadas se dibujan como siempre.
if (!is_rocket && !is_granada && speed > 0 && sprite_index != spr_bala_silenciada) scr_bala_estela(x, y, direction, min(speed * 2.2, 40));
draw_self();
