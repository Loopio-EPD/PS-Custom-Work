import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import requestGoNoGoSubmission from '@salesforce/apex/GoNoGoController.requestGoNoGoSubmission';

export default class RequestGoNoGoSubmissionLWC extends NavigationMixin(LightningElement)  {

    @api recordId;

    connectedCallback(){
        setTimeout(() => {
            this.requestSubmission();
        }, 5);
    }

    requestSubmission(){
        if(this.recordId && this.recordId != ''){
            requestGoNoGoSubmission({opportunityId : this.recordId})
            .then(result => {
                if(result){
                    const event = new ShowToastEvent({
                        title: 'Success',
                        variant: 'success',
                        message: 'Go/No-Go Submission requested successfully.'
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
                this.cancelButtonClick();
            }).catch(error=>{
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: error.body.message
                });
                this.dispatchEvent(event);
                this.cancelButtonClick();
            })
        }
    }

    cancelButtonClick(){
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }
}