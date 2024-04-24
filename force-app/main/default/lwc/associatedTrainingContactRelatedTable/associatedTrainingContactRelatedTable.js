import { LightningElement, api, track, wire } from 'lwc';
import getDataByTrainingEventId from '@salesforce/apex/AssociatedTrainingContactService.getDataByTrainingEventId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { refreshApex } from '@salesforce/apex';

export default class AssociatedTrainingContactRelatedTable extends NavigationMixin(LightningElement) {

    currTrainingEventId;

    @api
    get recordId(){
        return this.currTrainingEventId;
    }
    set recordId(value){
        this.currTrainingEventId = value;
    }

    @track 
    sortBy;
    @track 
    sortDirection;

    error;

    @track
    isLoading = true
    @track
    isData = false
    @track
    isDeleting = false;

    @track
    tableData = [];

    @api
    columns = [
        {type: "button", typeAttributes: {  
            label: 'Edit',  
            name: 'Edit',  
            title: 'Edit',
            variant: "base", 
            disabled: false,  
            value: 'Edit',  
            iconPosition: 'left',
            style: 'height: 10px'
        },
        cellAttributes: {
            style: 'height: 10px',
            class: 'edit-column'
        }, fixedWidth: 40},  
        {type: "button", typeAttributes: {  
            label: 'Delete',  
            name: 'Delete',  
            title: 'Delete',
            variant: "base", 
            disabled: false,  
            value: 'Delete',  
            iconPosition: 'left',
            style: 'height: 10px' 
        },
        cellAttributes: {
            style: 'height: 10px',
            class: 'delete-column'
        }, fixedWidth:60},
        {label: 'First Name', fieldName: 'ContactFirstNameURL', sortable: true, type: 'url',
        typeAttributes: {label: {fieldName: 'First_Name_Feedback__c'}, target:'_blank'}
        },
        {label: 'Last Name', fieldName: 'ContactLastNameURL', sortable: true, type: 'url',
        typeAttributes: {label: {fieldName: 'Last_Name_Feedback__c'}, target:'_blank'}
        },
        {label: 'Email', fieldName: 'Contact_Email_for_GetFeedback__c', type: 'email', sortable: true},
        {label: 'Account Name', fieldName: 'AccountURL', type: 'url', sortable: true,
        typeAttributes: {label: {fieldName: 'Account_Name__c'}, target:'_blank'}
        },
        {label: 'Status', fieldName: 'Status__c', type: 'text', sortable: true},
        {label: 'Internal Notes', fieldName: 'Internal_Notes__c', type: 'text'},
        {label: 'Prework Task Status', fieldName: 'prework_task_status__c', type: 'text', sortable: true},
        {label: 'Project Grouping', fieldName: 'Project_Grouping__c', type: 'text', sortable: true},
        {label: 'Material Opportunity', fieldName: 'MaterialOppURL', type: 'url', sortable: true,
        typeAttributes: {label: {fieldName: 'MaterialOppName'}, target:'_blank'}
        },
        {label: 'Materials Delivered', fieldName: 'Materials_Delivered__c', type: 'boolean', sortable: true},
        {label: 'Order No.', fieldName: 'Order_No__c', type: 'text', sortable: true}
    ];

    // Methods

    // Load Data
    connectedCallback(){
        if(this.currTrainingEventId){
            this.getData();
        }
    }

    handleRefresh(){
        return refreshApex(this.getData());
    }

    getData(){
        const ERROR_TITLE = 'Error loading associated training contacts data';
        const ERROR_VARIANT = 'error';
        getDataByTrainingEventId({trainingEventId: this.currTrainingEventId})
        .then(result => {
            this.tableData = JSON.parse(JSON.stringify(result));
            if(this.tableData){
                for(let i = 0; i < this.tableData.length; i++){
                    this.tableData[i].AccountURL = '/' + this.tableData[i].Contact__r.AccountId;
                    if(this.tableData[i].Material_Opportunity__c){
                        this.tableData[i].MaterialOppURL = '/' + this.tableData[i].Material_Opportunity__c;
                        this.tableData[i].MaterialOppName = this.tableData[i].Material_Opportunity__r.Name;
                    }
                    this.tableData[i].ContactFirstNameURL = '/' + this.tableData[i].Contact__c;
                    this.tableData[i].ContactLastNameURL = '/' + this.tableData[i].Contact__c;
                }
            }
            this.error = undefined;
            if(this.tableData.length > 0){
                this.isData = true
            }
            this.isLoading = false;
        })
        .catch(error => {
            this.error = error;
            this.data = undefined;
            const toast = new ShowToastEvent({
                title: ERROR_TITLE,
                variant: ERROR_VARIANT,
                message: error.message
            });
            this.dispatchEvent(toast);
        })
    }

    // Column Sorting 
    handleSortData(event) {       
        let sortByField = event.detail.fieldName;
        if(sortByField === 'ContactFirstNameURL'){
            this.sortBy = 'First_Name_Feedback__c';
        } else if(sortByField === 'ContactLastNameURL'){
            this.sortBy = 'Last_Name_Feedback__c';
        } else if(sortByField === 'AccountURL'){
            this.sortBy = 'Account_Name__c';
        } else if(sortByField === 'MaterialOppURL'){
            this.sortBy = 'MaterialOppName';
        } else{
            this.sortBy = sortByField;
        }
        this.sortDirection = event.detail.sortDirection;       
        this.sortData(this.sortBy, this.sortDirection);
        this.sortBy = sortByField;
    }

    sortData(fieldname, direction) {
        
        let parseData = JSON.parse(JSON.stringify(this.tableData));

        let keyValue = (a) => {
            return a[fieldname];
        };

       let isReverse = direction === 'asc' ? 1: -1;

           parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
           
            return isReverse * ((x > y) - (y > x));
        });
    
        this.tableData = parseData;
    }

    // Add, edit and delete functionality 
    handleRowAction(event){
        const rowId = event.detail.row.Id;
        const actionName = event.detail.action.name;
        if(actionName === 'Edit'){
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes:{
                    recordId: rowId,
                    objectApiName: 'Associated_Training_Contacts__c',
                    actionName: 'view'
                }
            })
            .then((url) => {
                window.open(url, "_blank");
            });
        } else if(actionName === 'Delete'){
            this.handleDelete(rowId)
        }
    }


    // Delete method
    handleDelete(rowId){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Please wait...',
                message: 'Deleting record',
                variant: 'info'
            })
        )
        deleteRecord(rowId)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record deleted',
                        variant: 'success'
                    })
                );
                this.tableData = this.tableData.filter(item => item.Id != rowId)
                if(this.tableData < 1){
                this.isData = false;
            }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    // Add contact functionality
    handleAdd(){
        const defaultValues = encodeDefaultFieldValues({
            Training_Event__c: this.currTrainingEventId,
        });
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Associated_Training_Contacts__c',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues,
                navigationLocation: 'RELATED_LIST'
            }
        });
    }

    // navigate to related list view
    handleNaviagateViewAll(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.currTrainingEventId,
                objectApiName: 'Training_Event__c',
                relationshipApiName: 'Training_Members__r',
                actionName: 'view'
            }
        });
    }


}