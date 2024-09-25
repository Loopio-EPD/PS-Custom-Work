import { LightningElement,api } from 'lwc';
import getLinkedSubmissions from '@salesforce/apex/GoNoGoController.getLinkedSubmissions';

export default class ScoreBreakdownScreen extends LightningElement {
    @api recordId;
    showData = false;
    linkedSubmissionsWrapperList = [];

    connectedCallback(){
        setTimeout(() => {
            this.loadInitialData();
        }, 5);
    }

    loadInitialData(){
        if(this.recordId && this.recordId != ''){
            getLinkedSubmissions({submissionId : this.recordId})
            .then(linkedResult => {
                if(linkedResult && linkedResult.length){
                    this.linkedSubmissionsWrapperList = linkedResult;
                    this.showData = true;
                }
            }).catch(error=>{})
        }
    }
}