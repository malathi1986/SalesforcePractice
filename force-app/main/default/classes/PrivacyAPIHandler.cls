public with sharing class PrivacyAPIHandler {
   
    @AuraEnabled(cacheable=true)
    public static String invokeDNCApi(String phoneNumber, String integrationName){
      System.debug('PHONe Num--->,IntegrationName--->'+phoneNumber);
        Authentication_Parameters__mdt auth = getAuthentication(integrationName);
        String accessToken = getAccessToken(integrationName, auth);
        System.debug('accessToken ====' +  accessToken);

        Http http=new Http();
        HttpRequest httpReq=new HttpRequest();
        httpReq.setEndpoint(auth.API_Endpoint__c);
        httpReq.setMethod('POST');
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Authorization', 'Bearer '+accessToken);
        String body = '{"phoneNumber":"'+phoneNumber+'"}';
        httpReq.setBody(body);
        httpResponse response= http.send(httpReq);
        system.debug('API Response===>'+JSON.serializePretty(response.getBody()));
        Map<String, Object> responseMap = null;
        if(response.getStatusCode() == 200) { 
            return response.getBody().toString();
        }
        System.debug('status=====>'+String.valueOf(responseMap.get('status')));
        return null;
        //System.debug('status=====>'+String.valueOf(responseMap.get('status')));
    }

    private static Authentication_Parameters__mdt getAuthentication(String integrationName){
  System.debug('Inside Authentication Method===>'+integrationName);
        Authentication_Parameters__mdt auth = [SELECT Access_Token_URL__c,
        Client_Id__c,
        Client_Secret__c,
        DeveloperName,
        User_name__c,
        Password__c,
        Grant_Type__c,
        Refresh_Token__c,
        API_Endpoint__c,
        Id,
        IntegerationSetting__c,
        Label,
        Language,
        MasterLabel 
    FROM Authentication_Parameters__mdt WHERE DeveloperName =:integrationName LIMIT 1];
    return auth;

    }

    private static String getAccessToken(String integrationName, Authentication_Parameters__mdt auth){
        System.debug('IntegrationName=====  '+integrationName);
        Http http=new Http();
        HttpRequest httpReq=new HttpRequest();
        //httpReq.setEndpoint('https://api.ftc.gov/v0/dnc-complaints?api_key=Jacru36zSeXYjtnKezjAMMFJ3309HZRgAKqPS1L7&created_date_from=%222020-02-27%2004:10:00%22&created_date_to=%222020-02-27%2004:30:00%22');
        //httpReq.setEndpoint('https://aaa-7e-dev-ed.develop.lightning.force.com/services/oauth2/token?grant_type=password&client_id=3MVG91oqviqJKoEEKn2bKfSYoh_.KqzCNmv2nr.Tx4NUc6XweA2F.AsHDxbIRFSSI7enbt2Qkx_B7RR9HxDIn&client_secret=FBB4015E89BDD38B12D54F2E1BCCBB08AD946EE98281FB0FD130DCC4DD38F00C&username=malathi.pragathi@gmail.com.int&password=Malathi@123JEgdROqcjVlJTvg0jkkmD8I9');
        
     
        String queryParameters = '?grant_type='+auth.Grant_Type__c+'&client_id='+auth.Client_Id__c+'&client_secret='+auth.Client_Secret__c+'&refresh_token='+auth.Refresh_Token__c;
        
        String endPoint = auth.Access_Token_URL__c+queryParameters;
        system.debug('endPoint===>'+endPoint);
        httpReq.setEndpoint(endPoint);
        httpReq.setMethod('POST');
        httpReq.setHeader('Content-Type', 'application/json');
       // httpReq.setClientCertificateName('DNCCertificate');
       // httpReq.setHeader('PHONE-NUMBER', phoneNumber);
       
        httpResponse response= http.send(httpReq);
        system.debug('API Response===>'+JSON.serializePretty(response.getBody()));
        Map<String, Object> responseMap = null;
        if(response.getStatusCode() == 200) { 
            responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        }
        return String.valueOf(responseMap.get('access_token'));
    }
}
    