({
	
	/* ----------------------------------------------
	-- Load address from RecordId
	-----------------------------------------------*/
    doInit: function(component, event, helper) {
	
		//Config
		var addressType = component.get("v.addressType");
		var addressPrefix = addressType.split(" ")[0];
		component.set('v.addressPrefix', addressPrefix);


		//Get Address
		var action = component.get("c.getAddress");

        action.setParams({
			"recordId"		: component.get("v.recordId"),
			"addressPrefix" : addressPrefix
        });
       
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

				var response = response.getReturnValue();

				//Set adress in address fiels and clear search field
				component.set('v.updatedAccount', response);
				component.set('v.searchAddress', "");
				helper.showMap(component);
				
            }
            else {
				var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
						helper.toastMessage('Error', errors[0].message, 'error');	
                    }
				}
				else{
					helper.errorMessage(response);
				}	
            }
        });

		$A.enqueueAction(action);
		
	
	},


	/* ----------------------------------------------
	-- Update new address
	-----------------------------------------------*/
	updateAddressCmp: function(component, event, helper){

        var action = component.get("c.updateAddress");

        action.setParams({
			"recordId"		: component.get("v.recordId"),
			"updatedAccount": component.get("v.updatedAccount")
        });
       
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

				helper.showMap(component);
				helper.toastMessage('Address updated', 'The new address has been updated.', 'success');
            }
            else {
				helper.errorMessage(response);
            }
        });

        $A.enqueueAction(action);
	},
	

	/* ----------------------------------------------
	-- Get Post Canada API results
	-----------------------------------------------*/
	getItems : function(component, event, helper) {

		var seachTerm		= component.get('v.searchAddress');

		// If searchTerm under 3 caracters or odd - no call to API
		if(seachTerm.length%2 == 0 || seachTerm.length < 3){
			if(seachTerm.length == 0){
				component.set("v.results", []);
			}
			return;
		}

		var placeId			= "";
		var maxSuggestion 	= 10;
		var maxResults		= 10;
		
     
		var action = component.get("c.getPCAddressList");

        action.setParams({
			"Term" 				: seachTerm,
			"Id"				: placeId,
			"MaxSuggestions" 	: maxSuggestion,
			"MaxResults" 		: maxResults,
			"ApiKey"			: component.get("v.apiKey")
        });
       
		action.setCallback(this, function(response) {
			
			var state = response.getState();
			
			if (state === "SUCCESS") {
				var resp = JSON.parse(response.getReturnValue());

				if(resp.Items[0].hasOwnProperty('Error')){
					helper.toastMessage(resp.Items[0].Description, resp.Items[0].Cause+" "+resp.Items[0].Resolution, 'error');
				}
				else{
					component.set('v.results', resp.Items);
				}
			}
			else {
				
				helper.errorMessage(response);
					
            }
        });

        $A.enqueueAction(action);
	},

	/* ----------------------------------------------
	-- Clear and hide result on blur
	-----------------------------------------------*/
	hideResults : function(component, event, helper){
		setTimeout(function(){component.set("v.results", []);}, 300);
	
	},

	/* ----------------------------------------------
	-- Set the selected addres in the address fields 
	or select a pack of address from one location
	-----------------------------------------------*/
	setAddress: function(component, event, helper){

		var selectedItem 	= event.currentTarget;
		var next 			= selectedItem.dataset.next;

		if(next == 'Retrieve'){
			
			var text 		= selectedItem.dataset.text;
			var description = selectedItem.dataset.description;
		
			var splitDesc 	= description.split(", ");
			var addressPrefix = component.get('v.addressPrefix');
		
			component.set("v.updatedAccount."+addressPrefix+"Street", text);
			component.set("v.updatedAccount."+addressPrefix+"City", splitDesc[0]);
			component.set("v.updatedAccount."+addressPrefix+"State", splitDesc[1]);
			component.set("v.updatedAccount."+addressPrefix+"PostalCode", splitDesc[2]);
			component.set("v.updatedAccount."+addressPrefix+"Country", 'Canada');
			

			component.set("v.results", []);
			component.set('v.searchAddress', "");
		}

		else if(next == "Find"){
			
			var placeId 		= selectedItem.dataset.placeid;
			var seachTerm		= "";
			var maxSuggestion 	= 10;
			var maxResults		= 100;
		
			var action = component.get("c.getPCAddressList");

			action.setParams({
				"Term" 				: seachTerm,
				"Id"				: placeId,
				"MaxSuggestions" 	: maxSuggestion,
				"MaxResults" 		: maxResults,
				"ApiKey"			: component.get("v.apiKey")
			});
		
			action.setCallback(this, function(response) {
				
				var state = response.getState();
				
				if (state === "SUCCESS") {
					var resp = JSON.parse(response.getReturnValue());

					if(resp.Items[0].hasOwnProperty('Error')){
						helper.toastMessage(resp.Items[0].Description, resp.Items[0].Cause+" "+resp.Items[0].Resolution, 'error');
					}
					else{
						component.set('v.results', resp.Items);
					}
				}
				else {
					helper.errorMessage(response);
				}
			});

			$A.enqueueAction(action);

		}	
	}
})