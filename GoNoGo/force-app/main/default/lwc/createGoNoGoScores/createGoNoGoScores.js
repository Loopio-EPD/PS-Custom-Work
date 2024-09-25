import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import getExistingScoresForQuestion from '@salesforce/apex/CreateGoNoGoScoresController.getExistingScoresForQuestion'
import saveScoringRecords from '@salesforce/apex/CreateGoNoGoScoresController.saveScoringRecords'
import deleteScoreRecord from '@salesforce/apex/CreateGoNoGoScoresController.deleteScoreRecord'


export default class CreateGoNoGoScores extends LightningElement {
    @track items = [];
    @api recordId;
    disableContinueButton = true;
    selectedAccountId = '';
    showSpinner = true;
    dataType = 'Text';
    dataTypeToShow = 'text';

    connectedCallback(){
        setTimeout(() => {
            this.loadInitialData();
        }, 5);
    }

    loadInitialData(){
        if(this.recordId && this.recordId != ''){
            getExistingScoresForQuestion({questionId : this.recordId})
            .then(result => {
                if(result){
                    if(result.scoringList && result.scoringList.length){
                        for(var j = 0 ; j < result.scoringList.length ; j++){
                            var obj = {};
                            obj.id = 'myid'+j;
                            obj.scoreId = result.scoringList[j].Id;
                            obj.value = result.scoringList[j].loopio_ext__Value__c;
                            obj.score = result.scoringList[j].loopio_ext__Score__c;
                            this.items.push(obj);
                        }
                    }
                    else{
                        this.addQuestion();
                    }
                    if(result.dataType){
                        this.dataType = result.dataType;
                        if(result.dataType == 'Number'){
                            this.dataTypeToShow = 'number';
                        }
                    }
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
    }

    addQuestion(){
        this.items = [...this.items, { id: 'myid'+this.items.length, value: '', score: ''}];
    }

    handleValueChange(event){
        var tagid = event.target.id;
        if(tagid.includes('-')){
            tagid = tagid.split('-')[0];
        }
        if(this.items && this.items.length){
            for(var j = 0 ; j < this.items.length ; j++){
                if(this.items[j].id && this.items[j].id === tagid){
                    if(event.target.value){
                        this.items[j].value = event.target.value;
                    }
                    else{
                        this.items[j].value = '';
                    }
                    break;
                }
            }
        }

    }

    handleScoreChange(event){
        var tagid = event.target.id;
        if(tagid.includes('-')){
            tagid = tagid.split('-')[0];
        }
        if(this.items && this.items.length){
            for(var j = 0 ; j < this.items.length ; j++){
                if(this.items[j].id && this.items[j].id === tagid){
                    if(event.target.value){
                        this.items[j].score = event.target.value;
                    }
                    else{
                        this.items[j].score = '';
                    }
                    break;
                }
            }
        }
    }

    saveScores(){
        if(this.recordId && this.recordId != ''){
            if(this.items && this.items.length){
                this.showSpinner = true;
                for(var j = 0 ; j < this.items.length ; j++){
                    if(this.items[j].value != undefined){
                        this.items[j].value = this.items[j].value.toString();
                    }
                    if(this.items[j].score != undefined){
                        this.items[j].score = parseInt(this.items[j].score);
                    }
                    
                    if(this.items[j].score == undefined || this.items[j].value == undefined || this.items[j].value == "" || this.items[j].score == NaN){
                        const event = new ShowToastEvent({
                            title: 'Error',
                            variant: 'error',
                            message: 'Please add value and score for all records.'
                        });
                        this.dispatchEvent(event);
                        this.showSpinner = false;
                        return;
                    }
                }
                saveScoringRecords({jsonString : JSON.stringify(this.items), questionId : this.recordId})
                .then(result => {
                    if(result && result.isSuccess){
                        const event = new ShowToastEvent({
                            title: 'Success',
                            variant: 'success',
                            message: 'Go/No-Go scoring records created successfully.'
                        });
                        this.dispatchEvent(event);
                        this.showSpinner= false;
                        this.cancelButtonClick();
                        // setTimeout(() => {
                        //     window.location.reload(true);
                        // }, 1000);
                    }
                    else{
                        if(result && result.errorMsg){
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
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
        //this.dispatchEvent(new CloseActionScreenEvent());
        //window.history.back()
    }

    deleteScore(event){
        console.log(this.items);
        var tagid = event.target.id;
        if(tagid.includes('-')){
            tagid = tagid.split('-')[0];
        }
        var scoreIdToDelete, tagIdToDelete;
        this.showSpinner= true;
        if(this.items && this.items.length){
            for(var j = 0 ; j < this.items.length ; j++){
                if(this.items[j].id && this.items[j].id === tagid){
                    if(this.items[j].scoreId){
                        scoreIdToDelete = this.items[j].scoreId;
                    }
                    else{
                        tagIdToDelete = this.items[j].id;
                    }
                    break;
                }
            }
        }

        if(scoreIdToDelete){
            deleteScoreRecord({scoreRecordId : scoreIdToDelete})
            .then(result => {
                if(result){
                    const event = new ShowToastEvent({
                        title: 'Success',
                        variant: 'success',
                        message: 'Go/No-Go scoring record deleted successfully.'
                    });
                    this.dispatchEvent(event);
                    const closeQA = new CustomEvent('refresh');
                    this.dispatchEvent(closeQA);
                    this.refreshItemsOnUI(scoreIdToDelete);
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
        else if(tagIdToDelete){
            this.refreshItemsOnUI(tagIdToDelete);
        }
        else{
            this.showSpinner= false;
        }
    }

    refreshItemsOnUI(recordOrItemId){
        console.log(this.items);
        if(this.items && this.items.length){
            var updatedItems = [];
            for(var j = 0 ; j < this.items.length ; j++){
                if(this.items[j].id != recordOrItemId && this.items[j].scoreId != recordOrItemId){
                    updatedItems.push(this.items[j]);
                }
            }
            this.items = [];
            for(var i = 0 ; i < updatedItems.length ; i++){
                updatedItems[i].id = 'myid'+i;
            }
            this.items = updatedItems;
            console.log(this.items);
        }
        this.showSpinner= false;
    }

    cancelButtonClick(){
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }
}