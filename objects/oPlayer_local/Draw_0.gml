//draw a bar to show the speed
var healthbarLength = speed*10
draw_healthbar(x - healthbarLength, y -30, x+ healthbarLength,y-35,100, c_black, c_red ,c_lime,false,true,false)
draw_healthbar(x - 30, y -40, x+ 30,y-45,health, c_black, c_red ,c_green,false,true,false)

if (invulnerable && (current_time % 200 < 100)) {
    // No dibujamos nada o dibujamos con transparencia para el efecto de parpadeo
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_white, 0.5);
} else {
    draw_self();
}

image_blend = c_blue;


draw_text(x,y-10,has_flag)