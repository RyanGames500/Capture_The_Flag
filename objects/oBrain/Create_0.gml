/// @description Creates the Brain. Do Not Tamper!
kill_feed = [];      // array de mensajes
kill_feed_max = 5;   // máximo en pantalla

kf_in  = 10;   // frames entrada
kf_hold= 90;   // frames visible
kf_out = 12;   // frames salida


// ===== ALERTAS (HUD) =====
alerts = array_create(0);

// config (ajusta a gusto)
alert_in_frames  = 10;  // entrada
alert_hold_frames = 70; // tiempo en pantalla
alert_out_frames = 12;  // salida


#region // --- PRESETS DE ARMAS ---
weapon_struct_pistola = {
	sprite_suelo: spr_gun,
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
	sprite_suelo: spr_escopeta,
    sprite: spr_escopeta,
    object: oGun,
    subimage: 0,
    ammo: 6,//6
    maxAmmo: 6,//6
    frequency: room_speed / 1.2,
    type2: "escop",
	damage: 16,
	pellets: 7,
	
    ammoType:"escop",
    clipSize:30,
    reloadTime: room_speed * 1.2
};

weapon_struct_smg = {
	sprite_suelo: spr_smg,
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

weapon_struct_bazooka = {
    sprite_suelo: spr_bazooka, // sprite de la bazooka en el suelo
    sprite: spr_bazooka,           // sprite de la bazooka en manos
    object: oGun,
    subimage: 0,
    ammo: 1,                       // Solo 1 misil por carga
    maxAmmo: 1,
    frequency: room_speed * 1.5,   // Tarda 1.5 seg entre disparos
    type2: "bazooka",
    damage: 50,                    // Daño directo alto
    
    ammoType: "heavy",
    clipSize: 5,                   // Reserva total pequeña
    reloadTime: room_speed * 2.5   // Recarga lenta
};
#endregion

//efecto fantasma
global.EffectTrial = true;
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

