import { LightningElement, track, api, wire } from "lwc";
import getNotificationRecords from "@salesforce/apex/AlertController.getNotificationRecords";
import getSpendActivityRecords from "@salesforce/apex/AlertController.getSpendActivityRecords";
import getActiveAlertRecords from "@salesforce/apex/AlertController.getActiveAlertRecords";
import getExpiredAlertRecords from "@salesforce/apex/AlertController.getExpiredAlertRecords";
import getAssetNames from "@salesforce/apex/AlertController.getAssetNames";

import myModal from "c/newAlert";
import UserPreferencesReminderSoundOff from "@salesforce/schema/User.UserPreferencesReminderSoundOff";

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

const spendActivityColumns = [
  { label: "Account", fieldName: "Account__c" },
  { label: "Transaction Outcome", fieldName: "TransactionType__c" },
  { label: "Amount", fieldName: "Amount__c" },
  { label: "Transaction Date", fieldName: "Createddate" }
];

export default class realtime_spend extends LightningElement {
  constructor() {
    super();
    console.log("constructor called....");
  }
  @api recordId;
  @track dataList = [];
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
  @track isShowAlertdatatable = true;
  @track alert;
  @track isDataListEmpty = false;
  @track isSpendActivityTab = true;
  @track isViewNameEntered = true;
  @track isTransactionEntered = true;
  @track isMinimumAggregatedAmountEntered = true;
  @track isSelectedTimeFrameEntered = true;
  @track showSearchResultsTable = false;
  @track showAlertsTable = false;

  //*page = 1; //initialize 1st page for pagination
  //activeAlertRecordsList = []; //contains all the records.
  result = []; //data displayed in the table

  columns = columns; //holds column info.
  notificationColumns = notificationColumns;
  spendActivityColumns = spendActivityColumns;

  //startingRecord = 1; //start record position per page
  //endingRecord = 0; //end record position per page
  //pageSize = 10; //default value we are assigning
  // totalRecountCount = 0; //total record count received from all retrieved records
  //totalPage = 0; //total number of page is needed to display all records
  //selectedRows = [];

  @track viewOptions = [];
  get transactionOutcomeOptions() {
    return [
      { label: "Approved", value: "approved" },
      { label: "Declined", value: "declined" },
      { label: "Approved or Declined", value: "approved or declined" }
    ];
  }
  get timeFrameOptions() {
    return [
      { label: "Past 30 Days", value: "30" },
      { label: "Past 60 Days", value: "60" },
      { label: "Past 90 Days", value: "90" }
    ];
  }

  connectedCallback() {
    this.dataList = undefined;
    window.clearTimeout(this.delayTimeout);
    this.delayTimeout = setTimeout(() => {
      console.log("=====", this.recordId);
      this.populateView();
    }, 0);
  }

  async populateView() {
    console.log("this.recordId ", this.recordId);
    getAssetNames({ accountId: this.recordId })
      .then((result) => {
        const option = {
          label: "Aggregated",
          value: "Aggregated"
        };
        // this.selectOptions.push(option);
        this.viewOptions = [...this.viewOptions, option];

        for (const key in result) {
          const option = {
            label: result[key],
            value: key
          };
          // this.selectOptions.push(option);
          this.viewOptions = [...this.viewOptions, option];
        }
      })
      .catch((error) => {});
  }
  handleview(event) {
    this.view = event.target.value;
    this.isViewNameEntered = true;
    console.log("View===>", this.view);
  }
  handletransactionOutcome(event) {
    this.transactionOutcome = event.target.value;
    this.isTransactionEntered = true;
    console.log("transaction outcome===>", this.transactionOutcome);
  }
  handleMinAggregatedAmount(event) {
    this.minimumAggregatedAmount = event.target.value;
    this.isMinimumAggregatedAmountEntered = true;
    console.log("AggregatedAmount===>", this.minimumAggregatedAmount);
  }
  handleTimeFrame(event) {
    this.selectedTimeFrame = event.target.value;
    this.isSelectedTimeFrameEntered = true;
    console.log("selectedTimeFrame===>", this.selectedTimeFrame);
  }

  getElement(elementName, id) {
    let divElements = this.template.querySelectorAll(elementName);
    let foundElement;
    divElements.forEach((divElement) => {
      console.log("elements Id ", divElement.id === undefined);
      console.log("elements Id ", divElement.id);
      console.log("elements Id type ", typeof divElement.id);
      if (divElement.id !== " " && divElement.id.trim().includes(id)) {
        console.log("elements found ...");
        foundElement = divElement;
      }
    });
    return foundElement;
  }

  handleTabClick(event) {
    this.dataList = undefined;
  }

  validateInputForm() {
    let isValid = true;
    if (this.view === undefined) {
      this.isViewNameEntered = false;
      isValid = false;
    }
    if (this.transactionOutcome === undefined) {
      this.isTransactionEntered = false;
      isValid = false;
    }
    if (this.minimumAggregatedAmount === undefined) {
      this.isMinimumAggregatedAmountEntered = false;
      isValid = false;
    }
    if (this.selectedTimeFrame === undefined) {
      this.isSelectedTimeFrameEntered = false;
      isValid = false;
    }
    return isValid;
  }

  handleSearch(event) {
    if (!this.validateInputForm()) {
      return;
    }

    let spendActivityWrapper = {
      recordId: this.recordId,
      view: this.view,
      transactionType: this.transactionOutcome,
      amount: this.minimumAggregatedAmount,
      timeFrame: this.selectedTimeFrame
    };

    let spendActivityData = JSON.stringify(spendActivityWrapper);
    getSpendActivityRecords({ spendActivity: spendActivityData }).then(
      (result) => {
        this.dataTableColumns = spendActivityColumns;

        if (result.length === 0) {
          this.isDataListEmpty = true;
          this.dataList = undefined;
        } else {
          this.isDataListEmpty = false;
          this.dataList = result;
          this.error = undefined;
        }
      }
    );
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
    getNotificationRecords({ accountId: this.recordId })
      .then((result) => {
        this.isNotificationRecords = true;
        this.isActiveAlerts = false;
        this.isExpiredAlerts = false;
        this.isSpendActivityTab = false;
        this.dataTableColumns = this.notificationColumns;
        this.dataList = result["Notifications__r"];
        this.error = undefined;
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
        this.isSpendActivityTab = false;
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
        this.isSpendActivityTab = false;
        this.dataTableColumns = columns;
        this.dataList = result;
      })
      .catch((error) => {
        console.log("some error in code:", error);
      });
  }
}
