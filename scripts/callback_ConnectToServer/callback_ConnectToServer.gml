function callback_ConnectToServer(){
    // Activamos el online
    global.ONLINE = true;
    
    // Le avisamos a la pantalla de carga que la conexión fue un éxito
    if (instance_exists(oLoadingScreen)) {
        oLoadingScreen.conector_listo = true;
        oLoadingScreen.mensaje = "CONEXION EXITOSA!";
    }
    
    // Si quieres que cambie de room automáticamente al conectar:
    // ChangeRoom("public"); 
}