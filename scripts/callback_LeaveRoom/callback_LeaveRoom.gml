// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function callback_LeaveRoom(){
//called after you have left a room
//you are back to your private room now 

	//show_message("back to my private room");

// 1. Limpiamos las variables para la próxima partida
    global.game_over = false;
    global.puntos_rojo = 0;
    global.puntos_azul = 0;
    global.winner_team = 0;
    oBrain.ammo_spawned=false;
	oBrain.weapons_spawned=false;
    // 2. Quitamos el mensaje de "back to my private room" para que no moleste
    show_debug_message("Regresé a mi sala privada con éxito.");

    // 3. Volvemos al menú principal
    room_goto(rm_menu);
}