trigger BuyerRequestQuoteInputRepresentationCreatedEvent on BuyerRequestQuoteInputRepCreated__e (after insert) {
    
    for (BuyerRequestQuoteInputRepCreated__e event : Trigger.New) {
        System.debug('recordId: ' + event.BuyerRequestQuoteInputRepresentation__c);
        System.debug('status: ' + event.status__c);

        //Add Event fields at flow parameters
        Map<String, Object> Params = new Map<String, Object>();
        Params.put('recordId',event.BuyerRequestQuoteInputRepresentation__c);
        Params.put('status','Active');

        //create instance of Interview
        Flow.Interview.Buyer_Request_Quote_Input_Representation_Status_Update run = new Flow.Interview.Buyer_Request_Quote_Input_Representation_Status_Update(Params);
        
        //Invoke start method
        run.start();

    }
}