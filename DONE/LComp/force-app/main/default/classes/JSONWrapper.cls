global with sharing class JSONWrapper {
// вспомогательный класс, в работе не использовался
   
    public  class JSONInfo{
    public String base;
    public String dateText;
       
       
    public String getBase(){
           return base;
       }
       
    public String getDateText(){
    return dateText;
    }


    public void getInfo(){
    System.debug('!!!!BASE!!!!!'+ base);
    System.debug('!!!!DATE!!!!!'+ dateText);
        
    }
    
}


 }