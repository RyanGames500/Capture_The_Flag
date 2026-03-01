var gmd_hor=keyboard_check(vk_right)-keyboard_check(vk_left);
var gmd_ver=keyboard_check(vk_down)-keyboard_check(vk_up);


if (point_in_rectangle(x+gmd_hor*16,y+gmd_ver*16,xstart-150,ystart-150,xstart+150,ystart+150)){
	x+=gmd_hor*4;
	y+=gmd_ver*4;
}