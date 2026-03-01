
////////////// Set a new name //////////////
if global.delay<=0{
	
if gmda_status(){
gmda_setNewname(global.setname);
gmda_reloadinfo(); //Reload leaderboards information
}else{
show_message_async("Error to establish connection to server")	
}



global.delay=40;//Make a small delay to regulate
}