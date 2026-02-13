function scr_trigger_intro(_azules, _rojos) {
    if (!instance_exists(oIntroVersus)) {
        var intro = instance_create_layer(0, 0, "Instances", oIntroVersus);
        
        // Lógica de espejo: En mi pantalla, MI equipo es el aliado
        if (global.myTeam == "AZUL") {
            intro.aliados = _azules;
            intro.rivales = _rojos;
        } else {
            intro.aliados = _rojos;
            intro.rivales = _azules;
        }
        
        if (instance_exists(oPlayer)) oPlayer.state = PLAYERSTATE.INTRO;
    }
}