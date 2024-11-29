public class BuyerRequestQuoteRecordWriterInvocabale {
    @InvocableMethod(label = 'Buyer Request Quote Record Writer' iconName='slds:custom:custom67')
    public static List<ToObjectResult> toObject( List<ToObjectRequest> requests ) {
        
        List<ToObjectResult> results = new List<ToObjectResult>();
        
        List<BuyerRequestQuoteInputRepresentation__c> brqirs = new List<BuyerRequestQuoteInputRepresentation__c>();

        for (Integer r = 0; r < requests.size(); r++) {

            ToObjectRequest request = requests[r];

            BuyerRequestQuoteInputRepresentation__c brqir = new BuyerRequestQuoteInputRepresentation__c();

            Map<String,Object> jsonCart = new Map<String,Object>();

            WebCart cart = [SELECT Id,
                                    AccountId,
                                    Contact__c,
                                    OwnerId,
                                    WebStoreId,
                                    PoNumber,
                                    BillingStreet,
                                    BillingCity,
                                    BillingState,
                                    BillingPostalCode,
                                    BillingCountry,
                                    BillingLatitude,
                                    BillingLongitude
                                    //,CurrencyIsoCode
                                FROM WebCart 
                                WHERE Id = :request.cartId  
                                LIMIT 1
            ];

            Id cartDeliveryGroupId = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :cart.Id][0].Id;
            
            List<CartItem> cartItems = [SELECT
                                            AdjustmentAmount,
                                            Product2Id,
                                            Type,
                                            Quantity,
                                            ListPrice,
                                            SalesPrice,
                                            TotalLineAmount
                                        FROM CartItem 
                                        WHERE CartDeliveryGroupId = :cartDeliveryGroupId];

            jsonCart.put('Id',request.cartId);

            jsonCart.put('AccountId',cart.AccountId);
            jsonCart.put('Contact__c',cart.Contact__c);
            jsonCart.put('OwnerId',cart.OwnerId);
            jsonCart.put('WebStoreId',cart.WebStoreId);
            jsonCart.put('cartItems',cartItems);
            
            brqir.Cart__c = request.cartId;
            brqir.JSON__c = JSON.serialize(jsonCart);
            brqir.Status__c = 'Draft';
            brqirs.add(brqir);

            ToObjectResult response = new ToObjectResult();
            response.inputRepresentationID = brqir.Id;
            results.add(response);

        }

        insert brqirs;

        return results;

    }

    public class ToObjectRequest {

        @InvocableVariable(
            label = 'Cart Id'
            required=true
         )
        public ID cartId;

    }

    public class ToObjectResult {

        @InvocableVariable( 
            label = 'Output String'
        )
        public ID inputRepresentationID;

    }

}