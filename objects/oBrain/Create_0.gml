/// @description Creates the Brain. Do Not Tamper!
kill_feed = [];      // array de mensajes
kill_feed_max = 5;   // máximo en pantalla


#region // --- PRESETS DE ARMAS ---
weapon_struct_pistola = {
    sprite: spr_gun,
    object: oGun,
    subimage: 0,
    ammo: 10,//10
    maxAmmo: 10,//10
    frequency: room_speed / 2,
    type2: "gun",
	damage: 10,
	
	ammoType:"gun",
	clipSize:30,
	reloadTime: room_speed * 1.2
};

weapon_struct_escopeta = {
    sprite: spr_escopeta,
    object: oGun,
    subimage: 0,
    ammo: 6,//6
    maxAmmo: 6,//6
    frequency: room_speed / 1.2,
    type2: "escop",
	damage: 8,
	pellets: 7,
	
    ammoType:"escop",
    clipSize:30,
    reloadTime: room_speed * 1.2
};

weapon_struct_smg = {
    sprite: spr_smg,
    object: oGun,
    subimage: 0,
    ammo: 30,//30
    maxAmmo: 30,//30
    frequency: room_speed / 8,
    type2: "smg",
	damage: 12,
	
    ammoType:"smg",
    clipSize:30,
    reloadTime: room_speed * 1.2,
};

#endregion


global.ONLINE=false;
weapons_spawned = false;
ammo_spawned = false;

connect = -10
non_blocking_success_yet = false
entitiesCreated = 0;
entitiesActive= []
waitingForURL = false
alarm[0]=5
alarm[1]=5
afk =0;
last_got_ping = current_time
global.clientId = -1

global.ping = -1
global.sharedProperties = {
	//Add stuff and update this struct always


}

oBrain.AmIPseudoHost = false
sent_ready = false;

pseudoHostClientId = -1
victory_alpha = 0; // Empieza invisible
global.score_blue = 0;
global.score_red = 0;
oBrain.t = 0;
global.myTeam = "";
global.puntos_azul = 0;
global.puntos_rojo = 0;
global.winner_team = 0;
global.game_over = false;
global.sfx=true;
global.music=true;

ammo_min_on_map   = 6;   // mínimo de packs que quieres siempre en el mapa
ammo_check_cd     = 0;   // cooldown de chequeo
ammo_check_every  = 60;  // cada 60 frames (1s)

weap_min_on_map   = 3;   // opcional: mínimo de armas en el mapa
weap_check_cd     = 0;
weap_check_every  = 90;  // cada 1.5s

ConnectToServer();

