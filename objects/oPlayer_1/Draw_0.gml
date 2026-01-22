//draw a bar to show the speed
var healthbarLength = speed*10
draw_healthbar(x - healthbarLength, y -30, x+ healthbarLength,y-35,100, c_black, c_red ,c_lime,false,true,false)
draw_healthbar(x - 30, y -40, x+ 30,y-45,health, c_black, c_red ,c_green,false,true,false)

draw_self(); // Primero te dibujas a ti

if (has_flag) {
    // Usamos el sprite que guardamos cuando recibimos el evento "captured"
    // El y-20 es para subirla a la espalda, y el image_xscale para que gire contigo
    draw_sprite_ext(flag.sprite, 0, x, y - 20, image_xscale * 0.8, 0.8, 0, c_white, 1);
}
