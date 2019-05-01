({
	 /* ----------------------------------------------------
	* FUNCTION : doInit
	* Prepare grid + get Account list + get Selection
    *
    *------------------------------------------------------*/
	doInit: function (component, event, helper) {

		component.set('v.columns', [

			{
                type: 'text',
                fieldName: 'Name',
                label: 'Account Site'
            },
            {
                type: 'text',
                fieldName: 'ShippingStreet',
                label: 'Street'
            },
            {
                type: 'text',
                fieldName: 'ShippingCity',
                label: 'City'
			},
			{
                type: 'text',
                fieldName: 'ShippingState',
                label: 'Province'
			},
			{
                type: 'text',
                fieldName: 'ShippingPostalCode',
                label: 'Postal Code'
            }
		]);
		
		helper.getAccountSite(component, helper);
		helper.getSelectedSite(component, helper);
	},

	/* ----------------------------------------------------
	* FUNCTION : onPageChanged
	* Next and previous action for pagination
    *
    *------------------------------------------------------*/
	onPageChanged : function(component, event, helper) {          

		var btnClicked = event.getSource().get('v.label');
	
        var pageNumber = component.get("v.pageNumber");
     	
		//Trick to not get the object by reference
		var siteListSelected = JSON.parse(JSON.stringify(component.get('v.selection')));
		var emptySelection = true;
		
		var i = siteListSelected.length;
		while (i--) {
			if(siteListSelected[i].split("-")[1] == pageNumber){
				emptySelection = false;
				break;
			}
		}
		// FIX : Problem with TreeGrid, OnRowSelection Event is not called on the new page if the 
		// page before has no checkbox selected. So we do not set v.hasPageChange to true in that case
		// because the event won<t be call and won't change the value in the else statement
		if(!emptySelection){
			component.set("v.hasPageChanged", true);
		}
        
		if(btnClicked == 'Prev'){
			component.set("v.pageNumber", pageNumber-1);
		}
		else if(btnClicked == 'Next'){
			component.set("v.pageNumber", pageNumber+1);
		}
		
        helper.getAccountSite(component, helper);
	},

	 /* ----------------------------------------------------
	* FUNCTION : onRowSelection
	* Event on row selection, prepare v.selection base on the
    * actual page
    *------------------------------------------------------*/
    onRowSelection : function(component, event, helper) {
		
		console.log('Page : '+component.get("v.hasPageChanged")+'  Toggle : '+component.get("v.hasToggleClosed"));

        if(!component.get("v.hasPageChanged") && !component.get("v.hasToggleClosed")){
			
			//Get currently select rows, This will only give the rows available on current page
            var selectedRows = event.getParam('selectedRows');
            
            //Get all selected rows from datatable, this will give all the selected data from all the pages
            var allSelectedRows = component.get("v.selection");
            
            //Get current page number
            var currentPageNumber = component.get("v.pageNumber");
            
            //Process the rows now
            //Condition 1 -> If any new row selected, add to our allSelectedRows attribute
            //Condition 2 -> If any row is deselected, remove from allSelectedRows attribute
            //Solution - Remove all rows from current page from allSelectedRows attribute and then add again
    
            //Removing all rows coming from curent page from allSelectedRows
            var i = allSelectedRows.length;
            while (i--) {
                var pageNumber = allSelectedRows[i].split("-")[1];
                if (pageNumber && pageNumber == currentPageNumber) { 
                    allSelectedRows.splice(i, 1);
                } 
            }
            
            //Adding all the new selected rows in allSelectedRows
            selectedRows.forEach(function(row) {
                allSelectedRows.push(row.Id);
            });

            //Setting new value in selection attribute
			component.set("v.selection", allSelectedRows);
			
        } else{
			component.set("v.hasPageChanged", false);
			component.set("v.hasToggleClosed", false);
        }
    },

	/* ----------------------------------------------------
	* FUNCTION : saveSelection
	* Save the selection and merge the initial selection 
    * with the new selection for filters
    *------------------------------------------------------*/
	saveSelection: function (component, event, helper) {
	
		//Trick to not get the object by reference
		var siteListSelected = JSON.parse(JSON.stringify(component.get('v.selection')));

		// NEED TO MERGE THE INITIIAL LIST WITH THE NEW LIST IF FILTER ACTIVE
	 	if (component.get('v.filterActive')){
			var siteListSelectedInitial = JSON.parse(JSON.stringify(component.get('v.selectionCopy')));

			// Remove Page number
			siteListSelectedInitial.forEach(function(value, index, array){
				siteListSelectedInitial[index] = value.split("-")[0];
			});

			siteListSelected = [...siteListSelected, ...siteListSelectedInitial];
		}

		// Remove Page number
		siteListSelected.forEach(function(value, index, array){
			siteListSelected[index] = value.split("-")[0];
		});

		helper.updateSelectedSite(component, helper, siteListSelected);
		
	},

	/* ----------------------------------------------------
	* FUNCTION : reloadSelection
	* Reload the selection to activate the opening toggle
    * 
    *------------------------------------------------------*/
	reloadToggle: function(component, event, helper){

		var isExpended = event.getParam('isExpanded');

		if(!isExpended){
			component.set("v.hasToggleClosed", true);
		}
		else{
			component.set("v.hasToggleClosed", false);
		}
		
		component.set("v.selection",component.get("v.selection"));
	},

	/* ----------------------------------------------------
	* FUNCTION : handleShowModal
	* Open Model for the filter 
    * 
    *------------------------------------------------------*/
	handleShowModal: function(component, evt, helper) {

		$A.createComponent("c:SponsorSiteListModal", 
			{"siteListDataChild":component.getReference("v.siteListData")},
			
			function(content, status) {
				
				if (status === "SUCCESS") {
					
					component.find('overlayLib').showCustomModal({
						header: "Postal Code Filter",
						body: content, 
						showCloseButton: true
					})
				}                               
			}
		);
	},
	
	/* ----------------------------------------------------
	* FUNCTION : handleShowModal
	* Display new data received from SiteListFilter
    * No pagination is added
    *------------------------------------------------------*/
	handleFilter: function(component, event, helper) {

		var filtredList = event.getParam('siteListDataFitred');

		var filterStats = {
			numListFiltred : filtredList.numListFiltred,
			numNonValid : filtredList.numNonValid,
			numReceived : filtredList.numReceived,
			nonValidList : filtredList.nonValidList
		}

		// Change ChildAccounts for _children (expected by treegrid) and add 
		// the page number 1 (no pagination for Filter)
		var FiltredListID = Array();

		filtredList.sponsors.forEach((row) => {
			if(row.ChildAccounts != null){
				row._children = row.ChildAccounts;
				delete row.ChildAccounts;
				
				row._children.forEach(function(rowChil){
					FiltredListID.push(rowChil.Id);
					rowChil.Id = rowChil.Id+'-1';
				});
			}
			FiltredListID.push(row.Id);
			row.Id = row.Id+'-1';
		})

		// Add One page only (-1) to all Filtred Selection and keep copye without page
		var filtredSelection = component.get('v.selection');
		var SelectionListID = Array();

		var i = filtredSelection.length;
		while (i--) {
			var Id = filtredSelection[i].split("-")[0];
			filtredSelection[i] = Id+'-1';

			SelectionListID.push(Id);
		}

		// Keep a copy of the initial Selection without the filtred Data in order to combien both array later 
		var selectionCopyWithoutFiltredData = SelectionListID.filter( function(el) {
			return !FiltredListID.includes(el);
		});

		// Enlever ce qui a été reçu du filter
		component.set('v.selectionCopy', selectionCopyWithoutFiltredData);

		// Set the filter
		component.set('v.data',filtredList.sponsors);
		component.set('v.filterStats', filterStats);
		component.set('v.filterActive', true);

		var tree = component.find('siteListGridTree');
    	tree.expandAll();
			
		component.set('v.selection', filtredSelection);
	},

	/* ----------------------------------------------------
	* FUNCTION : handleClearFilter
	* Clear Filter and call doInit to reset 
    *------------------------------------------------------*/
	handleClearFilter: function(component, event, helper) {

		let getdata = component.get("c.doInit");
		$A.enqueueAction(getdata);

		component.set('v.filterActive', false);

	},

	/* ----------------------------------------------------
	* FUNCTION : handleFilterInvalidModal
	* Show invalid Postal Code in a modal
    *------------------------------------------------------*/
	handleFilterInvalidModal: function(component, event, helper) {

		event.preventDefault();

		var list = component.get("v.filterStats");
		var formatedList = "";

		for (var i = 0; i < list.nonValidList.length; i++) {
			formatedList += list.nonValidList[i]+'<br/> ';
		}

		$A.createComponent("ui:outputRichText", 
			{"value":formatedList},
			
			function(content, status) {
				
				if (status === "SUCCESS") {
					
					component.find('overlayLib').showCustomModal({
						header: "Non valid postal codes",
						body: content, 
						showCloseButton: true
					})
				}                               
			}
		);
	},

	exportExcel : function(component, event, helper){
		alert('This feature will come later, thank you');
	}

})