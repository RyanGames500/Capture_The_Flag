// Si NO tiene la bandera (está en el aire o suelo)
if(global.ONLINE == false)
{

if (!has_flag) 
{
    // Aquí va todo tu código de gravedad que pusimos antes
    if (!place_meeting(x, y + 1, obj_wall)) {
        velocidad_caida += gravedad;
        
        if (place_meeting(x, y + velocidad_caida, obj_wall)) {
            while (!place_meeting(x, y + sign(velocidad_caida), obj_wall)) {
                y += sign(velocidad_caida);
            }
            velocidad_caida = 0;
        }
    } else {
        velocidad_caida = 0;
    }
    y += velocidad_caida;
} 
else // Si SÍ la tiene el jugador
{
    // La bandera sigue al jugador y reseteamos la velocidad para que no "acumule" fuerza
    x = oPlayer_local.x;
    y = oPlayer_local.y - 16;
    velocidad_caida = 0; 
}

}

else // --- MODO ONLINE ---
{
    if (has_flag) 
    {
        // Si alguien la lleva, que siga al portador (Local o Remoto)
        // Usamos una variable 'portador_instancia' que asignarás en el callback

			if (has_flag && portador_instancia != noone && instance_exists(portador_instancia)) 
			{
			    x = portador_instancia.x;
			    y = portador_instancia.y - 16;
			}
    }
    else 
    {
        // --- BANDERA EN EL SUELO ---
        if (oBrain.AmIPseudoHost) 
        {
 // HOST: físicas de bandera en el suelo
if (!place_meeting(x, y + 1, obj_wall)) 
{
    velocidad_caida += gravedad;

    // COLISIÓN vertical (el fix)
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

// publicar para el cliente
global.sharedProperties._flagX = x;
global.sharedProperties._flagY = y;


        }
        else 
        {
            // EL CLIENTE SOLO COPIA AL HOST
            // SP es el struct que recibes del otro jugador (el Host)
            if (variable_instance_exists(id, "SP")) {
                x = SP._flagX;
                y = SP._flagY;
            }
        }
    }
}
