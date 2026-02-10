var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var mid_x = gui_w / 2;
var mid_y = gui_h / 2 - 250;

// ======================================================
// 1. CUADRO DE NOMBRE (INPUT)
// ======================================================
draw_set_color(input_activo ? c_white : c_gray);
draw_roundrect_ext(mid_x - 200, mid_y - 30, mid_x + 200, mid_y + 30, 20, 20, false);

draw_set_color(c_black);
var display_text = texto_input;

cursor_timer++;
if (input_activo && (cursor_timer mod 40 < 20)) {
    display_text += "|";
}

draw_set_font(fnt_menu);
draw_text_transformed(mid_x, mid_y, display_text, 1.5, 1.5, 0);

draw_set_color(c_white);
draw_text(mid_x, mid_y + 60, "Presiona ENTER para entrar a la batalla");

// ======================================================
// 2. MENÚ PRINCIPAL (ESTADO "MAIN")
// ======================================================
if (menu_state == "main") {
    
    // --- TÍTULO DEL MODO SELECCIONADO (ESQUINA SUPERIOR DERECHA) ---
    var margin = 40;
    var panel_w = 420;
    var panel_h = 100;
    var top_x = gui_w - panel_w - margin;
    var top_y = margin;

    var m_color = (global.gameMode == MODOS.CTF) ? c_lime : c_aqua;
    var nombre_modo = (global.gameMode == MODOS.CTF) ? "CAPTURAR BANDERA" : "DESTRUIR BASE";

    // Fondo Panel
    draw_set_alpha(0.2);
    draw_set_color(c_black);
    draw_roundrect_ext(top_x, top_y, top_x + panel_w, top_y + panel_h, 20, 20, false);
    // Borde Neón
    draw_set_alpha(0.8);
    draw_set_color(m_color);
    draw_roundrect_ext(top_x, top_y, top_x + panel_w, top_y + panel_h, 20, 20, true);

    draw_set_halign(fa_right);
    draw_set_color(c_white);
    draw_text_transformed(gui_w - margin - 15, top_y + 20, "MODO DE JUEGO SELECCIONADO", 0.6, 0.6, 0);
    draw_set_color(m_color);
    draw_text_transformed(gui_w - margin - 15, top_y + 50, nombre_modo, 1.3, 1.3, 0);
    draw_set_color(c_gray);
    draw_text_transformed(gui_w - margin - 15, top_y + 85, "PRESIONA [TAB] PARA CAMBIAR", 0.5, 0.5, 0);
    draw_set_alpha(1);

    // --- OPCIONES DEL MENÚ (IZQUIERDA) ---
    draw_set_halign(fa_left);
    draw_set_font(fnt_menu);
    
    var start_x = 150;
    var start_y = gui_h / 2;
    var spacing = 80;

    for (var i = 0; i < array_length(menu_options); i++) {
        var is_selected = (i == index);
        var color = is_selected ? c_aqua : c_white;
        var alpha = is_selected ? 1 : 0.6;
        
        if (is_selected) {
            draw_set_alpha(0.2);
            draw_set_color(c_aqua);
            draw_rectangle(0, (start_y + (i * spacing)) - 35, gui_w * 0.4, (start_y + (i * spacing)) + 35, false);
        }

        draw_set_alpha(alpha);
        draw_set_color(color);
        draw_text_transformed(start_x + menu_x_offset[i], start_y + (i * spacing), menu_options[i], 1.2, 1.2, 0);

        // Sub-menú de PLAY (Slots)
        if (i == 0 && is_selected) {
            draw_set_color(c_yellow);
            var slots_text = "<< SLOTS: " + game_modes[mode_index] + " >>";
            draw_text_transformed(start_x + menu_x_offset[i] + 200, start_y + (i * spacing), slots_text, 0.9, 0.9, 0);
            
            draw_set_color(c_white);
            draw_set_alpha(0.5);
            draw_text_transformed(start_x + menu_x_offset[i] + 200, start_y + (i * spacing) + 30, "FLECHAS PARA AJUSTAR", 0.5, 0.5, 0);
        }
        draw_set_alpha(1);
    }
}
// ======================================================
// 3. PANTALLA DE BUSCANDO PARTIDA (MATCHMAKING)
// ======================================================
else if (menu_state == "connecting")
{
    if (string_count("auto_matchmake", string(global.roomId)))
    {
        var cx = gui_w * 0.5;
        var cy = gui_h * 0.5;
        var t = current_time * 0.001;
        var pulse = 0.5 + 0.5 * sin(t * 2.5);
        var pulse2 = 0.5 + 0.5 * sin(t * 1.3 + 1.2);

        draw_set_alpha(1);
        draw_set_color(make_color_rgb(12, 14, 18));
        draw_rectangle(0, 0, gui_w, gui_h, false);

        for (var r = 420; r > 0; r -= 30) {
            var a = (r / 420) * 0.12;
            draw_set_alpha(a);
            draw_set_color(make_color_rgb(30, 40, 60));
            draw_circle(cx, cy, r + pulse * 18, false);
        }

        // Panel central glass
        var panel_w = 560;
        var panel_h = 260;
        var px1 = cx - panel_w * 0.5;
        var py1 = cy - panel_h * 0.5;

        draw_set_alpha(0.70);
        draw_set_color(make_color_rgb(18, 22, 30));
        draw_rectangle(px1, py1, px1 + panel_w, py1 + panel_h, false);
        draw_set_alpha(0.95);
        draw_set_color(make_color_rgb(80, 150, 255));
        draw_rectangle(px1, py1, px1 + panel_w, py1 + panel_h, true);

        // Orbe Animado
        var orb_r = 46 + pulse * 6;
        var ring_r = 70 + pulse2 * 8;
        draw_set_alpha(0.90);
        draw_set_color(make_color_rgb(120, 200, 255));
        draw_circle(cx - 170, cy - 10, orb_r, false);

        // Texto y Tips
        draw_set_halign(fa_left);
        draw_set_color(c_white);
        draw_text(px1 + 210, py1 + 55, "BUSCANDO RIVAL");
        
        var count = (waiting_timer div 12) mod 4;
        draw_text(px1 + 210, py1 + 95, waiting_message + string_repeat(".", count));

        // Barra de progreso
        var bar_x1 = px1 + 210;
        var bar_y1 = py1 + 145;
        var bar_w = 300;
        draw_set_color(c_black);
        draw_rectangle(bar_x1, bar_y1, bar_x1 + bar_w, bar_y1 + 12, false);
        draw_set_color(make_color_rgb(80, 150, 255));
        draw_rectangle(bar_x1, bar_y1, bar_x1 + (bar_w * ((t*0.35) mod 1)), bar_y1 + 12, false);

        draw_set_halign(fa_center);
        draw_text(cx, py1 + panel_h + 22, "Presiona ESC para cancelar");
    }

    if (string_count("auto_match", string(global.roomId))) {
        draw_set_halign(fa_center);
        draw_text(gui_w * 0.5, gui_h * 0.5, "¡RIVAL ENCONTRADO! Room: " + string(global.roomId));
    }
}