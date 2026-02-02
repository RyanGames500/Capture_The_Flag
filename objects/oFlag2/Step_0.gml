if(global.ONLINE == false) {
    // --- MODO OFFLINE (Tu código de siempre) ---
    if (!has_flag) {
        if (!place_meeting(x, y + 1, obj_wall)) velocidad_caida += 0.5;
        if (place_meeting(x, y + velocidad_caida, obj_wall)) {
            while (!place_meeting(x, y + sign(velocidad_caida), obj_wall)) y += sign(velocidad_caida);
            velocidad_caida = 0;
        }
        y += velocidad_caida;
    } else {
        x = oPlayer2_local.x;
        y = oPlayer2_local.y - 16;
        velocidad_caida = 0; 
    }
} 
else {
    // --- MODO ONLINE (oFlag2) ---
    
    // 1. ¿ALGUIEN LA LLEVA?
    if (has_flag && portador_instancia != noone && instance_exists(portador_instancia)) {
        x = portador_instancia.x;
        y = portador_instancia.y - 16;
        velocidad_caida = 0;
    } 
    // 2. SI NO LA LLEVA NADIE (Físicas controladas por el Host)
    else {
if (oBrain.AmIPseudoHost) 
{
if (!place_meeting(x, y + 1, obj_wall)) 
{
    velocidad_caida += gravedad;

    if (place_meeting(x, y + velocidad_caida, obj_wall)) 
    {
        while (!place_meeting(x, y + sign(velocidad_caida), obj_wall)) {
            y += sign(velocidad_caida);
        }
        velocidad_caida = 0;
    }

    y += velocidad_caida;
}
else 
{
    velocidad_caida = 0;
}

global.sharedProperties._flagAzulX = x;
global.sharedProperties._flagAzulY = y;


}
        else 
		{
            // EL CLIENTE (Rojo) solo obedece a la red
            if (variable_instance_exists(id, "SP")) {
                x = SP._flagAzulX;
                y = SP._flagAzulY;
            }
        }
    }
}



if (has_flag) 
{
    // 1. Si alguien la lleva, ponemos el sprite pequeño
    sprite_index = spr_mano;
    
    // 2. Seguir al portador (esto ya lo tienes, pero asegúrate de que esté aquí)
    if (instance_exists(portador_instancia)) {
        x = portador_instancia.x;
        y = portador_instancia.y - 16; // Ajusta la altura para que se vea bien
        image_xscale = portador_instancia.image_xscale;
    }
} 
else 
{
    // 3. Si está suelta (en base o caída), ponemos el sprite grande
    sprite_index = spr_suela;
    image_xscale = 1; // Reset de escala
}

if (has_flag) {
    depth = portador_instancia.depth - 1; // Que se dibuje por delante del jugador
} else {
    depth = -y; // Profundidad normal de objeto en el suelo
}