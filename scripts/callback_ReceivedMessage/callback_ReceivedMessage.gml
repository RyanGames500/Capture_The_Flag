// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function callback_ReceivedMessage(theMessage , senderClientId){
	show_debug_message("You got a message : "+theMessage+" from "+string(senderClientId))

	
	if(theMessage == "point")	
{
		
		if instance_exists(oOtherPlayer)
			{
			if oPlayer.isDead = false 
			{
				global.kills++;
			}
		
			}
}

}