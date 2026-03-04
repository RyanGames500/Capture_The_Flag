function scrCamShake(_power)
{
if (instance_exists(oCameraController))
{
    oCameraController.shake = min(oCameraController.shake + _power, 12);
}

if (instance_exists(oCameraController_offline))
{
    oCameraController_offline.shake = min(oCameraController_offline.shake + _power, 12);
}
}
