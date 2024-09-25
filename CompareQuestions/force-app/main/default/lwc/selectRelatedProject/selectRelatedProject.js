import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';


export default class SelectRelatedProject extends LightningElement {
    @api recordId;
    disableContinueButton = true;
    selectedAccountId = '';
    @api relatedProjectId = '';

    lookupRecord(event){
        this.selectedAccountId = '';
        this.relatedProjectId = '';
        this.disableContinueButton = true;
        if(event && event.detail && event.detail.selectedRecord && JSON.parse(JSON.stringify(event.detail.selectedRecord)).Id){
            this.relatedProjectId = JSON.parse(JSON.stringify(event.detail.selectedRecord)).Id;
            this.disableContinueButton = false;
        }
    }

    lookupAccountRecord(event){
        this.selectedAccountId = '';
        this.relatedProjectId = '';
        this.disableContinueButton = true;
        if(event && event.detail && event.detail.selectedRecord && JSON.parse(JSON.stringify(event.detail.selectedRecord)).Id){
            this.selectedAccountId = JSON.parse(JSON.stringify(event.detail.selectedRecord)).Id;
        }
    }

    continueClick(){
        if(this.relatedProjectId && this.relatedProjectId != ''){
            // this[NavigationMixin.Navigate]({
            //     type: "standard__component",
            //     attributes: {
            //         componentName: "c__NavigationConnector"
            //     },
            //     state: {
            //         c__projectid: this.relatedProjectId,
            //         c__recordid: this.recordId
            //     }
            // });

            // var compDetails = {
            //     componentDef: "c:compareQuestions",
            //     attributes: {
            //         //Value you want to pass to the next lwc component
            //         relatedprojectid: this.relatedProjectId,
            //         currentprojectid: this.recordId
            //     }
            // };
            // // Base64 encode the compDefinition JS object
            // var encodedCompDetails = btoa(JSON.stringify(compDetails));
            // this[NavigationMixin.Navigate]({
            //     type: 'standard__webPage',
            //     attributes: {
            //         url: '/one/one.app#' + encodedCompDetails
            //     }
            // });

            var urlToRedirect = "/lightning/n/Compare_Questions_Tab?c__relatedprojectid="+this.relatedProjectId+"&c__currentprojectid="+this.recordId;
            window.open(urlToRedirect,'_self');

        }
        else{
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: 'Please select the related project.'
            });
            this.dispatchEvent(event);
        }
    }

    cancelButtonClick(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}