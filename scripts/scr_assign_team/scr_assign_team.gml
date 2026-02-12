function scr_assign_team(_clientId)
{
    var red = 0;
    var blue = 0;

    var keys = ds_map_keys(global.playerTeams);

    for (var i = 0; i < array_length(keys); i++)
    {
        var t = global.playerTeams[? keys[i]];
        if (t == "ROJO") red++;
        else blue++;
    }

    var team = (red <= blue) ? "ROJO" : "AZUL";

    global.playerTeams[? _clientId] = team;

    return team;
}
