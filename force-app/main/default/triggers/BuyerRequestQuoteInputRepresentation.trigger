trigger BuyerRequestQuoteInputRepresentation on BuyerRequestQuoteInputRepresentation__c (after insert) {
    
    //Publish Event after creation
    for(BuyerRequestQuoteInputRepresentation__c o : Trigger.New){
        BuyerRequestQuoteInputRepCreated__e event = new BuyerRequestQuoteInputRepCreated__e();
        event.BuyerRequestQuoteInputRepresentation__c = o.Id;
        event.status__c = o.Status__c;
        EventBus.publish(event);
    }
}