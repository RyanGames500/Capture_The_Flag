
///////////// Refresh Information //////////////
if gmda_status(){
if global.delay<=0{
gmda_reloadinfo(); //Reload leaderboards information
gmda_refreshDate(); // Refresh Current server date
global.delay=40;//Make a small delay to regulate submit span
}}else{
show_message_async("Error to establish connection to server")	
}