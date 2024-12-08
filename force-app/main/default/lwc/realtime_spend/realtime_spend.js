import { LightningElement,track,wire } from 'lwc';
import getActiveAlertRecords from '@salesforce/apex/AlertController.getActiveAlertRecords';
import getExpiredAlertRecords from '@salesforce/apex/AlertController.getExpiredAlertRecords';


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
    data = [];
    columns = columns;
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
    handleActiveAlerts(event){
        console.log('Method invoked....');
        getActiveAlertRecords({
        }).then((result) => {
            console.log('Method callback invoked....', result);
            this.isActiveAlerts=true;
            this.isExpiredAlerts=false;
            this.activeAlertRecordsList = result;
            console.log("return from remote call");
        }).catch((error) => {
            console.log("some error in code:", error);
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
}