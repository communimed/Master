@isTest
public class SponsorSiteListControllerTest
{

	@isTest
	public static void testgetSiteList(){

		Account accountSite = new Account(Name='Test', ShippingStreet='Gouvernment', RecordTypeId='012f4000000iYKbAAM', language__c='English');

		test.startTest();
			insert accountSite;
		test.stopTest();

		List<Account> insertedAcc =  SponsorSiteListController.getSiteList('5','1');
	}

	@isTest
	public static void testgetSiteSelected(){

		List<String> preferredSiteList = new List<String>();

		test.startTest();

			List<Account> AccountSiteList = new List<Account>();
			
			for(Integer i=0; i<10; i++) {
				Account acc 		= new Account();
				acc.Name    		= 'Site Account' + i; 
				acc.RecordTypeId    ='012f4000000iYKbAAM'  ;
				acc.language__c 	= 'English';
				AccountSiteList.add(acc);
			}
			insert AccountSiteList;

			Account childAccount = new Account(Name='Site Account A', ParentId=AccountSiteList[0].Id ,RecordTypeId='012f4000000iYKbAAM', language__c='English');
			insert childAccount;

			Account accountSponsor = new Account(Name='Account Sponsor test', RecordTypeId='012f4000000iYKWAA2', language__c='English');
			insert accountSponsor;
			
			SponsorProduct__c Product = new SponsorProduct__c(Name='Test', Type__c='OTC', Sponsor__c=accountSponsor.Id);
			insert Product;

			SponsorSiteList__c sponsorList = new SponsorSiteList__c(name='Test site List', SponsorProduct__c=Product.Id);
			insert sponsorList;

			List<SponsorSiteListJoinTable__c> SponsorJoinList = new List<SponsorSiteListJoinTable__c>();
			
			for(Account a : AccountSiteList){
				SponsorSiteListJoinTable__c joinObj = new SponsorSiteListJoinTable__c();
				joinObj.AccountID__c=a.Id;
				joinObj.SponsorSiteListID__c=sponsorList.Id;
			}
			insert SponsorJoinList;

			String recordId = sponsorList.Id;
			String pageSize = '5';

			preferredSiteList = SponsorSiteListController.getSiteSelected(pageSize, recordId);
				
		test.stopTest();
	}

	@isTest
	public static void testsaveSiteSelection(){

		List<String> selection = new List<String>();
		selection.add('sdfsdfsd');
		selection.add('sdfsdfsasdfd');

		String recordId = 'Gouvernment';

		SponsorSiteListController.saveSiteSelection(recordId, selection);

	}

	@isTest
	public static void testgetPostalCodeListFiltred()
	{
		String postalcode = 'sdfsafs \n dsfsfsd \n sfsdfsfs \n sdfsdf \n';

		SponsorSiteListController.getPostalCodeListFiltred (postalcode);

	}
}