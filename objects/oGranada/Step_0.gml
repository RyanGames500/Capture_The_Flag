vsp += grv;

// Colisión simple con suelo/pared
if (place_meeting(x + hsp, y, obj_wall)) {
    instance_create_layer(x, y, "Instances", oExplosion); // Tu objeto de explosión
    instance_destroy();
}
if (place_meeting(x, y + vsp, obj_wall)) {
    instance_create_layer(x, y, "Instances", oExplosion);
    instance_destroy();
}

// Colisión con jugadores (otros o tú mismo si quieres)
var target = instance_place(x, y, oOtherPlayer);
if (target != noone && !done) {
    instance_create_layer(x, y, "Instances", oExplosion);
    instance_destroy();
    done = true;
}

x += hsp;
y += vsp;
image_angle += hsp * 2; // Que rote al volar