/// Antes: liberaba el punto de spawn MÁS CERCANO a donde se agarró algo (con 10 s fijos).
/// Eso fallaba: agarrar un arma tirada por un muerto liberaba un punto que seguía lleno
/// y salían dos cosas encimadas. Ahora cada punto sabe qué puso (mi_item) y él solo se
/// libera cuando eso ya no existe (oBrain Step, sección 4), con el tiempo de su categoría.
/// Se deja la función para no romper a quien la llama (recoger munición, armas y poderes).
function scr_release_spawn_point(_x, _y) {
}

/// Manda el estado de un punto de spawn: ocupado y cuántos frames le faltan (t) para el anillo.
/// Sin _destino se lo manda a todos.
function scr_spawn_point_enviar(_pt, _destino = -1) {
    if (!instance_exists(_pt)) exit;
    var _s = { pID: _pt.myID, isOcupado: _pt.ocupado, t: _pt.cooldown, tm: _pt.cooldown_max, n: _pt.nivel };
    if (_destino != -1) { SendEventToClient(_destino, "sync_spawn_point", _s); exit; }
    with (oOtherPlayer) SendEventToClient(clientId, "sync_spawn_point", _s);
}

/// (Host nuevo a mitad de partida) Busca lo que hay encima del punto para adoptarlo.
function scr_spawn_point_item_cerca() {
    var _mejor = noone, _d = 40;
    var _objs = [oGun, oAmmoPack, oPowerupPickup];
    for (var i = 0; i < array_length(_objs); i++) {
        var _it = instance_nearest(x, y, _objs[i]);
        if (_it != noone) {
            var _dd = point_distance(x, y, _it.x, _it.y);
            if (_dd < _d) { _d = _dd; _mejor = _it; }
        }
    }
    return _mejor;
}

/// Devuelve el clientId del host REAL (el que dice el servidor).
function scr_get_host_id() {
    if (variable_instance_exists(oBrain, "pseudoHostClientId") && oBrain.pseudoHostClientId != -1) {
        return oBrain.pseudoHostClientId;
    }
    var _h = -1;
    with (oOtherPlayer) { if (variable_instance_exists(id, "isHost") && isHost) _h = clientId; }
    if (_h == -1 && instance_exists(oOtherPlayer)) _h = instance_find(oOtherPlayer, 0).clientId;
    return _h;
}