
function SendEventToClient(recieverClientId,eventName, yourMessageStruct){
	// Los bots de la sala privada no son clientes del servidor: sus golpes los maneja el lider (scr_objetivo)
	if (is_numeric(recieverClientId) && recieverClientId <= BOTNET_ID_BASE) {
		scr_botnet_evento(recieverClientId, eventName, yourMessageStruct);
		return;
	}
	//format for sending info to server 
		var Buffer = buffer_create(1, buffer_grow, 1)
	
		//WHAT DATA 
		var data = ds_map_create();

		data[?"message"] = json_stringify(yourMessageStruct)
		data[? "clientId"] = global.clientId;
		data[? "RclientId"] = recieverClientId;
		data[? "event"] = eventName
		ds_map_add(data,"eventName","SETC");
		buffer_write(Buffer, buffer_text, EC(string(json_encode(data))))
		network_send_raw(oBrain.socket, Buffer, buffer_tell(Buffer),network_send_text)
		buffer_delete(Buffer)
		ds_map_destroy(data)


}