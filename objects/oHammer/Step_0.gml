/// @description Prensa: esperar, avisar, caer
var _decide = (!global.ONLINE || oBrain.AmIPseudoHost);

switch (estado) {
    case "espera":
        if (_decide) {
            timer -= 1;
            if (timer <= 0) {
                hammer_empezar(PRENSA_AVISO);
                timer = room_speed * random_range(1.5, 4);   // la próxima la decide el host
                if (global.ONLINE) {
                    var _hid = myHammerId;
                    with (oOtherPlayer) SendEventToClient(clientId, "hammer_go", { hid: _hid });
                }
            }
        }
    break;

    case "aviso":
        aviso_t -= 1;
        // tic-tic de aviso, solo si estoy cerca
        if ((aviso_t == 30 || aviso_t == 12) && global.sfx && hammer_cerca(400)) audio_play_sound(snd_empy, 5, false, 0.8, 0, 1.6);
        if (aviso_t <= 0) {
            estado = "cae";
            image_index = 0;
            image_speed = 1;
        }
    break;

    case "cae":
        var _f = floor(image_index);
        // el golpe: polvo, sonido y temblor (más fuerte si estoy cerca)
        if (_f >= 2 && !golpe_ya) {
            golpe_ya = true;
            fx_dust(x + 16, y + 90, 12, 0);
            if (global.sfx && hammer_cerca(500)) audio_play_sound(snd_hammer_hit, 1, false);
            if (hammer_cerca(350)) scrCamShake(5);
            else if (hammer_cerca(700)) scrCamShake(2);
        }
        // aplasta solo con la cabeza y solo en los cuadros de abajo
        if (_f >= 2 && _f <= 4 && !mato_ya) hammer_aplastar(_f);

        if (image_index >= image_number - 1) {
            image_index = 0;
            image_speed = 0;
            estado = "espera";
        }
    break;
}
