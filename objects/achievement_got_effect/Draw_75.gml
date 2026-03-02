// 1. Forzamos la posición a la esquina superior derecha
var gui_w = display_get_gui_width();
var draw_x = gui_w - 410; // 400 de ancho + 10 de margen
var draw_y = 20;          // 20 píxeles desde el borde de arriba

// Tu lógica de alpha (esto lo mantenemos igual)
alpha += 0.02 * dir;
if alpha > 4 { dir = -1; }
if alpha < 0 { instance_destroy(); }

draw_set_alpha(alpha);
draw_set_font(fnt_menu);
// --- DIBUJO ---
draw_set_color(c_green); 
draw_roundrect(draw_x, draw_y, draw_x + 400, draw_y + 50, 0); 

var ach_info = gmda_get_achievement_info(ach_id);
if (ach_info != -1) {
    var ach_name = ds_map_find_value(ach_info, "name");
    var ach_image = real(ds_map_find_value(ach_info, "value"));

    draw_sprite(spr_achievements_images, ach_image, draw_x + 8, draw_y + 8); 
    
    // 🔥 CORRECCIÓN DE TEXTO: Alineación y más espacio a la derecha
    draw_set_halign(fa_left); 
    draw_set_valign(fa_top);

    draw_set_color(c_yellow);
    // Subimos de 48 a 65 para que empiece después del icono
    draw_text_transformed(draw_x + 65, draw_y + 12, "ACHIEVEMENT UNLOCKED:", 0.7, 0.7, 0); 
    
    draw_set_color(c_white);
    // Subimos de 48 a 65 también aquí
    draw_text_transformed(draw_x + 65, draw_y + 28, ach_name, 0.9, 0.9, 0); 
}

// Bordes blancos
draw_set_color(c_white);
draw_roundrect(draw_x, draw_y, draw_x + 400, draw_y + 50, 1);

draw_set_alpha(1);