clientId = -1;
/*initially set to -1
updates later automatically as other players 
in this room are created 
DO NOT TAMPER
*/
sharedProperties = -1
entities = "{}"
//entities = {}
oldE = {}
alarm[0]=10;


/*
Room id of this instance of other player
DO NOT TAMPER
*/
roomId = -1

//add your personal variables under this line
isHost = false;
guns = [noone, noone];

weapon = {
	index: 0,
	angle: 0,
	frequency: 0
};
isDead = false;
enemyHealth = 100
state=0;
team="";
BSI = 0;
has_flag = false;
invulnerable=0;
Name = "Cargando..."; 
mySelectedPJ = 0;
isReady = false;
WSI = 0;
ammo=0;
reloading=0;
recoil_kick=0;
recoil_angle=0;
melee_active = 0;
melee_prev_net = 0;
hit_bloqueo_timer = 0;
hit_eco = 0;          // ventana para no repetir el golpe que llega tarde por la red
hit_eco_visto = false;
thisPlayerTeam="";
has_shield = false;
max_health = enemyHealth;
enemyHealth_net = enemyHealth;
pred_dmg   = 0;
pred_base  = 0;
pred_timer = 0;
TAG="";
// Cuando aparece un jugador nuevo en mi pantalla...
if (global.ONLINE) {
    SendEventToClient(clientId, "sync_lobby_name", { 
        nombre: global.myName, // Cambiado de 'name' a 'nombre'
        team: scr_my_team()
    });
}

alarm[1] = 2;

// Predicción de empuje (scr_predict_push)
net_x = x;
net_y = y;
pp_start_x = 0;
pp_start_y = 0;
pp_dx = 0;
pp_dy = 0;
pp_h = 0;
pp_vy = 0;
pp_off_x = 0;
pp_off_y = 0;
pp_timer = 0;
pp_seen_up = false;
lobby_team = "";   // equipo que me avisó en la selección (sync_lobby_name)
last_sp_time = current_time;   // último dato que llegó de este jugador
// Habilidad que manda por la red (scr_personajes)
hab_co = false;
hab_da = false;
hab_gf = 0;
hab_gx = 0;
hab_gy = 0;
