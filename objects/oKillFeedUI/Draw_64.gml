var n = array_length(feed);
for (var i = 0; i < n; i++)
{
    var e = feed[i];

    // ===== anim entrada =====
    e.t = min(1, e.t + 0.12);

    // ===== vida/salida =====
    e.life--;
    if (e.life <= room_speed * 0.6) // últimos 0.6s
        e.out = min(1, e.out + 0.10);

    // guardar cambios
    feed[i] = e;

    // interpolaciones (entrada desde la izquierda + fade)
    var inx = lerp(-220, 0, e.t);
    var alpha = 1 - e.out;

    // y por fila
    var yy = y_start + i * line_h;

    // texto según razón
    var text;
    if (e.reason == "crush")
    {
        // si tú eres la víctima
        if (e.victim == global.myName) text = "Moriste aplastado";
        else text = e.victim + " murió aplastado";
    }
    else
    {
        // 1v1: solo a la víctima le sale “te eliminó”
        // (si quieres que siempre diga eso cuando tú eres víctima)
        if (e.victim == global.myName)
            text = e.killer + " te eliminó";
        else
            text = e.killer + " eliminó a " + e.victim;
    }

    // colores
    var colK = scrTeamColor(e.killerTeam);
    var colV = scrTeamColor(e.victimTeam);

    // fondo
    draw_set_alpha(alpha * 0.75);
    draw_set_color(c_black);
    draw_rectangle(x_pos + inx - 6, yy - 2, x_pos + inx + 360, yy + 18, false);

    // icono arma
    var icon = scrWeaponIconSprite(e.weapon);
    draw_set_alpha(alpha);
    draw_set_color(c_white);
    draw_sprite(icon, 0, x_pos + inx + 10, yy + 8);

    // texto con colores (killer y victim)
    var tx = x_pos + inx + 28;

    // truco: dibujar el killer en color, luego resto en blanco/víctima
    // si no hay killer (crush), solo blanco
    draw_set_alpha(alpha);

    if (e.reason != "crush")
    {
        draw_set_color(colK);
        draw_text(tx, yy, e.killer);

        // calcular ancho killer para seguir
        var wK = string_width(e.killer);
        draw_set_color(c_white);
        draw_text(tx + wK + 6, yy, (e.victim == global.myName) ? "te eliminó" : "eliminó a");

        var mid = (e.victim == global.myName) ? "te eliminó" : "eliminó a";
        var wMid = string_width(mid);

        draw_set_color(colV);
        draw_text(tx + wK + 6 + wMid + 8, yy, (e.victim == global.myName) ? "" : e.victim);
    }
    else
    {
        draw_set_color(c_white);
        draw_text(tx, yy, text);
    }
}

// limpiar entradas muertas
for (var k = array_length(feed) - 1; k >= 0; k--)
{
    if (feed[k].out >= 1)
        array_delete(feed, k, 1);
}

draw_set_alpha(1);
draw_set_color(c_white);
