({
    /* ----------------------------------------------------
	* FUNCTION : getAccountSite
    * Get the account list for the page required and preprare
    * data for the treegrid
    *
    *------------------------------------------------------*/
	getAccountSite : function(component, helper){

        var self = this; 
        var action = component.get("c.getSiteList");
        action.setStorable();

        var pageSize = component.get("v.pageSize").toString();
        var pageNumber = component.get("v.pageNumber").toString();

        action.setParams({
            'pageSize' : pageSize,
            'pageNumber' : pageNumber
        });

		action.setCallback(this, function(response) {
			
			const state = response.getState();

			if (state === "SUCCESS") {
                
                var response = response.getReturnValue();

                if(response.length < component.get("v.pageSize")){
                    component.set("v.isLastPage", true);

                } else{
                    component.set("v.isLastPage", false);
                }
             
                // Change ChildAccounts for _children (expected by treegrid) and add the page number to the Id 
                response.forEach(function(row){
                    if(row.ChildAccounts != null){
                        row._children = row.ChildAccounts;
                        delete row.ChildAccounts;
                        
                        row._children.forEach(function(rowChil){
                            rowChil.Id = rowChil.Id+'-'+pageNumber;
                        });
                    
                    } 
                    row.Id = row.Id+'-'+pageNumber;
                });
            
                component.set("v.resultSize", response.length);
                component.set("v.data", response);
                
                //Set selected rows with our selection attribute which has id of each attribute and expend all
                var tree = component.find('siteListGridTree');
                tree.set("v.selectedRows",component.get("v.selection"));
                tree.expandAll();
			}
			else {
                self.errorMessage(response, component);
            }
        });

        $A.enqueueAction(action);

    },

    /* ----------------------------------------------------
	* FUNCTION : getSelectedSite
	* Get all selected Sites for this list (RecordID)
    *
    *------------------------------------------------------*/
	getSelectedSite : function(component, helper){
        
        var self = this;
		var action = component.get("c.getSiteSelected");
	   
		action.setParams({
            "pageSize"  : component.get("v.pageSize").toString(),
            "recordID"	: component.get("v.recordId")
        });

		action.setCallback(this, function(response) {
            
            const state = response.getState();
            
			if (state === "SUCCESS") {
                
                component.set('v.selection', response.getReturnValue());
			}
			else {
                self.errorMessage(response, component);
            }
        });

        $A.enqueueAction(action);
	},

    /* ----------------------------------------------------
	* FUNCTION : updateSelectedSite
	* Save the new preferred sites selected on the treegrid
    *
    *------------------------------------------------------*/
    updateSelectedSite: function(component, helper, siteListSelected){

        var self = this;
        var action = component.get("c.saveSiteSelection");

        action.setParams({
			"recordID"	: component.get("v.recordId"),
			"siteListSelected" : siteListSelected
		});
		
		action.setCallback(this, function(response) {
			
            const state = response.getState();
            
			if (state === "SUCCESS") {
				helper.toastMessage('Preferred Sites List Updated', 'Your new configuration has been successfully saved !', 'success');
			}
			else {
				self.errorMessage(response, component);
            }
        });

        $A.enqueueAction(action);
    },
    
    /* ----------------------------------------------------
	* FUNCTION : errorMessage
	* Show error message received from an ajax call
    * Need :  <lightning:notificationsLibrary aura:id="notifLib"/>
    *------------------------------------------------------*/
    errorMessage : function(response, component){
        
        var errors = response.getError();
        var msgText = 'Unknow error, please contact your administrator';

        if (errors) {
            if (errors[0] && errors[0].message) {
                msgText = errors[0].message;	
            }
        }

        component.find('notifLib').showNotice({
            "variant": "error",
            "header": "Something has gone wrong!",
            "message": msgText
        });

    },

    /* ----------------------------------------------------
	* FUNCTION : toastMessage
	* toast Message from Controller or Helper
    *
    *------------------------------------------------------*/
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