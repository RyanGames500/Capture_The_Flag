// Las armas fuertes esperan 20 segundos al empezar (el nivel llega del código de creación, por eso va aquí y no en Create)
if (primera_vez) {
    primera_vez = false;
    if (nivel == 3) { timer = scr_spawn_primera_espera(); timer_max = timer; }
}

// Mientras su arma siga en el piso, no hace nada
if (instance_exists(my_item)) exit;

if (timer > 0) { timer--; exit; }

// EQUIPAMIENTO: donde salian pistolas, subfusiles y rifles ahora sale municion o granadas (scr_armas)
if (EQ_MAPA_SOLO_FUERTES && (nivel == 1 || nivel == 2 || (nivel == 0 && random(100) < 70))) {   // nivel 0 (mapas sin niveles): 3 de cada 10 veces sale una fuerte
    my_item = instance_create_layer(x, y, "Instances", oAmmoPack);
    with (my_item) {
        if (random(100) < 25) {
            is_grenade_pack = true;
            amount = 3;
            sprite_index = spr_granada;
            image_xscale = 1.5;
            image_yscale = 1.5;
        } else {
            amount = 20;
        }
    }
    timer = scr_spawn_frames("ammo", nivel);
    timer_max = timer;
    exit;
}

my_item = instance_create_layer(x, y, "Instances", objgun);
my_item.weapon = scr_arma_al_azar(nivel);   // según el nivel del punto (scr_armas)
if (nivel == 3) scrAddAlert(scr_arma_nombre(my_item.weapon) + " EN EL CENTRO", c_orange);

// Cuánto tarda en volver cuando la agarren (10 / 15 / 25 s según el nivel, ±20%)
timer = scr_spawn_frames("weapon", nivel);
timer_max = timer;
