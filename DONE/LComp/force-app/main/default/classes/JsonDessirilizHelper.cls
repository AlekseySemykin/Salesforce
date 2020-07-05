public class JsonDessirilizHelper implements Schedulable {

    public void execute(SchedulableContext ctx) 
    {
        // выполнится при отработке JOBs 
        parseJSON();
    }
        // вызыв метода, чтобы Jobs создались 
        // сделано 6 штук, из-за ограничений SF 
    public static void testSch(){

        String sch1 = '0 0 * * * ?'; System.schedule('Schedule of Currency Pairs refresh 1', sch1, new JsonDessirilizHelper());
        String sch2 = '0 10 * * * ?'; System.schedule('Schedule of Currency Pairs refresh 2', sch2, new JsonDessirilizHelper());
        String sch3 = '0 20 * * * ?'; System.schedule('Schedule of Currency Pairs refresh 3', sch3, new JsonDessirilizHelper());
        String sch4 = '0 30 * * * ?'; System.schedule('Schedule of Currency Pairs refresh 4', sch4, new JsonDessirilizHelper());
        String sch5 = '0 40 * * * ?'; System.schedule('Schedule of Currency Pairs refresh 5', sch5, new JsonDessirilizHelper());
        String sch6 = '0 50 * * * ?'; System.schedule('Schedule of Currency Pairs refresh 6', sch6, new JsonDessirilizHelper());
    }

// Парсинг JSON
    @future(callout=true)
     @AuraEnabled(cacheable=true)    // что бы вызвать метод по кнопке в js
    public static void parseJSON(){
    Http httpProtocol = new Http();
    HttpRequest request = new HttpRequest(); 
    String endpoint = 'https://api.ratesapi.io/api/latest';
    request.setEndPoint(endpoint);
    request.setMethod('GET');
    HttpResponse response = httpProtocol.send(request);
    JSONParser parser = JSON.createParser(response.getBody());
   
    // Попытка дессирилизовать JSON в поля объекта JSONWrapper , не удачная поэтому парсинг идет в лоб 

    // JSONWrapper.JSONInfo jsonGetInfo = (JSONWrapper.JSONInfo)JSON.deserialize(response.getBody().replace('"date":', '"dateText":'),JSONWrapper.JSONInfo.class);
    // System.debug('!!!!!!!!!!!!jsonGetInfo ' +jsonGetInfo);
    // jsonGetInfo.getInfo();
    // Map<String, Object> jsonGetMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
 
    // Map<String, Object> jsonGetMapInfo = (Map<String, Object>)jsonGetMap.get('rates');
     
    // for (String key : jsonGetMapInfo.keySet())
    //         {
    //             // lolacl = jsonGetMapInfo.get(key).toString();
    //             // System.debug('STRING!!!!!!!!!!!!!!!!!!!!!!!!!!!!!' + lolacl);
    //             System.debug('!!!!!!!!!!!!!!!!!!Key + Value = ' + key + ' ' + 'LOL ' + jsonGetMapInfo.get(key));
    //         }

     // for(Object obj:jsonGetMapInfo){
    //     ratesMap.add(obj);
        
    // }

     // Инициализация переременных для дальнейщшей записи 
    String str='';
    String baseText = '';
    String dateText ='';
    Map<String, String> RatesPairs = new Map<String, String>();

    parser.nextToken() ;   
// получние информации из JSON  BASE
    while (parser.nextToken() != null) {
        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'base')) {
            parser.nextToken();
            baseText = parser.getText();
            System.debug('baseText !!!!!!!!! ' + baseText);
        } 
        // получние информации из JSON  RATES
        else
         if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'rates')) {
                parser.nextToken();
             while(parser.nextToken() != JSONToken.END_OBJECT) {
                    
                    String rateNameText = parser.getText();

                    JSONToken rateValue = parser.nextValue();
                    String rateValueText = parser.getText();

                    RatesPairs.put(rateNameText,rateValueText);
            }
            for (String key : RatesPairs.keySet())
            {
                System.debug('Key + Value = ' + key + ' ' + RatesPairs.get(key));
            }
        }
        //получние информации из JSON  Date
         else if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'date')) {
            parser.nextToken();
            dateText = parser.getText();
            System.debug('dateText !!!!!!!!! ' + dateText);
        }
    }
    // передача данных в созданные на org объекты
    CurrencyPair__c [] currencyMassiv = [SELECT Id, Base__c, Date__c
                                         FROM CurrencyPair__c WHERE Base__c=: baseText];
        if(!currencyMassiv.isEmpty()&& currencyMassiv!=null){
            currencyMassiv[0].Base__c=baseText;
            currencyMassiv[0].Date__c=dateText;
            update currencyMassiv[0];
         } else {
            CurrencyPair__c test = new CurrencyPair__c(Base__c=baseText,Date__c=dateText);
            insert test;
         }

         // получение id для lookup
         CurrencyPair__c  currencyRecord = [SELECT Id, Base__c, Date__c
         FROM CurrencyPair__c WHERE Base__c=: baseText];

         Pair__c [] pairsMassiv =  [SELECT Id, Currency__c, CurrencyPair__c,Name
         FROM Pair__c];


         if(!pairsMassiv.isEmpty() && pairsMassiv!=null){
         try{
             delete pairsMassiv;
         } catch   (DmlException e){
             System.debug(e);
         }

        }
         Pair__c []  pairsMatrix = new Pair__c[]{};
         for (String key : RatesPairs.keySet()){
             pairsMatrix.add(new Pair__c(Name=key, Currency__c=RatesPairs.get(key), CurrencyPair__c= currencyRecord.Id));
             }
             insert pairsMatrix;



        //  if(!pairsMassiv.isEmpty() && pairsMassiv!=null){
        //     // update 


        //     } else {
        //     Pair__c []  pairsMatrix = new Pair__c[]{};
        //     for (String key : RatesPairs.keySet()){
        //         pairsMatrix.add(new Pair__c(Name=key, Currency__c=RatesPairs.get(key), CurrencyPair__c= currencyRecord.Id));
        //         }
        //         insert pairsMatrix;
        //     }
    }
}