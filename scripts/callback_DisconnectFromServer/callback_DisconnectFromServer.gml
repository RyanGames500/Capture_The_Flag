// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function callback_DisconnectFromServer(){
//called after you have successfully disconnected from
//your server (volunarily after calling the main function)

	//this part is just to destroy any other players and their entities
	with(oOtherPlayer){
		instance_destroy(id)
	}
	with(oOtherPlayersEntity){
		instance_destroy(id)
	}


	//edit ths code to do whatever you want
	//show_message("You have successfully disconnected. (Most likely because you were killed)");
	global.ONLINE=false;

}