// Si ya fue tomado o no es visible, ignorar
if (taken || !visible) exit;

if (global.ONLINE) {
    // Pedimos permiso al HOST (ID 0) igual que la munición
    SendEventToClient(0, "request_powerup", { uid: net_uid, tipo: tipo });
    
    // Lo "desactivamos" localmente para que no se manden mil peticiones
    taken = true;
    visible = false;
} else {
    // Modo local
    scr_apply_powerup(tipo, 20);
    instance_destroy();
}