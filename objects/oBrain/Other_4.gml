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
        SendEventToClient(oOtherPlayer.clientId, "init_pos_color", { x: 1359, y: 400,  team: "ROJO"});
    }
}



//creacion de municion
var i = 0;
with(oSpawnPoint) {
    myID = i++; // El primer punto es 0, el segundo 1, etc.
}


// 📦 Pedirle al host todo lo que hay en el mapa cuando YO ya cargué (3 veces por si el host aún cargaba)
resync_left = (global.ONLINE && room != rm_menu && !AmIPseudoHost) ? 3 : 0;
resync_cd   = 5;
