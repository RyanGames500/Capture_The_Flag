function scr_release_spawn_point(_x, _y) {
    // Solo el Host ejecuta esto
    if (!oBrain.AmIPseudoHost) exit;

    var _pt = instance_nearest(_x, _y, oSpawnPoint);
    if (_pt != noone) {
        _pt.ocupado = false;
        _pt.cooldown = 600; // Aquí empieza el conteo real en el Host
        
        // Avisar al cliente para que visualmente sepa que el punto está libre
        if (instance_exists(oOtherPlayer)) {
            SendEventToClient(oOtherPlayer.clientId, "sync_spawn_point", { 
                pID: _pt.myID, 
                isOcupado: false 
            });
        }
    }
}