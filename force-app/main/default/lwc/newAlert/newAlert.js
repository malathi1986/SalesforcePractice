import { api, track, wire } from "lwc";
import insertAlertRecord from "@salesforce/apex/AlertController.insertAlertRecord";
import getAssetRecords from "@salesforce/apex/AlertController.getAssetRecords";
import LightningModal from "lightning/modal";
import { CurrentPageReference } from "lightning/navigation";

import RecordCreationModal from "c/recordCreationConfirmationModal";

const columns = [
  { label: "Date Received", fieldName: "name" },
  { label: "Card Number", fieldName: "website", type: "url" },
  { label: "Alert Name", fieldName: "phone", type: "phone" }
];

export default class NewAlert extends LightningModal {
  @track alertRecord = {};
  @api content;
  @track header = "New Alert";
  @api recordId;
  @track assetRecordsList;
  @track alertId;
  @track alertName;
  @track selectedAlertType;
  @track selectedTransactionType;
  @track selectedMerchantType;
  @track enteredAmount;
  @track selectedDate;
  @track notificationOnEmailDeliveryValue;
  @track specificMerchantinputValue;
  @track notesInputValue;
  @track emailRecipientInputValue;
  @track notificationInputValue;
  @track selectedAssetValue;
  @track isAlertNameEntered = true;
  @track isAlertTypeSelected = true;
  @track isTransactionTypeSelected = true;
  @track isMerchantTypeSelected = true;
  @track isMerchantTypeEntered = true;
  @track isEnteredAmount = true;
  @track isPastDateSelected = true;
  selectedCardNumbers = [];

  @track assets;
  checkboxVal = true;
  data = [];
  columns = columns;

  constructor() {
    super();
  }

  connectedCallback() {
    getAssetRecords({ accountId: this.content["accountId"] })
      .then((result) => {
        console.log("result ===== ", result);
        this.assets = result;
        this.assets.forEach((asset) => {
          console.log(" asset ", asset.Name);
        });
      })
      .catch((error) => {
        console.log("error ===== ", error);
      });
  }

  //@wire(getAssetRecords, {accountId : this.content['accountId']}) assets;

  get alerttypes() {
    return [
      { label: "Large Purchase", value: "largePurchase" },
      { label: "Declined Transaction", value: "declinedTransaction" },
      { label: "Internationl Purchase", value: "internationalPurchase" }
    ];
  }

  get transaction() {
    return [
      { label: "Sales", value: "sales" },
      { label: "Purchases", value: "purchases" },
      { label: "Payments", value: "payment" }
    ];
  }

  get merchant() {
    return [
      { label: "All", value: "all" },
      { label: "Specific Merchant", value: "specific merchant" }
    ];
  }

  handleAlertName(event) {
    this.alertName = event.target.value;
    this.isAlertNameEntered = true;
  }

  handleAlertType(event) {
    this.selectedAlertType = event.target.value;
    this.isAlertTypeSelected = true;
  }

  handleTransactionType(event) {
    this.selectedTransactionType = event.target.value;
    this.isTransactionTypeSelected = true;
  }

  handleMerchantType(event) {
    this.selectedMerchantType = event.target.value;
    this.isMerchantTypeSelected = true;
    if (!this.isMerchantTypeEntered) {
      this.isMerchantTypeEntered = true;
    }
    const inputFields = this.template.querySelectorAll("lightning-input");

    if (inputFields) {
      inputFields.forEach((field) => {
        if (
          field.label === "Specific Merchant" &&
          this.selectedMerchantType === "specific merchant"
        ) {
          field.disabled = false;
        } else if (
          field.label === "Specific Merchant" &&
          this.selectedMerchantType === "all"
        ) {
          field.disabled = true;
          field.value = undefined;
        }
      });
    }
  }
  handleminAggregatedSpend(event) {
    this.enteredAmount = event.target.value;
    this.isEnteredAmount = true;
  }

  handleSpecificMerchant(event) {
    console.log('Specific merchant =====>',event);
    this.specificMerchantinputValue = event.target.value;
    console.log('Specific merchant =====>',this.specificMerchantinputValue);
    this.isMerchantTypeEntered = true;
  }
  handleSelectedDate(event) {
    this.selectedDate = event.target.value;
    this.isPastDateSelected = true;
  }
  handleSelectedCard(event) {
    this.selectedCard = event.target.value;
  }
  handleNotes(event) {
    this.notesInputValue = event.target.value;
  }
  handleEmailRecipients(event) {
    this.emailRecipientInputValue = event.target.value;
  }

  handleNotificationsDeliveryOptions(event) {
    this.notificationOnEmailDeliveryValue = event.target.value;
  }
  handleSelectedasset(event) {
    console.log("Event===>", event);

    if (event.detail.checked === true) {
      if (!this.selectedCardNumbers.includes(event.target.value)) {
        this.selectedCardNumbers.push(event.target.value);
      }
    } else {
      if (this.selectedCardNumbers.includes(event.target.value)) {
        this.selectedCardNumbers.pop(event.target.value);
      }
    }
    console.log("selected cards:=====>" + this.selectedCardNumbers);
  }

  getInputDate() {
    if (this.selectedDate !== undefined) {
      let inputDateArr = this.selectedDate.split("-");
      console.log("inputDateArr ", inputDateArr[0]);
      console.log("inputDateArr ", inputDateArr[1]);
      console.log("inputDateArr ", inputDateArr[2]);
      let inputDateConverted = new Date();
      inputDateConverted.setDate(inputDateArr[2]);
      inputDateConverted.setMonth(inputDateArr[1] - 1);
      inputDateConverted.setFullYear(inputDateArr[0]);
      return inputDateConverted;
    } else {
      return undefined;
    }
  }

  validateInputForm() {
    let isValid = true;
    if (this.alertName === undefined) {
      this.isAlertNameEntered = false;
      isValid = false;
    }

    if (this.selectedAlertType === undefined) {
      this.isAlertTypeSelected = false;
      isValid = false;
    }
    if (this.selectedTransactionType === undefined) {
      this.isTransactionTypeSelected = false;
      console.log("TRANSCATIONTYPE--- >", this.selectedTransactionType);
      isValid = false;
    }
    if (this.selectedMerchantType === undefined) {
      this.isMerchantTypeSelected = false;
      console.log("MERCHANTTYPE--- >", this.selectedMerchantType);
      isValid = false;
    }
    if (
      this.selectedMerchantType === "specific merchant" &&
      this.specificMerchantinputValue === undefined
    ) {
      this.isMerchantTypeEntered = false;
      isValid = false;
    }
    if (this.enteredAmount === undefined || this.enteredAmount < 2500) {
      this.isEnteredAmount = false;
      console.log(
        "The aggregated spend amount should be minimum $2500.. ",
        this.enteredAmount
      );
      isValid = false;
    }
    let inputDate = this.getInputDate();
    let today = new Date();
    if (this.selectedDate === undefined || inputDate < today) {
      this.isPastDateSelected = false;
      isValid = false;
    }
    return isValid;
  }

  handleSave(event) {
    if (!this.validateInputForm()) {
      return;
    }

    this.alertRecord["AlertName__c"] = this.alertName;
    this.alertRecord["Alert_Type__c"] = this.selectedAlertType;
    this.alertRecord["Transcation_Type__c"] = this.selectedTransactionType;
    this.alertRecord["Merchant_Type__c"] = this.selectedMerchantType;
    this.alertRecord["Amount__c"] = this.enteredAmount;
    this.alertRecord["AlertDate__c"] = this.selectedDate;
    this.alertRecord["SpecificMerchant_Type__c"] =this.specificMerchantinputValue;
    this.alertRecord["EmailRecipients__c"] = this.emailRecipientInputValue;
    this.alertRecord["Notes__c"] = this.notesInputValue;
    // this.alertRecord["creditCardNumber__c"] = this.alertName;

    console.log("alertRecord", this.createAlertRecord);
    let alertRecordWrapper = {
      alert: this.alertRecord,
      creditCardNumbers: this.selectedCardNumbers
    };
    let alertData = JSON.stringify(alertRecordWrapper);
    insertAlertRecord({ alert: alertData }).then((result) => {
      console.log("result---->", result["AlertName__c"]);
      this.close("okay");
      this.openModal(result["AlertName__c"]);
    });
  }

  openModal(alertName) {
    RecordCreationModal.open({
      recordcreated: alertName + " Record Created Successsfully",
      size: "small", //small, medium, large, and full
      onrecordCreatedEvent: (e) => {
        console.log(e.detail.message);
      }
    }).then((result) => {
      console.log(result);
    });
  }

  handlecancel() {
    this.close("done");
  }
}
