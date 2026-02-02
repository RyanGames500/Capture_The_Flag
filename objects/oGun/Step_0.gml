if (no_pickup_timer > 0) no_pickup_timer--;


// Si el arma está en el suelo (no ha sido tomada)
if (!taken) {
    // 1. Animación de flotar (Seno)
    // El 0.05 es la velocidad, el 5 es la altura del movimiento
    y += sin(current_time * 0.005) * 0.5;  
    
    // 3. Efecto de brillo o escala (opcional)
    image_xscale = 1 + sin(current_time * 0.01) * 0.1;
    image_yscale = image_xscale;
} else {
    // Si alguien la agarró pero el objeto aún no se destruye, reseteamos el ángulo
    image_angle = 0;
    image_xscale = 1;
    image_yscale = 1;
}


// --- LÓGICA DE AUTODESTRUCCIÓN (Solo Host) ---
if (oBrain.AmIPseudoHost && vida_timer > 0) {
    vida_timer--;
    
    // Si el tiempo se acaba, avisamos y destruimos
    if (vida_timer <= 0) {
        var _uid = net_uid;
        
        // Avisar a clientes que esta arma específica se "pudrió"
        if (instance_exists(oOtherPlayer)) {
            with(oOtherPlayer) {
                SendEventToClient(clientId, "weapon_pickup_taken", { uid: _uid });
            }
        }
        
        instance_destroy();
    }
}

// --- EFECTO VISUAL (Opcional): Que parpadee cuando le quede poco tiempo ---
if (vida_timer > 0 && vida_timer < 300) { // Últimos 5 segundos
    // Si el timer es bajo, hacemos que el alpha oscile rápido
    image_alpha = (vida_timer % 10 < 5) ? 0.3 : 1;
}