function scr_trigger_intro(_azules, _rojos) {
    if (!instance_exists(oIntroVersus)) {
        var intro = instance_create_layer(0, 0, "Instances", oIntroVersus);

        // Respaldo: los nombres en texto como antes ("Ryan & Ana")
        intro.txt_azul = _azules;
        intro.txt_rojo = _rojos;

        // Cada jugador con su personaje y su equipo de verdad
        var _yo = scr_my_team();
        intro.mi_equipo = _yo;
        var _mine = { n: global.myName, pj: global.pj_selected };
        if (_yo == "AZUL") array_push(intro.lista_azul, _mine); else array_push(intro.lista_rojo, _mine);
        with (oOtherPlayer) {
            var _tm = (variable_instance_exists(id, "team") && team != "") ? team : lobby_team;
            var _p  = { n: Name, pj: variable_instance_exists(id, "mySelectedPJ") ? mySelectedPJ : 0 };
            if (_tm == "AZUL") array_push(intro.lista_azul, _p); else array_push(intro.lista_rojo, _p);
        }

        if (instance_exists(oPlayer)) oPlayer.state = PLAYERSTATE.INTRO;
    }
}
