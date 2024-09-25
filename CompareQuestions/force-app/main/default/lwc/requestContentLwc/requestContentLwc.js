import { LightningElement,api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import savesyncrequest from '@salesforce/apex/RequestContentController.savesyncrequest'
import { NavigationMixin } from 'lightning/navigation';

export default class RequestContentLwc extends NavigationMixin(LightningElement) {
    showSpinner = false;

    questionvalue;
    needvalue;
    priorityvalue;

    get priorityoptions() {
        return [
            { label: 'High', value: 'High' },
            { label: 'Medium', value: 'Medium' },
            { label: 'Low', value: 'Low' },
        ];
    }

    handleQuestionChange(event) {
        this.questionvalue = event.detail.value;
    }

    handleNeedChange(event) {
        this.needvalue = event.detail.value;
    }

    handlePriorityChange(event) {
        this.priorityvalue = event.detail.value;
    }

    saveRequest(){
        this.showSpinner= true;
        
        if(!this.questionvalue || !this.needvalue || !this.priorityvalue){
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: 'Please fill all the data.'
            });
            this.dispatchEvent(event);
            this.showSpinner = false;
            return;
        }

        savesyncrequest({
            questionvalue :  this.questionvalue , needvalue : this.needvalue , priorityvalue : this.priorityvalue
        })
        .then(result=>{
            if(result && result.isSuccess && result.recordId){    
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result.recordId,
                        actionName: 'view',
                    },
                }).then((url) => {
                    const event = new ShowToastEvent({
                        title: 'Success',
                        variant: 'success',
                        message: 'Library Sync Request created successfully. {0} to open the record.',
                        messageData: [
                            {
                                url: url,
                                label: 'Click here',
                            },
                        ],
                    });
                    this.dispatchEvent(event);
                });
                this.questionvalue = '';
                this.needvalue = '';
                this.priorityvalue = '';
                this.showSpinner = false;
            }
            else{
                var errorMsg = 'Something went wrong.';
                if(result && result.errormsg && result.errormsg.length){
                    errorMsg = result.errormsg;
                }
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: errorMsg
                });
                this.dispatchEvent(event);
                this.showSpinner = false;
            }
        }).catch(error=>{
            this.showSpinner = false;
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