import { api, LightningElement, track, wire } from 'lwc';
import fetchLookupData from '@salesforce/apex/GoNoGoController.getSObjectList';
import fetchDefaultRecord from '@salesforce/apex/GoNoGoController.fetchDefaultRecord';

export default class CustomLookupComponent extends LightningElement {
    @api objName;
    @api iconName;
    @api filter = '';
    @api searchPlaceholder='Search';
    @track selectedName;
    @track records;
    @track isValueSelected;
    @track blurTimeout;
    @api defaultRecordId;
    @api fromAura = false;
    @api restrictToRemove = false;
    searchTerm;
    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';

    connectedCallback(){
        this.loadInitialData();
    }

   @api
   loadInitialData(){
        if(this.defaultRecordId != ''){
            fetchDefaultRecord({ recordId: this.defaultRecordId , 'sObjectApiName' : this.objName })
            .then((result) => {
                if(result != null){
                let selectedId = result.Id;
                let selectedName = result.Name;
                const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  selectedId });
                this.dispatchEvent(valueSelectedEvent);
                this.isValueSelected = true;
                this.selectedName = selectedName;
                if(this.blurTimeout) {
                    clearTimeout(this.blurTimeout);
                }
                this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
                }
            })
            .catch((error) => {
            alert('error');
            console.log(error);
                this.error = error;
            });
        }
   }

    @wire(fetchLookupData, {searchKey : '$searchTerm', objectName : '$objName'})
    wiredRecords({ error, data }) {
        if (data) {
            this.error = undefined;
            this.records = data;
        } else if (error) {
            this.error = error;
            this.records = undefined;
        }
    }
    handleClick() {
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }

    onBlur() {
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
    }

    onSelect(event) {
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  selectedId });
        this.dispatchEvent(valueSelectedEvent);
        this.isValueSelected = true;
        this.selectedName = selectedName;
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
         //dispatch event to parent
         if(this.fromAura){
            const selectedEvent = new CustomEvent("ownervaluechange", {
                detail : {selectedRecId:selectedId}
            });
            this.dispatchEvent(selectedEvent);   
         }
         else{
            const selectedEvent = new CustomEvent("ownervaluechange", {
                detail : selectedId
            });
            this.dispatchEvent(selectedEvent);   
         }
        
    }

    handleRemovePill() {
        this.isValueSelected = false;
        //dispatch event to parent
        const selectedEvent = new CustomEvent("ownervaluechange", {
            detail : ''
        });
        this.dispatchEvent(selectedEvent);
    }

    onChange(event) {
        this.searchTerm = event.target.value;
    }
}