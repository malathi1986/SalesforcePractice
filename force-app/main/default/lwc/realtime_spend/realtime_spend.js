import { LightningElement, track, api } from "lwc";
import getNotificationRecords from "@salesforce/apex/AlertController.getNotificationRecords";
import getSpendActivityRecords from "@salesforce/apex/AlertController.getSpendActivityRecords";
import getActiveAlertRecords from "@salesforce/apex/AlertController.getActiveAlertRecords";
import getExpiredAlertRecords from "@salesforce/apex/AlertController.getExpiredAlertRecords";

import myModal from "c/newAlert";

const columns = [
  { label: "Id", fieldName: "Id" },
  { label: "Alert Date", fieldName: "AlertDate__c" },
  { label: "Alert Name", fieldName: "AlertName__c" },
  { label: "Alert Type", fieldName: "Alert_Type__c" },
  { label: "Amount", fieldName: "Amount__c" },
  { label: "Email Receipients", fieldName: "EmailRecipients__c" },
  { label: "Merchant Type", fieldName: "Merchant_Type__c" },
  { label: "Notes", fieldName: "Notes__c" },
  { label: "Transaction Type", fieldName: "Transcation_Type__c" }
];

const notificationColumns = [
  { label: "Id", fieldName: "Id" },
  { label: "Account", fieldName: "Account__c" },
  { label: "Amount", fieldName: "Amount__c" },
  { label: "CardNumber", fieldName: "CardNumber__c" },
  { label: "CreatedBy", fieldName: "CreatedById" }
];

export default class realtime_spend extends LightningElement {
  @api recordId;
  @track dataList;
  @track dataTableColumns;
  @track activeAlertRecordsList;
  @track notificationsList;
  @track expiredAlertRecordsList;
  @track isNotificationRecords;
  @track isActiveAlerts = false;
  @track isExpiredAlerts = false;
  @track isNotificationRecords = false;
  @track expiredAlertValue;
  @track error;
  @track showAlertdatatable = true;
  @track alert;
  @track spendActivityInputData = {};

  //*page = 1; //initialize 1st page for pagination
  //activeAlertRecordsList = []; //contains all the records.
  result = []; //data displayed in the table
  columns = columns; //holds column info.
  notificationColumns = notificationColumns;
  //startingRecord = 1; //start record position per page
  //endingRecord = 0; //end record position per page
  //pageSize = 10; //default value we are assigning
  // totalRecountCount = 0; //total record count received from all retrieved records
  //totalPage = 0; //total number of page is needed to display all records
  selectedRows = [];

  get viewOptions() {
    return [
      { label: "Individual", value: "individual" },
      { label: "Aggregated", value: "aggregated" }
    ];
  }
  get transactionOutcomeOptions() {
    return [
      { label: "Approved", value: "approved" },
      { label: "Declined", value: "declined" },
      { label: "Approved or Declined", value: "approved or declined" }
    ];
  }
  handleview(event) {
    this.view = event.target.value;
    console.log("View===>", this.view);
  }
  handletransactionOutcome(event) {
    this.transactionOutcome = event.target.value;
    console.log("transaction outcome===>", this.transactionOutcome);
  }
  handleMinAggregatedAmount(event) {
    this.minimumAggregatedAmount = event.target.value;
    console.log("AggregatedAmount===>", this.minimumAggregatedAmount);
  }
  handleSelectedFromDate(event) {
    this.selectedFromDate = event.target.value;
    console.log("FromDate===>", this.selectedFromDate);
  }
  handleSelectedToDate(event) {
    this.selectedToDate = event.target.value;
    console.log("ToDAte===>", this.selectedToDate);
  }
  handleShowResults(event) {
    let spendActivityWrapper = {
        recordId : this.recordId,
        view:this.view,
        transactionType:this.transactionOutcome,
        amount:this.minimumAggregatedAmount,
        fromDate: this.selectedFromDate,
        toDate:this.selectedToDate
 };
 let spendActivityData = JSON.stringify(spendActivityWrapper);
 getSpendActivityRecords({spendActivity: spendActivityData }).then((result) => {
          //console.log("result---->", result["AlertName__c"]);
        });
   

  }
 
  async handleAddAlert() {
    console.log("recordId before opening the modal ======", this.recordId);
    const result = await myModal.open({
      size: "medium",
      description: "Accessible description of modal's purpose",
      content: {
        accountId: this.recordId
      }
    });
    console.log(result);
  }
  async handlePagination() {}
  handleNotifications(event) {
    console.log("Method invoked....", event);
    getNotificationRecords({ accountId: this.recordId })
      .then((result) => {
        this.isNotificationRecords = true;

        this.isActiveAlerts = false;
        this.isExpiredAlerts = false;
        console.log("result:", result);
        this.notificationColumns = notificationColumns;
        console.log("result[] ", result.Id);
        this.notificationsList = result["Notifications__r"];
        this.columns = this.notificationColumns;

        this.dataTableColumns = this.notificationColumns;
        this.dataList = result["Notifications__r"];

        // console.log('result------ ', this.notificationsList);
      })
      .catch((error) => {
        console.log("some error in code:", error);
      });
  }
  handleActiveAlerts(event) {
    console.log("Method invoked....");
    getActiveAlertRecords({ accountId: this.recordId })
      .then((result) => {
        console.log("Method callback invoked....", result);
        this.isActiveAlerts = true;
        this.isExpiredAlerts = false;
        this.isNotificationRecords = false;
        this.activeAlertRecordsList = result;

        this.dataTableColumns = columns;
        this.dataList = result;

        this.error = undefined;
        console.log("return from remote call");
      })
      .catch((error) => {
        console.log("some error in code:", error);
        this.error = error;
        this.result = undefined;
        // this.showToast(this.error, 'Error', 'Error');
      });
    console.log("Method finished....");
  }
  handleExpiredAlerts() {
    getExpiredAlertRecords({ accountId: this.recordId })
      .then((result) => {
        console.log("Inside Expired Alerts Method....", result);
        this.isExpiredAlerts = true;
        this.isActiveAlerts = false;
        this.isNotificationRecords = false;

        this.dataTableColumns = columns;
        this.dataList = result;
      })
      .catch((error) => {
        console.log("some error in code:", error);
      });
  }

  //press on previous button this method will be called
  /*  previousHandler() {
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
    }*/
}
