import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getGoNoGOQuestionsFromConfiguration from '@salesforce/apex/GoNoGoController.getGoNoGOQuestionsFromConfiguration';
import saveAnswerRecords from '@salesforce/apex/GoNoGoController.saveAnswerRecords';
import submitForApproval from '@salesforce/apex/GoNoGoController.submitForApproval';
import checkIfApproved from '@salesforce/apex/GoNoGoController.checkIfApproved';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getLinkedConfigs from '@salesforce/apex/GoNoGoController.getLinkedConfigs';

export default class GoNoGoScreenLWC extends NavigationMixin(LightningElement) {
    @api configName;
    @api recordId;
    @api fromoverridebutton = false;
    @api continuesubmission = false;
    questionsPresent = false;
    showSpinner = true;
    sectionsWrapperList = [];
    allSectionNames = [];
    gonogoanswerid;
    gonogoscore;
    gonogostatus;
    statuslabel;
    gonogoansweridpresent = false;
    gonogoscorepresent = false;
    gonogostatuspresent = false;
    approvalProcessPresent = false;
    showSubmitForApprovalButton = true;
    isApproved = true;
    apprvalerrormsg = 'You cannot create the loopio project for this Go/No-Go becuase it is not yet approved or it has been rejected.';
    showLoopioProjectCreationPage = false;
    loopioCreateProjectUrl = "/apex/Loopio__Create_Loopio_Project?id=";
    loopioPackagePresent = false;
    avnioPackagePresent = false;
    recordidpresent = true;
    fromrecord = true;
    showProjectTypeSelection = false;
    showLinkedConfigSelection = false;
    linkedConfigurationsList = [];
    selectedLinkedConfig;
    linkedDescriptionMsg;
    hideProjectCreationButton = false;
    submissionCompletedForContinue = false;
    isFinalScoreShown = false;
    finalgonogoscore;
    finalgonogostatus;
    finalstatuslabel;
    showNextButton = false;
    accountId;
    recordTypesForLFS = [];
    selectedRecordType;
    showRecordTypeSelectionForLFS = false;
    skipRecordTypeSelection = false;

    get dynamiClassName(){
        return this.fromoverridebutton ? 'modal-wrapper-with-padding': 'modal-wrapper';
    }

    get projecttypeoptions() {
        return [
            { label: 'Loopio', value: 'Loopio' },
            { label: 'Loopio for Salesforce', value: 'Loopio for Salesforce' },
        ];
    }

    connectedCallback(){
        setTimeout(() => {
            this.loadInitialData();
        }, 5);
    }

    loadInitialData(){
        if(this.recordId && this.recordId != ''){
            this.recordidpresent = true;
            getLinkedConfigs({submissionId : this.recordId, continuesubmission : this.continuesubmission})
            .then(linkedResult => {
                if(linkedResult && linkedResult.isCompleted){
                    this.submissionCompletedForContinue = true;
                    this.showSpinner= false;
                }
                else if(linkedResult && linkedResult.linkedConfigWrapper && linkedResult.linkedConfigWrapper.length){
                    this.linkedConfigurationsList = linkedResult.linkedConfigWrapper;
                    this.showLinkedConfigSelection = true;
                    this.showSpinner= false;
                }
                else{
                    this.getQuestionsData();
                }
            }).catch(error=>{
                if(error && error.body && error.body.message){
                    if(error.body.message == 'Submission already completed.'){
                        this.submissionCompletedForContinue = true;
                    }
                    else{
                        const event = new ShowToastEvent({
                            title: 'Error',
                            variant: 'error',
                            message: error.body.message
                        });
                        this.dispatchEvent(event);
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
            })
        }
        else{
            this.fromrecord = false;
            this.recordidpresent = false;
            this.showSpinner= false;
        }
    }

    getQuestionsData(){
        getGoNoGOQuestionsFromConfiguration({configName : this.configName, oppId : this.recordId})
        .then(result => {
            if(result && result.length){
                for(var j = 0 ; j < result.length ; j++){
                    this.allSectionNames.push(result[j].sectionName);
                    var questionRecords = result[j].questionRecords;
                    for(var i = 0 ; i < questionRecords.length ; i++){
                        questionRecords[i].isTextArea = false;
                        questionRecords[i].isDropdown = false;
                        questionRecords[i].isNumber = false;
                        questionRecords[i].salesforceInput = false;
                        if(questionRecords[i].dataType){
                            questionRecords[i].tagId = questionRecords[i].sectionId + '-' + questionRecords[i].questionId;
                            if(questionRecords[i].dataType == 'Dropdown' && questionRecords[i].scoringRecords && questionRecords[i].scoringRecords.length){
                                var options = [];
                                for(var k = 0 ; k < questionRecords[i].scoringRecords.length ; k++){
                                    var singleOption = {label: questionRecords[i].scoringRecords[k].value , value: questionRecords[i].scoringRecords[k].value};
                                    options.push(singleOption);
                                }
                                questionRecords[i].isDropdown = true;
                                questionRecords[i].options = options;
                            }
                            else if(questionRecords[i].dataType == 'Number'){
                                questionRecords[i].isNumber = true;
                            }
                            else if(questionRecords[i].dataType == 'Salesforce Input'){
                                questionRecords[i].salesforceInput = true;
                            }
                            else{
                                questionRecords[i].isTextArea = true;
                            }
                        }
                    }
                }
                result.sort((a, b) => {
                    return a.sectionSequence - b.sectionSequence;
                });
                this.questionsPresent = true;
                this.sectionsWrapperList = result;
            }
            else{
                this.questionsPresent = false;
            }
            this.showSpinner= false;
        }).catch(error=>{
            this.questionsPresent = false;
            this.showSpinner= false;
        })
    }

    handleChange(event){
        var tagid = event.target.id;
        var valueToAdd = event.detail.value ? event.detail.value : '';
        this.answerQuestion(tagid, valueToAdd);
    }

    answerQuestion(tagid, valueToAdd){
        var sectionId, questionId;
        if(tagid.includes('-')){
            var dividedTags = tagid.split('-');
            sectionId = dividedTags[0];
            questionId = dividedTags[1];
        }
        

        if(sectionId && questionId){
            for(var i=0 ; i < this.sectionsWrapperList.length ; i++){
                if(this.sectionsWrapperList[i].sectionId && this.sectionsWrapperList[i].sectionId === sectionId){
                    var questionRecords = this.sectionsWrapperList[i].questionRecords;
                    for(var j=0 ; j < questionRecords.length ; j++){
                        if(questionRecords[j].questionId && questionRecords[j].questionId === questionId){
                            this.sectionsWrapperList[i].questionRecords[j].answerValue = valueToAdd;
                            break;
                        }
                    }
                }
            }
        }
        else if(sectionId || questionId){
            for(var i=0 ; i < this.sectionsWrapperList.length ; i++){
                var questionRecords = this.sectionsWrapperList[i].questionRecords;
                for(var j=0 ; j < questionRecords.length ; j++){
                    if(questionRecords[j].questionId && (questionRecords[j].questionId === sectionId || questionRecords[j].questionId === questionId)){
                        this.sectionsWrapperList[i].questionRecords[j].answerValue = valueToAdd;
                        break;
                    }
                }
            }
        }
    }

    saveAnswers(){
        this.showSpinner = true;
        var throwError = false;
        for(var i=0 ; i < this.sectionsWrapperList.length ; i++){
            var questionRecords = this.sectionsWrapperList[i].questionRecords;
            for(var j=0 ; j < questionRecords.length ; j++){
                if(questionRecords[j].isRequired && (questionRecords[j].answerValue == undefined || questionRecords[j].answerValue == "" || questionRecords[j].answerValue.toString().trim() == "")){
                    questionRecords[j].requiredError = true;
                    throwError = true;
                }
                else{
                    questionRecords[j].requiredError = false;
                }
            }
        }

        if(throwError){
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: 'Please fill the required fields.'
            });
            this.dispatchEvent(event);
            this.showSpinner = false;
            return;
        }

        saveAnswerRecords({jsonString : JSON.stringify(this.sectionsWrapperList), oppId : this.recordId, selectedLinkedConfig : this.selectedLinkedConfig})
        .then(result => {
            if(result && result.isSuccess){
                this.isFinalScoreShown = false;
                if(result.isLoopioPresent){
                    this.loopioPackagePresent = result.isLoopioPresent;
                }
                if(result.isAvnioPresent){
                    this.avnioPackagePresent = result.isAvnioPresent;
                }
                if(result.gonogoanswerid){
                    this.gonogoanswerid = result.gonogoanswerid;
                    this.gonogoansweridpresent = true;
                }
                if(result.gonogoscore || result.gonogoscore == 0){
                    this.gonogoscore = result.gonogoscore;
                    this.gonogoscorepresent = true;
                    this.finalgonogoscore = result.gonogoscore;
                }
                if(result.staticresourcename){
                    this.gonogostatus = '/resource/' + result.staticresourcename;
                    this.gonogostatuspresent = true;
                    this.finalgonogostatus = '/resource/' + result.staticresourcename;
                }
                if(result.statuslabel){
                    this.statuslabel = result.statuslabel;
                    this.finalstatuslabel = result.statuslabel;
                }
                if(result.lastConfigScore || result.lastConfigScore == 0){
                    this.gonogoscore = result.lastConfigScore;
                    this.gonogoscorepresent = true;
                }
                if(result.lastConfigStaticresourcename){
                    this.gonogostatus = '/resource/' + result.lastConfigStaticresourcename;
                    this.gonogostatuspresent = true;
                }
                if(result.lastConfigStatusLabel){
                    this.statuslabel = result.lastConfigStatusLabel;
                }
                if(result.approvalProcessPresent){
                    this.approvalProcessPresent = result.approvalProcessPresent;
                }
                if(result.linkedConfigsDoneCount && this.linkedConfigurationsList.length){
                    this.linkedDescriptionMsg = result.linkedConfigsDoneCount + "/" + this.linkedConfigurationsList.length + " Configurations completed.";
                    this.hideProjectCreationButton = true;
                    if(result.linkedConfigsDoneCount == this.linkedConfigurationsList.length){
                        this.showNextButton = true;
                    }
                }
                else{
                    this.configName = 'Go/No-Go Score';
                    this.isFinalScoreShown = true;
                }
            }
            else{
                var errorMsg = 'Something went wrong. Please try again later.';
                if(result && result.errorMsg){
                    errorMsg = result.errorMsg;
                }
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: errorMsg
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

    openGoNoGoRecord(){
        var urlToRedirect = "/" + this.gonogoanswerid;
        window.open(urlToRedirect,'_blank');
    }

    createLoopioProject(){
        this.showSpinner = true;
        checkIfApproved({answerId : this.gonogoanswerid})
        .then(result => {
            if(result && result.isSuccess){
                if(result.isApproved && !this.approvalProcessPresent){
                    this.showLoopioProjectCreationPage = true;
                    if(result.opportunityId){
                        this.recordId = result.opportunityId;
                    }
                    if(result.accountId){
                        this.accountId = result.accountId;
                    }
                    if(result.recordTypesForLFS && result.recordTypesForLFS.length){
                        this.recordTypesForLFS = result.recordTypesForLFS;
                        this.selectedRecordType = result.recordTypesForLFS[0].value;
                    }
                    else{
                        this.skipRecordTypeSelection = true;
                    }
                    if(this.loopioPackagePresent && this.avnioPackagePresent){
                        this.showProjectTypeSelection = true;
                        this.loopioPackagePresent = true;
                        this.avnioPackagePresent = false;
                    }
                    else if(this.loopioPackagePresent){
                        this.showSpinner = false;
                        this.loopioCreateProjectUrl = "/apex/Loopio__Create_Loopio_Project?id=" + this.recordId + "&gonogoid="+ this.gonogoanswerid; 
                        //this.loopioCreateProjectUrl = "/apex/Create_Loopio_Custom?id=" + this.recordId + "&gonogoid="+ this.gonogoanswerid;
                        //window.open(urlToRedirect,'_self');
                        //this.cancelButtonClick();
                    }
                    else if(this.avnioPackagePresent){
                        if(this.skipRecordTypeSelection){
                            this.createLFSProjectWithoutRecordType();
                        }
                        else{
                            this.showRecordTypeSelectionForLFS = true;
                        }
                    }
                }
                else{
                    if(this.approvalProcessPresent){
                        this.apprvalerrormsg = 'You cannot create the loopio project for this Go/No-Go becuase it\'s score is less than the threshold value. Click on back button and send it for approval.';
                    }
                    else{
                        this.apprvalerrormsg = 'You cannot create the loopio project for this Go/No-Go becuase it is not yet approved or it has been rejected.';
                    }
                    this.isApproved = false;
                }
            }
            else{
                var errorMsg = 'Something went wrong. Please try again later.';
                if(result && result.errorMsg){
                    errorMsg = result.errorMsg;
                }
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: errorMsg
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

    submitForApproval(){
        this.showSpinner = true;
        submitForApproval({answerId : this.gonogoanswerid})
        .then(result => {
            if(result){
                this.showSubmitForApprovalButton = false;
                const event = new ShowToastEvent({
                    title: 'Success',
                    variant: 'success',
                    message: 'Go/No-Go recrod has been submitted for approval.'
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

    cancelButtonClick(){
        if(this.fromoverridebutton){
            if(this.fromrecord){
                var urlToRedirect = "/" + this.recordId;
                window.open(urlToRedirect,'_self');
            }
            else{
                window.open('/lightning/o/loopio_ext__Go_No_Go_Answer__c/list','_self');
            }
        }
        else {
            const closeQA = new CustomEvent('close');
            this.dispatchEvent(closeQA);
        }
    }

    backButtonClick(){
        this.isApproved = true;
    }

    handleopportunitychange(event){
        var recordId = event.target.id;
        if(recordId.includes('-')){
            recordId = recordId.split('-')[0];
        }
        var returneduserid = event.detail;
        this.recordId = returneduserid;
    }

    selectOpp(){
        if(this.recordId){
            this.showSpinner = true;
            this.loadInitialData();
        }
        else{
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: 'Please select the opportunity to continue.'
            });
            this.dispatchEvent(event);
        }
    }

    handleProjectTypeChange(event) {
        const selectedOption = event.detail.value;
        this.loopioPackagePresent = false;
        this.avnioPackagePresent = false;
        if(selectedOption == "Loopio"){
            this.loopioPackagePresent = true;
        }
        else if(selectedOption == "Loopio for Salesforce"){
            this.avnioPackagePresent = true;
        }
    }

    selectOptionForProjectType(event) {
        this.showProjectTypeSelection = false;
        if(this.avnioPackagePresent){
            if(this.skipRecordTypeSelection){
                this.createLFSProjectWithoutRecordType();
            }
            else{
                this.showRecordTypeSelectionForLFS = true;
            }
        }
    }

    selectLinkedConfig(event) {
        var allInputs = this.template.querySelectorAll('input');
        for(var i=0 ; i < this.linkedConfigurationsList.length ; i++){
            if(allInputs[i].checked){
                this.configName = this.linkedConfigurationsList[i].label;
                this.selectedLinkedConfig = this.linkedConfigurationsList[i].value;
                break;
            }
        }
        if(this.selectedLinkedConfig){
            this.showSpinner = true;
            this.showLinkedConfigSelection = false;
            this.getQuestionsData();
        }
        else{
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: 'Please select the Configuration.'
            });
            this.dispatchEvent(event);
        }
    }

    showFinalScore(){
        this.linkedDescriptionMsg = 'Final Score'
        this.configName = 'Go/No-Go Score';
        this.showNextButton = false;
        this.gonogoscore = this.finalgonogoscore;
        this.gonogostatus = this.finalgonogostatus;
        this.statuslabel = this.finalstatuslabel;
        this.isFinalScoreShown = true;
        this.hideProjectCreationButton = false;
    }

    handleRecordTypeChange(event) {
        const selectedOption = event.detail.value;
        this.selectedRecordType = selectedOption;
    }

    continueToRecTypeSelection(event) {
        this.showRecordTypeSelectionForLFS = false;
        if(this.skipRecordTypeSelection){
            this.createLFSProjectWithoutRecordType();
        }
        else{
            if(this.selectedRecordType){
                const defaultValues = encodeDefaultFieldValues({
                    Opportunity__c: this.recordId,
                    Go_No_Go_Submission__c : this.gonogoanswerid,
                    avnio__AccountId__c : this.accountId
                });
                this[NavigationMixin.Navigate]({
                    type: "standard__objectPage",
                    attributes: {
                        objectApiName: "avnio__Project__c",
                        actionName: "new"
                    },
                    state: {
                        defaultFieldValues: defaultValues,
                        recordTypeId : this.selectedRecordType
                    }
                });
                this.cancelButtonClick();
            }
            else{
                this.createLFSProjectWithoutRecordType();
            }
        }
    }

    createLFSProjectWithoutRecordType(){
        const defaultValues = encodeDefaultFieldValues({
            Opportunity__c: this.recordId,
            Go_No_Go_Submission__c : this.gonogoanswerid,
            avnio__AccountId__c : this.accountId
        });
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "avnio__Project__c",
                actionName: "new",
            },
            state: {
                defaultFieldValues: defaultValues,
            }
        });
        this.cancelButtonClick();
    }
}