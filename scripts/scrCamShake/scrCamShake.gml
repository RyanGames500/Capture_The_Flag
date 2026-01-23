function scrCamShake(_power)
{
if (instance_exists(oCameraController))
{
    oCameraController.shake = min(oCameraController.shake + _power, 12);
}
}