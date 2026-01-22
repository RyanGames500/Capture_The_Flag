/// @description Creates the Brain. Do Not Tamper!

global.ONLINE=false;
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
ConnectToServer();

