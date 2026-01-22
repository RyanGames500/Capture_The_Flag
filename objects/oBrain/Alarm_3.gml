/// @description salir al menu principal
if (global.ONLINE) {
    DisconnectFromServer(); 
    // Recuerda que tu callback_DisconnectFromServer ya tiene el room_goto(rm_menu)
} else {
    global.game_over = false;
    room_goto(rm_menu);
}