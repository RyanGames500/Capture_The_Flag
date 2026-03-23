
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

draw_text(200,200,string(global.ultimo_rival_tag));

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

// --- DIBUJO DEL MENÚ PRINCIPAL ---
if (menu_state == "main") {
    draw_set_font(fnt_menu);
    draw_set_halign(fa_center);
    
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

    // EL SOBRE (Siempre visible en el Main)
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    var scale = (mx > mail_x - 30 && mx < mail_x + 30 && my > mail_y - 30 && my < mail_y + 30) ? 2.2 : 2;

    draw_sprite_ext(spr_textbox, 0, mail_x, mail_y, scale, scale, 0, c_white, 1);

    if (hay_solicitud_pendiente) {
        var wave = abs(sin(current_time / 200));
        draw_set_color(c_red);
        draw_circle(mail_x + 20, mail_y - 15, 6 + (wave * 2), false);
        draw_set_color(c_white);
    }
    draw_set_font(fnt_small);
    draw_text(mail_x, mail_y + 40, "[M] Correo");
}

// --- DIBUJO DEL ESTADO BUZÓN (Capa superior) ---
else if (menu_state == "mailbox") {
    var cx = gui_w / 2;
    var cy = gui_h / 2;

    // Fondo oscuro para que resalte el buzón
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_rectangle(0, 0, gui_w, gui_h, false);
    draw_set_alpha(1);

    // Contenido del Buzón
    draw_set_color(c_white);
    draw_set_font(fnt_menu);
    draw_text(cx, cy - 150, "--- BUZON ---");

    if (hay_solicitud_pendiente && is_struct(datos_solicitud_recibida)) {
        draw_text(cx, cy, "Solicitud de: " + string(datos_solicitud_recibida.desde_nombre));
        draw_set_color(c_yellow);
        draw_text(cx, cy + 50, "[Y] Aceptar   [N] Rechazar");
    } else {
        draw_set_color(c_gray);
        draw_text(cx, cy, "No hay mensajes nuevos.");
    }

    draw_set_color(c_white);
    draw_text(cx, cy + 150, "Presiona [ESC] para volver");
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
    
    // --- LÓGICA DE COPIAR CÓDIGO (TÍTULO) ---
    draw_set_font(fnt_menu);
    draw_set_halign(fa_center);
    
    var tx = gui_w / 2;
    var ty = 50;
    var room_text = "SALA: " + string(global.myRoomCode);
    
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    var hover_room = point_in_rectangle(mx, my, tx - 150, ty - 20, tx + 150, ty + 20);

    if (copiado_timer > 0) {
        copiado_timer--;
        draw_set_color(c_lime);
        draw_set_alpha(copiado_timer / 90);
        draw_text(tx, ty - 25, "COPIADO!");
        draw_set_alpha(1);
    } else if (hover_room) {
        draw_set_color(c_white);
        // Texto de ayuda al pasar el mouse
        draw_text_transformed(tx, ty - 25, "CLIC PARA COPIAR", 0.7, 0.7, 0);
        if (mouse_check_button_pressed(mb_left)) {
            clipboard_set_text(string(global.myRoomCode));
            copiado_timer = 90;
        }
    } else {
        draw_set_color(c_aqua);
    }
    draw_text(tx, ty, room_text);

    // --- 2. LÓGICA DE SLOTS (TU VERSIÓN REPARADA) ---
    for (var j = 0; j < 8; j++) global.slot_nombres[j] = "---";

    if (oBrain.AmIPseudoHost) {
        // --- SOY EL HOST ---
        global.slot_nombres[0] = global.myName; 
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

        with(oOtherPlayer) {
            if (isHost) {
                global.slot_nombres[0] = (Name != "" && Name != "Cargando...") ? Name : "Lider...";
                _host_encontrado = true;
            }
        }
        
        with(oOtherPlayer) {
            if (!isHost && _next_free_slot < 8) {
                global.slot_nombres[_next_free_slot] = Name;
                _next_free_slot++;
            }
        }

        // Tu Fix para el nombre local
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
        
        var color_equipo = es_derecha ? c_red : c_aqua;
        
        draw_set_alpha(0.4);
        draw_set_color(c_black);
        draw_roundrect_ext(_x, _y, _x + slot_w, _y + slot_h, 10, 10, false);
        
        draw_set_alpha(1);
        draw_set_color(color_equipo);
        draw_rectangle(_x, _y, _x + 8, _y + slot_h, false); 
        
        draw_set_color(c_white);
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        var nombre_final = global.slot_nombres[i];
        
        if (nombre_final == global.myName) {
            draw_set_color(c_yellow);
            draw_text(_x + 25, _y + (slot_h/2), string(nombre_final) /*+ " (TU)"*/);
        } else {
            draw_text(_x + 25, _y + (slot_h/2), nombre_final);
        }
    }

    // --- 4. FOOTER / BOTONES ---
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
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
	
	// --- DIBUJAR RESULTADO DE BÚSQUEDA ---
    if (estado_busqueda == "encontrado" && datos_busqueda_resultado != -1) {
        var rx = 700; // Posición a la derecha de tu perfil
        var ry = 200;
        
        draw_set_color(c_black); draw_set_alpha(0.8);
        draw_rectangle(rx-20, ry-20, rx+300, ry+250, false);
        draw_set_alpha(1); draw_set_color(c_white);
        
        draw_text(rx, ry, "JUGADOR ENCONTRADO:");
        draw_text(rx, ry+40, "Nombre: " + string(datos_busqueda_resultado.nombre));
        draw_text(rx, ry+70, "Copas: " + string(datos_busqueda_resultado.copas));
        draw_text(rx, ry+100, "Rango: " + string(datos_busqueda_resultado.rank));
        draw_text(rx, ry+130, "Kills: " + string(datos_busqueda_resultado.kills));
        
        draw_text(rx, ry+180, "[ENTER] para enviar solicitud");
        draw_text(rx, ry+210, "[ESC] para cerrar");
    }
}
else if (menu_state == "achievements") {
    var cx = gui_w / 2;
    var cy = gui_h / 2;
    
    // Título de la pantalla
    draw_set_font(fnt_menu);
    draw_set_color(c_aqua);
    draw_set_halign(fa_center);
    draw_text(cx, 60, "--- ACHIEVEMENTS ---");


    var tabla_ancho = 525; // El 'horsize' que definiste en la función
    gmda_draw_achievements(cx - (tabla_ancho / 2), 150);

    // Pie de página
    draw_set_color(c_gray);
    draw_text(cx-200, gui_h - 50, "Presiona ESC o ENTER para volver");
}
else if (menu_state == "friends_menu") {
    var cx = gui_w / 2;
    var cy = gui_h / 2;

    if (friends_state == "main") {
        draw_text(cx, cy - 150, "--- FRIENDS ---");
        for (var i = 0; i < array_length(friends_options); i++) {
            draw_set_color(i == friends_index ? c_yellow : c_white);
            draw_text(cx, cy - 50 + (i * 60), (i == friends_index ? "> " : "") + friends_options[i]);
        }
    }
    
else if (friends_state == "lista") {
    var cx = gui_w / 2;
    var cy = gui_h / 2;
    
    draw_set_color(c_aqua);
    draw_set_font(fnt_menu);
    draw_text(cx, 80, "--- TUS AMIGOS ---");

    // --- LÓGICA DE SCROLL SUAVE ---
    scroll_y = lerp(scroll_y, scroll_target, 0.15);
    
    var start_y = 180 + scroll_y;
    var card_h = 80;   
    var card_w = 500;  
    var gap = 15;      

    if (array_length(global.lista_amigos) > 0) {
        for (var i = 0; i < array_length(global.lista_amigos); i++) {
            var yy = start_y + (i * (card_h + gap));
            
            // Solo dibujamos si está en pantalla
            if (yy > 100 && yy < gui_h - 100) {
                var amigo = global.lista_amigos[i];
                var es_seleccionado = (i == friend_selected);
                
                // --- SEGURIDAD: Extraer datos verificando si existen ---
                // Si 'nombre' no existe, pone "??". Si 'tag' no existe, pone "#0000"
                var _nombre = variable_struct_exists(amigo, "nombre") ? amigo.nombre : "??";
                var _tag    = variable_struct_exists(amigo, "tag")    ? amigo.tag    : "#0000";
                
                // --- FONDO DE LA TARJETA ---
                draw_set_alpha(es_seleccionado ? 0.4 : 0.2);
                draw_set_color(es_seleccionado ? c_yellow : c_black);
                draw_roundrect_ext(cx - card_w/2, yy - card_h/2, cx + card_w/2, yy + card_h/2, 15, 15, false);
                
                if (es_seleccionado) {
                    draw_set_alpha(0.8);
                    draw_roundrect_ext(cx - card_w/2, yy - card_h/2, cx + card_w/2, yy + card_h/2, 15, 15, true);
                }
                
                // --- TEXTOS ---
                draw_set_alpha(1);
                draw_set_valign(fa_middle);
                
                // Nombre
                draw_set_halign(fa_left);
                draw_set_color(c_white);
                draw_set_font(fnt_menu);
                draw_text(cx - card_w/2 + 30, yy, _nombre);

				// 1. INDICADOR DE ESTADO (Puntito Online/Offline)
// Asumimos que Rocket te devuelve 'online' (true/false)
// --- DENTRO DEL for DE LA LISTA DE AMIGOS ---
var _amigo = global.lista_amigos[i];
var _tag_amigo = _amigo.tag;

// Usamos tu función gmda_status pasando el TAG del amigo
// (Asumo que gmda_status devuelve 1 o true si está online)
var _esta_online = gmda_status(_tag_amigo); 

// Definimos el color según el resultado de tu función
var _col_estado = (_esta_online) ? c_lime : c_gray;

// Dibujamos el punto con el color real
draw_set_color(_col_estado);
draw_circle(cx - card_w/2 + 20, yy, 6, false);

// 2. NIVEL (Lo ponemos pequeño al lado del nombre)
var _lvl = variable_struct_exists(amigo, "lvl") ? amigo.lvl : 1;
draw_set_halign(fa_left);
draw_set_color(c_yellow);
draw_set_font(fnt_small);
draw_text(cx - card_w/2 + 70 + string_width(_nombre) + 10, yy, "Lv." + string(_lvl));

// 3. BOTÓN ELIMINAR (Una X roja al final de la tarjeta)
var _bx = cx + card_w/2 - 25; // Posición X del botón
draw_set_color(c_red);
draw_set_alpha(es_seleccionado ? 0.8 : 0.3); // Solo brilla si está seleccionado
draw_circle(_bx, yy, 12, false); 
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_text(_bx, yy, "X");
draw_set_alpha(1);


// --- DENTRO DEL EVENTO DRAW GUI ---

// 1. PRIMERO definimos mx y my (esto evita el error)
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

if (_esta_online) {
    var _dx = cx + card_w/2 - 110; 
    
    draw_set_color(c_red);
    draw_circle(_dx, yy, 12, false);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle); // Para que el "!" quede centrado en el círculo
    draw_text(_dx, yy, "!"); 
    
    // Tooltip si pasas el mouse
    // Ahora mx y my ya existen, por lo que no dará error
    if (point_distance(mx, my, _dx, yy) < 15) {
        draw_set_color(c_white);
        draw_set_halign(fa_left); // Reset para el texto del tooltip
        draw_text(mx + 10, my - 20, "RETAR A DUELO");
    }
}
			
                // Tag sexy
                draw_set_halign(fa_right);
                draw_set_font(fnt_small);
                draw_set_color(es_seleccionado ? c_white : c_aqua);
                draw_text(cx + card_w/2 - 40, yy, "TAG: " + string(_tag));
            }
        }
        
        // Indicadores de flechas
        draw_set_halign(fa_center);
        draw_set_color(c_gray);
        if (scroll_target < 0) draw_text(cx, 140, "▲");
        if (array_length(global.lista_amigos) > 4) draw_text(cx, gui_h - 120, "▼");
		

    } else {
        draw_set_halign(fa_center);
        draw_set_color(c_gray);
        draw_text(cx, cy, "Tu lista esta vacia.\n¡Ve a 'ADD' para buscar amigos!");
    }

    draw_set_halign(fa_center);
    draw_set_color(c_white);
    draw_set_font(fnt_small);
    //draw_text(cx, gui_h - 60, "[ESC] Volver   [FLECHAS] Navegar");
	
	// --- NUEVO: PANEL DE ACCIONES PARA EL AMIGO SELECCIONADO ---
    if (array_length(global.lista_amigos) > 0) {
        var amigo_act = global.lista_amigos[friend_selected];
        var panel_y = gui_h - 180;
        
        // Dibujamos una pequeña barra de sugerencias
        draw_set_color(c_black);
        draw_set_alpha(0.6);
        draw_rectangle(0, panel_y, gui_w, panel_y + 60, false);
        draw_set_alpha(1);
        
        draw_set_font(fnt_small);
        draw_set_halign(fa_center);
        draw_set_color(c_yellow);
        
        // Texto dinámico según lo que puede hacer el usuario
        var _txt_acciones = "[P] Ver Perfil       [FLECHAS] Navegar      [X] Eliminar Amigo      [ESC] Volver";
        draw_text(cx, panel_y + 30, _txt_acciones);
        
        // --- OPCIONAL: Dibujar Mini-Perfil si se pulsa una tecla (Pre-visualización) ---
        if (keyboard_check(vk_control)) { // Si mantiene CTRL, mostramos el ID largo
             draw_set_color(c_white);
             draw_text(cx, panel_y - 20, "ID: " + string(amigo_act.id_largo));
        }
    }
	
}
else if (friends_state == "anadir") {
    draw_set_color(c_aqua);
    draw_text(cx, cy - 220, "ESCRIBE EL ID DEL JUGADOR:");
    
    // Cuadro de búsqueda
    draw_set_color(input_activo ? c_white : c_dkgray);
    draw_rectangle(cx - 250, cy - 180, cx + 250, cy - 120, false);
    
    draw_set_color(c_black);
    var cursor = (input_activo && (current_time mod 1000 < 500)) ? "|" : "";
    draw_text(cx, cy - 150, friends_search_input + cursor);

    // --- MANEJO INDEPENDIENTE DE ESTADOS ---
    
    // 1. CARGA
    var es_buscando = (estado_busqueda == "buscando" || estado_busqueda == "buscando_nombre" || estado_busqueda == "buscando_perfil_final");
    if (es_buscando) {
        draw_set_color(c_yellow);
        draw_text(cx, cy, "Buscando en la base de datos...");
    }
    
    // 2. ÉXITO (Solo si NO está buscando ya)
    if (estado_busqueda == "encontrado" && datos_busqueda_resultado != -1) {
        draw_set_color(c_lime);
        draw_text(cx, cy - 20, "JUGADOR ENCONTRADO!");
        draw_set_color(c_white);
        draw_text(cx, cy + 30, "Nombre: " + string(datos_busqueda_resultado.nombre));
        draw_text(cx, cy + 60, "Copas: " + string(datos_busqueda_resultado.copas));
        draw_set_color(c_yellow);
        draw_text(cx, cy + 120, "Presiona [F] para enviar solicitud");
		
    }
    
    // 3. ERROR (Prioridad absoluta si el estado es error)
    if (estado_busqueda == "error") {
        draw_set_color(c_red);
        // Aquí mostramos el mensaje_texto que viene del callback para ser exactos
        draw_text(cx, cy, string(mensaje_texto)); 
    }
    
    draw_set_color(c_gray);
    draw_text(cx, gui_h - 50, "ESC para volver");
}	
else if (friends_state == "perfil_amigo") 
{
    var cx = gui_w / 2;
    var cy = gui_h / 2;

    // Fondo estético
    draw_set_color(c_black); draw_set_alpha(0.85);
    draw_rectangle(0, 0, gui_w, gui_h, false);
    draw_set_alpha(1);


    if (estado_busqueda == "buscando") {
        draw_set_color(c_white);
        draw_text(cx, cy, "Obteniendo datos...");
    } 
    else if (estado_busqueda == "encontrado" && is_struct(datos_busqueda_resultado)) {
        
        // --- EXTRACCIÓN DE DATOS (Basado en tu scr_sincronizar_nube) ---
        var _n = datos_busqueda_resultado.nombre;
        var _t = datos_busqueda_resultado.friend_tag;
        var _l = datos_busqueda_resultado.lvl;
        var _c = datos_busqueda_resultado.copas;
        var _k = datos_busqueda_resultado.kills;
        var _w = datos_busqueda_resultado.wins;
        var _f = datos_busqueda_resultado.flags; // Se llama 'flags' en tu struct

        // --- DIBUJO DE CABECERA ---
        draw_set_color(c_aqua);
        draw_text_transformed(cx, cy - 200, "PERFIL DE JUGADOR", 1.2, 1.2, 0);
        
        draw_set_color(c_white);
        draw_set_font(fnt_menu);
        draw_text(cx, cy - 140, string(_n)); // Nombre grande
        
        draw_set_font(fnt_small);
        draw_set_color(c_yellow);
        draw_text(cx, cy - 100, "TAG: " + string(_t));

        // --- DIBUJO DE STATS (TABLA) ---
        draw_set_halign(fa_left);
        var gx = cx - 150; // Guía izquierda para las stats
        
        draw_set_color(c_white);
        draw_text(gx, cy - 20, "NIVEL: " + string(_l));
        draw_text(gx, cy + 10, "COPAS: " + string(_c));
        draw_text(gx, cy + 40, "KILLS: " + string(_k));
        draw_text(gx, cy + 70, "VICTORIAS: " + string(_w));
        draw_text(gx, cy + 100, "BANDERAS: " + string(_f));

    }

	
    draw_set_color(c_gray);
    draw_text(cx, gui_h - 60, "[ESC] VOLVER A LA LISTA");
}
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



if (mostrando_reto) {
    draw_emergency_challenge(display_get_gui_width()/2, display_get_gui_height()/2);
}

if menu_state == "main"
{
// --- CONFIGURACIÓN DEL CUADRO ---
var cuadro_x = 50;           // Posición X en la pantalla
var cuadro_y = 250;          // Posición Y
var cuadro_ancho = 300;      // Ancho del cuadro
var cuadro_alto = 280;       // Alto del cuadro
var padding = 20;            // Espacio interno del texto
var color_verde = make_color_rgb(170, 255, 0); // Verde neón de tu imagen

// 1. DIBUJAR EL FONDO (Semi-transparente)
draw_set_alpha(0.2);
draw_set_color(c_black);
draw_roundrect(cuadro_x, cuadro_y, cuadro_x + cuadro_ancho, cuadro_y + cuadro_alto, false);

// 2. DIBUJAR EL BORDE GRUESO
draw_set_alpha(1);
draw_set_color(color_verde);
draw_line_width(cuadro_x, cuadro_y, cuadro_x + cuadro_ancho, cuadro_y, 4); // Arriba
draw_line_width(cuadro_x, cuadro_y + cuadro_alto, cuadro_x + cuadro_ancho, cuadro_y + cuadro_alto, 4); // Abajo
draw_line_width(cuadro_x, cuadro_y, cuadro_x, cuadro_y + cuadro_alto, 4); // Izquierda
draw_line_width(cuadro_x + cuadro_ancho, cuadro_y, cuadro_x + cuadro_ancho, cuadro_y + cuadro_alto, 4); // Derecha

// 3. DIBUJAR EL TÍTULO "CONTROLS"
draw_set_font(fnt_large); // Cambia por tu fuente de títulos
draw_set_halign(fa_left);
draw_text_transformed(cuadro_x + padding, cuadro_y + padding, "controls", 1.5, 1.5, 0);

// 4. DIBUJAR LA LISTA DE CONTROLES
draw_set_font(fnt_small); // Tu fuente de texto normal
var texto_y = cuadro_y + 80;
var interlineado = 30;

draw_text(cuadro_x + padding, texto_y, "A, D - MOVE");
draw_text(cuadro_x + padding, texto_y + interlineado, "W - JUMP");
draw_text(cuadro_x + padding, texto_y + (interlineado * 2), "MOUSE - AIM");
draw_text(cuadro_x + padding, texto_y + (interlineado * 3), "L-CLICK - FIRE");
draw_text(cuadro_x + padding, texto_y + (interlineado * 4), "R-CLICK - GRENADE / MELEE");

// 5. ICONO DE TECLADO/MOUSE (Opcional - Dibujar un sprite si tienes uno)
// draw_sprite_ext(spr_icon_controls, 0, cuadro_x + 240, cuadro_y + 110, 1, 1, 0, color_verde, 1);

// Resetear ajustes de dibujo para no afectar a otros elementos
draw_set_color(c_white);
draw_set_alpha(1);
}