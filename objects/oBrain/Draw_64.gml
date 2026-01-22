// Datos de red arriba a la izquierda
draw_set_halign(fa_left);
draw_set_color(c_white);
draw_text(100, 100, "PING :" + string(global.ping));
draw_text(100, 130, "SALA :" + string(global.roomId)); // Bajé un poco el Y para que no se encimen

// --- 1. CONFIGURACIÓN ---
var mid_x = display_get_gui_width() / 2;
var mid_y = display_get_gui_height() / 2;

var pulse = 1 + sin(get_timer() / 200000) * 0.05;

// --- 2. MARCADOR NORMAL ---
if (!global.game_over && room == rm_game) {
    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_color(c_black); // Blanco resalta más
    draw_text(mid_x, 30, "AZUL: " + string(global.puntos_azul) + " | ROJO: " + string(global.puntos_rojo));
}

// --- 3. PANTALLA DE RESULTADOS ---
if (global.game_over) 
{
    draw_set_alpha(victory_alpha); 

    // Fondo oscuro más profundo
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);

    // --- PANEL CENTRAL MÁS GRANDE ---
    var p_w = 600; // Aumentado de 450 a 600
    var p_h = 400; // Aumentado de 250 a 400
    
    // Sombra del panel
    draw_set_color(c_black);
    draw_roundrect_ext(mid_x - p_w/2 + 8, mid_y - p_h/2 + 8, mid_x + p_w/2 + 8, mid_y + p_h/2 + 8, 30, 30, false);
    
    // Panel principal
    draw_set_color(make_color_rgb(40, 40, 45)); // Gris azulado oscuro
    draw_roundrect_ext(mid_x - p_w/2, mid_y - p_h/2, mid_x + p_w/2, mid_y + p_h/2, 30, 30, false);
    
    // Borde del panel según ganador
    var _col_ganador = (global.winner_team == 1) ? c_red : c_aqua;
    draw_set_color(_col_ganador);
    draw_roundrect_ext(mid_x - p_w/2, mid_y - p_h/2, mid_x + p_w/2, mid_y + p_h/2, 30, 30, true);

    // --- EFECTO DE PARTÍCULAS (SIMULADO) ---
    // Esto crea chispas del color del ganador saliendo del centro
    for(var p=0; p<10; p++) {
        var angle = random(360);
        var dist = (get_timer()/1000 % 500) * (p/10);
        var px = mid_x + lengthdir_x(dist, angle);
        var py = mid_y + lengthdir_y(dist, angle);
        draw_circle_color(px, py, 2, _col_ganador, c_white, false);
    }

    // TÍTULO DE VICTORIA MÁS GRANDE
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var _ganador_txt = (global.winner_team == 1) ? "¡VICTORIA ROJA!" : "¡VICTORIA AZUL!";
    draw_set_color(_col_ganador);
    // Escala aumentada a 3
    draw_text_transformed(mid_x, mid_y - 120, _ganador_txt, 3 * pulse, 3 * pulse, 0);

    // --- LAS BANDERAS (Más separadas y grandes) ---
    var spacing = 70; // Más espacio entre ellas
    var start_x_azul = mid_x - 150;
    var start_x_rojo = mid_x + 60;
    
    for (var i = 1; i <= 3; i++) 
    {
        // BANDERAS AZULES
        if (global.puntos_azul >= i) {
            draw_sprite_ext(spr_flag_blue, 0, start_x_azul + (i*spacing), mid_y + 20, 1.5 * pulse, 1.5 * pulse, 0, c_white, victory_alpha);
        } else {
            draw_sprite_ext(spr_flagvacia, 0, start_x_azul + (i*spacing), mid_y + 20, 1.2, 1.2, 0, c_black, victory_alpha * 0.3);
        }
        
        // BANDERAS ROJAS
        if (global.puntos_rojo >= i) {
            draw_sprite_ext(spr_flag_red, 0, start_x_rojo + (i*spacing), mid_y + 20, 1.5 * pulse, 1.5 * pulse, 0, c_white, victory_alpha);
        } else {
            draw_sprite_ext(spr_flagvacia, 0, start_x_rojo + (i*spacing), mid_y + 20, 1.2, 1.2, 0, c_black, victory_alpha * 0.3);
        }
    }

    // --- INSTRUCCIÓN DE SALIDA ---
    if (victory_alpha >= 0.9) {
        draw_set_color(c_yellow);
        draw_set_valign(fa_bottom);
        draw_text_transformed(mid_x, mid_y + 160, "[ Esc = Salir al Menu ]", 1.2, 1.2, 0);
    }

    draw_set_alpha(1); 
}