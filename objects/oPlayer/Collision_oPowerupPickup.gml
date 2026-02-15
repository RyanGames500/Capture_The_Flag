// EVENTO COLISIÓN CON oPowerupPickup
if (other.taken || !other.visible) exit;

// 1. PREDICCIÓN LOCAL INMEDIATA
if (other.tipo == "speed") { 
    speed_timer = other.duration; 
    walksp_mult = 1.5; 
} 
else if (other.tipo == "heal") { 
    health = min(100, health + other.amount); 
}
else if (other.tipo == "shield") {
    has_shield = true;
    shield_timer = 600; 
}
else if (other.tipo == "damage") {
    damage_boost = 2;
    damage_timer = 600;
}
else if (other.tipo == "ammo") {
    infinite_ammo = true;
    ammo_timer = 600;
}

// --- EFECTOS VISUALES LOCALES ---
// Elegimos el objeto de efecto según el tipo
var _obj = oHealFX;
if (other.tipo == "speed")  _obj = oSpeedFX;
if (other.tipo == "shield") _obj = oSpeedFX;
if (other.tipo == "damage") _obj = oSpeedFX;
if (other.tipo == "ammo")   _obj = oSpeedFX;

repeat(8) { 
    instance_create_layer(x + random_range(-20, 20), y + random_range(-10, 10), "Instances", _obj); 
}

// 2. MARCAR LOCALMENTE PARA QUE NO SE REPITA
other.taken = true;
other.visible = false; 

// --- LÓGICA ONLINE ---
if (global.ONLINE) {
    if (oBrain.AmIPseudoHost) {
        // ==========================================
        // --- SOY EL HOST ---
        // ==========================================
        var _uid = other.net_uid;
        var _tipo = other.tipo;
        
        // El Host le avisa a TODOS los clientes que borren el item y activen FX
        with(oOtherPlayer) {
            SendEventToClient(clientId, "powerup_taken", { uid: _uid });
            SendEventToClient(clientId, "powerup_fx", { tipo: _tipo, targetId: global.clientId });
        }
        
        // Liberamos el punto de spawn si tienes ese sistema
        if (script_exists(scr_release_spawn_point)) {
            scr_release_spawn_point(other.x, other.y); 
        }
        
        instance_destroy(other); // El Host lo borra físicamente
        // ==========================================
    } 
    else {
        // --- SOY CLIENTE ---
        var _targetHost = -1;
        // Buscamos quién es el Host en el lobby
        with(oOtherPlayer) { 
            if (variable_instance_exists(id, "isHost") && isHost) _targetHost = clientId; 
        }
        
        // Si no encontramos al host marcado, agarramos al primer jugador que aparezca
        if (_targetHost == -1 && instance_exists(oOtherPlayer)) { 
            _targetHost = instance_find(oOtherPlayer, 0).clientId; 
        }
        
        if (_targetHost != -1) {
            // Le pedimos permiso al Host para tomarlo
            SendEventToClient(_targetHost, "request_powerup", { uid: other.net_uid });
        }
    }
} else {
    // Si juegas solo (Offline)
    instance_destroy(other);
}