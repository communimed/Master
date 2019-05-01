@isTest
public class ExclusionsControllerTest {

	@isTest
	public static void testgetRecordList()
	{
		test.startTest();
		Account sponsor = new Account(Name='Test', Industry='Government', Type='Competitor', language__c ='English',RecordTypeId='012f4000000iYKWAA2');
		insert sponsor;
		SponsorProduct__c product = new SponsorProduct__c(Name='Test', Type__c='OTC', Sponsor__c=sponsor.Id);
		insert product;
		test.stopTest();

		Map<String,Object> insertedAcc =  ExclusionsController.getRecordList();

		Object testAccount = insertedAcc.get('products');

	}

	@isTest
	public static void testgetActiveExclusion()
	{
		
		ExclusionJoinTable__c exlusion = new ExclusionJoinTable__c(ProductID__c = 'Tefdghfdfdghdfhgdst', SponsorID__c='sdfsgfshfh', AccountID__c='0015B00000b9nIqQAI');
		
		test.startTest();
		insert exlusion;
		test.stopTest();

		String objectID = '0015B00000b9nIqQAI';
		String objectType = 'Account';

		Map<String,Object> insertedExclusion = ExclusionsController.getActiveExclusion(objectID, objectType);

	}

	@isTest
	public static void testupdateExclusionsList()
	{
		
		ExclusionJoinTable__c exlusion = new ExclusionJoinTable__c(ProductID__c = 'Tefdghfdfdghdfhgdst', SponsorID__c='sdfsgfshfh', AccountID__c='0015B00000b9nIqQAI');

		List<SponsorProduct__c> listProduct = new List<SponsorProduct__c>();
		List<Account> listAccount = new List<Account>();

		Account sponsor1 = new Account(Name='Test', Industry='Government', Type='Competitor', language__c ='English',RecordTypeId='012f4000000iYKWAA2');
		Account sponsor2 = new Account(Name='Test2', Industry='Government', Type='Competitor', language__c ='English',RecordTypeId='012f4000000iYKWAA2');
		Account sponsor3 = new Account(Name='Test34', Industry='Government', Type='Competitor', language__c ='English',RecordTypeId='012f4000000iYKWAA2');
		Account sponsor4 = new Account(Name='Test4', Industry='Government', Type='Competitor', language__c ='English',RecordTypeId='012f4000000iYKWAA2');

		listAccount.add(sponsor1);
		listAccount.add(sponsor2);
		listAccount.add(sponsor3);

		test.startTest();
		insert exlusion;
		insert listAccount;
		insert sponsor4;

		SponsorProduct__c product1 = new SponsorProduct__c(Name='Test', Type__c='OTC', Sponsor__c=sponsor4.Id);
		SponsorProduct__c product2 = new SponsorProduct__c(Name='Test1', Type__c='OTC', Sponsor__c=sponsor4.Id);
		SponsorProduct__c product3 = new SponsorProduct__c(Name='Test2', Type__c='OTC', Sponsor__c=sponsor4.Id);

		listProduct.add(product1);
		listProduct.add(product2);
		listProduct.add(product3);

		insert listProduct;
		test.stopTest();

		List<String> listAccountID = new List<String>();
		List<String> listProductID = new List<String>();

		for(Account account : listAccount){
			listAccountID.add(account.Id);
		}

		for(SponsorProduct__c product : listProduct){
			listProductID.add(product.Id);
		}

	
		String objectType = 'Account';

		List<ExclusionJoinTable__c> exclusionList = ExclusionsController.updateExclusionsList(exlusion.id, listProductID, listAccountID, objectType);

	}

}