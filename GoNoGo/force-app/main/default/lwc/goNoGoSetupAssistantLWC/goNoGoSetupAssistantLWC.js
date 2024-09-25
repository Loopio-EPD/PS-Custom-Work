import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveNewConfiguration from '@salesforce/apex/GoNoGoController.saveNewConfiguration';

export default class GoNoGoSetupAssistantLWC extends LightningElement {
    showSpinner = true;
    expandfirstsection = true;
    expandthirdsection = true;
    isShowModal = false;
    configname;
    gonogoconfigcreated = false;
    gonogoconfigid;
    configurationOwnerId;

    connectedCallback(){
        setTimeout(() => {
            this.loadInitialData();
        }, 5);
    }

    loadInitialData(){
        this.showSpinner = false;
    }

    handleOpenNewConfigModal(){
        this.gonogoconfigcreated = false;
        this.gonogoconfigid = '';
        this.isShowModal = true;
    }

    handleconfignamehange(event){
        this.configname = event.detail.value;
    }

    hideModalBox() {
        this.gonogoconfigcreated = false;
        this.gonogoconfigid = '';
        this.configname = '';
        this.isShowModal = false;
    }

    saveNewConfig() {
        this.gonogoconfigcreated = false;
        this.gonogoconfigid = '';
        if(this.configname == undefined || this.configname == undefined || this.configname == "" || this.configname == NaN || this.configurationOwnerId == undefined || this.configurationOwnerId == undefined || this.configurationOwnerId == "" || this.configurationOwnerId == NaN){
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: 'Please enter Go/No-Go Configuration Name and Owner.'
            });
            this.dispatchEvent(event);
            return;
        }

        this.showSpinner = true;
        saveNewConfiguration({ configname : this.configname, configurationOwnerId : this.configurationOwnerId})
        .then(result => {
            if(result && result.isSuccess){
                this.gonogoconfigid = result.errorMsg;
                this.gonogoconfigcreated = true;
                const event = new ShowToastEvent({
                    title: 'Success',
                    variant: 'success',
                    message: 'Go/No-Go Configuration "' + this.configname +'" created successfully.'
                });
                this.dispatchEvent(event);
            }
            else if(result && result.errorMsg) {
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: result.errorMsg
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
            this.showSpinner= false;
        }).catch(error=>{
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: error.body.message
            });
            this.dispatchEvent(event);
            this.showSpinner= false;
        })        
    }

    openCofigRecord(){
        var urlToRedirect = "/" + this.gonogoconfigid;
        window.open(urlToRedirect,'_blank');
    }

    handleOpenGoNoGoConfigurations(){
        window.open('/lightning/o/loopio_ext__Go_No_Go_Configuration__c/list','_blank');
    }

    handleOpenGoNoGoSections(){
        window.open('/lightning/o/loopio_ext__Go_No_Go_Section__c/list','_blank');
    }

    handleOpenGoNoGoQuestions(){
        window.open('/lightning/o/loopio_ext__Go_No_Go_Question_Bank__c/list','_blank');
    }

    handleOpenGoNoGoSettings(){
        window.open('/lightning/n/loopio_ext__Go_No_Go_Settings','_blank');
    }

    handleOpenOpportunities(){
        window.open('/lightning/o/Opportunity/list','_blank');
    }

    handleGoToApprovalProcessPage(){
        window.open('/lightning/setup/ApprovalProcesses/home','_blank');
    }

    handleThresholdValueClick(){
        window.open('https://support.loopio.com/hc/en-us/articles/25571240316051-Configuring-Loopio-Go-No-Go-Settings','_blank');
    }

    onfirstsectiondropclick(){
        this.expandfirstsection = false;
    }

    onthirdsectiondropclick(){
        this.expandthirdsection = false;
    }

    onfirstsectionsideclick(){
        this.expandfirstsection = true;
    }

    onthirdsectionsideclick(){
        this.expandthirdsection = true;
    }

    handleownervaluechange(event){
        var recordId = event && event.detail ? event.detail : '';
        if(recordId.includes('-')){
            recordId = recordId.split('-')[0];
        }
        if(recordId){
            this.configurationOwnerId = recordId;
        }
        else{
            this.configurationOwnerId = '';
        }
    }
}