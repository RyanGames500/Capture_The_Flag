if (other.taken || !other.visible) exit;

// 1. Predicción local inmediata (Para que el jugador no sienta lag)
if (other.tipo == "speed") { speed_timer = other.duration; walksp_mult = 1.5; } 
else if (other.tipo == "heal") { health = min(100, health + other.amount); }

var _obj = (other.tipo == "heal") ? oHealFX : oSpeedFX;
repeat(8) { instance_create_layer(x + random_range(-20, 20), y + random_range(-10, 10), "Instances", _obj); }

// 2. MARCAR PERO NO DESTRUIR TODAVÍA
other.taken = true;
other.visible = false; 

if (global.ONLINE) {
    if (oBrain.AmIPseudoHost) {
        // --- SOY HOST ---
        var _uid = other.net_uid;
        var _tipo = other.tipo;
        with(oOtherPlayer) {
            SendEventToClient(clientId, "powerup_taken", { uid: _uid });
            SendEventToClient(clientId, "powerup_fx", { tipo: _tipo, targetId: global.clientId });
        }
        scr_release_spawn_point(other.x, other.y); 
        instance_destroy(other); // El Host sí puede destruirlo
    } else {
        // --- SOY CLIENTE ---
        var _targetHost = -1;
        with(oOtherPlayer) { if (variable_instance_exists(id, "isHost") && isHost) _targetHost = clientId; }
        if (_targetHost == -1 && instance_exists(oOtherPlayer)) { _targetHost = instance_find(oOtherPlayer, 0).clientId; }
        
        if (_targetHost != -1) {
            SendEventToClient(_targetHost, "request_powerup", { uid: other.net_uid });
        }
        // 🔥 EL CAMBIO: No pongas instance_destroy(other) aquí. 
        // El objeto ya es invisible y tiene 'taken = true', deja que el 
        // mensaje de confirmación del Host lo borre luego o se quede así.
    }
} else { 
    instance_destroy(other); 
}