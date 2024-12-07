import { api,track} from 'lwc';
import insertAlertRecord from '@salesforce/apex/AlertController.insertAlertRecord';
import LightningModal from 'lightning/modal';




import RecordCreationModal from 'c/recordCreationConfirmationModal';

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
    @track alertName
    @track selectedAlertType
    @track selectedTransactionType
    @track selectedMerchantType
    @track enteredAmount
    @track selectedDate
    @track notificationOnEmailDeliveryValue
    @track specificMerchantinputValue
    @track notesInputValue
    @track emailRecipientInputValue
    @track notificationInputValue
    @track isAlertNameEntered=true
    @track isAlertTypeSelected=true
    @track isTransactionTypeSelected=true
    @track isMerchantTypeSelected=true
    @track isMerchantTypeEntered=true
    @track isEnteredAmount=true
    @track isPastDateSelected=true
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
            { label: 'All', value: 'all' },
            { label: 'Specific Merchant', value: 'specific merchant' },
        ];
    }

    handleAlertName(event){
        this.alertName=event.target.value;
        this.isAlertNameEntered=true;
    }

    handleAlertType(event){
        console.log('Alert data --- >', JSON.stringify(event));
        this.selectedAlertType=event.target.value;
        this.isAlertTypeSelected=true;
        console.log('Selected Alert Type===>', this.selectedAlertType);
    }

    handleTransactionType(event){
        this.selectedTransactionType=event.target.value;
        this.isTransactionTypeSelected=true;
    }

    handleMerchantType(event){

        this.selectedMerchantType=event.target.value;
        this.isMerchantTypeSelected=true;
        if(!this.isMerchantTypeEntered){
            this.isMerchantTypeEntered=true;
        }
        const inputFields = this.template.querySelectorAll(
            'lightning-input'
        );
    
        if (inputFields) {
            inputFields.forEach(field => {
                if(field.label === "Specific Merchant" && this.selectedMerchantType==='specific merchant' ) {
                    field.disabled = false;
                }
                else if((field.label === "Specific Merchant" && this.selectedMerchantType==='all')){
                    field.disabled = true;
                    field.value=undefined;
                }
            });
        }
    }
    handleminAggregatedSpend(event){
        this.enteredAmount=event.target.value;
        this.isEnteredAmount=true;    
    }

    handleSpecificMerchant(event){
        this.specificMerchantinputValue=event.target.value;
        this.isMerchantTypeEntered=true;
    }
    handleSelectedDate(event){
        this.selectedDate=event.target.value; 
        this.isPastDateSelected=true;
    }
    handleNotes(event){
        this.notesInputValue=event.target.value;
    }
    handleEmailRecipients(event){
        this.emailRecipientInputValue=event.target.value;
       // console.log('Email id===>',this.emailRecipientInputValue);
    }

    handleNotificationsDeliveryOptions(event){
        this.notificationOnEmailDeliveryValue = event.target.value;
    }

    getInputDate(){
        if(this.selectedDate!==undefined){
            let inputDateArr = this.selectedDate.split('-');
            console.log('inputDateArr ', inputDateArr[0]);
            console.log('inputDateArr ', inputDateArr[1]);
            console.log('inputDateArr ', inputDateArr[2]);
            let inputDateConverted = new Date();
            inputDateConverted.setDate(inputDateArr[2]);
            inputDateConverted.setMonth(inputDateArr[1]-1);
            inputDateConverted.setFullYear(inputDateArr[0]);
            return inputDateConverted;
        }else {
            return undefined;
        }
    }

    validateInputForm(){
        let isValid=true;
        if(this.alertName===undefined){
            this.isAlertNameEntered=false;
            isValid=false;
        } 
        
        if(this.selectedAlertType===undefined){
            this.isAlertTypeSelected=false;
            isValid=false;
        } 
        if(this.selectedTransactionType===undefined){
            this.isTransactionTypeSelected=false;
            console.log('TRANSCATIONTYPE--- >', this.selectedTransactionType); 
            isValid=false;
        }
        if(this.selectedMerchantType===undefined){
            this.isMerchantTypeSelected=false;
            console.log('MERCHANTTYPE--- >', this.selectedMerchantType); 
            isValid=false;
        }
        if(this.selectedMerchantType==='specific merchant'&& this.specificMerchantinputValue===undefined){
            this.isMerchantTypeEntered=false;
            isValid=false;
        }
        if(this.enteredAmount===undefined || this.enteredAmount<2500){
            this.isEnteredAmount=false;
            console.log('The aggregated spend amount should be minimum $2500.. ', this.enteredAmount);
            isValid=false;
        }  
        let inputDate = this.getInputDate();
        let today = new Date();
        if(this.selectedDate === undefined || inputDate < today){
            this.isPastDateSelected=false;
            isValid=false;
        }
        return isValid;
    }
    

    handleSave(event){
       
        if(!this.validateInputForm()){
            return;
        }
        
        this.alertRecord["AlertName__c"]=this.alertName;
        this.alertRecord["Alert_Type__c"] = this.selectedAlertType;
        this.alertRecord["Transcation_Type__c"] = this.selectedTransactionType;
        this.alertRecord["Merchant_Type__c"] = this.selectedMerchantType;
        this.alertRecord["Amount__c"] = this.enteredAmount;
        this.alertRecord["AlertDate__c"]=this.selectedDate;
        this.alertRecord["specificMerchantinputValue"] = this.specificMerchantinputValue;
        this.alertRecord["EmailRecipients__c"]=this.emailRecipientInputValue;
        this.alertRecord["notesInputValue"] = this.notesInputValue;
        this.createAlertRecord = JSON.stringify(this.alertRecord);
        console.log('alertRecord', this.createAlertRecord); 
        insertAlertRecord({alert:this.createAlertRecord})
        .then(result=>{
            console.log('result---->',result['AlertName__c']);
            this.close('okay');
            this.openModal(result['AlertName__c']);
        })
    }

    openModal(alertName) {
        RecordCreationModal.open({
            recordcreated : alertName +' Record Created Successsfully', 
            size: 'small', //small, medium, large, and full
            onrecordCreatedEvent: (e) => {
                console.log(e.detail.message);
            }
        }).then((result) => {
            console.log(result);
            

        });
    }

    handlecancel(){
        this.close('done');
    }
    
 }
    
