import { LightningElement,track } from 'lwc';
import myModal from 'c/newAlert';


const columns = [
    { label: 'Date Received', fieldName: 'name' },
    { label: 'Card Number', fieldName: 'website', type: 'url' },
    { label: 'Alert Name', fieldName: 'phone', type: 'phone' },
    { label: 'Transaction Status', fieldName: 'amount', type: 'currency' },
    { label: 'Transaction', fieldName: 'closeAt', type: 'date' },
    { label: 'Amount', fieldName: 'closeAt', type: 'date' },
    { label: 'Merchant', fieldName: 'closeAt', type: 'date' },
    { label: 'SE Number', fieldName: 'closeAt', type: 'date' },
    { label: 'Note', fieldName: 'closeAt', type: 'date' }
];

export default class SpendActivity extends LightningElement {
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
    
}