({
	  
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