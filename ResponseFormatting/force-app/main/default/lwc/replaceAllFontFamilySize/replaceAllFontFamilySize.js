import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import replaceFontSizeAndStyle from '@salesforce/apex/ReplaceAllFontFamilySizeController.replaceFontSizeAndStyle';
import removeFontSizeAndStyle from '@salesforce/apex/ReplaceAllFontFamilySizeController.removeFontSizeAndStyle';
import replaceSelectedFontSizeAndStyle from '@salesforce/apex/ReplaceAllFontFamilySizeController.replaceSelectedFontSizeAndStyle';

export default class ReplaceAllFontFamilySize extends NavigationMixin(LightningElement) {

    showSpinner = false;
    @api records;
    @api actiontype = 'replaceall';
    fontsize;
    fontstyle;
    fontsizeold;
    fontstyleold;
    showsuccess = false;
    showreplaceall;
    showremoveallformat;
    showfindnandreplace;
    removeFontSize = false;
    removeFontFamily = false;

    connectedCallback(){
        if(!this.actiontype || (this.actiontype && this.actiontype == 'replaceall')){
            this.showreplaceall = true;
        }
        else if(this.actiontype && this.actiontype == 'removeall'){
            this.showremoveallformat = true;
        }
        else if(this.actiontype && this.actiontype == 'findandreplace'){
            this.showfindnandreplace = true;
        }
    }

    handlefontsizechange(event) {
        this.fontsize = event.target.value;
    }

    handlefontstylehange(event) {
        this.fontstyle = event.target.value;
    }
    
    handlefontsizechangeold(event) {
        this.fontsizeold = event.target.value;
    }

    handlefontstylehangeold(event) {
        this.fontstyleold = event.target.value;
    }

    handleReplaceClick() {
        if(this.fontsize || this.fontstyle){
            let responseIds = this.records.map(res => res.Id);
            this.showSpinner = true;
            replaceFontSizeAndStyle({responseIds : responseIds, fontstyle : this.fontstyle, fontsize : this.fontsize})
                .then((response) => {
                    this.showSpinner = false;
                    if(response){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Responses Formatted Successfully.',
                                variant: 'success'
                            })
                        );
                        this.fontsize = '';
                        this.fontstyle = '';
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
                    message: 'Please enter font size or font style.',
                    variant: 'error'
                })
            );
        }
    }

    handleRemoveFontSizeChange(event){
        this.removeFontSize = event.detail.checked;
    }

    handleRemoveFontFamilyChange(event){
        this.removeFontFamily = event.detail.checked;
    }

    handleRemoveClick() {
        let responseIds = this.records.map(res => res.Id);
        this.showSpinner = true;
        removeFontSizeAndStyle({responseIds : responseIds, removeFontSize : this.removeFontSize, removeFontFamily : this.removeFontFamily})
        .then((response) => {
            this.showSpinner = false;
            if(response){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Removed Responses formatting Successfully.',
                        variant: 'success'
                    })
                );
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

    handleReplaceClick() {
        let responseIds = this.records.map(res => res.Id);
        this.showSpinner = true;
        replaceSelectedFontSizeAndStyle({responseIds : responseIds, fontstyleold : this.fontstyleold, fontsizeold : this.fontsizeold , fontstyle : this.fontstyle , fontsize : this.fontsize})
        .then((response) => {
            this.showSpinner = false;
            if(response){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Responses formatted Successfully.',
                        variant: 'success'
                    })
                );
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
}