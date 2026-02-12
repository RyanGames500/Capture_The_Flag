var gw = display_get_gui_width();
var gh = display_get_gui_height();

draw_set_alpha(alpha);

// --- FONDO (Barras negras que se desvanecen) ---
draw_set_color(c_black);
draw_rectangle(0, 0, gw, 120 * alpha, false);
draw_rectangle(0, gh - (120 * alpha), gw, gh, false);

// --- CONFIGURACIÓN DE FUENTE ---
draw_set_font(fnt_intro);

// ==========================================
// 🔵 TUS ALIADOS (IZQUIERDA)
// ==========================================
// Usamos "aliados" que contiene: "Nombre1 & Nombre2..."
var x_me = lerp(-500, gw * 0.40, anim); // Un poco más de margen para nombres largos
draw_set_halign(fa_right);
draw_set_valign(fa_middle);

// Dibujamos la lista de aliados
draw_text_transformed_color(x_me, gh/2, aliados, 1.2, 1.2, 0, c_aqua, c_aqua, c_white, c_white, alpha);

// ==========================================
// 🔴 TUS RIVALES (DERECHA)
// ==========================================
// Usamos "rivales" que contiene: "Enemigo1 & Enemigo2..."
var x_rival = lerp(gw + 500, gw * 0.60, anim);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);

// Dibujamos la lista de rivales
draw_text_transformed_color(x_rival, gh/2, rivales, 1.2, 1.2, 0, c_red, c_red, c_white, c_white, alpha);

// ==========================================
// ⚡ EL "VS" (CENTRO)
// ==========================================
var vs_scale = (1 - (anim - 1)) * alpha; 
if (estado == 1) vs_scale = anim; // 1 suele ser tu estado ENTRADA

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_alpha(alpha);
draw_text_transformed(gw/2, gh/2, "VS", vs_scale, vs_scale, 0);

// Reset de dibujo
draw_set_alpha(1);
draw_set_valign(fa_top);