if (menu_state == "main") {
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fnt_menu); // Asegúrate de haber creado una fuente llamada fnt_menu

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var spacing = 60; // Espacio entre letras

for (var i = 0; i < array_length(menu_options); i++) {
    // Si es la opción seleccionada, la dibujamos de otro color
    if (i == index) {
        draw_set_color(c_yellow);
        var txt = "> " + menu_options[i] + " <";
    } else {
        draw_set_color(c_white);
        var txt = menu_options[i];
    }
    
    // Dibujar el texto en el centro de la pantalla
    draw_text(gui_w / 2, (gui_h / 2 - 50) + (i * spacing), txt);
}

} 
else if (menu_state == "connecting")
{
    if (string_count("auto_matchmake", string(global.roomId)))
    {
        // --- GUI dims ---
        var gui_w = display_get_gui_width();
        var gui_h = display_get_gui_height();
        var cx = gui_w * 0.5;
        var cy = gui_h * 0.5;

        // --- tiempo ---
        var t = current_time * 0.001;                 // segundos
        var pulse  = 0.5 + 0.5 * sin(t * 2.5);        // 0..1
        var pulse2 = 0.5 + 0.5 * sin(t * 1.3 + 1.2);  // 0..1

        // --- Fondo ---
        draw_set_alpha(1);
        draw_set_color(make_color_rgb(12, 14, 18));
        draw_rectangle(0, 0, gui_w, gui_h, false);

        // --- Glow central ---
        var r;
        for (r = 420; r > 0; r -= 30)
        {
            var a = (r / 420) * 0.12;
            draw_set_alpha(a);
            draw_set_color(make_color_rgb(30, 40, 60));
            draw_circle(cx, cy, r + pulse * 18, false);
        }
        draw_set_alpha(1);

        // --- Scanlines ---
        draw_set_alpha(0.08);
        draw_set_color(c_black);
        var yy;
        for (yy = 0; yy < gui_h; yy += 4)
        {
            draw_rectangle(0, yy, gui_w, yy + 1, false);
        }
        draw_set_alpha(1);

        // --- “estrellitas” ---
        draw_set_alpha(0.35);
        draw_set_color(c_white);
        var i;
        for (i = 0; i < 40; i++)
        {
            var px = (sin(i * 123.45 + t * 0.6) * 9999);
            px = px - floor(px);
            px *= gui_w;

            var py = (sin(i * 54.321 + t * 0.9) * 8888);
            py = py - floor(py);
            py *= gui_h;

            draw_rectangle(px, py, px + 2, py + 2, false);
        }
        draw_set_alpha(1);

        // --- Panel central (rectángulo “glass”) ---
        var panel_w = 560;
        var panel_h = 260;
        var px1 = cx - panel_w * 0.5;
        var py1 = cy - panel_h * 0.5;

        // relleno
        draw_set_alpha(0.70);
        draw_set_color(make_color_rgb(18, 22, 30));
        draw_rectangle(px1, py1, px1 + panel_w, py1 + panel_h, false);

        // borde
        draw_set_alpha(0.95);
        draw_set_color(make_color_rgb(80, 150, 255));
        draw_rectangle(px1, py1, px1 + panel_w, py1 + panel_h, true);
        draw_set_alpha(1);

        // --- Orbe + anillo ---
        var orb_r  = 46 + pulse * 6;
        var ring_r = 70 + pulse2 * 8;

        // glow
        draw_set_alpha(0.20);
        draw_set_color(make_color_rgb(80, 150, 255));
        draw_circle(cx - 170, cy - 10, ring_r + 24, false);

        // orbe
        draw_set_alpha(0.90);
        draw_set_color(make_color_rgb(120, 200, 255));
        draw_circle(cx - 170, cy - 10, orb_r, false);

        // anillo con puntos girando
        var steps = 24;
        var ang_base = (t * 120);
        var s;
        draw_set_alpha(0.90);
        for (s = 0; s < steps; s++)
        {
            var a2 = ang_base + (s * (360 / steps));
            var rx = (cx - 170) + lengthdir_x(ring_r, a2);
            var ry = (cy - 10)  + lengthdir_y(ring_r, a2);

            var dot = 2;
            if ((s mod 3) == 0) dot = 3;

            draw_set_color(make_color_rgb(80, 150, 255));
            draw_circle(rx, ry, dot, false);
        }
        draw_set_alpha(1);

        // --- Texto ---
        draw_set_font(fnt_menu);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);

        draw_set_color(c_white);
        draw_text(px1 + 210, py1 + 55, "BUSCANDO RIVAL");

        // puntos animados
        var count = (waiting_timer div 12) mod 4;
        var dots = string_repeat(".", count);

        draw_set_alpha(0.85);
        draw_set_color(make_color_rgb(190, 210, 255));
        draw_text(px1 + 210, py1 + 95, waiting_message + dots);
        draw_set_alpha(1);

        // --- Barra de progreso falsa ---
        var bar_x1 = px1 + 210;
        var bar_y1 = py1 + 145;
        var bar_w = 300;
        var bar_h = 12;

        draw_set_alpha(0.60);
        draw_set_color(make_color_rgb(10, 12, 16));
        draw_rectangle(bar_x1, bar_y1, bar_x1 + bar_w, bar_y1 + bar_h, false);

        // progreso loop 0..1
        var p = (t * 0.35);
        p = p - floor(p);

        var fill = bar_w * (0.15 + p * 0.85);

        draw_set_alpha(0.95);
        draw_set_color(make_color_rgb(80, 150, 255));
        draw_rectangle(bar_x1, bar_y1, bar_x1 + fill, bar_y1 + bar_h, false);
        draw_set_alpha(1);

        // brillo que recorre
        var shine = (t * 0.9);
        shine = shine - floor(shine);
        var shine_x = bar_x1 + (bar_w * shine);

        draw_set_alpha(0.22);
        draw_set_color(c_white);
        draw_rectangle(shine_x, bar_y1 - 2, shine_x + 30, bar_y1 + bar_h + 2, false);
        draw_set_alpha(1);

        // --- Tips rotativos ---
        var tips = [
            "Tip: mata al portador para dropear la bandera.",
            "Tip: defiende tu base cuando tu bandera esté fuera.",
            "Tip: el host decide, el cliente pide (menos desync).",
            "Tip: juega agresivo, pero no descuides tu retorno."
        ];
        var tip_i = (waiting_timer div (room_speed * 2)) mod array_length(tips);

        draw_set_alpha(0.85);
        draw_set_color(make_color_rgb(170, 180, 200));
        draw_text(px1 + 40, py1 + 210, tips[tip_i]);
        draw_set_alpha(1);

        // --- Footer ---
        draw_set_halign(fa_center);
        draw_set_color(make_color_rgb(180, 180, 180));
        draw_text(cx, py1 + panel_h + 22, "Presiona ESC para cancelar");
    }

    if (string_count("auto_match", string(global.roomId)))
    {
        var gui_w2 = display_get_gui_width();
        var gui_h2 = display_get_gui_height();

        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_font(fnt_menu);
        draw_set_color(c_white);

        draw_text(gui_w2 * 0.5, gui_h2 * 0.5,
                  "¡RIVAL ENCONTRADO!  Room: " + string(global.roomId));
    }

    try {
        if (global.roomId != -1 && real(global.roomId) == real(global.clientId)) {
            // opcional
        }
    } catch(e) {}
}
