@isTest
public class CanadaPostControllerTest {
	
	@isTest
	Public static void testgetAddress()
	{
		
		Account myAcc = new Account(Name='Test', Language__c='English',ShippingStreet='6595 avenue', ShippingCity='Montreal', ShippingState='QC', ShippingCountry='CA', ShippingPostalCode='H2S 2M3');
		test.startTest();
		insert myAcc;
		test.stopTest();

		String prefix = 'Shipping';

		Account insertedAcc =  CanadaPostController.getAddress(myAcc.id, prefix);

		system.assertEquals('6595 avenue', insertedAcc.ShippingStreet);

	}

	@isTest
	Public static void testupdateAddress()
	{
		Account myAcc = new Account(Name='this a test', Language__c='English');
		test.startTest();
		insert myAcc;
		test.stopTest();

		Account insertedAcc = [Select Id, Name, Description FROM Account WHERE id = :myAcc.id];
		insertedAcc.Name = 'this is a new name';
	

		Account result = CanadaPostController.updateAddress(myAcc.id, insertedAcc);

		system.assertEquals('this is a new name', result.Name);

	}

	@isTest
	Public static void testgetInfoPC(){

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		String api = 'testAPI';

		String address = CanadaPostController.getPCAddressList('','',10,10, api);

		String expectedValue = '{"Items":[{"Id":"CA&#124;CP&#124;A&#124;1620329","Text":"6509-11811 Lake Fraser Dr SE","Highlight":"0-4","Cursor":0,"Description":"Calgary, AB, T2J 7J4","Next":"Retrieve"},{"Id":"CA&#124;CP&#124;A&#124;16539667","Text":"6509-1000 Boul Du Beau-Pr\u00E9","Highlight":"0-4","Cursor":0,"Description":"Beaupr\u00E9, QC, G0A 1E0","Next":"Retrieve"},{"Id":"CA&#124;CP&#124;A&#124;16231154","Text":"6509-1429 Sheffield Rd","Highlight":"0-4","Cursor":0,"Description":"Cambridge, ON, N1R 8B2","Next":"Retrieve"},{"Id":"CA&#124;CP&#124;A&#124;17897580","Text":"6509-388 Yonge St","Highlight":"0-4","Cursor":0,"Description":"Toronto, ON, M5B 0A4","Next":"Retrieve"},{"Id":"CA&#124;CP&#124;A&#124;19507109","Text":"6509-168 Rue Fraser","Highlight":"0-4","Cursor":0,"Description":"Rivi\u00E8re-Du-Loup, QC, G5R 0E2","Next":"Retrieve"},{"Id":"CA&#124;CP&#124;A&#124;18766097","Text":"6509-14 York St","Highlight":"0-4","Cursor":0,"Description":"Toronto, ON, M5J 0B1","Next":"Retrieve"},{"Id":"CA&#124;CP&#124;A&#124;20403487","Text":"6509-100 Harbour St","Highlight":"0-4","Cursor":0,"Description":"Toronto, ON, M5J 0B5","Next":"Retrieve"}]}';
        System.assertEquals(address, expectedValue);

	}
}