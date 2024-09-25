import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import runBatchFromApex from '@salesforce/apex/RFxIntegrationSchedular.runIntegrationBatch';

export default class RFxIntegrationPage extends LightningElement {

    showSpinner = false;

    runBatch(){
            this.showSpinner = true;
            runBatchFromApex()
            .then(result => {
                if(result){
                    const event = new ShowToastEvent({
                        title: 'Success',
                        variant: 'success',
                        message: 'Batch processed successfully.'
                    });
                    this.dispatchEvent(event);
                }
                else{
                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        message: 'Something went wrong. Please try again later.'
                    });
                    this.dispatchEvent(event);
                }
                this.showSpinner = false;
            }).catch(error=>{
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: error.body.message
                });
                this.dispatchEvent(event);
                this.showSpinner = false;
            })
        }
}