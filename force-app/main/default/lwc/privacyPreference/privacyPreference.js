import { LightningElement,wire,track } from 'lwc';
import invokeDNCApi from '@salesforce/apex/PrivacyAPIHandler.invokeDNCApi';
const columns=[

    {label: 'PhoneNumber', fieldName: 'phoneNumber'},
    
    {label: 'Status', fieldName: 'status'},
    
    {label: 'Time Stamp', fieldName: 'time_stamp'},
    
    ];
export default class PrivacyPreference extends LightningElement {
    enteredPhoneNumber
    integrationName
   
    @track error;
    @track columns = columns;
    @track data;
    @track status = false;
    @track  phoneNumber;

    handleGo(event) {
       // this.clickedButtonLabel = event.target.label;
        var inputElementsArray=this.template.querySelectorAll("lightning-input");
        console.log('==>'+inputElementsArray[0].value);
        inputElementsArray.forEach(function(element){
            if(element.name=="phoneNumber"){
                this.name=element.value;
                this.enteredPhoneNumber= element.value;
            }

        },this);
       
        invokeDNCApi({phoneNumber: this.enteredPhoneNumber, integrationName:'DNCAPI'})
        .then(result => {
            const responseObj = JSON.parse(result);
            console.log('result.PhoneNumber===>'+responseObj.PhoneNumber);
            if(result !== undefined){
                this.status = true;
            }
            this.data = [{
                phoneNumber: responseObj.PhoneNumber,
                status: responseObj.status,
                time_stamp: responseObj.time_stamp
            }];

           // console.log('result==>'+this.status);
			this.error = undefined;
		})
		.catch(error => {
            console.log('error==>'+error);
			this.error = error;
			this.status = undefined;
		})
    }
}