/*

http://forceadventure.wordpress.com/2013/07/15/javascript-remoting-a-primer/



*/

global with sharing class JSRemotingBasicsController {
    public JSRemotingBasicsController() {
    }

/*

The method being called by Javascript Remoting must be annotated with @RemoteAction

*/
     
    @RemoteAction
    public static String doGetText() {
        return 'Hey, we got a response!';
    }
}