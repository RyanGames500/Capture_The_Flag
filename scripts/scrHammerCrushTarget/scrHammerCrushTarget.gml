/// scrHammerCrushTarget(_victim)
function scrHammerCrushTarget(_victim)
{
    if (!instance_exists(_victim)) exit;

    // elegir qué variable de vida usa este objeto
    var hpVar = "health";
    if (!variable_instance_exists(_victim, hpVar))
    {
        // fallback por si tu player usa otro nombre (por ejemplo en oOtherPlayer)
        if (variable_instance_exists(_victim, "enemyHealth")) hpVar = "enemyHealth";
        else exit; // no tiene ninguna vida, no podemos matarlo
    }

    if (_victim[$ hpVar] <= 0) exit;

    // cooldown por jugador
    if (!variable_instance_exists(_victim, "crush_cd")) _victim.crush_cd = 0;
    if (_victim.crush_cd > 0) exit;

    // zona de aplastamiento (ajusta)
    var left   = x - 30;
    var right  = x + 30;
    var top    = y + 10;
    var bottom = y + 45;

    var hit =
        (_victim.bbox_right  > left) &&
        (_victim.bbox_left   < right) &&
        (_victim.bbox_bottom > top) &&
        (_victim.bbox_top    < bottom);

    if (!hit) exit;

    _victim.crush_cd = 20;

    // matar
    _victim[$ hpVar] = 0;

    // feed
    var victimName = scrGetPlayerName(_victim);
    var text = victimName + " fue aplastado";
    scrAddKillFeed(text);

    // avisos online
    if (global.ONLINE)
    {
        if (variable_instance_exists(_victim, "clientId"))
        {
            SendEventToClient(_victim.clientId, "kill_feed", { msg: text });
            SendEventToClient(_victim.clientId, "player_squashed", {});
        }

        if (instance_exists(oOtherPlayer))
            SendEventToClient(oOtherPlayer.clientId, "kill_feed", { msg: text });
    }
}
