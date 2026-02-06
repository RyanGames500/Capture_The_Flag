if (global.ONLINE) {
    // Le pedimos permiso al Host para recogerlo
    SendEventToClient(0, "request_powerup", { uid: net_uid, tipo: tipo });
} else {
    // Modo Offline
    scr_apply_powerup(tipo, amount);
    instance_destroy();
}