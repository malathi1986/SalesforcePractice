import { api,track} from 'lwc';
//import Alert__c from '@salesforce/schema/AlertController'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import insertAlertRecord from '@salesforce/apex/AlertController.insertAlertRecord';
import LightningModal from 'lightning/modal';

const columns = [
    { label: 'Date Received', fieldName: 'name' },
    { label: 'Card Number', fieldName: 'website', type: 'url' },
    { label: 'Alert Name', fieldName: 'phone', type: 'phone' },
   
];

export default class NewAlert extends LightningModal{
   @track alertRecord = {
   };
   @track alertId;
   @track error;
   @track alertNameValue
   @track selectedAlertType
   @track selectedTransactionType
   @track selectedMerchantType
   @track notificationOnEmailDeliveryValue
    
   @track specificMerchantinputValue
   @track notesInputValue
   @track emailRecipientInputValue
   @track notificationInputValue

   
    

    @api content;
    checkboxVal = true;
    data = [];
    columns = columns;
    get alerttypes() {
        return [
            { label: 'Large Purchase', value: 'largePurchase' },
            { label: 'Declined Transaction', value: 'declinedTransaction' },
            { label: 'Internationl Purchase', value: 'internationalPurchase' },
        ];
    }

    get transaction() {
        return [
            { label: 'Sales', value: 'sales' },
            { label: 'Purchases', value: 'purchases' },
            { label: 'Payments', value: 'payment' },
        ];
    }

    get merchant() {
        return [
            { label: 'Retail', value: 'retail' },
            { label: 'Online', value: 'online' },
            { label: 'HighRisk', value: 'highRisk' },
        ];
    }
    handleAlertName(event){
        this.alertNameValue=event.target.value;
        console.log('Alert Name===>', this.alertNameValue);
    }
    handleAlertType(event){
        console.log('Alert data --- >', JSON.stringify(event));
        this.selectedAlertType=event.target.value;
        console.log('Selected Alert Type===>', this.selectedAlertType);

    }
    handleTransactionType(event){
        this.selectedTransactionType=event.target.value;

    }
    handleMerchantType(event){
        this.selectedMerchantType=event.target.value;

    }
    handleSpecificMerchant(event){
        this.specificMerchantinputValue=event.target.value;
    }
    handleNotes(event){
        this.notesInputValue=event.target.value;
    }
    handleEmailRecipients(event){
        this.emailRecipientInputValue=event.target.value;
    }


    handleNotificationsDeliveryOptions(event){
        this.notificationOnEmailDeliveryValue = event.target.value;
    }

    handleSave(event){

        console.log('Input data --- >', JSON.stringify(event)); 
        //console.log('this.selectedAlertType --- >', this.selectedAlertType); 
       // console.log('this.selectedTransactionType --- >',this.selectedTransactionType);
       //console.log('Alert Name===>', this.alertName);
        this.alertRecord["Alert_Type__c"] = this.selectedAlertType;
        this.alertRecord["Transcation_Type__c"] = this.selectedTransactionType;
        this.alertRecord["selectedMerchantType"] = this.sselectedMerchantType;
        this.alertRecord["specificMerchantinputValue"] = this.specificMerchantinputValue;
        this.alertRecord["notesInputValue"] = this.notesInputValue;
        this.createAlertRecord = JSON.stringify(this.alertRecord);
        console.log('alertRecord', this.createAlertRecord); 
        insertAlertRecord({alert:this.createAlertRecord})
        .then(result=>{
            console.log('result====>',result);
            const parsedResult = JSON.parse(result);
            //this.alertRecord={};
            //this.alertId=result.id;
            console.log('alertRecordCreated=====>'+parsedResult.id); 
            const toastEvent = new ShowToastEvent({
                title: 'Success!',
                message: 'Record created successfully',
                variant:'success'
        });
        this.dispatchEvent(toastEvent);
    })
        .catch(error=>{
            this.error=error.message;
        });
        }

        handlecancel(){
            this.close('done');
    
        }
        //@wire(insertAlert) insertRecord;
    }
    
