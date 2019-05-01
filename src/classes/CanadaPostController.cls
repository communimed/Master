public with sharing class CanadaPostController {

	@AuraEnabled
    public static Account getAddress(Id recordId, String addressPrefix) {

		String queryString = 'SELECT '+addressPrefix+'Street, '
										+addressPrefix+'City, '
										+addressPrefix+'State, '
										+addressPrefix+'PostalCode, '
										+addressPrefix+'Country FROM Account WHERE id = :recordId limit 1';

		Account Address = Database.query(queryString);

		return Address;
    }

	@AuraEnabled
    public static Account updateAddress(Id recordId, Account updatedAccount) {

		try{
			updatedAccount.Id = recordId;

			update updatedAccount;
        	return updatedAccount;
		}
		catch (Exception e){
			throw new AuraHandledException('Error message -> '+e.getMessage()+' -> Line :'+e.getLineNumber()+' -> Please contact your Salesforce Administrator.');
		}
    }


	@AuraEnabled
	public static String getPCAddressList(String Term, String Id, Integer MaxSuggestions, Integer MaxResults, String ApiKey){


		String key 					= ApiKey;
		String searchTerm 			= EncodingUtil.urlEncode(Term,'UTF-8');
		String searchFor			= 'Places';
		String country 				= 'CAN';
		String languagePreference 	= 'en';
		String responseBody;

		Http http = new Http();
		HttpRequest request = new HttpRequest();

		request.setEndpoint('http://ws1.postescanada-canadapost.ca/AddressComplete/Interactive/Find/v2.10/json3.ws?Key='+Key+
							'&SearchTerm='+searchTerm+
							'&SearchFor='+searchFor+
							'&Country='+country+
							'&LanguagePreference'+languagePreference+
							'&MaxSuggestions'+MaxSuggestions+
							'&MaxResults'+MaxResults+
							'&LastId='+Id
							);

		request.setMethod('GET');
		
		HttpResponse response = http.send(request);


		// If the request is successful, parse the JSON response.
		if (response.getStatusCode() == 200) {
			responseBody = response.getBody();
			system.debug(responseBody);
			return responseBody;
		}

		else{
			throw new AuraHandledException('Error with the API call');
		}		
	}

}