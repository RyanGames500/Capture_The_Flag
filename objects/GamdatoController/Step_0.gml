// STEP EVENT
// (Gamdato se quito del juego. Antes aqui tambien se cerraba el teclado del celular en cada frame
//  si no habia un cuadro de texto de Gamdato; eso hacia que se cerrara solo al escribir.)

// Teclado del celular: se cierra al darle ENTER / LISTO
if (keyboard_virtual_status() == true) {
	if (keyboard_check_released(kbv_returnkey_continue) or keyboard_check(vk_enter)) {
		keyboard_virtual_hide();
	}
}
