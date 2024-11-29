public class BuyerRequestQuoteRecordReaderInvocabale {
    @InvocableMethod(label = 'Buyer Request Quote Record reader')
    public static List<FromObjectResult> toObject( List<FromObjectRequest> requests ) {
        
        List<FromObjectResult> results = new List<FromObjectResult>();

        for (Integer r = 0; r < requests.size(); r++) {

            FromObjectRequest request = requests[r];
            
            FromObjectResult response = new FromObjectResult();
          
            BuyerRequestQuoteInputRepresentation__c brqir = [SELECT 
                                                JSON__c,
                                                Status__c
                                            FROM BuyerRequestQuoteInputRepresentation__c 
                                            WHERE Id = :request.inputRepresentationID
                                            LIMIT 1];

            Map<String, Object> jsonCart = (Map<String, Object>) JSON.deserializeUntyped(brqir.JSON__c);

            String AccountId = (String) jsonCart.get('AccountId');
            String ContactId = (String) jsonCart.get('Contact__c');
            String OwnerId = (String) jsonCart.get('OwnerId');
            String WebStoreId = (String) jsonCart.get('WebStoreId');
            String contactName = [SELECT Name FROM Contact WHERE Id = :ContactId LIMIT 1].Name;
            String webStoreName = [SELECT Name FROM WebStore WHERE Id = :WebStoreId LIMIT 1].Name;
            String currencyIsoCode = [SELECT CurrencyIsoCode FROM Account WHERE Id = :AccountId LIMIT 1].CurrencyIsoCode;
            String PricebookId = [SELECT StrikethroughPricebookId FROM WebStore WHERE Id = :WebStoreId LIMIT 1].StrikethroughPricebookId;

            //String BuyerGroupId = [SELECT BuyerGroupId FROM BuyerGroupMember WHERE BuyerId = :AccountId AND BuyerGroupId IN  (SELECT BuyerGroupId FROM WebStoreBuyerGroup WHERE WebStoreId = :AccountId) LIMIT 1].BuyerGroupId;
            // BuyerGroupId 0ZI7Q000000MASIWA4
            //String Pricebook2Id = [SELECT Pricebook2Id FROM BuyerGroupPricebook WHERE BuyerGroupId = :BuyerGroupId LIMIT 1].Pricebook2Id;
            // Pricebook2Id 01s7Q00000K6n7cQAB

            Quote q = new Quote();    
            q.ContactId = ContactId;
            q.Name = contactName + ' - Quote Request';
            q.Description = contactName + ' - Quote Request isuue from ' + webStoreName;
            q.Status = 'Draft';
            q.CurrencyIsoCode = currencyIsoCode;
            q.Pricebook2Id = PricebookId;

            insert q;    

            List<QuoteLineItem> quoteLines = new List<QuoteLineItem>();

            List<Object> objects = (List<Object>) jsonCart.get('cartItems');
            for (Object o : objects) {
                Map<String, Object> cartItem = (Map<String, Object>) o;
                if(cartItem.get('Type') == 'Product') {
                    Decimal AdjustmentAmount = (Decimal) cartItem.get('AdjustmentAmount');
                    Decimal ListPrice = (Decimal) cartItem.get('ListPrice');
                    String Product2Id = (String) cartItem.get('Product2Id');
                    Decimal Quantity = (Decimal) cartItem.get('Quantity');
                    Decimal SalesPrice = (Decimal) cartItem.get('SalesPrice');
                    Decimal TotalLineAmount = (Decimal) cartItem.get('TotalLineAmount');
                    Decimal AjustedSalesPrice = ( ( SalesPrice * Quantity ) + AdjustmentAmount ) / Quantity; // AdjustmentAmount is = to Line Adjustment 

                    PricebookEntry PricebookEntry = [SELECT Id,Pricebook2Id,Product2Id,ProductCode,UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :PricebookId AND UnitPrice = :ListPrice AND Product2Id = :Product2Id AND CurrencyIsoCode = :currencyIsoCode LIMIT 1];

                    QuoteLineItem ql = new QuoteLineItem();
                    ql.QuoteId = q.Id;
                    ql.Product2Id = Product2Id;
                    ql.Quantity = Quantity;
                    ql.PricebookEntryId = PricebookEntry.Id;
                    ql.UnitPrice = ListPrice;
                    ql.Discount = ( 1 - ( AjustedSalesPrice / ListPrice ) ) * 100;

                    quoteLines.add(ql);
                }
            }

            insert quoteLines;

            response.AccountId = AccountId;
            response.ContactId = ContactId;
            response.WebStoreId = WebStoreId;
            response.contactName = contactName;
            response.webStoreName = webStoreName;
            response.QuoteId = q.Id;
            response.OrgDomainUrl = Url.getOrgDomainUrl().toExternalForm();
            results.add(response);

        }

        return results;
    }

    public class FromObjectRequest {

        @InvocableVariable( 
            label = 'Input Representation ID'
        )
        public ID inputRepresentationID;

    }

    public class FromObjectResult {

        @InvocableVariable(
            label = 'AccountId'
            )
        public String AccountId;

        @InvocableVariable(
            label = 'ContactId'
            )
        public String ContactId;

        @InvocableVariable(
            label = 'WebStoreId'
            )
        public String WebStoreId;

        @InvocableVariable(
            label = 'contactName'
            )
        public String contactName;
        
        @InvocableVariable(
            label = 'webStoreName'
            )
        public String webStoreName;

        @InvocableVariable(
            label = 'QuoteId'
            )
        public String QuoteId;
        
        @InvocableVariable(
            label = 'OrgDomainUrl'
            )
        public String OrgDomainUrl;
    }
}