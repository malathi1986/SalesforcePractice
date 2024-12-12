import { LightningElement,track,wire } from 'lwc';
import getActiveAlertRecords from '@salesforce/apex/AlertController.getActiveAlertRecords';
import getExpiredAlertRecords from '@salesforce/apex/AlertController.getExpiredAlertRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



import myModal from 'c/newAlert';


const columns = [
    { label: 'Id', fieldName: 'Id' },
    { label: 'Alert Date', fieldName: 'AlertDate__c'},
    { label: 'Alert Name', fieldName: 'AlertName__c'},
    { label: 'Alert Type', fieldName: 'Alert_Type__c'},
    { label: 'Amount', fieldName: 'Amount__c'},
    { label: 'Email Receipients', fieldName: 'EmailRecipients__c'},
    { label: 'Merchant Type', fieldName: 'Merchant_Type__c'},
    { label: 'Notes', fieldName: 'Notes__c'},
    { label: 'Transaction Type', fieldName: 'Transcation_Type__c'},
];

//AlertDate__c,AlertName__c,Alert_Type__c,Amount__c,EmailRecipients__c,Merchant_Type__c,Notes__c,Transcation_Type__c

export default class realtime_spend extends LightningElement {

    @track activeAlertRecordsList;
    @track expiredAlertRecordsList
    @track isActiveAlerts=false;
    @track isExpiredAlerts=false;
    @track expiredAlertValue
    @track error
    @track showAlertdatatable=false;

    page = 1; //initialize 1st page for pagination
    activeAlertRecordsList = []; //contains all the records.
    result = []; //data displayed in the table
    columns = columns;//holds column info.
    startingRecord = 1; //start record position per page
    endingRecord = 0; //end record position per page
    pageSize = 10; //default value we are assigning
    totalRecountCount = 0; //total record count received from all retrieved records
    totalPage = 0; //total number of page is needed to display all records
    selectedRows = [];

    get alerttypes() {
        return [
            { label: 'New', value: 'new' },
            { label: 'In Progress', value: 'inProgress' },
            { label: 'Finished', value: 'finished' },
        ];
    }
    get timeframeoptions() {
        return [
            { label: 'New', value: 'new' },
            { label: 'In Progress', value: 'inProgress' },
            { label: 'Finished', value: 'finished' },
        ];
    }
    async handleAddAlert(){
        const result = await myModal.open({
            size: 'medium',
            description: 'Accessible description of modal\'s purpose',
            content: 'New Alert',
        });
        console.log(result);

    }
    async handlePagination(){

    }
    
    handleActiveAlerts(event){
        console.log('Method invoked....');
        getActiveAlertRecords({
        }).then((result) => {
            console.log('Method callback invoked....', result);
            this.isActiveAlerts=true;
            this.isExpiredAlerts=false;
            this.activeAlertRecordsList = result;
            this.totalRecountCount = result.length;
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
            //here we slice the data according page size
            this.result = this.activeAlertRecordsList.slice(0, this.pageSize);
            this.endingRecord = this.pageSize;
            this.columns = columns;
            this.error = undefined;
            console.log("return from remote call");
        }).catch((error) => {
            console.log("some error in code:", error);
            this.error = error;
            this.result = undefined;
            this.showToast(this.error, 'Error', 'Error'); 
        });
        console.log('Method finished....');
    }
    handleExpiredAlerts(){
        getExpiredAlertRecords({
        }).then((result) => {
            this.isExpiredAlerts=true;
            this.isActiveAlerts=false;
            this.expiredAlertRecordsList = result;
            
        }).catch((error) => {
            console.log("some error in code:", error);
        });

    }

    //press on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1;
            this.displayRecordPerPage(this.page);
        }
    }
    //press on next button this method will be called
    nextHandler() {
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1;
            this.displayRecordPerPage(this.page);
        }
    }
    //this method displays records page by page
    displayRecordPerPage(page) {
        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount)
            ? this.totalRecountCount : this.endingRecord;
        this.result = this.activeAlertRecordsList.slice(this.startingRecord, this.endingRecord);
        //increment by 1 to display the startingRecord count, 
        //so for 2nd page, it will show "Displaying 6 to 10 of 23 records. Page 2 of 5"
        this.startingRecord = this.startingRecord + 1;
        this.template.querySelector('[data-id="datatable"]').selectedRows = this.selectedRows;
    }
    handleRowSelection(event) {
        let updatedItemsSet = new Set();
        // List of selected items we maintain.
        let selectedItemsSet = new Set(this.selectedRows);
        // List of items currently loaded for the current view.
        let loadedItemsSet = new Set();
        this.result.map((ele) => {
            loadedItemsSet.add(ele.Id);
        });
        if (event.detail.selectedRows) {
            event.detail.selectedRows.map((ele) => {
                updatedItemsSet.add(ele.Id);
            });
            // Add any new items to the selectedRows list
            updatedItemsSet.forEach((id) => {
                if (!selectedItemsSet.has(id)) {
                    selectedItemsSet.add(id);
                }
            });
        }
        loadedItemsSet.forEach((id) => {
            if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
                // Remove any items that were unselected.
                selectedItemsSet.delete(id);
            }
        });
        this.selectedRows = [...selectedItemsSet];
        console.log('selectedRows==> ' + JSON.stringify(this.selectedRows));
    }
    showToast(message, variant, title) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}