// ref: http://www.salesforce.com/us/developer/docs/apex_workbook/index.htm
/*
You can create custom REST Web service APIs on top of the Force.com platform or Database.com by exposing your Apex classes as REST resources. 
Client applications can call the methods of your Apex classes using REST to run Apex code in the platform.
Apex REST supports both XML and JSON for resource formats sent in REST request and responses. 
By default, Apex REST uses JSON to represent resources.

For authentication, Apex REST supports OAuth 2.0 and the Salesforce session. 

This tutorial uses Workbench to simulate a REST client. 
Workbench uses the session of the logged-in user as an authentication mechanism for calling Apex REST methods.

*/

/*
The REST class is global and defined with the @RestResource(urlMapping='/Merchandise/*') annotation. 
Any Apex class you want to expose as a REST API must be global and annotated with the @RestResource annotation. The parameter of the @RestResource annotation, urlMapping, is used to uniquely identify your resource and is relative to the base URL https://instance.salesforce.com/services/apexrest/. The base URL and the urlMapping value form the URI that the client sends in a REST request. In this case, the URL mapping contains the asterisk wildcard character, which means that the resource URI can contain any value after /Merchandise/. In Step 3 of this tutorial, we’ll be appending an ID value to the URI for the record to retrieve.
*/

/*

Apex REST supports two formats for representations of resources: JSON and XML. 
JSON representations are passed by default in the body of a request or response, and the format is indicated by the Content-Type property in the HTTP header. 
You can retrieve the body as a Blob from the HttpRequest object if there are no parameters to the Apex method. 
If parameters are defined in the Apex method, an attempt is made to deserialize the request body into those parameters. 
If the Apex method has a non-void return type, the resource representation is serialized into the response body.

*/

/*
Apex class methods that are exposed through the Apex REST API don't enforce object permissions and field-level security by default. 
We recommend that you make use of the appropriate object or field describe result methods to check the current user’s access level on the objects and fields that the Apex REST API method is accessing. 
See DescribeSObjectResult Class and DescribeFieldResult Class.
Also, sharing rules (record-level access) are enforced only when declaring a class with the with sharing keyword. 
This requirement applies to all Apex classes, including to classes that are exposed through Apex REST API. 
To enforce sharing rules for Apex REST API methods, declare the class that contains these methods with the with sharing keyword. See Using the with sharing or without sharing Keywords.

*/

/* 

note: the authorization of Rest session can be handled via 

1. traditonal sessionID estalbished after logging in:

curl -H "Authorization: Bearer sessionId" "https://instance.salesforce.com/services/apexrest/Account/accountId"
Replace sessionId with the <sessionId> element that you noted in the login response.
Replace instance with your <serverUrl> element.
Replace accountId with the ID of an account which exists in your organization.

or 
2. OAuth as connected app

//https://www.salesforce.com/us/developer/docs/api_rest/


*/


@RestResource(urlMapping='/Merchandise/*')
global with sharing class MerchandiseManager {



    // The class contains two global static methods defined with Apex REST annotations. All Apex REST methods must be global static. 
    @HttpGet
    global static Merchandise__c getMerchandiseById() {

	    // Note: this function obtains the request and request URI through the Apex static RestContext class.
        RestRequest req = RestContext.request;        
        String merchId = req.requestURI.substring(
                                  req.requestURI.lastIndexOf('/')+1);
        Merchandise__c result = 
                       [SELECT Name,Description__c,Price__c 
                        FROM Merchandise__c 
                        WHERE Id = :merchId];
        return result;
    }




    // @HttpPost annotation. This annotation exposes the method as a REST API and is called when an HTTP POST request is sent from the client.  
    @HttpPost
    global static String createMerchandise(String name,
        String description, Decimal price) {
        Merchandise__c m = new Merchandise__c(
            Name=name,
            Description__c=description,
            Price__c=price);
        insert m;
        return m.Id;
    }
    
    /*
To test the POST method:
	Navigate to: workbench.developerforce.com.
	If prompted for your credentials, enter your login information and click Login.
	For Environment, select Production.
	Accept the terms of service and click Login with Salesforce.
	Click Allow to allow Workbench to access your information.
	After logging in, click utilities | REST Explorer.
	Click POST.
	The URL path that REST explorer accepts is relative to the instance URL of your org, so you only have to provide the path that is appended to the instance URL. In the relative URL box, replace the default URL with /services/apexrest/Merchandise/
	For the request body, insert the following JSON string representation of the object to insert:
	{
	  "name" : "Eraser",
	  "description" : "White eraser",
	  "price" : 0.75,
	  "inventory" : 1000
	}
Note that the field names for the object to create must match and must have the same case as the names of the parameters of the method that will be called.
    
    */
    
    
    
}