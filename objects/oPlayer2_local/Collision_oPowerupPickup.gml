// =#####################################################
// 🍎 COLISIÓN CON oPowerupPickup (VERSIÓN LOCAL)
// =#####################################################

if (other.taken || !other.visible) exit;

// 1. APLICAR EFECTOS SEGÚN EL TIPO
switch (other.tipo) 
{
    case "speed":
        speed_timer = other.duration; 
        walksp_mult = 1.5; 
        break;
        
    case "heal":
        // Si usas hp o health, asegúrate de que sea la variable correcta
        hp = min(hp_max, hp + other.amount); 
        break;
        
    case "shield":
        has_shield = true;
        shield_timer = 600; 
        break;
        
    case "damage":
        damage_boost = 2;
        damage_timer = 600;
        break;
        
    case "ammo":
        infinite_ammo = true;
        ammo_timer = 600;
        break;
}

// 2. EFECTOS VISUALES
var _obj = oHealFX;
if (other.tipo != "heal") _obj = oSpeedFX; // Si no es cura, usa el de velocidad/boost

repeat(8) { 
    instance_create_layer(x + random_range(-20, 20), y + random_range(-10, 10), "Instances", _obj); 
}

// Sonido al agarrar (Opcional)
//if (global.sfx) audio_play_sound(snd_powerup, 10, false);

// 3. FINALIZAR (Destrucción local inmediata)
other.taken = true;
instance_destroy(other);