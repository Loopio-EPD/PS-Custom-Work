import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDefaultConfigurations from '@salesforce/apex/GoNoGoController.getDefaultConfigurations';
import updateDefaultConfigName from '@salesforce/apex/GoNoGoController.updateDefaultConfigName';
import updateThreshold from '@salesforce/apex/GoNoGoController.updateThreshold';
import updateStatusValues from '@salesforce/apex/GoNoGoController.updateStatusValues';
import createLinkedConifg from '@salesforce/apex/GoNoGoController.createLinkedConifg';
import updateAsigneeNotification from '@salesforce/apex/GoNoGoController.updateAsigneeNotification';

export default class GoNoGoSettingsLWC extends LightningElement {
    showSpinner = true;
    defaultConfigName;
    thresholdvalue = "None";
    autoSubmitForApproval = false;
    editDefaultConfigName = false;
    editThreshold = false;
    availableConfigurationsList = [];
    linkedConfigList = [];
    updatedDefaultConfigName;
    updatedThreshold = "None";;
    updatedAutoSubmitForApproval = false;
    editStatuses = false;
    showStatusTable = false;
    statusList = [];
    statusListBackup = [];
    isShowModal = false;
    modalHeader = "Add Status";
    modalstatuslabel;
    modalstaticresourcename;
    modalminrange;
    modalmaxrange;
    isShowDeleteModal = false;
    isShowLinkedConfigModal = false;
    selectedStatusRecordId;
    hasadminaccess = false;
    manageCustomSettingUrl;
    statusIdsToDelete = [];
    linkedConfigName;
    linkedConfigNameFromApex;
    selectedLinkedConfigs = [];
    isLinkedConfigPresent = false;
    editAsigneeNotification = false;
    asigneeNotification = false;
    updatedAsigneeNotification = false;
    opportunityStatuses = [];
    selectedOppStatus;
    reminderNotification = false;
    updatedReminderNotification = false;
    reminderNotificationDays = '3';
    updatedReminderNotificationDays = '3';
    disableReminderNotification = true;
    disableReminderDays = true;
    reminderNotificationDaysOptions = [];

    connectedCallback(){
        var day1 = {};
        day1.label = '1 day';
        day1.value = '1'
        this.reminderNotificationDaysOptions.push(day1);
        var day2 = {};
        day2.label = '2 days';
        day2.value = '2'
        this.reminderNotificationDaysOptions.push(day2);
        var day3 = {};
        day3.label = '3 days';
        day3.value = '3'
        this.reminderNotificationDaysOptions.push(day3);
        var day7 = {};
        day7.label = '1 week';
        day7.value = '7'
        this.reminderNotificationDaysOptions.push(day7);
        setTimeout(() => {
            this.loadInitialData();
        }, 5);
    }

    loadInitialData(){
        getDefaultConfigurations({})
        .then(result => {
            if(result){
                if(result.defaultConfigName){
                    this.defaultConfigName = result.defaultConfigName;
                    this.updatedDefaultConfigName = result.defaultConfigName;
                }
                if(result.linkedConfigName){
                    this.linkedConfigName = result.linkedConfigName;
                    this.linkedConfigNameFromApex = result.linkedConfigName;
                    this.isLinkedConfigPresent = true;
                }
                if(result.availableConfigurationsList && result.availableConfigurationsList.length){
                    this.availableConfigurationsList = result.availableConfigurationsList;
                }
                if(result.linkedConfigList && result.linkedConfigList.length){
                    this.linkedConfigList = result.linkedConfigList;
                }
                if(result.thresholdvalue){
                    this.thresholdvalue = result.thresholdvalue;
                    this.updatedThreshold = result.thresholdvalue;
                }
                if(result.autoSubmitForApproval){
                    this.autoSubmitForApproval = result.autoSubmitForApproval;
                    this.updatedAutoSubmitForApproval = result.autoSubmitForApproval;
                }
                if(result.goNoGoStatusWrapperList && result.goNoGoStatusWrapperList.length){
                    this.statusList = result.goNoGoStatusWrapperList;
                    this.statusListBackup = JSON.parse(JSON.stringify(result.goNoGoStatusWrapperList));
                    this.showStatusTable = true;
                }
                if(result.hasadminaccess){
                    this.hasadminaccess = result.hasadminaccess;
                }
                if(result.manageCustomSettingUrl){
                    this.manageCustomSettingUrl = result.manageCustomSettingUrl;
                }
                if(result.asigneeNotification){
                    this.asigneeNotification = result.asigneeNotification;
                    this.updatedAsigneeNotification = result.asigneeNotification;
                    this.disableReminderNotification = false;
                }
                if(result.reminderNotification){
                    this.reminderNotification = result.reminderNotification;
                    this.updatedReminderNotification = result.reminderNotification;
                }
                if(result.reminderNotificationDays){
                    this.reminderNotificationDays = result.reminderNotificationDays;
                    this.updatedReminderNotificationDays = result.reminderNotificationDays;
                }
                if(result.opportunityStatuses && result.opportunityStatuses.length){
                    this.opportunityStatuses = result.opportunityStatuses;
                }
                if(result.selectedOppStatus){
                    this.selectedOppStatus = result.selectedOppStatus;
                }
                this.checkDisableReminderDays();
            }
            this.showSpinner= false;
        }).catch(error=>{
            this.showSpinner= false;
        })
    }

    handelEditDefaultConfigName(){
        this.editDefaultConfigName = true;
    }

    cancelEditDefaultConfigName(){
        this.editDefaultConfigName = false;
        if(this.linkedConfigNameFromApex){
            this.linkedConfigName = this.linkedConfigNameFromApex;
            this.isLinkedConfigPresent = true;
        }
        else{
            this.linkedConfigName = "";
            this.selectedLinkedConfigs = [];
            this.isLinkedConfigPresent = false;
        }
    }

    handleConfigChange(event){
        this.updatedDefaultConfigName = event.detail.value ? event.detail.value : this.defaultConfigName;
    }

    saveConfigChange(){
        if(this.updatedDefaultConfigName){
            this.showSpinner= true;
            updateDefaultConfigName({defaultConfigNameNew : this.updatedDefaultConfigName})
            .then(result => {
                if(result.isSuccess){
                    this.linkedConfigNameFromApex = '';
                    this.defaultConfigName = this.updatedDefaultConfigName;
                    this.editDefaultConfigName = false;
                    const event = new ShowToastEvent({
                        title: 'Success',
                        variant: 'success',
                        message: 'Default Configuration updated successfully.'
                    });
                    this.dispatchEvent(event);
                }
                else if(result.errorMsg) {
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
        else if(this.linkedConfigName && this.selectedLinkedConfigs && this.selectedLinkedConfigs.length){
            this.showSpinner= true;
            createLinkedConifg({linkedConfigName : this.linkedConfigName, selectedLinkedConfig : this.selectedLinkedConfigs})
            .then(result => {
                if(result){
                    this.defaultConfigName = this.updatedDefaultConfigName;
                    this.editDefaultConfigName = false;
                    const event = new ShowToastEvent({
                        title: 'Success',
                        variant: 'success',
                        message: 'Linked Configuration created successfully.'
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
        else{
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: 'Please select the default configuration or linked configuration.'
            });
            this.dispatchEvent(event);
        }
    }

    handelEditThreshold(){
        this.editThreshold = true;
    }

    cancelEditThreshold(){
        this.editThreshold = false;
    }

    handleThresholdChange(event){
        this.updatedThreshold = event.detail.value;
    }

    handleAutoSubmitForApprovalChange(event){
        this.updatedAutoSubmitForApproval = event.detail.checked;
    }

    saveThresholdChange(){
        this.showSpinner= true;
        var updatedthresholdvalue = this.updatedThreshold ? parseInt(this.updatedThreshold) : null;
        updateThreshold({thresholdNew : updatedthresholdvalue, autoSubmitForApprovalNew : this.updatedAutoSubmitForApproval})
        .then(result => {
            if(result.isSuccess){
                this.thresholdvalue = this.updatedThreshold ? this.updatedThreshold : "None";
                this.autoSubmitForApproval = this.updatedAutoSubmitForApproval;
                this.editThreshold = false;
                const event = new ShowToastEvent({
                    title: 'Success',
                    variant: 'success',
                    message: 'Threshold value updated successfully.'
                });
                this.dispatchEvent(event);
            }
            else if(result.errorMsg) {
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

    handelEditStatuses(){
        this.editStatuses = true;
    }

    cancelEditStatuses(){
        this.statusList = [];
        this.statusList = JSON.parse(JSON.stringify(this.statusListBackup));
        this.statusIdsToDelete = [];
        this.editStatuses = false;
        if(this.statusList.length){
            this.showStatusTable = true;
        }
        else{
            this.showStatusTable = false;
        }
    }

    saveStatusesChange(){
        this.showSpinner = true;
        updateStatusValues({ statusListJson :  JSON.stringify(this.statusList) , statusIdsToDelete : this.statusIdsToDelete})
        .then(result => {
            if(result && result.isSuccess){
                this.statusList = [];
                this.statusListBackup = [];
                this.showStatusTable = false;
                if(result.goNoGoStatusWrapperList && result.goNoGoStatusWrapperList.length){
                    this.statusList = result.goNoGoStatusWrapperList;
                    this.statusListBackup = JSON.parse(JSON.stringify(result.goNoGoStatusWrapperList));
                    this.showStatusTable = true;
                }
                this.editStatuses = false;
                const event = new ShowToastEvent({
                    title: 'Success',
                    variant: 'success',
                    message: 'Go/No-Go Status values updated successfully.'
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

    handelAddNewButtonClick(){
        this.modalHeader = "Add Status";
        this.modalstatuslabel = "";
        this.modalstaticresourcename = "";
        this.modalminrange = "";
        this.modalmaxrange = "";
        this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;
    }

    handlemodalstatuslabelchange(event){
        this.modalstatuslabel = event.detail.value;
    }

    handlemodalminrangechange(event){
        this.modalminrange = event.detail.value;
    }

    handlemodalmaxrangechange(event){
        this.modalmaxrange = event.detail.value;
    }

    handlemodalstaticresourcenamechange(event){
        this.modalstaticresourcename = event.detail.value;
    }

    handleeditstatusclick(event){
        this.modalHeader = "Edit Status";
        var recordId = event.target.id;
        if(recordId.includes('-')){
            recordId = recordId.split('-')[0];
        }
        this.selectedStatusRecordId = recordId;
        if(this.statusList && this.statusList.length){
            for(var j = 0 ; j < this.statusList.length ; j++){
                if(this.statusList[j].statusid && this.statusList[j].statusid === recordId){
                    this.modalstatuslabel = this.statusList[j].label;
                    this.modalstaticresourcename = this.statusList[j].staticresourcename;
                    this.modalminrange = this.statusList[j].minrange.toString();
                    this.modalmaxrange = this.statusList[j].maxrange.toString();
                }
            }
        }
        this.isShowModal = true;
    }

    handledeletestatusclick(event){
        this.selectedStatusRecordId = "";
        var recordId = event.target.id;
        if(recordId.includes('-')){
            recordId = recordId.split('-')[0];
        }
        this.selectedStatusRecordId = recordId;
        this.isShowDeleteModal = true;
    }

    hideDeleteModalBox() {  
        this.isShowDeleteModal = false;
    }

    deleteStatus() {  
        if(this.selectedStatusRecordId && this.statusList && this.statusList.length){
            for(var j = 0 ; j < this.statusList.length ; j++){
                if(this.statusList[j].statusid && this.statusList[j].statusid === this.selectedStatusRecordId){
                    if(this.selectedStatusRecordId.length != 10 && this.selectedStatusRecordId.length > 10){
                        this.statusIdsToDelete.push(this.selectedStatusRecordId);
                    }
                    this.statusList.splice(j, 1);
                    this.selectedStatusRecordId = "";
                    break;
                }
            }

            if(this.statusList.length){
                this.showStatusTable = true;
            }
            else{
                this.showStatusTable = false;
            }
            this.isShowDeleteModal = false;
        }
    }

    saveNewStatus() {
        if(this.modalstatuslabel == undefined || this.modalstatuslabel == undefined || this.modalstatuslabel == "" || this.modalstatuslabel == NaN ||
            this.modalminrange == undefined || this.modalminrange == undefined || this.modalminrange == "" || this.modalminrange == NaN ||
            this.modalmaxrange == undefined || this.modalmaxrange == undefined || this.modalmaxrange == "" || this.modalmaxrange == NaN ||
            this.modalstaticresourcename == undefined || this.modalstaticresourcename == undefined || this.modalstaticresourcename == "" || this.modalstaticresourcename == NaN){
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: 'Please enter all values.'
            });
            this.dispatchEvent(event);
            return;
        }

        if(this.modalHeader == "Add Status"){
            var newStatus = {};
            newStatus.statusid = this.getUniueId(10);
            newStatus.label = this.modalstatuslabel;
            newStatus.minrange = parseInt(this.modalminrange);
            newStatus.maxrange = parseInt(this.modalmaxrange);
            newStatus.staticresourcename = this.modalstaticresourcename;
            this.statusList.push(newStatus);
        }
        else if(this.modalHeader == "Edit Status"){
            if(this.selectedStatusRecordId && this.statusList && this.statusList.length){
                for(var j = 0 ; j < this.statusList.length ; j++){
                    if(this.statusList[j].statusid && this.statusList[j].statusid === this.selectedStatusRecordId){
                        this.statusList[j].label = this.modalstatuslabel;
                        this.statusList[j].staticresourcename = this.modalstaticresourcename;
                        this.statusList[j].minrange = parseInt(this.modalminrange);
                        this.statusList[j].maxrange = parseInt(this.modalmaxrange);
                        this.selectedStatusRecordId = "";
                        break;
                    }
                }
            }
        }
        if(this.statusList.length){
            this.showStatusTable = true;
        }
        else{
            this.showStatusTable = false;
        }
        this.isShowModal = false;
    }

    handleManageCustomSettingsPage(){
        window.open(this.manageCustomSettingUrl,'_blank');
    }

    handleGoToApprovalProcessPage(){
        window.open('/lightning/setup/ApprovalProcesses/home','_blank');
    }

    getUniueId(length) {
        let result = '';
        const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        const charactersLength = characters.length;
        let counter = 0;
        while (counter < length) {
          result += characters.charAt(Math.floor(Math.random() * charactersLength));
          counter += 1;
        }
        return result;
    }

    handleCreateLinkedConfig(){
        this.isShowLinkedConfigModal = true;
    }

    handleRemoveLinkedConfig(){
        this.linkedConfigName = "";
        this.selectedLinkedConfigs = [];
        this.isLinkedConfigPresent = false;
    }

    hideCloseLinkedModalBox() {  
        this.isShowLinkedConfigModal = false;
    }

    cacheLinkedConfig() {
        if(this.linkedConfigName && this.selectedLinkedConfigs && this.selectedLinkedConfigs.length > 1){
            this.isLinkedConfigPresent = true;
            this.isShowLinkedConfigModal = false;
            this.updatedDefaultConfigName = "";
        }
        else{
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: 'Please enter linked configuration name and select at least two configurations.'
            });
            this.dispatchEvent(event);
        }
    }

    handleLinkedConfigNamechange(event) {  
        this.linkedConfigName = event.detail.value;
    }

    handleCheckedConfig(event){
        var configValue = event.target.id;
        if(configValue.includes('-')){
            configValue = configValue.split('-')[0];
        }
        if(event.target.checked){
            this.selectedLinkedConfigs.push(configValue);
        }
        else{
            const indexofelement = this.selectedLinkedConfigs.indexOf(configValue);
            if (indexofelement > -1) {
                this.selectedLinkedConfigs.splice(indexofelement, 1);
            }
        }
    }

    handelEditAsigneeNotification(){
        this.editAsigneeNotification = true;
    }

    cancelEditAsigneeNotification(){
        this.editAsigneeNotification = false;
    }

    handleAsigneeNotificationChange(event){
        this.updatedAsigneeNotification = event.detail.checked;
        if(!event.detail.checked){
            this.reminderNotification = false;
            this.updatedReminderNotification = false;
            this.disableReminderNotification = true;
        }
        else{
            this.disableReminderNotification = false;
        }
        this.checkDisableReminderDays();
    }

    handleReminderNotificationChange(event){
        this.updatedReminderNotification = event.detail.checked;
        this.checkDisableReminderDays();
    }

    checkDisableReminderDays(){
        if(this.updatedAsigneeNotification && this.updatedReminderNotification){
            this.disableReminderDays = false;
        }
        else{
            this.disableReminderDays = true;
        }
    }

    saveAsigneeNotificationChange(){
        this.showSpinner= true;
        if(this.updatedAsigneeNotification && (this.selectedOppStatus == undefined || this.selectedOppStatus == undefined || this.selectedOppStatus == "" || this.selectedOppStatus == NaN)){
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: 'Please select the Opportutnity stage from the dropdown.'
            });
            this.dispatchEvent(event);
            this.showSpinner= false;
            return;
        }
        var updatedReminderNotificationDaysValue = this.updatedReminderNotificationDays ? parseInt(this.updatedReminderNotificationDays) : null;
        updateAsigneeNotification({asigneeNotificationlNew : this.updatedAsigneeNotification, selectedOppStatus : this.selectedOppStatus, reminderNotificationlNew : this.updatedReminderNotification, reminderNotificationDaysNew : updatedReminderNotificationDaysValue})
        .then(result => {
            if(result.isSuccess){
                this.asigneeNotification = this.updatedAsigneeNotification;
                this.reminderNotification = this.updatedReminderNotification;
                this.reminderNotificationDays = this.updatedReminderNotificationDays ? this.updatedReminderNotificationDays : "None";
                this.editAsigneeNotification = false;
                const event = new ShowToastEvent({
                    title: 'Success',
                    variant: 'success',
                    message: 'Assignee Notification value updated successfully.'
                });
                this.dispatchEvent(event);
            }
            else if(result.errorMsg) {
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

    handleOppStageChange(event){
        this.selectedOppStatus = event.detail.value ? event.detail.value : this.selectedOppStatus;
    }

    handleReminderDaysChange(event){
        this.updatedReminderNotificationDays = event.detail.value ? event.detail.value : this.reminderNotificationDays;
    }
}