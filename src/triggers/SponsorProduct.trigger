trigger SponsorProduct on SponsorProduct__c (after delete) {

    if(Trigger.isAfter && Trigger.isDelete){
        List<Id> productsIdList = new List<Id>();

		for(SponsorProduct__c a : Trigger.old){
			productsIdList.add(a.Id);
		}

		List<ExclusionJoinTable__c> exclusionToDelete = [SELECT Id FROM ExclusionJoinTable__c WHERE ProductID__c IN :productsIdList];
		List<SponsorSiteList__c> preferredSiteListToDelete = [SELECT Id FROM SponsorSiteList__c WHERE SponsorProduct__c IN :productsIdList ];

		if(exclusionToDelete.isEmpty()) {
			return;
		}
		
		Database.delete(exclusionToDelete, false);
		Database.delete(preferredSiteListToDelete, false);
    }

}