import { LightningElement,track } from 'lwc';

export default class SampleUserRegistration extends LightningElement {
    @track firstName;
    @track showfirstName;

    setfirstName(event){
        this.firstName=event.target.value;
    }
    handleClick(){
        this.showfirstName=true;
    }
    handleDisable(){
        this.showfirstName=null;
        this.firstName=null;
    }

}