vsp += grv;

if (is_granada)
{
    if (irandom(2) == 0)
    {
        var sm = instance_create_layer(x, y, "Instances", oSmokeTrail);
        sm.color = c_gray;
    }
    image_angle = direction;
}

// Colisión simple con suelo/pared
if (place_meeting(x + hsp, y, obj_wall)) || (place_meeting(x + hsp, y, oPlataformaPasable)){
    instance_create_layer(x, y, "Instances", oExplosion); // Tu objeto de explosión
	scrCamShake(11);
    instance_destroy();
}
if (place_meeting(x, y + vsp, obj_wall)) {
    instance_create_layer(x, y, "Instances", oExplosion);
	scrCamShake(11);
    instance_destroy();
}

// Colisión con jugadores (otros o tú mismo si quieres)
var target = instance_place(x, y, oPlayer2_local);
if (target != noone && !done) {
    instance_create_layer(x, y, "Instances", oExplosion);
	scrCamShake(11);
	oPlayer2_local.hp-=40;
    instance_destroy();
    done = true;
}

x += hsp;
y += vsp;
image_angle += hsp * 2; // Que rote al volar