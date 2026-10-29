
function ConnectToServer(){
	oBrain.waitingForURL = true;
	if(!global.manualServerURLconnection){
		PreConnect()
	}else{
		// Conexión directa a nuestro servidor: no esperamos URL por HTTP
		// (si no, las respuestas HTTP de Gamdato se confundirían con la URL)
		oBrain.waitingForURL = false;

		if(global.manualServerSecure){
			oBrain.socket = network_create_socket(network_socket_wss)
		}else{
			oBrain.socket = network_create_socket(network_socket_ws)
		}
		var PORT = global.manualServerPort
		var IP = global.manualServerURL

		show_debug_message("Conectando a "+IP+" en el puerto "+string(PORT)+(global.manualServerSecure ? " (wss)" : " (ws)"))
		oBrain.connect=network_connect_raw_async(oBrain.socket, IP,PORT)
		show_debug_message("connect is "+string(oBrain.connect))
	}

}