
////////////// Recovering session //////////////
if global.delay<=0{
	
if gmda_status(){
gmda_getSession(global.recovercode); //Recover session using the code
gmda_reloadinfo(); //Reload leaderboards information
}else{
show_message_async("Error to establish connection to server")	
}



global.delay=40;//Make a small delay to regulate
}