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

// ---- MUNCIÓN: mantener stock ----
if (ammo_check_cd > 0) ammo_check_cd--;

if (ammo_check_cd <= 0)
{
    ammo_check_cd = ammo_check_every;

    var freeAmmo = scrCountFree(oAmmoPack);

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
