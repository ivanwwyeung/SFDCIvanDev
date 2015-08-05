/**

It has a constructor that retrieves the record from the controller parameter, 
and saves it in the acct variable. The class also has a method called getTitle() that returns a string containing the account’s name 
and identifier.
Most extensions have this form—with the constructor being the key ingredient. When the extension is used, 
Visualforce automatically invokes the constructor, passing in the controller for the page being viewed. 
This controller provides access to the record being viewed.


**/
public class exAccountExtension {
    private final Account acct;
    
    public exAccountExtension(ApexPages.StandardController controller) {
        this.acct = (Account)controller.getRecord();
    }
    
    
    public String getTitle() {
        return 'Account: ' + acct.name + ' (' + acct.id + ')';
    }
}