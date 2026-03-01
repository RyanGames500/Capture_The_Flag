
///////////// Save Game //////////////
if gmda_status(){
if global.delay<=0{

	// Create a ds_map with the information you want to save
	var gmd_savemap=ds_map_create();
	ds_map_add(gmd_savemap,"version",global.save_version) //We recommend to write the version to deal with future changes when loading
	ds_map_add(gmd_savemap,"x",string(obj_playertest.x)) //Save player's x-position
	ds_map_add(gmd_savemap,"y",string(obj_playertest.y)) //Save player's y-position
	ds_map_add(gmd_savemap,"money",string(global.money)) //Save money value
	ds_map_add(gmd_savemap,"Map-id",string(global.mapid)) //Save map id
	gmda_sendgamesave(gmd_savemap);  //Send data to server
	ds_map_destroy(gmd_savemap);

global.delay=40;//Make a small delay to regulate submit span
}}else{
show_message_async("Error to establish connection to server")	
}