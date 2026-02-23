// Detectar quién está arriba (1 pixel arriba)
var _lista = ds_list_create();
var _num = instance_place_list(x, y - 1, all, _lista, false);

if (_num > 0) {
    for (var i = 0; i < _num; i++) {
        var _inst = _lista[| i];
        
        // Solo empujamos si es el jugador o un enemigo
        if (_inst.object_index == oPlayer || _inst.object_index == oOtherPlayer || _inst.object_index == oPlayer_offline || _inst.object_index == oPlayer2_local) {
            with(_inst) {
                // Si no hay pared en el camino, lo movemos
                if (!place_meeting(x + other.push_speed, y, obj_wall)) {
                    x += other.push_speed;
                }
            }
        }
    }
}
ds_list_destroy(_lista);