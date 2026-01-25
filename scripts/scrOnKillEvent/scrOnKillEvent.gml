/// scrOnKillEvent(_data)
function scrOnKillEvent(_data)
{
    var killer = string(_data.killer);
    var victim = string(_data.victim);
    var reason = string(_data.reason);

    var msg = "";

    if (reason == "crush")
    {
        // si quieres que sea personalizado también:
        if (victim == global.myName) msg = "Moriste aplastado";
        else msg = victim + " murio aplastado";
    }
    else
    {
        if (victim == global.myName)
            msg = killer + " te elimino";
        else
            msg = killer + " eliminó a " + victim;
    }

    scrAddKillFeed(msg);
}
