var mapnum=global.mapid mod 8;
draw_set_color(mapcolor[mapnum])
draw_set_alpha(0.5)
draw_rectangle(xstart-150,ystart-150,xstart+150,ystart+150,0);
draw_set_alpha(1)
draw_set_color(c_white)
draw_self();

draw_set_halign(fa_left)
draw_text(xstart+170,ystart-130,"x: "+string(obj_playertest.x))
draw_text(xstart+170,ystart-100,"y: "+string(obj_playertest.y))