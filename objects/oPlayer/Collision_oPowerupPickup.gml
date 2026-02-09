/// @description Colisión oPlayer con oPowerupPickup

// 1. Si soy el HOST: Lo aplico directo y aviso que se borre
if (oBrain.AmIPseudoHost) 
{
    // Aplicar efecto localmente al Host
    switch (other.tipo) {
        case "speed":
            speed_timer = other.duration;
            walksp_mult = 1.5;
		repeat(8) {
		    var _offset_x = random_range(-20, 20);
		    var _offset_y = random_range(-10, 10);
		    instance_create_layer(x + _offset_x, y + _offset_y, "Instances", oSpeedFX);
		}
        break;
        case "heal":
            health = min(100, health + other.amount);
			// 2. La ráfaga de cruces
			repeat(8) {
			    var _offset_x = random_range(-20, 20);
			    var _offset_y = random_range(-10, 10);
			    instance_create_layer(x + _offset_x, y + _offset_y, "Instances", oHealFX);
			}
        break;
    }

    // Avisar al cliente que el Host ya lo tomó para que lo borre de su pantalla
    if (instance_exists(oOtherPlayer)) {
        SendEventToClient(oOtherPlayer.clientId, "powerup_taken", { uid: other.net_uid });
    }

    // Liberar spawn
    scr_release_spawn_point(other.x, other.y); 

    instance_destroy(other);

	if (instance_exists(oOtherPlayer)) {
	    SendEventToClient(oOtherPlayer.clientId, "powerup_fx", { 
	        tipo: other.tipo, 
	        targetId: global.clientId // El Host dice: "El efecto es sobre mí"
	    });
	}
} 
// 2. SI SOY EL CLIENTE
else 
{
    if (other.visible && !other.taken) 
    {
        // --- PREDICCIÓN (Activar de inmediato localmente) ---
        if (other.tipo == "speed") {
            speed_timer = other.duration;
            walksp_mult = 1.5;		
			repeat(8) {
		    var _offset_x = random_range(-20, 20);
		    var _offset_y = random_range(-10, 10);
		    instance_create_layer(x + _offset_x, y + _offset_y, "Instances", oSpeedFX);
		}
        } else if (other.tipo == "heal") {
		repeat(8) {
		    var _offset_x = random_range(-20, 20);
		    var _offset_y = random_range(-10, 10);
		    instance_create_layer(x + _offset_x, y + _offset_y, "Instances", oHealFX);
		}
            health = min(100, health + other.amount);
        }
        
        // --- FEEDBACK VISUAL INMEDIATO ---
        other.visible = false; 
        other.taken = true; 

        // --- ENVIAR AL HOST ---
if (instance_exists(oOtherPlayer)) {
        SendEventToClient(oOtherPlayer.clientId, "request_powerup", { 
            uid: other.net_uid,
            already_applied: true,
            fx_done: true // <--- AÑADE ESTO
        });
        }
    }
}