public with sharing class CurrencyPairHelper {
    @AuraEnabled(cacheable=true)
    public static List<sObject> getCurrencyPairList() {
        return [SELECT name, Currency__c, CurrencyPair__r.Base__c, CurrencyPair__r.date__c FROM Pair__c];
    }
}
 