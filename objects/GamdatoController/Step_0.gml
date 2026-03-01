// STEP EVENT
gmda_Updatefunction(); //Update function


//Virtual Keyboard - Control
if keyboard_virtual_status() == true{
	if keyboard_check_released(kbv_returnkey_continue) or keyboard_check(vk_enter){
	keyboard_virtual_hide();
}}

var vkeyboard=0;

with(obj_textbox){
	if selected{
	vkeyboard=1;
	}	
}


if !(vkeyboard){
	keyboard_virtual_hide();
}

