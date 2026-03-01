draw_set_font(f1);


// GET INFORMATION TO DISPLAY
var status=gmda_status();
global.playername=gmda_getPlayername(); //Player's nickname
global.player_id=gmda_getPlayerid(); //Unique player ID(DON'T SHOW IT IN THE FINAL VERSION OF THE GAME)
global.serverdate=gmda_getDate(); //Get Date

var numtable=1; // Number of leaderboard connected
for(var gmd_i=1;gmd_i<=numtable;gmd_i++){ //Cycle for multiple leaderboars tables(max: 3)
global.playerpos[gmd_i]=gmda_getPlayerpos(gmd_i); // Player's global position
global.bestscore[gmd_i]=gmda_getBestscore(gmd_i); //Best score submitted
global.dat1[gmd_i]=gmda_getExtrainfo(1,gmd_i); //"Extra information 1" from the best score
global.dat2[gmd_i]=gmda_getExtrainfo(2,gmd_i); //"Extra information 2" from the best score
global.dat3[gmd_i]=gmda_getExtrainfo(3,gmd_i); //"Extra information 3" from the best score
}

//  Draw leaderboard(global or player's table)   
var title;
if global.leaderboardoption=1{ //Option 1: Draw Best Global scores
	title="Global Table";
	var gettable=gmda_getTabledata(gmda_globaltable,1);
	gmda_draw_table(80,342,gettable,global.playername);
	
}else{ //Option 2: Draw Best Player's score
	title=global.playername+" - Table";
	var gettable=gmda_getTabledata(gmda_playertable,1);
	gmda_draw_table(80,342,gettable,global.playername);

}

// Draw title
draw_set_colour(c_dkgray);
draw_roundrect(80,272+40,710,300+38,0);
draw_set_colour(c_white);
draw_set_halign(fa_center);
draw_text((80+710)/2,272+14+40,title);

//PLAYER's INFORMATION         
draw_set_halign(fa_left);
draw_text(72,32,"ID: "+string(global.player_id));
draw_text(72,32*3,"Nickname: "+string(global.playername));
draw_text(72,32*4,"Global Position: "+string(global.playerpos[1]));
draw_text(72,32*5,"Best Score: "+string(global.bestscore[1]));
draw_text(72,32*6,"STATUS: "+string(status));

//Best score information
draw_text(128+32*5,32*3,"D1: "+string(global.dat1[1]));
draw_text(128+32*5,32*4,"D2: "+string(global.dat2[1]));
draw_text(128+32*5,32*5,"D3: "+string(global.dat3[1]));

// EXTRA
if not(global.serverdate=""){
draw_text(72,32*2,"DATE: "+date_datetime_string(global.serverdate));}else{draw_text(72,32*2,"DATE: -");	}
draw_text(room_width/2,room_height-32,"version: 1.0.85");


//Achievements

/* Draw title */
draw_set_halign(fa_left);
draw_set_valign(fa_center);
draw_set_colour(c_white);
draw_text(128+32*11+4,32,"Achievements");
gmda_draw_achievements(128+32*11,48)

/* Notes */
draw_set_halign(fa_left);
draw_set_valign(fa_center);
draw_set_colour(c_white);
draw_text(128+32*26+4,32*18,"IMPORTANT NOTES:");
draw_text(128+32*26+4,32*19,"-Contact me if you want this work for HTML5 module.");
draw_text(128+32*26+4,32*20,"-Contact me if you want something personalized");
draw_text(128+32*26+4,32*21,"-Please, report any issue");
draw_text(128+32*26+4,32*22,"-Have fun :)");

gmda_draw_achievements(128+32*11,48)





if global.delay{
draw_set_alpha(0.4);
draw_rectangle(0,0,room_width,room_height,0);
draw_set_alpha(1);
}
