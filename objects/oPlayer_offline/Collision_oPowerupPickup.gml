// other = oPowerupPickup

// 1. FILTROS DE SEGURIDAD
if (other.taken || !other.visible) exit;
other.taken = true; // Marcamos de una vez para evitar doble colisión

// 2. APLICAR EFECTO AL INSTANTE
switch (other.tipo) {
    case "speed":
        speed_timer = other.duration; 
        walksp_mult = 1.5; 
        break;
        
    case "heal":
        // Usamos hp o la variable que tengas para la vida del player
        health = min(100, health + other.amount); 
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

// 3. EFECTOS VISUALES Y SONIDO
var _obj = (other.tipo == "heal") ? oHealFX : oSpeedFX;

repeat(8) { 
    instance_create_layer(x + random_range(-20, 20), y + random_range(-10, 10), "Instances", _obj); 
}

//if (global.sfx) audio_play_sound(snd_powerup, 10, false);

// 4. LIMPIEZA DE SPAWN (Si usas el sistema de oSpawnPoint)
if (variable_instance_exists(other, "spawn_id")) {
    var _sid = other.spawn_id;
    with(oSpawnPoint) {
        if (myID == _sid) {
            ocupado = false;
            cooldown = 600; // Los powerups suelen tardar más en salir (10 seg)
        }
    }
}

// 5. DESTRUCCIÓN INMEDIATA
instance_destroy(other);

// Dentro de la colisión del player con el item:
if (variable_instance_exists(other, "spawn_id") && instance_exists(other.spawn_id)) {
    other.spawn_id.ocupado = false;
    other.spawn_id.timer = other.spawn_id.cooldown_max;
}
instance_destroy(other);