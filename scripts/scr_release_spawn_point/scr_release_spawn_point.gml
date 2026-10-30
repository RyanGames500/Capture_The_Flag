function scr_release_spawn_point(_x, _y) {
    if (!oBrain.AmIPseudoHost) exit;

    var _pt = instance_nearest(_x, _y, oSpawnPoint);
    if (_pt != noone) {
        _pt.ocupado = false;
        _pt.cooldown = 600;

        // Avisar a TODOS (antes solo le avisaba a un jugador)
        var _pid = _pt.myID;
        with (oOtherPlayer) {
            SendEventToClient(clientId, "sync_spawn_point", { pID: _pid, isOcupado: false });
        }
    }
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