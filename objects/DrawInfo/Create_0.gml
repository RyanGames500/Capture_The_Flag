//Titles
global.leaderboardoption=1; //1 - Display Global Table, 2 - Display User Table  
depth=-1;

//  INFORMATION TO SHOW
global.playername=""; //Player's nickname
global.player_id=""; //Unique player ID(DON'T SHOW IT IN THE FINAL VERSION OF THE GAME)

var numtable=1; // Number of leaderboard connected
global.serverdate=""; //Date
for(var gmd_i=1;gmd_i<=numtable;gmd_i++){ //Cycle for multiple leaderboars tables(max: 3)
global.playerpos[gmd_i]=""; // Player's global position for multiple leaderboars
global.bestscore[gmd_i]=""; //Best score submitted for multiple leaderboars
global.dat1[gmd_i]=""; //"Extra information 1" from the best score for multiple leaderboars
global.dat2[gmd_i]=""; //"Extra information 2" from the best score for multiple leaderboars
global.dat3[gmd_i]=""; //"Extra information 3" from the best score for multiple leaderboars
}

/* Information to submit(LEADERBOARD)- Defaults*/
global.setname="..."          //New possible name(needs verification)
global.xscore=100;            //Score to submit(example)
global.information1="2";      //Extra information 1(example)
global.information2="10";     //Extra information 2(example)
global.information3="Mexico"; //Extra information 3(example)

/* Information to submit(GAMESAVE)- Examples*/
global.money=0; //Money
global.mapid=0; //Id of the current room
global.save_version="1" // Write/read the version is useful to deal with updates
global.recovercode=""; //The recovery code is used to open a player's session in other device

/* Extra */
global.delay=0; //To regulate the time interval when sending information




