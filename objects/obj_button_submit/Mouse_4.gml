
if global.delay<=0{

// Submit Score and extra information
if gmda_status(){
gmda_submit(1,global.xscore,global.information1,global.information2,global.information3);
}else{
show_message_async("Error to establish connection to server")	
}


global.delay=40;//Make a small delay to regulate submit span

}