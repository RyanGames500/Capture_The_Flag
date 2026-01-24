if (room != rm_game) exit;

// 1) Movimiento local SOLO del host (la “verdad”)
if (global.ONLINE && oBrain.AmIPseudoHost)
{
    // ejemplo: izquierda-derecha
    x = base_x + amp * sin(current_time * spd);
    // si quieres arriba-abajo:
    // y = base_y + amp * sin(current_time * spd);
}

// 2) Todos (incluye host) leen el persistent object para sincronizar
//    PERO solo el cliente (no host) lo aplica. El host ya es autoritario.
if (global.ONLINE && !oBrain.AmIPseudoHost)
{
    var got = false;
    var rx = x;
    var ry = y;

    with (oPersistentObject)
    {
        try {
            var pOp = json_parse(persistentObjectProperties);
            if (pOp._type == "moving_platform")
            {
                rx = pOp._x;
                ry = pOp._y;
                got = true;
                break;
            }
        } catch(e) {}
    }

    if (got)
    {
        // suavizado para que no “teletransporte”
        x = lerp(x, rx, 0.35);
        y = lerp(y, ry, 0.35);
    }
}
