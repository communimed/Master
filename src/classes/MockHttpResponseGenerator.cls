@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
	// Implement this interface method
	global HTTPResponse respond(HTTPRequest req) {
		
		// Create a fake response
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody('{"Items":[{"Id":"CA&#124;CP&#124;A&#124;1620329","Text":"6509-11811 Lake Fraser Dr SE","Highlight":"0-4","Cursor":0,"Description":"Calgary, AB, T2J 7J4","Next":"Retrieve"},{"Id":"CA&#124;CP&#124;A&#124;16539667","Text":"6509-1000 Boul Du Beau-Pr\u00E9","Highlight":"0-4","Cursor":0,"Description":"Beaupr\u00E9, QC, G0A 1E0","Next":"Retrieve"},{"Id":"CA&#124;CP&#124;A&#124;16231154","Text":"6509-1429 Sheffield Rd","Highlight":"0-4","Cursor":0,"Description":"Cambridge, ON, N1R 8B2","Next":"Retrieve"},{"Id":"CA&#124;CP&#124;A&#124;17897580","Text":"6509-388 Yonge St","Highlight":"0-4","Cursor":0,"Description":"Toronto, ON, M5B 0A4","Next":"Retrieve"},{"Id":"CA&#124;CP&#124;A&#124;19507109","Text":"6509-168 Rue Fraser","Highlight":"0-4","Cursor":0,"Description":"Rivi\u00E8re-Du-Loup, QC, G5R 0E2","Next":"Retrieve"},{"Id":"CA&#124;CP&#124;A&#124;18766097","Text":"6509-14 York St","Highlight":"0-4","Cursor":0,"Description":"Toronto, ON, M5J 0B1","Next":"Retrieve"},{"Id":"CA&#124;CP&#124;A&#124;20403487","Text":"6509-100 Harbour St","Highlight":"0-4","Cursor":0,"Description":"Toronto, ON, M5J 0B5","Next":"Retrieve"}]}');
		res.setStatusCode(200);
		return res;
	}
}