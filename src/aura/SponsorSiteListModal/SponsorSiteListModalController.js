({
	handleCancel : function(component, event, helper) {
        //closes the modal or popover from the component
		component.find("overlayLib").notifyClose();
	},
	
    handleFilter : function(component, event, helper) {
	
		var postalCodeList = component.get("v.postalCodeList");

		if($A.util.isEmpty(postalCodeList)){
			helper.toastMessage('Warning','Please insert one or more postal codes', 'warning');
			return;
		}

		var action = component.get('c.getPostalCodeListFiltred');

		action.setParams({
			"postalCodeList" : postalCodeList
        });

		action.setCallback(this, function(response) {
			
			var state = response.getState();

			if (state === "SUCCESS") {
				
				var response = response.getReturnValue();

				var filterEvent = $A.get("e.c:SponsorSiteListFilter");
				filterEvent.setParams({"siteListDataFitred": response});
				filterEvent.fire();
				
				component.find("overlayLib").notifyClose();

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