/// scrAddAlert(_text, _col)
function scrAddAlert(_text, _col)
{
    // En línea sale como tarjeta (scr_feedback, avisos chicos). En local, como siempre.
    if (variable_global_exists("ONLINE") && global.ONLINE && room != rm_menu) {
        fb_toast(_text, "Arma fuerte disponible", _col, "arma");
        exit;
    }

    if (!instance_exists(oBrain)) exit;

    with (oBrain)
    {
        var a = {
            text: _text,
            col:  _col,
            t:    0,   // contador
            a:    0,   // alpha
            yoff: -18  // offset para entrada
        };

        // mete arriba
        array_insert(alerts, 0, a);

        // límite para que no se acumulen
        if (array_length(alerts) > 4) array_resize(alerts, 4);
    }
}
