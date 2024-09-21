public with sharing class PrivacyAPIHandler {
    public PrivacyAPIHandler() {

    }
    public static void invokeDNCApi(){
        Http http=new Http();
        HttpRequest httpReq=new HttpRequest();
        //httpReq.setEndpoint('https://api.ftc.gov/v0/dnc-complaints?api_key=Jacru36zSeXYjtnKezjAMMFJ3309HZRgAKqPS1L7&created_date_from=%222020-02-27%2004:10:00%22&created_date_to=%222020-02-27%2004:30:00%22');
        httpReq.setEndpoint('https://api.ftc.gov/v0/dnc-complaints/2dae54c3d3c06d1960689139d39c3138?api_key=Jacru36zSeXYjtnKezjAMMFJ3309HZRgAKqPS1L7');
        httpReq.setMethod('GET');
        httpReq.setClientCertificateName('DNCCertificate');
        httpResponse response= http.send(httpReq);
        system.debug('API Response===>'+response.getBody());
    }
}