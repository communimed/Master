({
	/* -----------------------------
	FUNCTION : init
	Set the column of the treegrid and get all the products List from server
	-------------------------------*/
	init: function (component, event, helper) {

		/* Set columns of the treegrids (Product & Sponsors) */
		helper.setColumn(component);


		/* Get Product List  */
		
		var action = component.get("c.getRecordList");

		action.setCallback(this, function(response) {
			
			var state = response.getState();

			if (state === "SUCCESS") {
				var response = response.getReturnValue();
				
				/* Set Product and get exclusions */
				var products = response['products'];

				for(var i = 0; i < products.length; i++) {	
					products[i]['Sponsor_Name'] = products[i]['Sponsor__r']['Name'];	
				}
				component.set('v.productData',products);

				/* Set Sponsors and get exclusions */
				var sponsors = response['sponsors'];
				//Change "ChildAccounts" key to "_children"
                for (var i=0; i<sponsors.length; i++ ) {
					if(sponsors[i]['ChildAccounts'] != null){
						sponsors[i]._children = sponsors[i]['ChildAccounts'];
                   		delete sponsors[i].ChildAccounts;
					}  	
                }
				component.set('v.sponsorData', sponsors);

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

	/* -----------------------------
	FUNCTION : getExclusion (called from Init)
	Get que ID of the Product assigned to the
	Account ID in the Join Table ExcludedACProduct__c
	-------------------------------*/
	getExlusions : function(component, event, helper){

		/*var tree = component.find('sponsorListId');
		tree.expandAll();*/

		var action = component.get("c.getActiveExclusion");
	   
		action.setParams({
			"objectID"	: component.get("v.recordId"),
			"objectType": component.get("v.objectType")
        });

		action.setCallback(this, function(response) {
			
			var state = response.getState();
			if (state === "SUCCESS") {
				var response = response.getReturnValue();
				console.dir(response);
				component.set('v.sponsorSelectedRows', response['sponsors']);
				component.set('v.productSelectedRows', response['products']);	
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

	/* -----------------------------
	FUNCTION : updateSelection
	Update attribute v.productSelectedRows when a line is checked
	-------------------------------*/
	updateSelection : function(component, event, helper){
		
		var sourceId = event.getSource().getLocalId();
	
		var activeRows = event.getParam('selectedRows');

		var tempArray = [];

		for (var i = 0; i < activeRows.length; i++) {
			tempArray.push(activeRows[i].Id);
		}

		if(sourceId == 'productListId'){
			component.set("v.productSelectedRows", tempArray);
		}
		else if (sourceId == 'sponsorListId'){
			component.set("v.sponsorSelectedRows", tempArray);
		}
			
	},
	
	updateExclusionForm : function(component, event, helper) {
			helper.toastMessage('Exclusions updated', 'Your new configuration has been successfully saved !', 'success');
	},


	/* -----------------------------
	FUNCTION : saveSelection
	Delete all reference of the accountID Or ContactID in table JoinExcludedProduct__c and 
	add new Produt ID
	-------------------------------*/
	saveSelection: function (component, event, helper) {
	
		var listProduct = component.get('v.productSelectedRows');
		var listSponsor = component.get('v.sponsorSelectedRows');

		var action = component.get('c.updateExclusionsList');

		action.setParams({
			"objectID"	: component.get("v.recordId"),
			"listProduct" : listProduct,
			"listSponsor" : listSponsor,
			"objectType": component.get("v.objectType")
        });

		action.setCallback(this, function(response) {
			
			var state = response.getState();
			if (state === "SUCCESS") {
				helper.toastMessage('Exclusions updated', 'Your new configuration has been successfully saved !', 'success');
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

	}
})