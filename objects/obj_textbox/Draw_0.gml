// Draw textbox input

draw_set_colour(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_center)


//Titles
var titles;
titles[1]="Name: "     //Name
titles[2]="Score: "    //Score
titles[3]="Level: "    //Extra information 1(example)
titles[4]="Kills: "    //Extra information 2(example)
titles[5]="Country: "  //Extra information 3(example)


//Set variables from textbox value - "func value" is set in the room creation code
switch(func){
case 1:
draw_text(x,y-10,titles[1]);
global.setname=gmda_textbox(x,y,200,32,global.setname,0,20);
break;
case 2:
draw_text(x,y-10,titles[2]);
global.xscore=real(gmda_textbox(x,y,150,32,global.xscore,2,10));
break
case 3:
draw_text(x,y-10,titles[3]);
global.information1=gmda_textbox(x,y,150,32,global.information1,0,10);
break
case 4:
draw_text(x,y-10,titles[4]);
global.information2=gmda_textbox(x,y,150,32,global.information2,0,10);
break
case 5:
draw_text(x,y-10,titles[5]);
global.information3=gmda_textbox(x,y,150,32,global.information3,0,10);
break
case 6:
draw_text(x,y-10,"Money:");
global.money=real(gmda_textbox(x,y,70,32,global.money,2,5));
break;
case 7:
draw_text(x,y-10,"Map-id:");
global.mapid=real(gmda_textbox(x,y,70,32,global.mapid,2,5));
break
case 8:
draw_text(x,y-10,"Recovery code:");
global.recovercode=gmda_textbox(x,y,120,32,global.recovercode,0,6);
break

}





