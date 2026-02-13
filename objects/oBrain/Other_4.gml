if (AmIPseudoHost) {

    // 1) Mover al host a la izquierda
    with (oPlayer) {
        x = 51;
        y = 400;
        latest_x = x;
        latest_y = y;
    }

    // 2) Decirle al cliente que se ponga a la derecha
    if (instance_exists(oOtherPlayer)) {
        SendEventToClient(oOtherPlayer.clientId, "init_pos_color", { x: 591, y: 400,  team: "ROJO"});
    }
}



//creacion de municion
var i = 0;
with(oSpawnPoint) {
    myID = i++; // El primer punto es 0, el segundo 1, etc.
}