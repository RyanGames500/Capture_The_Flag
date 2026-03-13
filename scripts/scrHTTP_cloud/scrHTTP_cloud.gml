// Manage responses from server related to cloud storage data
//& code generation to recovery the session

function scrHTTP_cloud(response,valueref){
	
switch(response){
////////////////////////////// LOADING CLOUD DATA /////////////////
case gmd_resp_datareceived: /* DATA RECEIVED   */
    var gmd_load = json_decode(valueref);
    if not(gmd_load == "-1") {

        show_debug_message("Data loaded successfully");
        
        /* Here you can do whatever you want with the data recived(gmd_load - ds_map) */
        if variable_global_exists("save_version") {
            if (ds_map_exists(gmd_load, "version")) {
                var get_save_version = (ds_map_find_value(gmd_load, "version"));
                if not(get_save_version == global.save_version) {
                    show_message_async("Warning: The current version and the version saved are different");
                }
            }
			//Datos a cargar
            if (ds_map_exists(gmd_load, "name"))       { global.myName = string(ds_map_find_value(gmd_load, "name")); }
            if (ds_map_exists(gmd_load, "registrado")) { global.registrado = real(ds_map_find_value(gmd_load, "registrado")); }
            if (ds_map_exists(gmd_load, "lvl"))        { global.lvl = real(ds_map_find_value(gmd_load, "lvl")); }
            if (ds_map_exists(gmd_load, "xp"))         { global.xp = real(ds_map_find_value(gmd_load, "xp")); }
            if (ds_map_exists(gmd_load, "wins"))       { global.wins = real(ds_map_find_value(gmd_load, "wins")); }
            if (ds_map_exists(gmd_load, "flags"))      { global.flags_captured = real(ds_map_find_value(gmd_load, "flags")); }
            if (ds_map_exists(gmd_load, "rank"))       { global.rank = string(ds_map_find_value(gmd_load, "rank")); }
			// --- CARGAR LAS QUE FALTABAN ---
            if (ds_map_exists(gmd_load, "kills")) { 
                global.kills = real(ds_map_find_value(gmd_load, "kills")); 
            }
            if (ds_map_exists(gmd_load, "returned")) { 
                global.flags_returned = real(ds_map_find_value(gmd_load, "returned")); 
            }
			if (ds_map_exists(gmd_load, "losses")) { 
			    global.losses = real(ds_map_find_value(gmd_load, "losses")); 
			}
			
			if (ds_map_exists(gmd_load, "copas")) { 
			    global.copas = real(ds_map_find_value(gmd_load, "copas")); 
			}
				
			if (ds_map_exists(gmd_load, "id_friend")) {
			    global.miFriendTag = string(ds_map_find_value(gmd_load, "id_friend")); 
			}
			
if (ds_map_exists(gmd_load, "amigos_data")) {
    var _amigos_raw = string(ds_map_find_value(gmd_load, "amigos_data"));
    
    // Si la nube devuelve algo vacío o nulo
    if (_amigos_raw == "" || _amigos_raw == "0" || _amigos_raw == "undefined") {
        global.lista_amigos = [];
        show_debug_message(">>> [NUBE] Lista vacía recibida.");
    } else {
        try {
            // 1. Decodificamos el Base64
            var _json_real = base64_decode(_amigos_raw);
            
            // 2. Verificamos que el resultado sea un JSON válido
            if (_json_real != "" && _json_real != "undefined") {
                global.lista_amigos = json_parse(_json_real);
                show_debug_message(">>> [NUBE] Amigos cargados: " + _json_real);
            } else {
                global.lista_amigos = [];
            }
        } catch(_e) {
            // Si falla el parseo, reiniciamos a lista vacía para no crashear
            global.lista_amigos = [];
            show_debug_message(">>> [ERROR] Error al parsear amigos: " + string(_e.message));
        }
    }
}
			
			//Guardar local
			scr_save_to_local();
        }

        ds_map_destroy(gmd_load);
    }
break;

case gmd_resp_nodata: // No data received
show_message_async("No data received");
break;

////////////////////////////// SAVING CLOUD DATA /////////////////
case gmd_resp_datasaved: //Data saved successfully
show_debug_message("Data saved successfully");
break;
case gmd_resp_error_savingdata: //Error when connecting to server
show_message_async("Error to establish connection to server(Saving data)");
break;
case gmd_resp_invalidformat_saving: //Invalid format when saving data
show_message_async("Invalid format(Saving data)");
break;	

////////////////////////////// GET RECOVERY CODE /////////////////
case gmd_resp_getcode: //Get recovery code
show_message_async("Your recovery code is: "+string(valueref)); //The code expires in 10min
show_message_async("The code expires in 10 min");
break;

case gmd_resp_error_code: //Error when getting a code
show_message_async("An error has occurred(recovery code)");           
break;
	
////////////////////////////// RECOVERING SESSION /////////////////
case gmd_resp_sessionloaded: //Session loaded(USING A RECOVERY CODE)
show_message_async("Session loaded!"); //Session recovered
show_message_async("Player name: "+string(valueref));
/*ADVICE: RESTART THE GAME TO PREVENT INFORMATION ERRORS WITH THE PREVIOUS SESSION  */
break;
case gmd_resp_invalidcode: //Wrong code
show_message_async("Wrong code..."); //The code is wrong or it expired
break;


/////////////// EXTRA ///////
default: // Unknown error
show_message_async("An error has occurred");
break;

}





}





