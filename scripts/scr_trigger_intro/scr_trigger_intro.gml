function scr_trigger_intro(_azules, _rojos) {
    if (!instance_exists(oIntroVersus)) {
        var intro = instance_create_layer(0, 0, "Instances", oIntroVersus);
        
        // Si yo soy azul, mis aliados son los azules y mis rivales los rojos
        if (global.myTeam == "AZUL") {
            intro.aliados = _azules;
            intro.rivales = _rojos;
        } else {
            intro.aliados = _rojos;
            intro.rivales = _azules;
        }
        
    }
}