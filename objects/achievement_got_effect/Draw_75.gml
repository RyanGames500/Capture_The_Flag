// DRAW A SMALL NOTIFICATION WHEN AN ACHIEVEMENT IS UNLOCK
//Use gmda_get_achievement_info(id) to get a ds_map with the achievement information(name,descrip,value..)
//ach_id(achievement id) is defined when the object is created at the "scrHTTP_getachievement" script(line:8).

// Alpha and y-movement of the notification


alpha+=0.02*dir;
if alpha>4{dir=-1}
if alpha<1{
y-=0.5*dir;
}

if alpha<0{instance_destroy()}
draw_set_alpha(alpha)

draw_set_color(c_green) //Notification color
draw_roundrect(x,y,x+400,y+50,0) //Draw a box

var ach_info=gmda_get_achievement_info(ach_id);//Get achievement information
var ach_name=ds_map_find_value(ach_info,"name"); //Get name
var ach_image = real(ds_map_find_value(ach_info,"value")); //Get value(used for index an image)

draw_sprite(spr_achievements_images,ach_image,x+8,y+8) //Draw achievement image
draw_set_color(c_yellow) //Notification title color
draw_text_transformed(x+48,y+15,"ACHIEVEMENT UNLOCKED:",1,1,0);// Draw notification title
draw_set_color(c_white)//achievement name color
draw_text_transformed(x+48,y+35,ach_name,1,1,0); //Draw name

//Draw a white border
draw_roundrect(x,y,x+400,y+50,1)
draw_roundrect(x,y,x+398,y+52,1)

draw_set_alpha(1)