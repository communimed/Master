public class SponsorSiteListController {
	
	static String ACCOUNT_SITE_RECORDTYPE = '012f4000000iYKbAAM';

	/* ----------------------------------------------------
	* FUNCTION : getSiteList
	* Get non filtred list of all Account Site with pagination
    *
    *------------------------------------------------------*/
	@AuraEnabled
    public static List<Account> getSiteList(String pageSize, String pageNumber) {

		List<Account> result = new List<Account>();

		Integer ps = Integer.valueOf(pageSize);
		Integer pn = Integer.valueOf(pageNumber)-1;

		result = [SELECT Name, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode,
				(SELECT Name, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode FROM ChildAccounts WHERE RecordTypeId =: ACCOUNT_SITE_RECORDTYPE ORDER BY Name ASC)
					FROM Account WHERE RecordTypeId =: ACCOUNT_SITE_RECORDTYPE AND ParentId = null ORDER BY Name ASC LIMIT :ps OFFSET :(ps*pn)];

		return result;
	}

	/* ----------------------------------------------------
	* FUNCTION : getSiteSelected
	* Get selected Site Selected for a site liste record ID
    * Need to keep track of the pagination number of the parent 
	* In order to make it work with the interface
    *------------------------------------------------------*/
	@AuraEnabled
    public static List<String> getSiteSelected(String pageSize, String recordID) {

		List<String> preferredSiteList = new List<String>();
		Map<String, Integer> AllAccountsMap = new Map<String, Integer>();
		Decimal ps = Decimal.valueOf(pageSize);
		
		// GET ALL ACCOUNT AND MAP BY ID AND POSITION - GET THE POSITION OF THE RECORD ACCOUNT INSIDE THE NORMAL PAGINATION
		try{

			List<Account> allAccount = [SELECT Name, Id, (SELECT Name, Id FROM ChildAccounts WHERE RecordTypeId =: ACCOUNT_SITE_RECORDTYPE ORDER BY Name ASC)
										FROM Account WHERE RecordTypeId =: ACCOUNT_SITE_RECORDTYPE AND ParentId = null ORDER BY Name ASC];

			Integer i = 1;
			for(Account a : allAccount){	
				if(a.ChildAccounts != null){
					AllAccountsMap.put(a.Id, i);
					//Add the same page number to the Child
					for(Account child : a.ChildAccounts){
						AllAccountsMap.put(child.Id, i);
					}
					i++;
				}
				else{
					AllAccountsMap.put(a.Id, i);
					i++;
				}
			}


			for(SponsorSiteListJoinTable__c a : [SELECT AccountID__c, Name FROM SponsorSiteListJoinTable__c WHERE SponsorSiteListID__c =: recordID]){

				Decimal key = Decimal.valueOf(AllAccountsMap.get(a.AccountID__c));

				Decimal page = key.divide(ps, 4);

				System.debug(key+' - '+page);
				preferredSiteList.add(a.AccountID__c+'-'+page.round(System.RoundingMode.UP));
			}
		}
		catch (Exception e){
			throw new AuraHandledException('Error message -> '+e.getMessage()+' -> Line :'+e.getLineNumber()+' -> Please contact your Salesforce Administrator.');
		}
		
		return preferredSiteList;
	}
	
	/* ----------------------------------------------------
	* FUNCTION : saveSiteSelection
	* Save the Account Selection for one Site List
	* 
    *------------------------------------------------------*/
	@AuraEnabled
    public static List <SponsorSiteListJoinTable__c> saveSiteSelection(String recordID, List<String> siteListSelected) {

		List<SponsorSiteListJoinTable__c> newSiteList = new List<SponsorSiteListJoinTable__c>();

		// DELETE ALL RELATED ITEM FOR THIS recordID (site List) in the Join table
		try{
			List<SponsorSiteListJoinTable__c> activeRecord = [SELECT Id FROM SponsorSiteListJoinTable__c WHERE SponsorSiteListID__c =: recordID];
			Delete activeRecord;
		
			//Insert new selection by concatening the list inside a set in order to eliminate duplicate
			if(siteListSelected.isEmpty()) {return newSiteList;}

			//Concat in a set to eliminate duplicate
			Set<String> concatList = new Set<String>();

			concatList.addAll(siteListSelected);
			siteListSelected.clear();
			siteListSelected.addAll(concatList);
		
			for (String accountID : siteListSelected) {
				SponsorSiteListJoinTable__c site = new SponsorSiteListJoinTable__c();
				site.SponsorSiteListID__c = recordID;
				site.AccountID__c = accountID;
				newSiteList.add(site);
			}		

			Insert newSiteList;
		}
		catch (Exception e){
			throw new AuraHandledException('Error message -> '+e.getMessage()+' -> Line :'+e.getLineNumber()+' -> Please contact your Salesforce Administrator.');

		}

		return newSiteList;
	}

	/* ----------------------------------------------------
	* FUNCTION : getPostalCodeListFiltred
	* Filter a list of postal code received by the user, clean up and send bac statistique
	* 
    *------------------------------------------------------*/
	@AuraEnabled
	public static Object getPostalCodeListFiltred (String postalCodeList){

		List<String> cleanedList = new List<String>();
		List<String> nonValidList = new List<String>();
		Map<String,Object> listMap = new Map<String,Object>();
		Integer numReceived = 0;
		String postalCodeRegex = '^(?!.*[DFIOQU])[A-VXY][0-9][A-Z] ?[0-9][A-Z][0-9]$';

		try{
			if(String.isEmpty(postalCodeList)){
				return new Map<String, Integer>{'numReceived' => 0, 'numNonValid' => 0, 'numListFiltred' => 0};
			}

			for(String a : postalCodeList.split('\n')){
				if(String.isEmpty(a)){continue;}
				numReceived++;
				String cleanPC = a.normalizeSpace().touppercase();
				if(Pattern.matches(postalCodeRegex, cleanPC)){
					cleanedList.add(cleanPC);
				}
				else{
					nonValidList.add(a);
				}
			}

			Integer numNonValid = numReceived-(cleanedList.size());
		 
			List<Account> listFiltred = [SELECT Name, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode,
						(SELECT Name, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode FROM ChildAccounts WHERE RecordTypeId =: ACCOUNT_SITE_RECORDTYPE AND ShippingPostalCode IN :cleanedList ORDER BY Name ASC)
							FROM Account WHERE RecordTypeId =: ACCOUNT_SITE_RECORDTYPE AND ShippingPostalCode IN :cleanedList ORDER BY Name ASC];
			
			
			Set<Id> listParentToRemove = new Set<Id>();

			for(Account a : listFiltred){
				if(a.ChildAccounts != null){
					for(Account child : a.ChildAccounts){
						listParentToRemove.add(child.id);
					}
				}
			}

			Integer j = 0;

			while (j < listFiltred.size()){
				
				if(listParentToRemove.contains(listFiltred.get(j).Id)){
					listFiltred.remove(j);
				}
    			j++;
  			}
			
			// Si un ID dans un Child est présent dans la liste, remove list 
			
			Integer numListFiltred = listFiltred.size();

			listMap.put('sponsors', listFiltred);
			listMap.put('numReceived', numReceived);
			listMap.put('numNonValid', numNonValid);
			listMap.put('numListFiltred', numListFiltred);
			listMap.put('nonValidList', nonValidList);
				
		}
		catch (Exception e){
			throw new AuraHandledException('Error message -> '+e.getMessage()+' -> Line :'+e.getLineNumber()+' -> Please contact your Salesforce Administrator.');
		}

		return listMap;
	}
}