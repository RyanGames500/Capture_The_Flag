function host_spawn_powerup(_x, _y) {
    var _uid = "pw_" + string(date_current_datetime()) + string(irandom(999));
    var _tipo = (irandom(1) == 0) ? "salud" : "velocidad";

    // 1. Crear en el Host
    var inst = instance_create_layer(_x, _y, "Instances", oPowerUp);
    inst.net_uid = _uid;
    inst.tipo = _tipo;

    // 2. Avisar al Cliente
    if (instance_exists(oOtherPlayer)) {
        SendEventToClient(oOtherPlayer.clientId, "spawn_powerup", {
            uid: _uid,
            x: _x,
            y: _y,
            tipo: _tipo
        });
    }
}