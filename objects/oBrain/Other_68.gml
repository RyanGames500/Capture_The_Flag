/// @description Async ws Events. Do Not Tamper!
var type = async_load[? "type"]
if(type == network_type_non_blocking_connect){
	if( async_load[? "succeeded"] == false){
		show_debug_message("failed non blocking connection. Please check your internet connection and firewalls.")
	}
	if( async_load[? "succeeded"] == true){
		show_debug_message("Succeeded non blocking conection. ")
		non_blocking_success_yet = true;
		
			//code to join server
			
			var Buffer = buffer_create(1, buffer_grow, 1)
			//WHAT DATA 
			var data = ds_map_create();
			data[? "serverId"] = md5_string_utf8(global.SERVERID);
			data[? "gameId"] = (global.gameId);
			data[? "uC"] = global.useCiphering;
			//whatever data you want to send as key value pairs

			ds_map_add(data,"eventName","join_server");
			buffer_write(Buffer, buffer_text, ((json_encode(data))))
			network_send_raw(oBrain.socket, Buffer, buffer_tell(Buffer),network_send_text)
			buffer_delete(Buffer)
			ds_map_destroy(data)
			
			
			
			
	}
	//there was code here for join server
	//ConnectToServer();
}
if(type == network_type_data){
	var buffer_raw = async_load[? "buffer"];
	var buffer_processed = buffer_read(buffer_raw , buffer_text);
	
	if(string_pos("eventName", buffer_processed)!=0){
		//eventName is there
		var realData = json_parse(buffer_processed)
		
	}else{
		var decrypted = substitutionDecrypt(buffer_processed,global.SERVERID)
		var realData = json_parse(decrypted)
	}

	
	
	
	
	if(variable_struct_exists(realData , "eventName")){
		//show_message(buffer_processed)
	}
	var eventName = variable_struct_get(realData,"eventName")
	
	
	
	
	switch(eventName){
		case "created_you":
			global.clientId = realData.clientId
			global.roomId = string(global.clientId)
			alarm[2] = 1;
			callback_ConnectToServer();
		break;
		
		case "alert":
		//show_message(buffer_processed)
			if(realData.type == "show"){
				callback_Admin(realData.message)
			
			}
		
		break;
		
		case "changed_room":
		if(realData.roomId == string(global.clientId)){
			global.roomId = realData.roomId
			callback_LeaveRoom()
		}else{
			global.roomId = realData.roomId
			callback_ChangeRoom(realData.roomId)
		}
		instance_destroy(oOtherPlayer)
		
		with(oPersistentObject){
			if(roomId!=realData.roomId){
				instance_destroy(id)
			}
		}
		
		
		break;
		
		
		case "all_rooms":
		callback_ShowAllRooms(realData.rooms)
		break;
		
		case "all_clients":
		callback_ShowAllClientsInRoom(realData.clients, realData.roomId)
		break;
		
		
		case "all_pO":
	
		callback_ShowAllPersistentObjectsInRoom(realData.pOs, realData.roomId)
		break;
		
		
case "state_update":
    var found = false;
    with(oOtherPlayer){
        if(clientId == real(realData.clientId)){
            afk = realData.afk;
            sharedProperties = realData.SP;
            found = true;
            entities = (realData.entities);
        }
    }

    if(!found && real(realData.clientId) != global.clientId){
        var new_enemy = instance_create_layer(0, 0, global.OtherPlayersLayerName, oOtherPlayer);
        new_enemy.clientId = real(realData.clientId);
        
        // Asignar equipo por ID (Par = Azul, Impar = Rojo)
        new_enemy.team = (new_enemy.clientId % 2 == 0) ? "AZUL" : "ROJO";
        new_enemy.sharedProperties = realData.SP;
		

        // 🔥 SOLO ACTIVAMOS EL TIMER
        if (oBrain.AmIPseudoHost) {
            // Cada vez que entra alguien nuevo, reiniciamos el timer a 2 segundos (120 frames)
            // Esto da tiempo a que la red mande los nombres de TODOS antes de empezar
            oBrain.timer_intro = 60; //120
            oBrain.intro_disparada = false; 
        }
    }
    break;
		
		
		case "pO_update":
		var found = false;
		with(oPersistentObject){
			if(id.persistentObjectId == realData.POid)
			{			
				id.persistentObjectProperties = realData.pOp
				found = true;
			}
		
			
		}
		if(!found){
			
			var new_pO = instance_create_layer(0,0,global.OtherPlayersLayerName,oPersistentObject);
			new_pO.persistentObjectId = realData.POid;
			new_pO.persistentObjectProperties = realData.pOp
			new_pO.roomId = realData.roomId
		}
		break;
		
		
		case "disconnected":
		callback_DisconnectFromServer();
		break;
		
		case "destroy_player":
		//show_message(buffer_processed)
		with(oOtherPlayer){
			if(clientId==real(realData.clientId)){
				instance_destroy(id);
				
			}
		}
		with(oOtherPlayersEntity){
			if(clientId==real(realData.clientId)){
				instance_destroy(id);
				
			}
		}
		
		break;
		
		
		case "destroy_pO":
		with(oPersistentObject){
			if(persistentObjectId == realData.POid){
				instance_destroy(id)
			}
		}
		break;
		
		
		case "pong":
		global.ping = current_time - real(realData.ct)
		last_got_ping = current_time
		break;
		
		
		case "get_server_time":

		callback_GotServerTime(real(realData.time))
		break;
		
		
		case "SMTC":
		callback_ReceivedMessage(  realData.message , realData.senderClientId);
		break;
		
		case "SETC":
		callback_ReceivedEvent( realData.event , json_parse(realData.message) , realData.senderClientId);
		break;
		
		
		case "created_PO":
		callback_CreatedPersistentObject(realData.POid)
		break;
		
		case "pseudoHost":
		var pseudoHostClientId = real(realData.pH)
		oBrain.pseudoHostClientId = real(realData.pH)
		if(pseudoHostClientId == global.clientId){
			oBrain.AmIPseudoHost = true
		}else{
			oBrain.AmIPseudoHost = false
		}
		break;
		
		
		case "full_server_view":
		callback_ViewServerActivity(realData.activity)
		break;
		
		case "db_summary":
		callback_GetServerSummary(realData.db)
		break;
		
		case "read_data":
		callback_ReadSimpleData(realData.readId,(realData.data));
		break;
	
	}
	
	
	buffer_delete(buffer_raw)
}

