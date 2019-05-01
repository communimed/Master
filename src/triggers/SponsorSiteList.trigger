trigger SponsorSiteList on SponsorSiteList__c (before insert, before update, after delete) {
    
    //Check if another Site List is activated. Only one Site List can be activated

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        
        for (SponsorSiteList__c updatedSiteList : Trigger.new) {
        
            if(updatedSiteList.Active__c == true){

                for(SponsorSiteList__c listWithSameProduct : [SELECT id, Name, Active__c FROM SponsorSiteList__c WHERE SponsorProduct__c =: updatedSiteList.SponsorProduct__c]){

                    if(listWithSameProduct.Active__c == true){
                        updatedSiteList.Active__c.addError('You can\'t have 2 actives lists for a same Product. Please verify the following list :'+listWithSameProduct.Name);
                    }
                }
            }
        }
    }

     //Deleted the Site Liste reference in the jointe table : SponsorSiteListJoinTable__c
    else if(Trigger.isAfter && Trigger.isDelete ){

        List<Id> siteListId = new List<Id>();

        for(SponsorSiteList__c deletedList : Trigger.old){
            siteListId.add(deletedList.Id);
        }

        List<SponsorSiteListJoinTable__c> preferredSiteToDeleted = [SELECT Id FROM SponsorSiteListJoinTable__c WHERE SponsorSiteListID__c IN :siteListId];

        System.debug(preferredSiteToDeleted);

        if(preferredSiteToDeleted.isEmpty()) {
            return;
        }

        Database.DeleteResult[] deleteResults = Database.delete(preferredSiteToDeleted, false);

    }
}