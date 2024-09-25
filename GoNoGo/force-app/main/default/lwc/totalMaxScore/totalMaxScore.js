import { LightningElement,api,track } from 'lwc';
import getTotalMaxScore from '@salesforce/apex/GoNoGoController.getTotalMaxScore'

export default class TotalMaxScore extends LightningElement {
    @api recordId;
    messageString;
    actualScore;
    showMessageString = false;

    connectedCallback(){
        setTimeout(() => {
            this.loadInitialData();
        }, 5);
    }

    loadInitialData(){
        if(this.recordId && this.recordId != ''){
            getTotalMaxScore({recordId : this.recordId})
            .then(result => {
                if(result && result.label && result.value){
                    this.messageString = "This " + result.label + " has a total maximum score of ";
                    this.actualScore = result.value;
                    this.showMessageString = true;
                }
            }).catch(error=>{ })
        }
    }
}