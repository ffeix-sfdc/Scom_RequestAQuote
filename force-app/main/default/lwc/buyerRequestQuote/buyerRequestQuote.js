import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ToastContainer from 'lightning/toastContainer';

/**
 * @slot headerText ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Summary", textDisplayInfo: "{\"headingTag\": \"h3\", \"textStyle\": \"heading-medium\"}", "textDecoration": "{\"bold\": true}" }}] })
 * @slot successText ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Summary", textDisplayInfo: "{\"headingTag\": \"h3\", \"textStyle\": \"heading-medium\"}", "textDecoration": "{\"bold\": true}" }}] }) 
*/
export default class BuyerRequestQuote extends LightningElement {
    @api buttonLabel;
    @api toastSuccessMsg;
    @api cartId;
    @api uniqueProductCount;
    @api runFlow = false;
    @api isSuccess = false;
    @api isPreview = false;
    @track isLoading = false;

    connectedCallback() {
        this.isPreview = this.isInSitePreview();
        if (this.isPreview) {
            this.cartId = 'xxxxxx';
            this.uniqueProductCount = 10;
        }
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 3;
        toastContainer.toastPosition = 'top-center';
    }

    isInSitePreview() {
        let url = document.URL;
        
        return (url.indexOf('sitepreview') > 0 
            || url.indexOf('livepreview') > 0
            || url.indexOf('live-preview') > 0 
            || url.indexOf('live.') > 0
            || url.indexOf('.builder.') > 0);
    }

    get isEmpty() {
        return this.uniqueProductCount > 0 ? false : true;
    }

    handleClick(event){
        this.isLoading = true;
        this.runFlow = true;
    }

    get flowInputVariables() {
        return [{
            name: 'recordId',
            type: 'String',
            value: this.cartId
        }];
    }

    handleFlowStatusChange(event) {
        this.isLoading = false;        
        this.runFlow = false;
        this.isSuccess = true;       
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: this.toastSuccessMsg,
                variant: 'success'
            })
        );

    }

    get disableButton(){
        return this.runFlow;
    }

    /**
     * Enable the component to render as light DOM
     *
     * @static
     */
    static renderMode = 'light';

}