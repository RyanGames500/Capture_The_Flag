function scrGetPlayerName(_inst)
{
    if (!instance_exists(_inst)) return "???";

    if (variable_instance_exists(_inst, "playerName")) return string(_inst.playerName);
    if (variable_instance_exists(_inst, "Name")) return string(_inst.Name);

    return "Player";
}
