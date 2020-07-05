import { LightningElement ,api, wire, track} from 'lwc';
import getCurrencyPairList from '@salesforce/apex/CurrencyPairHelper.getCurrencyPairList';
 import parseJSON from '@salesforce/apex/JsonDessirilizHelper.parseJSON';

export default class LightningDatatableLWCExample extends LightningElement {

    @track columns = [
        {        
            label: 'Name',
            fieldName: 'Name',
            type: 'text',
            sortable: true
        },
        {
            label: 'Currency',
            fieldName: 'Currency__c',
            type: 'text',
            sortable: true
        },
 
    ];
    @track base;
    @track date;
    @track error;
    @track pairList ;
    @wire(getCurrencyPairList)
    
    wiredPairs({

        error,
        data
    }) {
        if (data) {
            console.log('!@#$% data[0].Name = ' + data[0].Name);
            console.log('!@#$% data[0].Currency__c = ' + data[0].Currency__c);
            console.log('!@#$% data[0].CurrencyPair__r.Base__c = ' + data[0].CurrencyPair__r.Base__c);
            console.log('!@#$% data[0].CurrencyPair__r.date__c = ' + data[0].CurrencyPair__r.Date__c);

            this.base = data[0].CurrencyPair__r.Base__c
            this.date = data[0].CurrencyPair__r.Date__c
            this.pairList = data;
        } else if (error) {
            this.error = error;
        }
    }
    //    как дополнительный вариант обновление по кнопке
    clickedButtonLabel;

    handleClick(event) {
                parseJSON()
        .then(result => {
            this.base = data[0].CurrencyPair__r.Base__c
            this.date = data[0].CurrencyPair__r.Date__c
            this.pairList = data;
        })
        .catch(error => {
            this.error = error;
        });

        this.clickedButtonLabel = event.target.label;
        console.log('!@#$% clickedButtonLabel');

    
        // parseJSON()
        // .then(result => {
        //     this.base = data[0].CurrencyPair__r.Base__c
        //     this.date = data[0].CurrencyPair__r.Date__c
        //     this.pairList = data;
        // })
        // .catch(error => {
        //     this.error = error;
        // });

        
        eval("$A.get('e.force:refreshView').fire();");
    }
}