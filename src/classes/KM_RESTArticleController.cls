/* Class Name   : KM_RESTArticleController for  UpsertArticle ,RetreiveArticle, SearchArticle (pagenation?) 
 * Project / CR:  KM Implementation
 * Description  : Controller for restful call for Article
 * Created By   : Ivan Yeung
 * Created On   : 4/20/2015

 * end point: https://instance.salesforce.com/services/apexrest/Article

 * Note: this rest controller is trying to follow the best practice of REST API implementation captured by Roy Thomas Fielding
 * ref: https://www.youtube.com/watch?v=ZpqCN8iO9Y8
 * Uniform interface 
 *      1. Identification of resources - Article(s)
 *      2. Manipulations of these resources 
           Ideally, we can take advantage of different URL endpoints: 
                e.g. 
                SearchArticle : URI = https://instance.salesforce.com/services/apexrest/Article
                CreateArticle : URI = https://instance.salesforce.com/services/apexrest/Article
                RetreiveArticleByID : URI = https://instance.salesforce.com/services/apexrest/Article/{articleID}
         
         
         
 *      3. Self Descriptive
 *      4. Hyermedia as the engine of application state: SubResourceUris  - it can be useful for AEM integrations
 
 * Note: 
 * ref: https://developer.salesforce.com/page/Secure_Coding_Guideline


 * Modification Log:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date                   Modification ID      Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 */

@RestResource(urlMapping='/Article/*')
global with sharing class KM_RESTArticleController {

	/*
		Methods annotated with @HttpGet or @HttpDelete should have no parameters. This is because GET and DELETE requests have no request body
	*/
    @HttpGet
    global static Account doGet() {
        RestRequest req = RestContext.request;  
        RestResponse res = RestContext.response;
        String articleExtId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Account result = [SELECT Id, Name, Phone, Website FROM Account WHERE Id = :articleExtId];
        return result;
    }
    
    /*
    
         //create the kav instance 
        FAQ__kav a = new FAQ__kav(
            Title = 'test apex',
            Summary = 'test from apex',
            Answer__c = 'test',
            Question__c = 'test',
            Category__c = 'test',
            URLName = 'test'
        );
 
        insert a;
        //retrieve master article Id created on FAQ__kav record insertion
        //in order to get the KnowledgeArticleId
        a = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :a.Id];
        
        
        //publish it
        KbManagement.PublishingService.publishArticle(a.KnowledgeArticleId, true);
    */

}