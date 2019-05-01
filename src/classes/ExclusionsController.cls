public with sharing class ExclusionsController {

	@AuraEnabled
    public static Map <string,object> getRecordList() {

		List<SponsorProduct__c> productList = [SELECT Name,Sponsor__r.Name,Type__c FROM SponsorProduct__c ORDER BY Name ASC];
		
		List<Account> sponsorList = [SELECT Name, Industry, Type, 
										(SELECT Name, Industry, Type FROM ChildAccounts WHERE RecordTypeId = '012f4000000iYKWAA2' ORDER BY Name ASC)
									FROM Account WHERE RecordTypeId = '012f4000000iYKWAA2' AND ParentId = null ORDER BY Name ASC];


		Map<String,Object> resultMap = new Map<String,Object>();

		resultMap.put('products',productList);
		resultMap.put('sponsors',sponsorList);

		return resultMap;

	}

	@AuraEnabled
    public static Map<String,Object> getActiveExclusion(String objectID, String objectType) {

		List<String> exclusionProductList = new List<String>();
		List<String> exclusionSponsorList = new List<String>();
		Map<String,Object> resultMap = new Map<String,Object>();
		String objField;

		if(objectType == 'Account'){objField = 'AccountID__c';}
		else if(objectType == 'Contact'){objField = 'ContactID__c';}
		else{return resultMap;}//Should throw an error

		/* Query for all exclusions (products & Sponsors) for a Contact or Account ID */
		String queryString = 'SELECT ProductID__c, SponsorID__c FROM ExclusionJoinTable__c WHERE '+objField+' =: objectID';

		List<ExclusionJoinTable__c> ExclusionIdList = Database.query(queryString);

		for(ExclusionJoinTable__c a : ExclusionIdList){
			exclusionProductList.add(a.ProductID__c);
			exclusionSponsorList.add(a.SponsorID__c);
		}

		resultMap.put('products', exclusionProductList);
		resultMap.put('sponsors', exclusionSponsorList);

		return resultMap;

	}
	
	@AuraEnabled
    public static List <ExclusionJoinTable__c> updateExclusionsList(String objectID, List<String> listProduct, List<String> listSponsor,  String objectType) {
		
		List<ExclusionJoinTable__c> exclusionList = new List<ExclusionJoinTable__c>();

		//Create a function for this part
		String objField;
		if(objectType == 'Account'){objField = 'AccountID__c';}
		else if(objectType == 'Contact'){objField = 'ContactID__c';}
		else{return exclusionList;}//Should throw an error

		// DELETE ALL RELATED ITEM FOR THIS ObjectID in the Join table
		String queryString = 'SELECT Id FROM ExclusionJoinTable__c WHERE '+objField+' =: objectID';

		List<ExclusionJoinTable__c> activeRecord = Database.query(queryString);

		Database.delete(activeRecord, false);


		//INSERT NEW EXCLUSISONS FOR PRODUCT

		if(listProduct.isEmpty() && listSponsor.isEmpty()) {return exclusionList;}
		
		for (String productID : listProduct) {
			ExclusionJoinTable__c productList = new ExclusionJoinTable__c();
			if(objField == 'AccountID__c'){
				productList.AccountID__c = objectID;
			}
			else if(objField == 'ContactID__c'){
				productList.ContactID__c = objectID;
			}
			productList.ProductID__c = productID;
			exclusionList.add(productList);
		}

		for (String sponsorID : listSponsor) {
			ExclusionJoinTable__c sponsorList = new ExclusionJoinTable__c();
			if(objField == 'AccountID__c'){
				sponsorList.AccountID__c = objectID;
			}
			else if(objField == 'ContactID__c'){
				sponsorList.ContactID__c = objectID;
			}
			sponsorList.SponsorID__c = sponsorID;
			exclusionList.add(sponsorList);
		}

		Database.insert(exclusionList, false);
		
		return exclusionList;
		
	}

}