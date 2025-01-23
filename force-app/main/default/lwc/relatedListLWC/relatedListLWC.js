import { LightningElement, api, track } from "lwc";
import getRelatedList from "@salesforce/apex/RelatedListController.getRelatedList";

const relatedListColumns = [];

export default class RelatedListLWC extends LightningElement {
  @api recordId;
  @api objectName;
  @api relationshipFieldName;
  @api fieldsList;
  @track dataTableColumns;
  @track dataList = [];
  @track error;
 
  @track relatedListColumns = [];

  constructor() {
    super();
    console.log("This---", this.recordId);
  }

  /* Pass all the properties to apex controller to fetch the related list
  Map the related list to the result in js and display the data in datatable*/
  connectedCallback() {
    console.log("This connected---", this.recordId);

    let relatedListWrapper = {
      recordId: this.recordId,
      objectName: this.objectName,
      relationshipFieldName:  this.relationshipFieldName,
      fieldsList: this.fieldsList
    };

    /*const columns = [
    { label: 'Label', fieldName: 'name' },
    { label: 'Website', fieldName: 'website', type: 'url' },
    { label: 'Phone', fieldName: 'phone', type: 'phone' },
    { label: 'Balance', fieldName: 'amount', type: 'currency' },
    { label: 'CloseAt', fieldName: 'closeAt', type: 'date' },
];
*/
    const fieldsArray = (this.fieldsList === undefined)? [] : this.fieldsList.split(',');
   // console.log("fieldsArray====",fieldsArray);
    let relatedList = [];
    fieldsArray.forEach(element => {
        //{ label: 'Label', fieldName: 'name' }
        let columnObject = {label:element, fieldName:element};
        this.relatedListColumns = [...this.relatedListColumns, columnObject];
        console.log("fieldsArray====",fieldsArray);

       // this.relatedList.push(columnObject);
    });

    
 let getRelatedListRecordData = JSON.stringify(relatedListWrapper);
    getRelatedList({ relatedListData: getRelatedListRecordData })
      .then((result) => {
        //console.log("result ------ ", JSON.stringify(result));
        //this.dataTableColumns = relatedListColumns;
        if (result.length === 0) {
          this.dataList = undefined;
          // this.error = 'Error fetching records: ' + error.body.message;
        } else {
            console.log("result ====> ", JSON.stringify(result));
          this.dataList = result[0][this.relationshipFieldName];
          console.log("result ====> ",this.dataList);
          this.error = undefined;
        }
      })
      .catch((error) => {
        console.error("e.message => " + error.message);
      });
  }
}
