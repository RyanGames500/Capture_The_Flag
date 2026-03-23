if (!instance_exists(owner)) { instance_destroy(); exit; }

// Seguir al dueño (usando tu offset de y-13)
x_base = owner.x;
y_base = owner.y - 13;
image_angle = owner.weapon.angle;

// Lógica de estiramiento
distancia += velocidad * estado;

if (distancia >= distancia_max) estado = -1; // Empezar a regresar
if (distancia <= 0 && estado == -1) instance_destroy(); // Se borra al volver

// Posición del puño
x = x_base + lengthdir_x(distancia, image_angle);
y = y_base + lengthdir_y(distancia, image_angle);

// --- COLISIÓN DENTRO DEL STEP DE oPunch_offline ---
var rival = instance_place(x, y, oPlayer2_local); 

if (rival != noone && ds_list_find_index(hit_list, rival) == -1) {
    
    // Cambiamos 'rival.owner_team' por 'rival.team' que es la que usa tu bot
    if (rival.team != global.myTeam) {
        
        rival.hp -= damage;
        
        // --- EL TRUCO DEL EMPUJE ---
        // Usamos push_h que tu bot ya maneja al final de su Step
        rival.push_h = lengthdir_x(25, image_angle); // Subí a 25 para que se note el viaje
        rival.vsp = -7; // Un poco más de altura para que despegue bien
        
        rival.state = PLAYER2.HIT;
        rival.hit_bloqueo_timer = 20; // Más tiempo de bloqueo para que no camine de inmediato

        // --- SOLTAR BANDERA (COMPLETO) ---
        if (rival.has_flag) {
            rival.has_flag = false;
            
            // Buscamos la bandera que tenga este dueño y la soltamos físicamente
            with(oFlag) { 
                if (portador_instancia == rival.id) { 
                    has_flag = false; 
                    portador_instancia = noone; 
                    vsp = -5; 
                    hsp = rival.push_h * 0.5; // La bandera sale volando un poco también
                } 
            }
            with(oFlag2) { 
                if (portador_instancia == rival.id) { 
                    has_flag = false; 
                    portador_instancia = noone; 
                    vsp = -5; 
                    hsp = rival.push_h * 0.5;
                } 
            }
        }
        
        if (global.sfx) audio_play_sound(snd_hit, 10, false);
        scrCamShake(6);
        ds_list_add(hit_list, rival);
        estado = -1; 
    }
}
// ======================================================
//  COLISIÓN CON PAREDES (PARA REBOTAR)
// ======================================================
if (place_meeting(x, y, obj_wall)) {
    if (estado == 1) { // Si iba hacia adelante...
        estado = -1;   // ...que rebote y regrese
        if (global.sfx) audio_play_sound(snd_empy, 10, false, 0.5);
    }
}