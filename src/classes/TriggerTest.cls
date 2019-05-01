@isTest
private class TriggerTest {
	
	@isTest static void AccountTrigger() {
			
		String ACCOUNT_SITE_RECORDTYPE = '012f4000000iYKbAAM';
		String ACCOUNT_SPONSOR_RECORDTYPE = '012f4000000iYKWAA2';

		Account sponsor = new Account(Name='Test', Industry='Gouvernment', Type='Competitor', language__c ='English', RecordTypeId=ACCOUNT_SPONSOR_RECORDTYPE);
		Account site = new Account(Name='Test', Industry='Gouvernment', Type='Competitor', language__c ='English', RecordTypeId=ACCOUNT_SITE_RECORDTYPE);

		test.startTest();
		insert sponsor;
		insert site;

		// Test Exclusion Table
		ExclusionJoinTable__c exclusion = new ExclusionJoinTable__c(AccountID__c = site.Id, SponsorID__c=sponsor.Id );
		insert exclusion;

		SponsorProduct__c Product = new SponsorProduct__c(Name='Test', Type__c='OTC', Sponsor__c=sponsor.Id);
		insert Product;

		// Create a sponsor Site List
		SponsorSiteList__c sponsorList = new SponsorSiteList__c(name='Test site List', SponsorProduct__c=Product.Id);
		insert sponsorList;

		SponsorSiteListJoinTable__c SponsorJoinList = new SponsorSiteListJoinTable__c(AccountID__c=site.Id, SponsorSiteListID__c=sponsorList.Id);
		insert SponsorJoinList;

		delete sponsor;
		delete site;
		test.stopTest();
	}

	@isTest static void SponsorSiteListTriggerActive() {

		String ACCOUNT_SITE_RECORDTYPE = '012f4000000iYKbAAM';
		String ACCOUNT_SPONSOR_RECORDTYPE = '012f4000000iYKWAA2';
		List<SponsorSiteList__c> SitesList = new List<SponsorSiteList__c>();


		test.startTest();
			
			Account Sponsor = new Account(Name='TestSponsor', Industry='Gouvernment', Type='Competitor', language__c ='English', RecordTypeId=ACCOUNT_SPONSOR_RECORDTYPE);

			insert Sponsor;

			SponsorProduct__c Product = new SponsorProduct__c(Name='Test', Type__c='OTC', Sponsor__c=Sponsor.Id);

			insert Product;

			SponsorSiteList__c spsl = new SponsorSiteList__c();
			spsl.Name = 'Name A';
			spsl.SponsorProduct__c = Product.Id;
			spsl.Active__c = true;

			insert spsl;

			SponsorSiteList__c spsl2 = new SponsorSiteList__c();
			spsl2.Name = 'Name B';
			spsl2.SponsorProduct__c = Product.Id;
			spsl2.Active__c = true;

			try {
           		insert spsl2;
			}
			catch(Exception e) {
				System.assert(e.getMessage().contains('You can\'t have 2 actives lists for a same Product. Please verify the following list :Name A'));
			}

		test.stopTest();
	}

	@isTest static void SponsorSiteListTriggerDelete() {

		String ACCOUNT_SITE_RECORDTYPE = '012f4000000iYKbAAM';
		String ACCOUNT_SPONSOR_RECORDTYPE = '012f4000000iYKWAA2';
		
		List<SponsorSiteList__c> SitesList = new List<SponsorSiteList__c>();
		
		test.startTest();
			Account Sponsor = new Account(Name='TestSponsor', Industry='Gouvernment', Type='Competitor', language__c ='English', RecordTypeId=ACCOUNT_SPONSOR_RECORDTYPE);
			insert Sponsor;
			
			SponsorProduct__c Product = new SponsorProduct__c(Name='Test', Type__c='OTC', Sponsor__c=Sponsor.Id);
			Account site = new Account(Name='Test', Industry='Gouvernment', Type='Competitor', language__c ='English', RecordTypeId=ACCOUNT_SITE_RECORDTYPE);
			insert site;
			insert Product;

			SponsorSiteList__c spsl = new SponsorSiteList__c();
			spsl.Name = 'Name A';
			spsl.SponsorProduct__c = Product.Id;
			spsl.Active__c = false;

			insert spsl;

			SponsorSiteListJoinTable__c SponsorJoinList = new SponsorSiteListJoinTable__c(AccountID__c=site.Id, SponsorSiteListID__c=spsl.Id);
			insert SponsorJoinList;

			delete spsl;

		test.stopTest();
	}

	@isTest static void SponsorProductTriggerDelete()
	{

		test.startTest();

			Account Account = new Account(Name='Test', Industry='Gouvernment', Type='Competitor', language__c ='English',RecordTypeId='012f4000000iYKWAA2');
			insert Account;

			SponsorProduct__c product = new SponsorProduct__c(Name = 'Test', Type__c='OTC', Sponsor__c=Account.Id);
			insert product;

			ExclusionJoinTable__c newExclusion = new ExclusionJoinTable__c(ProductID__c=product.ID, AccountID__c=Account.Id);
			insert newExclusion;

			delete product;
			
		test.stopTest();

	}


	@isTest static void ContactTriggerDelete()
	{

		test.startTest();

			Contact Contact = new Contact(LastName='Test', language__c ='English');
			insert Contact;
		
			ExclusionJoinTable__c newExclusion = new ExclusionJoinTable__c(ContactID__c=Contact.Id);
			insert newExclusion;

			delete Contact;
			
		test.stopTest();

	}
	
}