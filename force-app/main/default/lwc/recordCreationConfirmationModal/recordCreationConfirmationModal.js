import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class recordCreationConfirmationModal extends LightningModal {

    @api recordcreated;

    handleOk() {
        const event = new CustomEvent('recordCreatedEvent', {
            detail: { 'message': 'Ok' }
        });
        this.dispatchEvent(event);
        this.close('ok');
    }
    
}