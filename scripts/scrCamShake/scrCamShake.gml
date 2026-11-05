function scrCamShake(_power)
{
_power *= opt_temblor_mult(); // AJUSTES: normal / suave / apagado
if (_power <= 0) exit;
if (instance_exists(oCameraController))
{
    oCameraController.shake = min(oCameraController.shake + _power, 12);
}

if (instance_exists(oCameraController_offline))
{
    oCameraController_offline.shake = min(oCameraController_offline.shake + _power, 12);
}
}
