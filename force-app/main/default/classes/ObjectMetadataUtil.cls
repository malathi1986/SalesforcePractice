public with sharing class ObjectMetadataUtil {
    public ObjectMetadataUtil() {

    }

    public static Map<String, Schema.DescribeFieldResult> getFieldsType(String objectName, Set<String> fieldNames){
        SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult sObjectResult =  sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldsMap = sObjectResult.fields.getMap(); 
        
        Map<String, Schema.DescribeFieldResult> filteredFieldNames = new Map<String, Schema.DescribeFieldResult>();

        for (String incomingFieldName : fieldNames) {
            filteredFieldNames.put(incomingFieldName, fieldsMap.get(incomingFieldName).getDescribe());
        } 
        return filteredFieldNames;
    }
}