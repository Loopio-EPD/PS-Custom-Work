import { LightningElement,api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRelatedProjectQuestions from '@salesforce/apex/CompareQuestionsController.getRelatedProjectQuestions'
import updateProjectQuestions from '@salesforce/apex/CompareQuestionsController.updateProjectQuestions'
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

export default class CompareQuestions extends LightningElement {
    @api currentprojectid;
    @api recordId;
    @track itemsList = [];
    @track backupitemsList = [];
    @track itemsListPagination = [];
    showSpinner = true;
    showProductTable = false;
    @api relatedprojectid;
    relatedProjectName;
    prevProjUrl;
    showRelatedProject = false;
    showRetrieveAllButton = false;
    totalQuestions = 0;
    questionsFound = 0;
    questionsHaveAnswers = 0;
    retrievedQuestions = 0;
    nsechecked = false;
    baseUrl = 'https://avnio-nwdemo19-58.lightning.force.com';
    allprojects = true;
    accountSelected = false;
    @track currentPage = 1;
    @track totalPages = 1;
    @track recordsPerPage = 10;
    currentPageReference;

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
    }

    connectedCallback(){
        setTimeout(() => {
            this.loadInitialData();
        }, 5);
    }

    @api
    loadInitialData(){
        this.showSpinner= true;
        this.relatedprojectid = this.currentPageReference.state.c__relatedprojectid;
        this.recordId = this.currentPageReference.state.c__currentprojectid;
        getRelatedProjectQuestions({currentprojectId : this.recordId, relatedProjectId : this.relatedprojectid})
        .then(result => {
            if(result && result.projectQuestionWrapperList && result.projectQuestionWrapperList.length){
                if(result.previousProjectName && result.previousProjectId){
                    this.relatedProjectName = result.previousProjectName;
                    this.relatedprojectid = result.previousProjectId;
                    this.prevProjUrl = 'https://avnio-nwdemo19-58.lightning.force.com/'+result.previousProjectId;
                    this.showRelatedProject = true;
                    this.questionsFound = result.questionsFound;
                    this.questionsHaveAnswers = result.questionsHaveAnswers;
                    if(result.showRetrieveAllButton){
                        this.showRetrieveAllButton = result.showRetrieveAllButton;
                    }
                    this.totalQuestions = result.projectQuestionWrapperList.length;
                }
                this.backupitemsList = result.projectQuestionWrapperList;
                this.itemsList = result.projectQuestionWrapperList;
                this.itemsListPagination = this.itemsList;
                this.totalPages = Math.ceil(this.itemsListPagination.length / this.recordsPerPage);
                this.showProductTable = true;
                this.changePage();
            }
            this.baseUrl = result.baseUrl;
            this.showSpinner= false;
        }).catch(error=>{
            this.showSpinner = false;
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: error.body.message
            });
            this.dispatchEvent(event);
            this.showSpinner= false;
        })
    }

    // getProjectDetails(){
    //     this.showSpinner= true;
    //     getPreviousProjectQuestions({projectId : this.recordId})
    //     .then(result => {
    //         if(result && result.projectQuestionWrapperList && result.projectQuestionWrapperList.length){
    //             if(result.previousProjectName && result.previousProjectId){
    //                 this.relatedProjectName = result.previousProjectName;
    //                 this.relatedprojectid = result.previousProjectId;
    //                 this.prevProjUrl = 'https://avnio-nwdemo19-58.lightning.force.com/'+result.previousProjectId;
    //                 this.showRelatedProject = true;
    //                 this.questionsFound = result.questionsFound;
    //                 this.questionsHaveAnswers = result.questionsHaveAnswers;
    //                 if(result.showRetrieveAllButton){
    //                     this.showRetrieveAllButton = result.showRetrieveAllButton;
    //                 }
    //                 this.totalQuestions = result.projectQuestionWrapperList.length;
    //             }
    //             this.backupitemsList = result.projectQuestionWrapperList;
    //             this.itemsList = result.projectQuestionWrapperList;
    //             this.itemsListPagination = this.itemsList;
    //             this.totalPages = Math.ceil(this.itemsListPagination.length / this.recordsPerPage);
    //             this.showProductTable = true;
    //             this.changePage();
    //         }
    //         this.baseUrl = result.baseUrl;
    //         this.showSpinner= false;
    //     }).catch(error=>{
    //         this.showSpinner = false;
    //         const event = new ShowToastEvent({
    //             title: 'Error',
    //             variant: 'error',
    //             message: error.body.message
    //         });
    //         this.dispatchEvent(event);
    //     })
    // }

    handleRetrieveClick(event){
        var recordId = event.target.id;
        if(recordId.includes('-')){
            recordId = recordId.split('-')[0];
        }
        if(this.itemsList && this.itemsList.length){
            for(var j = 0 ; j < this.itemsList.length ; j++){
                if(this.itemsList[j].currentQuestionId && this.itemsList[j].currentQuestionId === recordId && this.itemsList[j].previousAnswer && this.itemsList[j].currentAnswer != this.itemsList[j].previousAnswer){
                    this.itemsList[j].currentAnswer = this.itemsList[j].previousAnswer;
                    this.itemsList[j].isChanged = true;
                    this.retrievedQuestions = this.retrievedQuestions + 1;
                }
            }

            for(var j = 0 ; j < this.backupitemsList.length ; j++){
                if(this.backupitemsList[j].currentQuestionId && this.backupitemsList[j].currentQuestionId === recordId && this.backupitemsList[j].previousAnswer && this.backupitemsList[j].currentAnswer != this.backupitemsList[j].previousAnswer){
                    this.backupitemsList[j].currentAnswer = this.backupitemsList[j].previousAnswer;
                    this.backupitemsList[j].isChanged = true;
                }
            }
        }
    }

    retrieveAllQuestions(){
        if(this.itemsList && this.itemsList.length){
            for(var j = 0 ; j < this.itemsList.length ; j++){
                if(this.itemsList[j].previousAnswer && this.itemsList[j].currentAnswer != this.itemsList[j].previousAnswer){
                    this.itemsList[j].currentAnswer = this.itemsList[j].previousAnswer;
                    this.itemsList[j].isChanged = true;
                    this.retrievedQuestions = this.retrievedQuestions + 1;
                }
            }

            for(var j = 0 ; j < this.backupitemsList.length ; j++){
                if(this.backupitemsList[j].previousAnswer && this.backupitemsList[j].currentAnswer != this.backupitemsList[j].previousAnswer && (!this.nsechecked || (this.nsechecked && this.backupitemsList[j].nseCheckbox == this.nsechecked))){
                    this.backupitemsList[j].currentAnswer = this.backupitemsList[j].previousAnswer;
                    this.backupitemsList[j].isChanged = true;
                }
            }
        }
    }

    handleUndoClick(event){
        var recordId = event.target.id;
        if(recordId.includes('-')){
            recordId = recordId.split('-')[0];
        }
        if(this.itemsList && this.itemsList.length){
            for(var j = 0 ; j < this.itemsList.length ; j++){
                if(this.itemsList[j].isChanged && this.itemsList[j].currentQuestionId && this.itemsList[j].currentQuestionId === recordId){
                    this.itemsList[j].currentAnswer = this.itemsList[j].currentInitialAnswer;
                    this.itemsList[j].isChanged = false;
                    if(this.retrievedQuestions && this.retrievedQuestions > 0){
                        this.retrievedQuestions = this.retrievedQuestions - 1;
                    }
                }
            }

            for(var j = 0 ; j < this.backupitemsList.length ; j++){
                if(this.backupitemsList[j].isChanged && this.backupitemsList[j].currentQuestionId && this.backupitemsList[j].currentQuestionId === recordId){
                    this.backupitemsList[j].currentAnswer = this.backupitemsList[j].currentInitialAnswer;
                    this.backupitemsList[j].isChanged = false;
                }
            }
        }
    }

    undoAllQuestions(){
        if(this.itemsList && this.itemsList.length){
            for(var j = 0 ; j < this.itemsList.length ; j++){
                if(this.itemsList[j].isChanged){
                    this.itemsList[j].currentAnswer = this.itemsList[j].currentInitialAnswer;
                    this.itemsList[j].isChanged = false;
                    if(this.retrievedQuestions && this.retrievedQuestions > 0){
                        this.retrievedQuestions = this.retrievedQuestions - 1;
                    }
                }
            }

            for(var j = 0 ; j < this.backupitemsList.length ; j++){
                if(this.backupitemsList[j].isChanged && (!this.nsechecked || (this.nsechecked && this.backupitemsList[j].nseCheckbox == this.nsechecked))){
                    this.backupitemsList[j].currentAnswer = this.backupitemsList[j].currentInitialAnswer;
                    this.backupitemsList[j].isChanged = false;
                }
            }
        }
    }

    saveQuestions(){
        this.showSpinner= true;
        var returnObj = {};
        returnObj['previousProjectId'] = this.relatedprojectid;
        returnObj['previousProjectName'] = this.relatedProjectName;
        returnObj['projectQuestionWrapperList'] = this.itemsList;
        updateProjectQuestions({
            jsonString :  JSON.stringify(returnObj)
        })
        .then(result=>{
            if(result){                
                const event = new ShowToastEvent({
                    title: 'Success',
                    variant: 'success',
                    message: 'Project Questions Updated'
                });
                this.dispatchEvent(event);
                setTimeout(() => {
                    var redirectURL = this.baseUrl + '/' + this.recordId;
                    window.open(redirectURL, "_self");
                    this.showSpinner = false;
                    //window.location.reload(true);
                }, 3000);
                
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
        })
    }

    changeToggle(event){
        this.nsechecked = !this.nsechecked;
        if(this.backupitemsList && this.backupitemsList.length){
            this.showSpinner = true;
            this.itemsList = [];
            if(this.nsechecked){
                for(var j = 0 ; j < this.backupitemsList.length ; j++){
                    if(this.backupitemsList[j].nseCheckbox == this.nsechecked){
                        this.itemsList.push(this.backupitemsList[j]);
                    }
                }
            }
            else{
                this.itemsList = this.backupitemsList;
            }
            this.itemsListPagination = this.itemsList;
            this.showSpinner = false;
        }
        this.resetPagination();
        this.changePage();
    }

    handleSearch(event) {
        const searchKey = event.target.value.toLowerCase();
 
        if (searchKey) {
            this.itemsList = this.backupitemsList;
 
            if (this.itemsList) {
                let searchRecords = [];
 
                for (let record of this.itemsList) {
                    let valuesArray = Object.values(record);
 
                    for (let val of valuesArray) {
                        let strVal = String(val);
 
                        if (strVal) {
 
                            if (strVal.toLowerCase().includes(searchKey)) {
                                searchRecords.push(record);
                                break;
                            }
                        }
                    }
                }
                this.itemsList = searchRecords;
            }
        } else {
            this.itemsList = this.backupitemsList;
        }
    }

    cancelButtonClick(){
        window.history.back()
    }

    changePage(event){
        this.showSpinner = true;
        if(event && event.target && event.target.value){
            if(event.target.value < 1){
                this.currentPage = 1;
            }
            else if(event.target.value > this.totalPages){
                this.currentPage = this.totalPages;
            }
            else {
                this.currentPage = event.target.value;
            }
        }
        else{
            this.currentPage = 1;
        }
        if(this.itemsListPagination && this.itemsListPagination.length){
            this.itemsList = [];
            var recordsToSkip = this.recordsPerPage * (this.currentPage - 1);
            var nextRecordsRange =  parseInt(recordsToSkip) + parseInt(this.recordsPerPage);
            if(this.itemsListPagination.length < nextRecordsRange){
                nextRecordsRange = this.itemsListPagination.length;
            }
            for(var i = recordsToSkip ; i < nextRecordsRange ; i++){
                this.itemsList.push(this.itemsListPagination[i]);
            }
        }
        this.showSpinner = false;
    }

    changeRecordsPerPage(event){
        if(event && event.target && event.target.value && event.target.value > 4 && event.target.value < 101){
            this.recordsPerPage = event.target.value;
        }
        else{
            this.recordsPerPage = 10;
        }
        this.totalPages = Math.ceil(this.itemsListPagination.length / this.recordsPerPage);
        this.changePage();
    }

    resetPagination(){
        this.showSpinner= true;
        this.currentPage = 1;
        this.recordsPerPage = 10;
        this.totalPages = Math.ceil(this.itemsList.length / this.recordsPerPage);
        this.showSpinner= false;
    }

    handleViewQuestion(event){
        var question = event.target.id;
        if(question.includes('-')){
            question = question.split('-')[0];
        }
        if(this.itemsList && this.itemsList.length){
            for(var j = 0 ; j < this.itemsList.length ; j++){
                if(this.itemsList[j].currentQuestionId && this.itemsList[j].currentQuestionId === question){
                    var urlToRedirect = "/lightning/cmp/avnio__QuestionFullPage?c__recordId="+this.recordId+"&c__questionId="+question+"&c__filter=focused";
                    window.open(urlToRedirect,'_blank')
                }
            }
        }
    }
}