({
    
    setColumn : function(component){
    
		var columnProduct = [
            {
                type: 'text',
                fieldName: 'Name',
                label: 'Product Name'
            },
            {
                type: 'text',
                fieldName: 'Sponsor_Name',
                label: 'Sponsor'
            },
            {
                type: 'text',
                fieldName: 'Type__c',
                label: 'Type'
            }
        ];

        var columnSponsor = [
            {
                type: 'text',
                fieldName: 'Name',
                label: 'Sponsor Name'
            },
            {
                type: 'text',
                fieldName: 'Industry',
                label: 'Industry'
            },
            {
                type: 'text',
                fieldName: 'Type',
                label: 'Type'
            }
        ];


        component.set('v.sponsorColumns', columnSponsor);
        component.set('v.productColumns', columnProduct);
    
    },
    
    errorMessage : function(response){
        
        var errors = response.getError();
        if (errors) {
            if (errors[0] && errors[0].message) {
                this.toastMessage('Error', errors[0].message, 'error');	
            }
        }
        else{
            this.toastMessage('Error', 'Unknown error', 'error');
        }  

    },

    toastMessage : function(title, message, type){

        var toastEvent = $A.get("e.force:showToast");

            toastEvent.setParams({
                title: title,
                type: type,
                message: message
            });
	
		toastEvent.fire();
	}
})