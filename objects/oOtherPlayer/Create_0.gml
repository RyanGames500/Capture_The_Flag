clientId = -1;
/*initially set to -1
updates later automatically as other players 
in this room are created 
DO NOT TAMPER
*/
sharedProperties = -1 
entities = {}
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

WSI = 0;
ammo=0;
reloading=0;
recoil_kick=0;
recoil_angle=0;
melee_active = 0;
melee_prev_net = 0;
hit_bloqueo_timer = 0;
thisPlayerTeam="";
has_shield = false;
// Cuando aparece un jugador nuevo en mi pantalla...
if (global.ONLINE) {
    SendEventToClient(clientId, "sync_lobby_name", { 
        nombre: global.myName // Cambiado de 'name' a 'nombre'
    });
}

alarm[1] = 2;