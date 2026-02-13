var gw = display_get_gui_width();
var gh = display_get_gui_height();

draw_set_alpha(alpha);

// --- 1. FONDO (Barras negras tipo cine) ---
draw_set_color(c_black);
draw_set_alpha(alpha * 0.7); 
draw_rectangle(0, 0, gw, 160 * alpha, false);
draw_rectangle(0, gh - (160 * alpha), gw, gh, false);
draw_set_alpha(alpha);

draw_set_font(fnt_intro);

// --- 2. LOGICA DE TAMAÑO DINÁMICO (Aquí va puesto) ---
var escala_dinamica = 2.0; // Tamaño gigante por defecto

if (string_length(aliados) > 15 || string_length(rivales) > 15) {
    escala_dinamica = 1.3; 
}
if (string_length(aliados) > 25 || string_length(rivales) > 25) {
    escala_dinamica = 0.9; // Un poco más pequeño si son muchísimos
}

// ==========================================
// 🔵 EQUIPO ALIADO
// ==========================================
var x_me = lerp(-600, gw * 0.45, anim); 
draw_set_halign(fa_right);
draw_set_valign(fa_middle);

// Sombra (usando escala_dinamica)
draw_text_transformed_color(x_me + 4, gh/2 + 4, aliados, escala_dinamica, escala_dinamica, 0, c_black, c_black, c_black, c_black, alpha * 0.5);
// Texto principal (usando escala_dinamica)
draw_text_transformed_color(x_me, gh/2, aliados, escala_dinamica, escala_dinamica, 0, c_aqua, c_aqua, c_white, c_white, alpha);


// ==========================================
// 🔴 EQUIPO RIVAL
// ==========================================
var x_rival = lerp(gw + 600, gw * 0.55, anim);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);

// Sombra (usando escala_dinamica)
draw_text_transformed_color(x_rival + 4, gh/2 + 4, rivales, escala_dinamica, escala_dinamica, 0, c_black, c_black, c_black, c_black, alpha * 0.5);
// Texto principal (usando escala_dinamica)
draw_text_transformed_color(x_rival, gh/2, rivales, escala_dinamica, escala_dinamica, 0, c_red, c_red, c_white, c_white, alpha);


// ==========================================
// ⚡ EL "VS"
// ==========================================
var vs_scale = (1 - (anim - 1)) * alpha; 
if (estado == INTRO_STATE.ENTRADA) vs_scale = anim * 2.5; 

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Sombra del VS
draw_text_transformed_color(gw/2 + 3, gh/2 + 3, "VS", vs_scale, vs_scale, 0, c_black, c_black, c_black, c_black, alpha * 0.5);
// VS Principal
draw_text_transformed(gw/2, gh/2, "VS", vs_scale, vs_scale, 0);


// --- RESET ---
draw_set_alpha(1);
draw_set_valign(fa_top);