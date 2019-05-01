trigger Account on Account (after delete) {
    
    String ACCOUNT_SITE_RECORDTYPE = '012f4000000iYKbAAM';
	String ACCOUNT_SPONSOR_RECORDTYPE = '012f4000000iYKWAA2';

    if(Trigger.isAfter && Trigger.isDelete){
        
        List<Id> accountIdList = new List<Id>();
		List<Id> sponsorIdList = new List<Id>();

		for(Account a : Trigger.old){
			//Check if it's an account Site
			if(a.RecordTypeId == ACCOUNT_SITE_RECORDTYPE){
				accountIdList.add(a.Id);
			}
			//Check if it's an account Sponsor
			// ATTENTION SI ON SUPPRIMER UN SPONSOR, ON DOIT SUPPRIMER SA LISTE ET TOUT LES JOIN RELIÉ À CETTE LISTE
			else if(a.RecordTypeId == ACCOUNT_SPONSOR_RECORDTYPE){
				sponsorIdList.add(a.Id);
			}
		}

		List<ExclusionJoinTable__c> exclusionToDelete = [SELECT Id FROM ExclusionJoinTable__c WHERE AccountID__c IN :accountIdList or SponsorID__c IN :sponsorIdList ];
		List<SponsorSiteListJoinTable__c> preferredSiteListToDelete = [SELECT Id FROM SponsorSiteListJoinTable__c WHERE AccountID__c IN :accountIdList ];
		List<DistributionChainBannerJoinTable__c> preferredChainBannerToDelete = [SELECT Id FROM DistributionChainBannerJoinTable__c WHERE AccountID__c IN :accountIdList ];

		if(!exclusionToDelete.isEmpty()) {
			Database.delete(exclusionToDelete, false);
		}
		else if(!preferredSiteListToDelete.isEmpty()){
			Database.delete(preferredSiteListToDelete, false);
		}
		else if(!preferredChainBannerToDelete.isEmpty()){
			Database.delete(preferredChainBannerToDelete, false);
		}

    }

}