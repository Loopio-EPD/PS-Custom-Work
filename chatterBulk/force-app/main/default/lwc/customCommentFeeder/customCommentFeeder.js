import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import createFeedItemRec from '@salesforce/apex/CustomCommentFeederController.createFeedItemRec';


export default class CustomCommentFeeder extends NavigationMixin(LightningElement) {

    showSpinner = false;
    @api records;
    commentbody = '';
    disablePostButton = true;
    showsuccess = false;
    selectedusers;

    handleChange(event) {
        this.commentbody = event.target.value;
        if(this.commentbody){
            this.disablePostButton = false;
        }
        else{
            this.disablePostButton = true;
        }
    }

    handlePostClick() {
        if(this.commentbody){
            let responseIds = this.records.map(res => res.Id);
            this.showSpinner = true;
            createFeedItemRec({responseIds : responseIds, textbody: this.commentbody, mentionedUsersList : this.selectedusers})
                .then((response) => {
                    this.showSpinner = false;
                    if(response){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Chatter posted successfully.',
                                variant: 'success'
                            })
                        );
                        this.commentbody = '';
                        this.showsuccess = true;
                    }
                    else{
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!',
                                message: 'Something went wrong. Please try again later.',
                                variant: 'error'
                            })
                        );
                    }
                })
                .catch((error) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                    this.showSpinner = false;
                });
        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: 'Please add the message to post.',
                    variant: 'error'
                })
            );
        }   
    }

    handleoptionschange(event){
        var details = event.detail;
        this.selectedusers = details;
    }
}