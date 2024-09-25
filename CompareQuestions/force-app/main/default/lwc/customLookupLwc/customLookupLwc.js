import { LightningElement,api,wire,track} from 'lwc';
// import apex method from salesforce module 
import fetchLookupData from '@salesforce/apex/CompareQuestionsController.fetchLookupData';
import fetchDefaultRecord from '@salesforce/apex/CompareQuestionsController.fetchDefaultRecord';

const DELAY = 300; // dealy apex callout timing in miliseconds  

export default class CustomLookupLwc extends LightningElement {
    // public properties with initial default values 
    @api iconName = 'standard:user';
   @api defaultRecordId;
   @api isprojectselected = false;
   @api sObjectApiName = 'Account';
   @api selectedaccountid ='';
   @api currentprojectid = '';
    // private properties 
    lstResult = []; // to store list of returned records   
    hasRecords = true; 
    searchKey=''; // to store input field value    
    isSearchLoading = false; // to control loading spinner  
    delayTimeout;
    @track selectedRecord = {}; // to store selected lookup record in object formate 



    connectedCallback(){
         if(this.defaultRecordId != ''){
            fetchDefaultRecord({ recordId: this.defaultRecordId})
            .then((result) => {
                if(result != null){
                    this.selectedRecord = result;
                    this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
                }
            })
            .catch((error) => {
              alert('error');
              console.log(error);
                this.error = error;
                this.selectedRecord = {};
            });
         }
    }

    // wire function property to fetch search record based on user input
    @wire(fetchLookupData, { searchKey: '$searchKey', sObjectApiName : '$sObjectApiName', selectedaccountid : '$selectedaccountid', currentprojectid : '$currentprojectid' })
     searchResult(value) {
        const { data, error } = value; // destructure the provisioned value
        this.isSearchLoading = false;
        if (data) {
             this.hasRecords = data.length == 0 ? false : true; 
             this.lstResult = JSON.parse(JSON.stringify(data)); 
         }
        else if (error) {
            console.log('(error---> ' + JSON.stringify(error));
         }
    };
       
    @api
    setUserRecord(strString) {
      console.log('IN Child call: '+strString);
      this.selectedRecord = JSON.parse(strString);
      console.log(this.selectedRecord);
      this.handelSelectRecordHelper();
    }

  // update searchKey property on input field change  
    handleKeyChange(event) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        this.isSearchLoading = true;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
        this.searchKey = searchKey;
        }, DELAY);
    }


    // method to toggle lookup result section on UI 
    toggleResult(event){
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute('data-source');
        switch(whichEvent) {
            case 'searchInputField':
                clsList.add('slds-is-open');
               break;
            case 'lookupContainer':
                clsList.remove('slds-is-open');    
            break;                    
           }
    }

   // method to clear selected lookup record 
   @api 
   handleRemove(){
    this.searchKey = '';    
    this.selectedRecord = {};
    this.lookupUpdatehandler(undefined);
    
    // remove selected pill and display input field again 
    const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
    searchBoxWrapper.classList.remove('slds-hide');
    searchBoxWrapper.classList.add('slds-show');

    const pillDiv = this.template.querySelector('.pillDiv');
    pillDiv.classList.remove('slds-show');
    pillDiv.classList.add('slds-hide');

    //dispatch event to parent
    const selectedEvent = new CustomEvent("ownervaluechange", {
      detail : ''
    });
    this.dispatchEvent(selectedEvent);
  }

  // method to update selected record from search result 
handelSelectedRecord(event){   
     var objId = event.target.getAttribute('data-recid'); // get selected record Id 
     this.selectedRecord = this.lstResult.find(data => data.Id === objId); // find selected record from list 
     console.log('selectedRecord: '+JSON.stringify(this.selectedRecord));
     this.lookupUpdatehandler(this.selectedRecord); // update value on parent component as well from helper function 
     this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
}

/*COMMON HELPER METHOD STARTED*/

handelSelectRecordHelper(){
    this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');

     const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
     searchBoxWrapper.classList.remove('slds-show');
     searchBoxWrapper.classList.add('slds-hide');

     const pillDiv = this.template.querySelector('.pillDiv');
     pillDiv.classList.remove('slds-hide');
     pillDiv.classList.add('slds-show'); 

    //dispatch event to parent
    const selectedEvent = new CustomEvent("ownervaluechange", {
      detail : this.selectedRecord.Id
    });
    this.dispatchEvent(selectedEvent);    
} 

lookupUpdatehandler(value){    
  const oEvent = new CustomEvent('lookupupdate',
  {
      'detail': {selectedRecord: value}
  }
);
this.dispatchEvent(oEvent);
}

  @api 
  handleselectedaccountid(accId){
    this.selectedaccountid = accId;
  }
}