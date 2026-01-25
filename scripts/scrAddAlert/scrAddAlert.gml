/// scrAddAlert(_text, _col)
function scrAddAlert(_text, _col)
{
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
