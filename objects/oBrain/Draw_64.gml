if (variable_global_exists("tracer_queue"))
{
    for (var i = array_length(global.tracer_queue)-1; i >= 0; i--)
    {
        var t = global.tracer_queue[i];
        draw_line_width(t[0], t[1], t[2], t[3], 2);

        t[4] -= 1;
        global.tracer_queue[i] = t;

        if (t[4] <= 0) array_delete(global.tracer_queue, i, 1);
    }
}

// Datos de red arriba a la izquierda
draw_set_halign(fa_left);
draw_set_color(c_white);
draw_text(100, 100, "PING :" + string(global.ping));
draw_text(100, 130, "SALA :" + string(global.roomId)); // Bajé un poco el Y para que no se encimen

var gw = display_get_gui_width();
var gh = display_get_gui_height();

// --- TARJETA JUGADOR LOCAL (TÚ) ---
draw_set_alpha(0.8);
draw_set_color(c_black);
draw_roundrect_ext(20, gh - 80, 250, gh - 20, 10, 10, false); // Fondo negro traslúcido

draw_set_alpha(1);
draw_set_color(global.myTeam == "AZUL" ? c_aqua : c_red);
draw_set_halign(fa_left);
draw_text_transformed(40, gh - 65, global.myName, 1.2, 1.2, 0); // Tu nombre
draw_rectangle(40, gh - 40, 40 + (health * 2), gh - 35, false); // Barra de vida mini


// --- TARJETA RIVAL (Lado Derecho) ---
if (instance_exists(oOtherPlayer)) 
{
    var gw = display_get_gui_width();
    var gh = display_get_gui_height();

    // 1. FONDO (Rectángulo negro traslúcido)
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    // Lo ubicamos a 20 pixeles del borde derecho (gw - 250)
    draw_roundrect_ext(gw - 270, gh - 80, gw - 20, gh - 20, 10, 10, false);

    // 2. TEXTO DEL NOMBRE
    draw_set_alpha(1);
    // Si tu equipo es AZUL, el rival es ROJO
    draw_set_color(global.myTeam == "AZUL" ? c_red : c_aqua); 
    draw_set_halign(fa_right); // Alineado a la derecha
    draw_set_valign(fa_middle);

    var rivalName = "Oponente";
    
    // Lógica segura de las propiedades
    if (oOtherPlayer.sharedProperties != -1) {
        var SP_Data;
        if (is_string(oOtherPlayer.sharedProperties)) {
            SP_Data = json_parse(oOtherPlayer.sharedProperties);
        } else {
            SP_Data = oOtherPlayer.sharedProperties;
        }

        if (variable_struct_exists(SP_Data, "_NAME")) {
            rivalName = string(SP_Data._NAME);
        }
    }
    
    // Dibujamos el nombre a 40 pixeles del borde derecho para que tenga margen
    draw_text_transformed(gw - 40, gh - 60, rivalName, 1.2, 1.2, 0);

    // 3. INDICADOR DE ESTADO
    draw_set_color(c_lime);
    draw_set_halign(fa_right);
    draw_text_transformed(gw - 40, gh - 35, "• ONLINE", 0.8, 0.8, 0);
    
    draw_set_alpha(1); // Reset
}

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

// --- LAS BANDERAS (CENTRADO PERFECTO) ---
    var spacing = 100; // Espacio entre cada bandera
    // Calculamos el inicio restando el ancho total (spacing * 2) dividido entre 2
    var start_x = mid_x - spacing; 

    for (var i = 1; i <= 3; i++)  
    {
        // Posición X para esta bandera (i-1 para que la primera sea 0)
        var bx = start_x + ((i-1) * spacing);
        
        // --- FILA AZUL (Arriba del centro) ---
        if (global.puntos_azul >= i) {
            draw_sprite_ext(spr_flag_blue, 0, bx, mid_y - 20, 1.5 * pulse, 1.5 * pulse, 0, c_white, victory_alpha);
        } else {
            draw_sprite_ext(spr_flagvacia, 0, bx, mid_y - 20, 1.2, 1.2, 0, c_black, victory_alpha * 0.3);
        }
        
        // --- FILA ROJA (Abajo del centro) ---
        if (global.puntos_rojo >= i) {
            draw_sprite_ext(spr_flag_red, 0, bx, mid_y + 80, 1.5 * pulse, 1.5 * pulse, 0, c_white, victory_alpha);
        } else {
            draw_sprite_ext(spr_flagvacia, 0, bx, mid_y + 80, 1.2, 1.2, 0, c_black, victory_alpha * 0.3);
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