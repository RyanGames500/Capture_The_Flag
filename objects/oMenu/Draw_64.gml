
// 1. OBTENER EL CENTRO REAL DE LA PANTALLA (Indispensable para centrar)
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var cx = gui_w / 2;
var cy = gui_h / 2;
var spacing = 60;

// Configuración inicial de dibujo
draw_set_font(fnt_menu);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

if (global.registrado == 0) {
    if (input_activo) global.myName = texto_input;

    // USAMOS SIEMPRE GUI PARA QUE NO SE DESPLACE
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    
    var mid_x = gui_w / 2;
    var mid_y = gui_h / 2 - 150; // Lo bajé un poco (estaba muy arriba en -250)

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    // 1. Dibujar el fondo del cuadro de nombre
    draw_set_color(input_activo ? c_white : c_gray);
    // Centrado exacto: mid_x es el centro, restamos y sumamos 200
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
    draw_set_font(fnt_menu); // Asegúrate de resetear la fuente
    draw_text(mid_x, mid_y + 80, "Presiona ENTER para entrar a la batalla");
}


// AL PURO INICIO DEL DRAW GUI
if (room == rm_menu) {
    if (!global.registrado) exit; 
    
}

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
        draw_text(gui_w / 2, (gui_h / 2 - 100) + (i * spacing), txt);
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
  
    // --- 1. DETECTAR LÍMITE DE SALA ---
    if (!oBrain.AmIPseudoHost) {
        if (string_copy(global.myRoomCode, 1, 3) == "MAX") {
            global.max_players_allowed = real(string_digits(string_copy(global.myRoomCode, 4, 1)));
        } else {
            global.max_players_allowed = 8; 
        }
    }
  
    // Fondo
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(12, 14, 18));
    draw_rectangle(0, 0, gui_w, gui_h, false);
    
    draw_set_font(fnt_menu);
    draw_set_halign(fa_center);
    draw_set_color(c_aqua);
    draw_text(gui_w / 2, 50, "SALA: " + string(global.myRoomCode));

    // --- 2. LÓGICA DE SLOTS (LIMPIEZA Y LLENADO) ---
    for (var j = 0; j < 8; j++) global.slot_nombres[j] = "---";

    if (oBrain.AmIPseudoHost) {
        // --- SOY EL HOST ---
        global.slot_nombres[0] = global.myName; // Mi nombre del INI/Registro
        var _index = 1;
        with(oOtherPlayer) {
            if (_index < 8) {
                var _nombre_real = ds_map_find_value(global.playerNames, string(clientId));
                global.slot_nombres[_index] = (!is_undefined(_nombre_real) && _nombre_real != "") ? _nombre_real : "Conectando...";
                _index++;
            }
        }
    } else {
        // --- SOY INVITADO ---
        var _host_encontrado = false;
        var _next_free_slot = 1;

        // Primero posicionamos al Host en el slot 0
        with(oOtherPlayer) {
            if (isHost) {
                global.slot_nombres[0] = (Name != "" && Name != "Cargando...") ? Name : "Lider...";
                _host_encontrado = true;
            }
        }
        
        // Luego posicionamos a los DEMÁS invitados
        with(oOtherPlayer) {
            if (!isHost && _next_free_slot < 8) {
                global.slot_nombres[_next_free_slot] = Name;
                _next_free_slot++;
            }
        }

        // ¡EL FIX!: Yo (el cliente actual) me pongo en el siguiente slot disponible
        // Esto evita que veas "NAME" o "---" en tu propio lugar
        if (_next_free_slot < 8) {
            global.slot_nombres[_next_free_slot] = global.myName;
        }
        
        if (!_host_encontrado) global.slot_nombres[0] = "Buscando lider...";
    }

    // --- 3. DIBUJAR LOS SLOTS ---
    var slot_w = 400; var slot_h = 60; var padding = 20;

    for (var i = 0; i < global.max_players_allowed; i++) {
        var mitad = global.max_players_allowed / 2;
        var es_derecha = (i >= mitad);
        var _x = es_derecha ? (gui_w / 2) + 50 : (gui_w / 2) - 450;
        var _y = 200 + ((i % mitad) * (slot_h + padding));
        
        // Color según equipo
        var color_equipo = es_derecha ? c_red : c_aqua;
        
        // Fondo del slot
        draw_set_alpha(0.4);
        draw_set_color(c_black);
        draw_roundrect_ext(_x, _y, _x + slot_w, _y + slot_h, 10, 10, false);
        
        // Borde y detalle
        draw_set_alpha(1);
        draw_set_color(color_equipo);
        draw_rectangle(_x, _y, _x + 8, _y + slot_h, false); // Barra lateral
        
        // Dibujar el nombre
        draw_set_color(c_white);
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        var nombre_final = global.slot_nombres[i];
        
        // Si el nombre es el mío, lo resaltamos un poco
        if (nombre_final == global.myName) {
            draw_set_color(c_yellow);
            draw_text(_x + 25, _y + (slot_h/2), nombre_final + " (TU)");
        } else {
            draw_text(_x + 25, _y + (slot_h/2), nombre_final);
        }
    }

    // --- 4. FOOTER / BOTONES ---
    draw_set_halign(fa_center);
    if (oBrain.AmIPseudoHost) {
        var cant = 1; with(oOtherPlayer) cant++;
        if (cant == global.max_players_allowed) {
            draw_set_color(c_yellow);
            draw_text(gui_w / 2, gui_h - 80, "SALA LLENA! PRESIONA 'S' PARA EMPEZAR");
        } else {
            draw_set_color(c_gray);
            draw_text(gui_w / 2, gui_h - 80, "ESPERANDO... (" + string(cant) + "/" + string(global.max_players_allowed) + ")");
        }
    } else {
        draw_set_color(c_white);
        draw_text(gui_w / 2, gui_h - 80, "Esperando a que el lider inicie...");
    }
}
else if (menu_state == "setup_room") {
    draw_set_font(fnt_menu);
    var cx = gui_w / 2;
    var cy = gui_h / 2;

    draw_set_color(c_aqua);
    draw_text(cx, cy - 150, "--- CONFIGURACION DE PARTIDA ---");

    for (var i = 0; i < array_length(setup_options); i++) {
        if (i == s_index) {
            draw_set_color(c_yellow);
            var txt = ">> " + setup_options[i] + " <<";
        } else {
            draw_set_color(c_white);
            var txt = setup_options[i];
        }
        draw_text(cx, cy - 50 + (i * 60), txt);
    }
    
    draw_set_color(c_gray);
    draw_text(cx, cy + 150, "Usa las flechas para cambiar opciones");
}
else if (menu_state == "offline_setup") {
    var cx = gui_w / 2;
    var cy = gui_h / 2;

    draw_set_color(c_orange);
    draw_text(cx, cy - 150, "--- ENTRENAMIENTO OFFLINE ---");

    for (var i = 0; i < array_length(offline_options); i++) {
        if (i == off_index) {
            draw_set_color(c_yellow);
            var txt = ">> " + offline_options[i] + " <<";
        } else {
            draw_set_color(c_white);
            var txt = offline_options[i];
        }
        draw_text(cx, cy - 50 + (i * 60), txt);
    }
    
    draw_set_color(c_gray);
    draw_set_font(-1); // Fuente pequeña para info
    draw_text(cx, cy + 230, "Usa las flechas para ajustar tu práctica");
}
if (menu_state == "play_selection") {
    draw_set_font(fnt_menu);
    draw_set_color(c_aqua);
    draw_text(gui_w / 2, gui_h / 2 - 120, "--- SELECT MODE ---");

    for (var i = 0; i < array_length(play_modes); i++) {
        if (i == play_index) {
            draw_set_color(c_yellow);
            var txt = ">> " + play_modes[i] + " <<";
        } else {
            draw_set_color(c_white);
            var txt = play_modes[i];
        }
        draw_text(gui_w / 2, (gui_h / 2 - 50) + (i * spacing), txt);
    }
}
if (menu_state == "profile") {
    draw_player_profile(room_width/2, room_height/2);
}
// --- DIBUJAR MENÚ DE KICK ---
if (show_kick_menu) {
    draw_set_color(c_red);
    draw_rectangle(kick_menu_x, kick_menu_y, kick_menu_x + 120, kick_menu_y + 40, false);
    draw_set_color(c_white);
    draw_rectangle(kick_menu_x, kick_menu_y, kick_menu_x + 120, kick_menu_y + 40, true);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(kick_menu_x + 60, kick_menu_y + 20, "EXPULSAR");
}

//mensajes de confirmacion
// Al final de tu evento Draw / Draw GUI
if (mensaje_alpha > 0) {
    var gui_w = display_get_gui_width(); // Consistencia total
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(fnt_large);
    
    draw_set_alpha(mensaje_alpha);
    // Sombra
    draw_set_color(c_black);
    draw_text(gui_w / 2 + 2, 100 + 2, mensaje_texto);
    
    // Texto
    draw_set_color(c_red); 
    draw_text(gui_w / 2, 100, mensaje_texto);
    
    draw_set_alpha(1);
}


