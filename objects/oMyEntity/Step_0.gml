/// @description Update this entity as much as you want


/*
* Update this struct
*/
entityProperties = {
	_entityId : entityId,
	//Add stuff here like type / x / y / whatever
	_type : tipo,
	_x : x,
	_y : y,
	_A : direction,
    _IMXS : image_xscale, // Para que la bandera mire a donde mira el portador
	_SI: sprite_index,
	_IR: is_rocket

}

if (life > 0) {
    life--;
    if (life <= 0) instance_destroy();
}	
var target_enemy = instance_place(x, y, oOtherPlayer);

if (target_enemy != noone)
{
    if (target_enemy.invulnerable) exit;

    // ======================================================
    // 🔥 PREDICCIÓN VISUAL INSTANTÁNEA (Feedback Local)
    // ======================================================
with(target_enemy) 
{
    if (state != PLAYERSTATE.DEAD) 
    {
        hit_bloqueo_timer = 10; // Bloqueamos la red por 10 frames (suficiente para ver el hit)
        state = PLAYERSTATE.HIT;
        image_index = 0;
    }
}
    
	// Al morir o chocar la bala
if (variable_instance_exists(id, "is_rocket") && is_rocket) 
{
	// 1. Crear la explosión principal (un objeto con animación)
    instance_create_layer(x, y, "Instances", oExplosionFX);

    // 2. Crear varias nubes de humo volando en todas direcciones
    repeat(10) {
        var sm = instance_create_layer(x, y, "Instances", oSmokeTrail);
        sm.direction = random(360);
        sm.speed = random_range(1, 4);
        sm.fade_speed = 0.02; // El humo de la explosión dura más
    }
    
    // Sacudir cámara de todos los que estén cerca
    scrCamShake(5);

    // DAÑO EN ÁREA (Explosión)
    var explosion_radius = 64;
    
    // Chequear si el otro jugador está en el rango
    if (instance_exists(oOtherPlayer)) {
        var dist = point_distance(x, y, oOtherPlayer.x, oOtherPlayer.y);
        if (dist < explosion_radius) {
            // Entre más cerca, más daño (opcional)
            var damage_mult = 1 - (dist / explosion_radius);
            var final_dmg = damage * damage_mult;
            
            if (global.ONLINE) {
                SendEventToClient(oOtherPlayer.clientId, "hit", {
                    damage: final_dmg,
                    killer: owner_name,
                    reason: "explosion"
                });
            }
        }
    }
    
    // Daño a ti mismo (¡Cuidado con disparar de cerca!)
    var dist_me = point_distance(x, y, oPlayer.x, oPlayer.y);
    if (dist_me < explosion_radius) {
        oPlayer.health -= 20; // Daño por proximidad
    }
}
	
    // Crear sangre y sonido al momento
    //instance_create_layer(x, y, "Instances", oBloodFX);
    if (global.sfx) audio_play_sound(snd_hit, 20, false, 1.1);
    // ======================================================

    if (global.ONLINE)
    {
        if (oBrain.AmIPseudoHost)
        {
            // El Host valida el golpe y lo manda a la víctima
            SendEventToClient(target_enemy.clientId, "hit", {
                damage: damage,
                killer: global.myName,
                reason: "pvp"
            });
        }
        else
        {
            // El Cliente le pide permiso al host
            SendEventToClient(oOtherPlayer.clientId, "request_hit", {
                victimId: target_enemy.clientId,
                damage: damage,
                killer: global.myName,
                reason: "pvp"
            });
        }
    }

    instance_destroy(); // La bala desaparece
}


// Step Event de oMyEntity
if (variable_instance_exists(id, "is_rocket") && is_rocket) 
{
    // Solo creamos humo cada 2 o 3 frames para no saturar de objetos
    if (irandom(2) == 0) 
    {
        var trail = instance_create_layer(x, y, "Instances", oSmokeTrail);
        trail.color = c_gray;
    }
    
    // El misil debe rotar hacia donde vuela
    image_angle = direction;
}













