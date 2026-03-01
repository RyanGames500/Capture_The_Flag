
////////////// Get recovery code //////////////
if global.delay<=0{
	
if gmda_status(){
gmda_getRecoverycode();
}else{
show_message_async("Error to establish connection to server")	
}

global.delay=40;//Make a small delay to regulate
}