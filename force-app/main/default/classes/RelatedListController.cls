public with sharing class RelatedListController {
    @AuraEnabled(cacheable=false)
    public static List<SObject> getRelatedList(String relatedListData){
        System.debug(LoggingLevel.INFO, 'relatedList =====' + JSON.serialize(relatedListData));
        Map<String, Object> relatedListDataObj = (Map<String, Object>) JSON.deserializeUntyped(relatedListData);
        String recordId = (String) relatedListDataObj.get('recordId');
        String objectName = (String) relatedListDataObj.get('objectName');
        String relationshipFieldName = (String) relatedListDataObj.get('relationshipFieldName'); 
        String fieldsList = (String) relatedListDataObj.get('fieldsList');
        System.debug(LoggingLevel.INFO, 'fieldsList =====' + fieldsList);
        String queryResult= 'SELECT (SELECT ' +fieldsList+ ' FROM ' +relationshipFieldName+ ' ) FROM ' +objectName+ ' WHERE Id =\'' +recordId+'\'';
        System.debug(LoggingLevel.INFO, 'queryResult =====' + queryResult);
        System.debug(LoggingLevel.INFO, 'Database.query(queryResult) =====' + Database.query(queryResult));
        return Database.query(queryResult);
    }
}