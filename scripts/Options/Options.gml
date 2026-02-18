// Settings    V1.9.1
// -- Updates in this version? 
//  - Support for many games inside 1 RNet server using global.gameId
//  - oBrain.pseudoHostClientId

/*
* Your server id or secret key. 
* This identifies your Rocket Net Server
* Please do not share with anyone!
* Then there is the Game Id. To separate your games, use this feature.
*/
global.SERVERID = "23a10cd8-4ca0-4bae-9d70-43bafa47e11e"
global.gameId = "Capture The Flag"

/* Normally, data packets in websockets are safe because of SSL, but your game players can see the messages sent back and forth using tools like Chrome dev tools.
* Your SERVERID is never revealed over these messages, but they will contain the Sructs of shared properties etc tec
*  Ciphering will make it impossible to even understand these messages.
*/   // The catch is that Ciphering can make your game slow especially in HTML5, so use with caution!
global.useCiphering = false;

/*
* On which layer do you want other players to be instantiated
*/
global.OtherPlayersLayerName = "Instances"

/*
* Do you want to manually connect to RNet? You can do this by copying your serverURL directy
* from dashboard.rocketnetworking.net
*/
global.manualServerURLconnection = false;
global.manualServerURL = "rocket-networking.uc.r.appspot.com/"


/*
* How often do you want to share your sharedProperties?
* The higher this Time period is in frames, thats how many frames later the server is updated
*/
global.sharingFrequency = 1;    //Equivalent to alarm of 1 frame
global.entitySharingFrequency = 1   //for entities


//Thank you for using Rocket Networking! See you on the moon :)