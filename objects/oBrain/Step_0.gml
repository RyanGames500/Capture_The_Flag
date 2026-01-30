//textos de aviso de bajas
for (var i = array_length(kill_feed)-1; i >= 0; i--)
{
    var it = kill_feed[i];
    it.t++;

    var tin  = kf_in;
    var th   = kf_hold;
    var tout = kf_out;

    if (it.t <= tin)
    {
        var p = it.t / tin;
        it.a = p;
        it.xoff = lerp(-80, 0, p);
        it.yoff = 0;
    }
    else if (it.t <= tin + th)
    {
        it.a = 1;
        it.xoff = 0;
        it.yoff = 0;
    }
    else
    {
        var p2 = (it.t - (tin + th)) / tout;
        it.a = 1 - p2;
        it.xoff = lerp(0, -20, p2);
        it.yoff = lerp(0, -10, p2);
    }

    kill_feed[i] = it;

    if (it.t >= it.life) array_delete(kill_feed, i, 1);
}



// --- 1. LÓGICA MIENTRAS SE JUEGA (SOLO HOST) ---
if (global.game_over == false) 
{
    if (oBrain.AmIPseudoHost) 
    {
        var _ganador = 0;
        if (global.puntos_rojo >= 3) _ganador = 1;
        if (global.puntos_azul >= 3) _ganador = 2;

        if (_ganador != 0) 
        {
            global.game_over = true;
            global.winner_team = _ganador;

            // Avisamos al cliente
            var _data = { winner: _ganador };
            if (instance_exists(oOtherPlayer)) {
                SendEventToClient(oOtherPlayer.clientId, "finalizar_partida", _data);
            }
        }
    }
}

// --- 2. LÓGICA DE PANTALLA DE VICTORIA (PARA TODOS) ---
if (global.game_over == true) 
{
    // Aparecer suavemente (fade in)
    if (victory_alpha < 1) {
        victory_alpha += 0.05; 
    }

    // Acciones cuando la pantalla ya es visible
    if (victory_alpha >= 0.9) 
    {
        if (keyboard_check_pressed(vk_escape)) 
        {
            /* Si soy el Host, le aviso al cliente que nos vamos
            if (oBrain.AmIPseudoHost && instance_exists(oOtherPlayer)) {
                SendEventToClient(oOtherPlayer.clientId, "host_abandono", {});
            }*/
            
            // Ambos ejecutan esto para cerrar su socket y limpiar
            LeaveRoom();
        }
    }
} 
else 
{
    victory_alpha = 0; // Reset si no hay game over
}

if (!AmIPseudoHost) exit;
if (room != rm_stage1) exit;

// ---- ARMAS ----
if (!weapons_spawned && instance_exists(oOtherPlayer))
{
    weapons_spawned = true;

    var p;

    p = scrFindSpawnPosTopBottom(80, 40, 18);
    host_spawn_weapon(oGun, p.x, p.y, weapon_struct_pistola);

    p = scrFindSpawnPosTopBottom(80, 40, 18);
    host_spawn_weapon(oGun, p.x, p.y, weapon_struct_escopeta);

    p = scrFindSpawnPosTopBottom(80, 40, 18);
    host_spawn_weapon(oGun, p.x, p.y, weapon_struct_smg);
}

// ---- MUNICIÓN ----
if (!ammo_spawned && instance_exists(oOtherPlayer))
{
    ammo_spawned = true;

    for (var k = 0; k < 6; k++)
    {
        var a = scrFindSpawnPosTopBottom(80, 40, 18);
        host_spawn_ammo(a.x, a.y, 25);
    }
}

if (!AmIPseudoHost) exit;
if (room != rm_stage1) exit;

// si tienes una variable para “partida activa”, úsala aquí
// if (!match_running) exit;

// ---- MANTENER STOCK ----
if (ammo_check_cd > 0) ammo_check_cd--;

if (ammo_check_cd <= 0)
{
    ammo_check_cd = ammo_check_every;

    // CAMBIO AQUÍ: Contamos entidades tipo "ammo"
    var freeAmmo = 0;
    with(oMyEntity) { if (tipo == "ammo") freeAmmo++; }

    if (freeAmmo < ammo_min_on_map)
    {
        var need = ammo_min_on_map - freeAmmo;
        for (var i = 0; i < need; i++)
        {
            var p = scrFindSpawnPosTopBottom(80, 40, 18);
            host_spawn_ammo(p.x, p.y, 25);
        }
    }
}


if (weap_check_cd > 0) weap_check_cd--;

if (weap_check_cd <= 0)
{
    weap_check_cd = weap_check_every;

    var freeWeaps = scrCountFree(oGun);

    if (freeWeaps < weap_min_on_map)
    {
        var need = weap_min_on_map - freeWeaps;

        for (var j = 0; j < need; j++)
        {
            var p = scrFindSpawnPosTopBottom(80, 40, 18);

            // elige aleatorio entre tus structs (SIN ? :)
            var pick = irandom(2);
            var wstruct;

            if (pick == 0) wstruct = weapon_struct_pistola;
            else if (pick == 1) wstruct = weapon_struct_escopeta;
            else wstruct = weapon_struct_smg;

            host_spawn_weapon(oGun, p.x, p.y, wstruct);
        }
    }
}


if (oBrain.AmIPseudoHost) {
    with(oHammer) {
        // Si el martillo está quieto, hay una pequeña chance de que ataque
        if (!ataca && irandom(200) == 1) { 
            ataca = true;
            image_speed = 1;
            
            // AVISAR A LOS DEMÁS
            var hammerData = { _id: myHammerId };
            with(oOtherPlayer) {
                SendEventToClient(id.clientId, "hammer_attack", hammerData);
            }
        }
    }
}
	
//Alertas Actualizar animacioes (Flag Capture etc)
for (var i = array_length(alerts)-1; i >= 0; i--)
{
    var it = alerts[i];
    it.t++;

    var tin  = alert_in_frames;
    var th   = alert_hold_frames;
    var tout = alert_out_frames;

    if (it.t <= tin)
    {
        var p = it.t / tin;
        it.a = p;
        it.yoff = lerp(-18, 0, p);
    }
    else if (it.t <= tin + th)
    {
        it.a = 1;
        it.yoff = 0;
    }
    else if (it.t <= tin + th + tout)
    {
        var p2 = (it.t - (tin + th)) / tout;
        it.a = 1 - p2;
        it.yoff = lerp(0, -12, p2);
    }
    else
    {
        array_delete(alerts, i, 1);
        continue;
    }

    alerts[i] = it;
}
