global with sharing class JSRemotingFormSubmitController {
    public JSRemotingFormSubmitController(ApexPages.StandardController c) {
    }
     
    @RemoteAction
    public static String doSubmitForm(String acctId, String description, String website, String phone) {
        if(acctId != null) {
            Account acct = getAccount(acctId);
            if(acct != null) {
                //DO VALIDATION HERE@!@@@!!!@!@!!@1111ONE
                acct.Description = description;
                acct.Website = website;
                acct.Phone = phone;
                update acct;
                return 'Success';
            } else {
                return 'Account could not be found';
            }
        } else {
            return 'Account Id was null';
        }
    }
     
    private static Account getAccount(String acctId) {
        list<Account> accounts = [SELECT Id, Name
                                  FROM Account
                                  WHERE Id =: acctId];
        if(accounts.isEmpty()) {
            return null;
        } else {
            return accounts[0];
        }
    }
}