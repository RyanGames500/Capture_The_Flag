/// @func scrFindSpawnPosTopBottom(_tries, _margin, _pad)
/// @desc Busca una posición aleatoria arriba o abajo de la room, evitando obj_wall.
/// @param _tries  Intentos máximos
/// @param _margin Margen de bordes
/// @param _pad    "colchón" para no spawn encima del wall (radio aprox)

function scrFindSpawnPosTopBottom(_tries, _margin, _pad)
{
    var rw = room_width;
    var rh = room_height;

    for (var i = 0; i < _tries; i++)
    {
        var xx = irandom_range(_margin, rw - _margin);

        // escoger arriba (0) o abajo (1)
        var top = (irandom(1) == 0);

        var yMin, yMax;
        if (top)
        {
            yMin = _margin;
            yMax = floor(rh * 0.25);
        }
        else
        {
            yMin = floor(rh * 0.75);
            yMax = rh - _margin;
        }

        var yy = irandom_range(yMin, yMax);

        // 1) no encima de pared
        if (place_meeting(xx, yy, obj_wall)) continue;

        // 2) pequeño “radio” de seguridad alrededor
        if (collision_circle(xx, yy, _pad, obj_wall, true, false) != noone) continue;

        // 3) opcional: que haya “suelo” cerca abajo (para que no quede flotando)
        // si tus walls son piso/tiles, esto ayuda:
        // if (!place_meeting(xx, yy + 8, obj_wall)) continue;
		// evita spawnear encima de otros pickups (arma o ammo)
		if (collision_circle(xx, yy, 32, oGun, true, false) != noone) continue;
		if (collision_circle(xx, yy, 32, oAmmoPack, true, false) != noone) continue;

        return { x: xx, y: yy };
    }

    // fallback: si no encontró, devuelve centro (pero te avisa)
    show_debug_message("scrFindSpawnPosTopBottom: no encontró spot válido");
    return { x: rw*0.5, y: rh*0.5 };
}
