/// @description Avanzar la intro y devolver el control al final
t += 1;
if (t >= T_FIN) {
    if (instance_exists(oPlayer)) oPlayer.state = PLAYERSTATE.IDLE;
    instance_destroy();
}
