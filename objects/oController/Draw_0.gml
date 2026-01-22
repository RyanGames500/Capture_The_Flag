draw_set_color(c_white)

if( string_count("auto_matchmake", global.roomId) ){
	draw_text(100,100,"Matchmaking ... Waiting ")

}


if( string_count("auto_match_", global.roomId) ){
	draw_text(100,100,"Welcome to match  ... "+ global.roomId)

}

try{
	if( global.roomId != -1 and real(global.roomId) == real(global.clientId) ){
		draw_text(100,100,"Welcome! Press M to join lobby..")

	}
}catch(e){}

if(keyboard_check_pressed(ord("M"))){
	ChangeRoom("auto_matchmake_3")
}