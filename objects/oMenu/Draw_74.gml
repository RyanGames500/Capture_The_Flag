var _guiW = display_get_gui_width();
var _guiH = display_get_gui_height();

// --- 1. GLITCH (Vibración) ---
var _offX = 0; var _offY = 0;
if (random(100) > 98.5) {
    _offX = random_range(-4, 4);
    _offY = random_range(-2, 2);
}

// --- 2. COLOR VERDE TERMINAL (Inyectado) ---
// Aquí subí el factor a 0.5 para que el verde se note de verdad
var _color_pulso = merge_color(c_white, c_lime, 0.4 + lengthdir_x(0.2, current_time * 0.1));

// --- 3. FLICKER (Parpadeo de monitor viejo) ---
// Esto hace que el brillo cambie rapidito, como una pantalla de tubo
var _flicker = random_range(0.8, 1.0); 

// Dibujamos el fondo con el color fuerte y el flicker
draw_sprite_stretched_ext(spr_MenuBackground, 0, _offX, _offY, _guiW, _guiH, _color_pulso, _flicker);

// --- 4. BARRIDO DE RADAR ---
var _scan_y = (current_time * 0.2) % (_guiH + 100);
draw_set_color(c_lime);
draw_set_alpha(0.5); // Ahora la línea es más visible
draw_line_width(0, _scan_y, _guiW, _scan_y, 4); 
draw_set_alpha(0.2);
draw_rectangle(0, _scan_y - 20, _guiW, _scan_y, false); // Estela de luz tras la línea

// === RESET TOTAL (Blindado para oBrain) ===
draw_set_alpha(1);
draw_set_color(c_white);
