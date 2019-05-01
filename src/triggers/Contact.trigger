trigger Contact on Contact (after delete) {

     if(Trigger.isAfter && Trigger.isDelete){
         
        List<Id> contactIdList = new List<Id>();

		for(Contact a : Trigger.old){
			contactIdList.add(a.Id);
		}

		List<ExclusionJoinTable__c> exclusionToDelete = [SELECT Id FROM ExclusionJoinTable__c WHERE ContactID__c IN :contactIdList];

		if(exclusionToDelete.isEmpty()) {
			return;
		}

		Database.DeleteResult[] deleteResults = Database.delete(exclusionToDelete, false);

    }

}