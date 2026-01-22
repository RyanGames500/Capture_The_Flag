// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function callback_ConnectToServer(){
//This function is called after a successfull connection
//You can edit this function to do anything...
	
	show_message("You connected as client with id "+ string(global.clientId)+" at time "+string(current_time)+
	". I am sending you to room public. "+
	"You can edit this message sequence in the Callback Functions Folder")
	
	//ChangeRoom("public");
	global.ONLINE=true;

}