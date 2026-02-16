draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var mid_x = room_width / 2;
var mid_y = room_height / 2 - 250;

// 1. Dibujar el fondo del cuadro de nombre
draw_set_color(input_activo ? c_white : c_gray);
draw_roundrect_ext(mid_x - 200, mid_y - 30, mid_x + 200, mid_y + 30, 20, 20, false);

// 2. Dibujar el texto del nombre
draw_set_color(c_black);
var display_text = texto_input;

cursor_timer++;
if (input_activo && (cursor_timer mod 40 < 20)) {
    display_text += "|";
}
draw_text_transformed(mid_x, mid_y, display_text, 1.5, 1.5, 0);

// 3. Instrucción abajo
draw_set_color(c_white);
draw_text(mid_x, mid_y + 60, "Presiona ENTER para entrar a la batalla");

// ==========================================
// LÓGICA DE DIBUJO DE MENÚS (MAIN vs PRIVATE)
// ==========================================
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var spacing = 60;

if (menu_state == "main") {
    draw_set_font(fnt_menu);
    for (var i = 0; i < array_length(menu_options); i++) {
        if (i == index) {
            draw_set_color(c_yellow);
            var txt = "> " + menu_options[i] + " <";
        } else {
            draw_set_color(c_white);
            var txt = menu_options[i];
        }
        draw_text(gui_w / 2, (gui_h / 2 - 50) + (i * spacing), txt);
    }
} 
else if (menu_state == "private") {
    draw_set_font(fnt_menu);
    draw_set_color(c_aqua);
    draw_text(gui_w / 2, gui_h / 2 - 120, "--- LOBBY PRIVADO ---");

    for (var i = 0; i < array_length(private_options); i++) {
        if (i == p_index) {
            draw_set_color(c_aqua);
            var txt = ">> " + private_options[i] + " <<";
        } else {
            draw_set_color(c_white);
            var txt = private_options[i];
        }
        draw_text(gui_w / 2, (gui_h / 2 - 50) + (i * spacing), txt);
    }
}

// ==========================================
// PANTALLA DE CARGA (TU EFECTO DEL ORBE)
// ==========================================
else if (menu_state == "connecting")
{
    // QUITAMOS EL FILTRO DE "auto_matchmake" para que el orbe se vea siempre
    var cx = gui_w * 0.5;
    var cy = gui_h * 0.5;

    // --- Tiempo ---
    var t = current_time * 0.001;                 
    var pulse  = 0.5 + 0.5 * sin(t * 2.5);        
    var pulse2 = 0.5 + 0.5 * sin(t * 1.3 + 1.2);  

    // --- Fondo ---
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(12, 14, 18));
    draw_rectangle(0, 0, gui_w, gui_h, false);

    // --- Glow central ---
    for (var r = 420; r > 0; r -= 30) {
        var a = (r / 420) * 0.12;
        draw_set_alpha(a);
        draw_set_color(make_color_rgb(30, 40, 60));
        draw_circle(cx, cy, r + pulse * 18, false);
    }
    draw_set_alpha(1);

    // --- Scanlines ---
    draw_set_alpha(0.08); draw_set_color(c_black);
    for (var yy = 0; yy < gui_h; yy += 4) draw_rectangle(0, yy, gui_w, yy + 1, false);
    draw_set_alpha(1);

    // --- Estrellitas ---
    draw_set_alpha(0.35); draw_set_color(c_white);
    for (var i = 0; i < 40; i++) {
        var px = (sin(i * 123.45 + t * 0.6) * 9999); px = (px - floor(px)) * gui_w;
        var py = (sin(i * 54.321 + t * 0.9) * 8888); py = (py - floor(py)) * gui_h;
        draw_rectangle(px, py, px + 2, py + 2, false);
    }
    draw_set_alpha(1);

    // --- Panel central ---
    var panel_w = 560; var panel_h = 260;
    var px1 = cx - panel_w * 0.5; var py1 = cy - panel_h * 0.5;
    draw_set_alpha(0.70); draw_set_color(make_color_rgb(18, 22, 30));
    draw_rectangle(px1, py1, px1 + panel_w, py1 + panel_h, false);
    draw_set_alpha(0.95); draw_set_color(make_color_rgb(80, 150, 255));
    draw_rectangle(px1, py1, px1 + panel_w, py1 + panel_h, true);
    draw_set_alpha(1);

    // --- Orbe + anillo ---
    var orb_r  = 46 + pulse * 6;
    var ring_r = 70 + pulse2 * 8;
    draw_set_alpha(0.20); draw_set_color(make_color_rgb(80, 150, 255));
    draw_circle(cx - 170, cy - 10, ring_r + 24, false);
    draw_set_alpha(0.90); draw_set_color(make_color_rgb(120, 200, 255));
    draw_circle(cx - 170, cy - 10, orb_r, false);

    // Anillo giratorio
    for (var s = 0; s < 24; s++) {
        var a2 = (t * 120) + (s * (360 / 24));
        var rx = (cx - 170) + lengthdir_x(ring_r, a2);
        var ry = (cy - 10)  + lengthdir_y(ring_r, a2);
        draw_set_color(make_color_rgb(80, 150, 255));
        draw_circle(rx, ry, (s mod 3 == 0) ? 3 : 2, false);
    }
    draw_set_alpha(1);

    // --- TEXTOS DINÁMICOS ---
    draw_set_font(fnt_menu); draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_set_color(c_white);
    
    // Cambiar título según si es Random o Privada
    var es_random = string_count("auto_matchmake", string(global.roomId));
    draw_text(px1 + 210, py1 + 55, es_random ? "BUSCANDO RIVAL" : "SALA PRIVADA");

    // Mostrar puntos de carga
    var dots = string_repeat(".", (waiting_timer div 12) mod 4);
    draw_set_alpha(0.85); draw_set_color(make_color_rgb(190, 210, 255));
    draw_text(px1 + 210, py1 + 95, (es_random ? waiting_message : "Creando sala") + dots);
    
    // Mostrar código si no es random
    if (!es_random && global.myRoomCode != "") {
        draw_set_color(c_yellow);
        draw_text(px1 + 210, py1 + 120, "CODIGO: " + string(global.myRoomCode));
    }
    draw_set_alpha(1);

    // --- Barra de progreso ---
    var bar_x1 = px1 + 210; var bar_y1 = py1 + 155;
    draw_set_color(make_color_rgb(10, 12, 16));
    draw_rectangle(bar_x1, bar_y1, bar_x1 + 300, bar_y1 + 12, false);
    draw_set_color(make_color_rgb(80, 150, 255));
    var fill = 300 * ((t * 0.35) % 1);
    draw_rectangle(bar_x1, bar_y1, bar_x1 + fill, bar_y1 + 12, false);

    // --- Footer ---
    draw_set_halign(fa_center); draw_set_color(make_color_rgb(180, 180, 180));
    draw_text(cx, py1 + panel_h + 22, "Presiona ESC para cancelar");
}
// Añade esto en tu lógica de dibujos de estados
else if (menu_state == "verifying") {
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    var dots = string_repeat(".", (current_time div 250) mod 4);
    draw_text(display_get_gui_width()/2, display_get_gui_height()/2, "VERIFICANDO CODIGO" + dots);
}
else if (menu_state == "lobby_espera") {
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    
    // 1. Fondo negro/azul
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(12, 14, 18));
    draw_rectangle(0, 0, gui_w, gui_h, false);
    
    draw_set_font(fnt_menu);
    draw_set_halign(fa_center);
    draw_set_color(c_aqua);
    draw_text(gui_w / 2, 50, "SALA: " + string(global.myRoomCode));

    // 2. LÓGICA DE SLOTS (Reparada)
    var slot_w = 400;
    var slot_h = 60;
    var padding = 20;

    // LIMPIAR PRIMERO: Ponemos "---" en todos para que no se queden nombres viejos
    for(var j = 0; j < 8; j++) { global.slot_nombres[j] = "---"; }

    // TÚ siempre eres el primero
    global.slot_nombres[0] = global.myName;
    
    // RELLENAR CON LOS DEMÁS
    var _index = 1;
    with(oOtherPlayer) {
        if (_index < 8) {
            // Buscamos la variable 'Name' que es la que estamos sincronizando
            if (Name != "") {
                global.slot_nombres[_index] = Name;
            } else {
                // Si el objeto existe pero no ha llegado el nombre aún
                global.slot_nombres[_index] = "Conectando..."; 
            }
            _index++;
        }
    }

    // 3. DIBUJAR LOS SLOTS (4 vs 4)
    for (var i = 0; i < 8; i++) {
        var es_derecha = (i >= 4);
        var _x = es_derecha ? (gui_w / 2) + 50 : (gui_w / 2) - 450;
        var _y = 150 + ((i % 4) * (slot_h + padding));
        
        var color_equipo = es_derecha ? c_red : c_blue;
        
        // Caja de fondo
        draw_set_alpha(0.3);
        draw_set_color(c_black);
        draw_rectangle(_x, _y, _x + slot_w, _y + slot_h, false);
        
        // Borde lateral de color
        draw_set_alpha(1);
        draw_set_color(color_equipo);
        draw_rectangle(_x, _y, _x + 10, _y + slot_h, false);
        
        // Texto del nombre
        draw_set_color(c_white);
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle); // Para que el texto quede centrado verticalmente
        draw_text(_x + 25, _y + (slot_h/2), global.slot_nombres[i]);
    }

    // 4. BOTÓN DE INICIO (Lógica del Host)
    draw_set_valign(fa_top); // Reset valign
    if (oBrain.AmIPseudoHost) {
        draw_set_halign(fa_center);
        draw_set_color(c_yellow);
        draw_text(gui_w / 2, gui_h - 100, "PRESIONA 'S' PARA INICIAR BATALLA");
        
        if (keyboard_check_pressed(ord("S"))) {
            with(oOtherPlayer) {
                SendEventToClient(clientId, "GO_TO_BATTLE", {});
            }
            room_goto(rm_stage1);
        }
    } else {
        draw_set_halign(fa_center);
        draw_set_color(c_white);
        draw_text(gui_w / 2, gui_h - 100, "Esperando al lider...");
    }
}