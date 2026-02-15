// EVENTO COLISIÓN CON oPowerupPickup
if (other.taken || !other.visible) exit;

// 1. Predicción local inmediata (Para que el jugador no sienta lag)
if (other.tipo == "speed") { 
    speed_timer = other.duration; 
    walksp_mult = 1.5; 
} 
else if (other.tipo == "heal") { 
    health = min(100, health + other.amount); 
}

// Efectos visuales locales
var _obj = (other.tipo == "heal") ? oHealFX : oSpeedFX;
repeat(8) { 
    instance_create_layer(x + random_range(-20, 20), y + random_range(-10, 10), "Instances", _obj); 
}

// 2. MARCAR LOCALMENTE PARA QUE NO SE REPITA
other.taken = true;
other.visible = false; 

if (global.ONLINE) {
    if (oBrain.AmIPseudoHost) {
        // ==========================================
        // --- AQUÍ VA EL BLOQUE QUE TE DI ANTES ---
        // ==========================================
        var _uid = other.net_uid;
        var _tipo = other.tipo;
        
        // El Host le avisa a TODOS los clientes que borren el item
        with(oOtherPlayer) {
            SendEventToClient(clientId, "powerup_taken", { uid: _uid });
            SendEventToClient(clientId, "powerup_fx", { tipo: _tipo, targetId: global.clientId });
        }
        
        scr_release_spawn_point(other.x, other.y); 
        instance_destroy(other); // El Host lo borra físicamente
        // ==========================================
    } 
    else {
        // --- SOY CLIENTE ---
        var _targetHost = -1;
        with(oOtherPlayer) { if (variable_instance_exists(id, "isHost") && isHost) _targetHost = clientId; }
        if (_targetHost == -1 && instance_exists(oOtherPlayer)) { _targetHost = instance_find(oOtherPlayer, 0).clientId; }
        
        if (_targetHost != -1) {
            SendEventToClient(_targetHost, "request_powerup", { uid: other.net_uid });
        }
    }
} else {
    // Si juegas solo (Offline)
    instance_destroy(other);
}