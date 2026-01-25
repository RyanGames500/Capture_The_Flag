function scrBroadcastAlert(_msg, _col)
{
    // 1) local siempre
    scrAddAlert(_msg, _col);

    // 2) mandar a todos los proxies remotos (listo 4v4)
    if (global.ONLINE)
    {
        with (oOtherPlayer)
        {
            if (variable_instance_exists(id, "clientId"))
            {
                SendEventToClient(id.clientId, "hud_alert", { msg: _msg, col: _col });
            }
        }
    }
}
