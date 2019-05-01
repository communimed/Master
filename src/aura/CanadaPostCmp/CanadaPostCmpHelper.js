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
    },


    showMap : function(component) {
        //Destroying existing mapComponent if exist
        var mapComponent = component.find('mapComponent');
        if(mapComponent){
            mapComponent.destroy();
        }
        //Get mapContainer Div to dynamically generate map
        //and push it in div body
        var mapContainer = component.find('mapContainer');
        var mapBody = mapContainer.get("v.body");
        var address = component.get('v.updatedAccount');

        var addressPrefix = component.get('v.addressPrefix');

        

        if(addressPrefix == "Shipping"){
            component.set('v.mapMarkers', [
                {
                    location: {
                        Street: address.ShippingStreet,
                        City: address.ShippingCity,
                        State: address.ShippingState,
                        Country: address.ShippingCountry,
                        PostalCode: address.ShippingPostalCode
                    }
                }
            ]);
        }

        else if(addressPrefix == "Billing"){
            component.set('v.mapMarkers', [
                {
                    location: {
                        Street: address.BillingStreet,
                        City: address.BillingCity,
                        State: address.BillingState,
                        Country: address.BillingCountry,
                        PostalCode: address.BillingPostalCode
                    }
                }
            ]);

        }



        $A.createComponent(
            "lightning:map",
            {
                //passing attribute values to dynamic map component
                "aura:id" : 'mapComponent',//aura:id of dynamic map component
                "mapMarkers" : component.get('v.mapMarkers'),
                "zoomLevel" : 14,
                "showFooter" : 'false'
            },
            function(lightningMap){  
                //Adding map component body to div element
                mapBody.push(lightningMap);
                mapContainer.set("v.body", mapBody); 
            
        });

        
            
    }
    
})