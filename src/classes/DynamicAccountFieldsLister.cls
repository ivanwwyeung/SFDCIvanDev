/* example from visualforce developer guide */

public class DynamicAccountFieldsLister {

/*

Visualforce automatically optimizes the SOQL query performed by a page’s StandardController (or StandardSetController), loading only the fields which are actually used on a page. When you create a Visualforce page with static references to objects and fields, the fields and objects can be known in advance. When the page is saved, Visualforce is able to determine and save which objects and fields need to be added to the SOQL query that the StandardController will perform later, when the page is requested.
Dynamic references are evaluated at runtime, after the SOQL query is run by the StandardController. If a field is only used via a dynamic reference, it won’t be automatically loaded. When that dynamic reference is later evaluated, it will resolve to data which is missing, the result of which is a SOQL error. You must provide some extra information to the controller, so that it knows what fields and related objects to load.
You can add any number of additional fields to a StandardController query, by using the addFields() method on the page controller to pass in the list of additional fields to load. In the prior example, this is done in the controller extension’s constructor:
    public DynamicAccountFieldsLister(ApexPages.StandardController controller) { 
        controller.addFields(editableFields);
    }


Adding fields to a controller is only required if you’re using the default query for a StandardController or StandardSetController. If your controller or controller extension performs its own SOQL query, using addFields() is unnecessary and has no effect.


*/


    public DynamicAccountFieldsLister(ApexPages.StandardController controller) { 
        controller.addFields(editableFields);
    }

    public List<String> editableFields {
        get {
            if (editableFields == null) {
                editableFields = new List<String>();
                editableFields.add('Industry');
                editableFields.add('AnnualRevenue');
                editableFields.add('BillingCity');
            }
            return editableFields ;
        }
        private set;
    }
}