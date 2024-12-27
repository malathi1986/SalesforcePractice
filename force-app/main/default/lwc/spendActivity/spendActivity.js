import { LightningElement,track } from 'lwc';
import getActiveAlertRecords from '@salesforce/apex/AlertController.getActiveAlertRecords';
import getExpiredAlertRecords from '@salesforce/apex/AlertController.getExpiredAlertRecords';


import myModal from 'c/newAlert';


const columns = [
    { label: 'Id', fieldName: 'Id' },
    { label: 'AlertDate__c', fieldName: 'AlertDate__c'}
];

export default class SpendActivity extends myModal {

    @track activeAlertRecordsList;
    @track expiredAlertRecordsList
    @track isActiveAlerts=false;
    @track isExpiredAlerts=false;
    @track expiredAlertValue
    @track error
    @track showAlertdatatable;
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
    handleNotifications(event){
        console.log('Method invoked....');
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