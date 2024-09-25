public with sharing class ResponseTriggerForDoorController {

    public static void beforeInsertAction(List<avnio__Response__c> newResponseList){
        for(avnio__Response__c newResponse: newResponseList){
            newResponse.Synced_to_Door__c = false;
        }
    }

    public static void beforeUpdateAction(Map<id,avnio__Response__c> oldResponseMap, List<avnio__Response__c> newResponseList){
        for(avnio__Response__c newResponse: newResponseList){
            //Answer changed
            String oldAnswer = oldResponseMap.get(newResponse.id) != null ? oldResponseMap.get(newResponse.id).avnio__Answer__c : null;
            Boolean syncToDoor = false;
            if(newResponse.avnio__Answer__c == null){
                if(oldAnswer != null){
                    syncToDoor = true;
                }
            }
            else{
                if(oldAnswer == null){
                    syncToDoor = true;
                }
                else if(!oldAnswer.equalsIgnoreCase(newResponse.avnio__Answer__c)){
                    syncToDoor = true;
                }
            }
            if(syncToDoor){
                newResponse.Synced_to_Door__c = false;
            }
        }
    }
    
    public static void afterAction(List<avnio__Response__c> newResponseList){
        Set<String> tableQuestionsSet = new Set<String>{'Q.5'};
        List<DoorRequestWrapperClass> doorRequestWrapperList = new List<DoorRequestWrapperClass>();
        List<DoorTableRequestWrapperClass> doorTableRequestWrapperList = new List<DoorTableRequestWrapperClass>();
        for(avnio__Response__c newResponse : newResponseList){
            if(!newResponse.Synced_to_Door__c && newResponse.Door_Question_Id__c != null && newResponse.avnio__Answer__c != null && newResponse.avnio__Status__c != null && newResponse.avnio__Status__c.equalsIgnoreCase('Published')){
                if(tableQuestionsSet.contains(newResponse.Door_Question_Id__c)){
                    DoorTableRequestWrapperClass doorTableRequestWrapper = new DoorTableRequestWrapperClass();
                    doorTableRequestWrapper.uniqueCode = newResponse.Door_Question_Id__c;
                    doorTableRequestWrapper.status = 'Ready to Publish';
                    doorTableRequestWrapper.answer = getFormattedAnswer(newResponse.Door_Question_Id__c, newResponse.avnio__Answer__c);
                    doorTableRequestWrapperList.add(doorTableRequestWrapper);
                }
                else{
                    DoorRequestWrapperClass doorRequestWrapper = new DoorRequestWrapperClass();
                    doorRequestWrapper.uniqueCode = newResponse.Door_Question_Id__c;
                    doorRequestWrapper.status = 'Ready to Publish';
                    doorRequestWrapper.answer = newResponse.avnio__Answer__c;
                    doorRequestWrapperList.add(doorRequestWrapper);
                }
            }
        }
        
        if(doorRequestWrapperList.size() > 0 || doorTableRequestWrapperList.size() > 0){
            makeCallout(JSON.serialize(doorRequestWrapperList),JSON.serialize(doorTableRequestWrapperList));
        }      
        
    }

    public static Map<String, Object> getFormattedAnswer(String questionId, String answerString){
        Map<String,Object> mapToReturn = new Map<String,Object>();
        if(questionId.equalsIgnoreCase('Q.5')){
            //String toRe = '{ "rows": [ { "Additional Comments": "noooo", "City": "Tokyo", "Main Functions": "Sales", "Office Type": "Main Office" }, { "Additional Comments": "yesssss", "City": "Nairobi", "Main Functions": "Developement", "Office Type": "Sub" } ] }';
            System.debug('original : '+answerString);
            String toRe = processQ5(answerString);
            System.debug('toRe : '+toRe);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(toRe);
            mapToReturn.putAll(m);
        }
        return mapToReturn;
    }

    public static String processQ5(String answerString){
        String stringToReturn = '';
        Integer initialStringSize = 0;
        Boolean headerRowDone = false;
        Dom.Document doc = new Dom.Document();  
        doc.load(answerString);  
        Dom.XMLNode rootElement = doc.getRootElement();
        if(rootElement.getChildElements().size() > 0){
            Map<Integer, String> positionMap = new Map<Integer,String>();
            stringToReturn = stringToReturn + '{ "rows": [';
            initialStringSize = stringToReturn.length();
            for ( Dom.XMLNode tBodyElement : rootElement.getChildElements() ) {
                for ( Dom.XMLNode trElement : tBodyElement.getChildElements() ) {
                    Integer tdCount = 0;
                    String innerString = '';
                    for ( Dom.XMLNode tdElement : trElement.getChildElements() ) {
                        if(tdElement.getName().equalsIgnoreCase('th') || !headerRowDone){
                            System.debug(tdElement.getText());
                            positionMap.put(tdCount,tdElement.getText());
                            tdCount++;
                        }
                        else if(tdElement.getName().equalsIgnoreCase('td')){
                            String keyElement = positionMap.get(tdCount);
                            if(keyElement != null){
                                if(String.isBlank(innerString)){
                                    if(initialStringSize != stringToReturn.length()){
                                        stringToReturn = stringToReturn + ',';
                                    }
                                    innerString = innerString + '{';
                                }
                                else{
                                    innerString = innerString + ',';
                                }
                                innerString = innerString + '"' + keyElement + '": "' + tdElement.getText() + '"';
                            }
                            tdCount++;
                        }
                    }
                    headerRowDone = true;
                    if(innerString.length() > 0){
                        innerString = innerString + '}';
                        stringToReturn = stringToReturn + innerString;
                    }
                }
                stringToReturn = stringToReturn + ']}';
            }
        }
        return stringToReturn;
    }
    
    @future(callout=true)
    public static void makeCallout(String serializedDoorRequestWrapperList, String serializedDoorTableRequestWrapperList){
        Door_Integration__c integrationSetting = Door_Integration__c.getOrgDefaults();
        if(integrationSetting != null && integrationSetting.API_Endpoint__c != null && integrationSetting.username__c != null && integrationSetting.password__c != null){
            Boolean tokenExpired = true;
            if(integrationSetting.Access_Token__c != null && integrationSetting.Token_Creation_Date_Time__c != null){
                DateTime tokenCreationDateTime = integrationSetting.Token_Creation_Date_Time__c;
                DateTime currentDateTime = System.now();
                Integer hoursPassed = Integer.valueOf(((currentDateTime.getTime())/1000/60/60) - ((tokenCreationDateTime.getTime())/1000/60/60));
                if(hoursPassed != null && hoursPassed < 1){
                    tokenExpired = false;
                }
            }
            if(tokenExpired){
                generateNewToken(integrationSetting, serializedDoorRequestWrapperList, serializedDoorTableRequestWrapperList);
            }
            else{
                pushDataToDoorBulk(integrationSetting.API_Endpoint__c,integrationSetting.Access_Token__c,serializedDoorRequestWrapperList, serializedDoorTableRequestWrapperList);
                //System.enqueueJob(new ResponseTriggerForDoorController.PushDataToDoorQueue(integrationSetting.API_Endpoint__c,integrationSetting.Access_Token__c,serializedDoorRequestWrapperList));
            }
        }
    }

    public static void generateNewToken(Door_Integration__c integrationSetting, String serializedDoorRequestWrapperList, String serializedDoorTableRequestWrapperList){
        String endPoint = integrationSetting.API_Endpoint__c;
        endPoint = endPoint + 'auth';

        String jsonRequestBody = '{"username":"'+ integrationSetting.username__c +'","password":"'+ integrationSetting.password__c +'"}';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setHeader('Content-type', 'application/json');
        req.setMethod('POST');
        req.setBody(jsonRequestBody);
        Http http = new Http();        
        HttpResponse res = new HttpResponse();
        res = http.send(req);
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 202){
            String body = res.getBody();
            JsonParser parser = JSON.createParser(body);
            String accessToken;
            while (parser.nextToken() != null) {
                if (parser.getText() == 'token') {
                    parser.nextToken();
                    accessToken = (String)parser.readValueAs(String.class);
                    break;
                }
            }
            if(accessToken != null){
                System.enqueueJob(new ResponseTriggerForDoorController.UpdateIntegrationSetting(integrationSetting.API_Endpoint__c,accessToken,serializedDoorRequestWrapperList,serializedDoorTableRequestWrapperList));
            }
        }
    }

    public with sharing class UpdateIntegrationSetting implements Queueable , Database.AllowsCallouts {
        String endPoint;
        String accessToken;
        String serializedDoorRequestWrapperList;
        String serializedDoorTableRequestWrapperList;
        
        public UpdateIntegrationSetting(String endPoint, String accessToken, String serializedDoorRequestWrapperList, String serializedDoorTableRequestWrapperList) {
            this.endPoint = endPoint;
            this.accessToken = accessToken;
            this.serializedDoorRequestWrapperList = serializedDoorRequestWrapperList;
            this.serializedDoorTableRequestWrapperList = serializedDoorTableRequestWrapperList;
        }
        public void execute(QueueableContext context) {
            try {
                Door_Integration__c integrationSetting = Door_Integration__c.getOrgDefaults();
                integrationSetting.Access_Token__c = accessToken;
                integrationSetting.Token_Creation_Date_Time__c = System.now();
                Database.upsert(integrationSetting);
            }
            catch(Exception e) {}
            System.enqueueJob(new ResponseTriggerForDoorController.PushDataToDoorQueue(endPoint,accessToken,serializedDoorRequestWrapperList,serializedDoorTableRequestWrapperList));
        }
    }

    public with sharing class PushDataToDoorQueue implements Queueable , Database.AllowsCallouts {
        String endPoint;
        String accessToken;
        String serializedDoorRequestWrapperList;
        String serializedDoorTableRequestWrapperList;

        public PushDataToDoorQueue(String endPoint, String accessToken, String serializedDoorRequestWrapperList, String serializedDoorTableRequestWrapperList) {
            this.endPoint = endPoint;
            this.accessToken = accessToken;
            this.serializedDoorRequestWrapperList = serializedDoorRequestWrapperList;
            this.serializedDoorTableRequestWrapperList = serializedDoorTableRequestWrapperList;
        }
        public void execute(QueueableContext context) {
            try {
                //pushDataToDoor(endPoint,accessToken,serializedDoorRequestWrapperList);
                pushDataToDoorBulk(endPoint,accessToken,serializedDoorRequestWrapperList,serializedDoorTableRequestWrapperList);
            }
            catch(Exception e) {}
        }
    }

    public static void pushDataToDoorBulk(String endPoint, String accessToken, String serializedDoorRequestWrapperList, String serializedDoorTableRequestWrapperList){
        List<DoorResponseBulkWrapperClass> finalListToUpdate = new List<DoorResponseBulkWrapperClass>();
        
        try{
            List<DoorRequestWrapperClass> doorRequestWrapperList = (List<DoorRequestWrapperClass>)JSON.deserialize(serializedDoorRequestWrapperList, List<DoorRequestWrapperClass>.class);
            System.debug('doorRequestWrapperList: '+doorRequestWrapperList);
            if(doorRequestWrapperList != null && doorRequestWrapperList.size() > 0){
                String endPointNew = endPoint + 'questions';
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endPointNew);
                req.setHeader('X-Auth-Token', accessToken);
                req.setHeader('Content-type', 'application/json');
                req.setMethod('POST');
                req.setBody(JSON.serialize(doorRequestWrapperList));
                Http http = new Http();        
                HttpResponse res = new HttpResponse();
                res = http.send(req);
                System.debug(res.getBody());
                if(res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 202){
                    String response = res.getBody();
                    List<DoorResponseBulkWrapperClass> doorResponse = (List<DoorResponseBulkWrapperClass>)JSON.deserialize(response, List<DoorResponseBulkWrapperClass>.class);
                    if(doorResponse != null && doorResponse.size() > 0){
                        finalListToUpdate.addAll(doorResponse);
                    }
                }
            }
        }catch(Exception e1) {}

        try{
            System.debug('serializedDoorTableRequestWrapperList: '+serializedDoorTableRequestWrapperList);
            String endPointNew = endPoint + 'questions';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPointNew);
            req.setHeader('X-Auth-Token', accessToken);
            req.setHeader('Content-type', 'application/json');
            req.setMethod('POST');
            req.setBody(serializedDoorTableRequestWrapperList);
            Http http = new Http();        
            HttpResponse res = new HttpResponse();
            res = http.send(req);
            System.debug(res.getBody());
            if(res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 202){
                String response = res.getBody();
                List<DoorResponseBulkWrapperClass> doorResponse = (List<DoorResponseBulkWrapperClass>)JSON.deserialize(response, List<DoorResponseBulkWrapperClass>.class);
                if(doorResponse != null && doorResponse.size() > 0){
                    finalListToUpdate.addAll(doorResponse);
                }
            }
        }catch(Exception e2) {}

        if(finalListToUpdate.size() > 0){
            try{
                updateResponsesInAvnioBulk(finalListToUpdate);
            }catch(Exception e3) {}
        }
    }

    public static void updateResponsesInAvnioBulk(List<DoorResponseBulkWrapperClass> doorResponse){
        Set<String> questionIds = new Set<String>();
        for(DoorResponseBulkWrapperClass singleRespo : doorResponse){
            if(singleRespo.success != null && singleRespo.success){
                questionIds.add(singleRespo.uniqueCode);
            }
        }
        List<avnio__Response__c> responsesListToUpdate = [SELECT id, Door_Question_Id__c, Synced_to_Door__c, avnio__Status__c FROM avnio__Response__c WHERE avnio__Status__c = 'Published' AND Door_Question_Id__c IN :questionIds LIMIT 49999];
        if(responsesListToUpdate != null && responsesListToUpdate.size() > 0){
            for(avnio__Response__c singleResponse : responsesListToUpdate){
                singleResponse.Synced_to_Door__c = true;
            }
            Database.update(responsesListToUpdate);
        }
    }

    // public static void pushDataToDoor(String endPoint, String accessToken, String serializedDoorRequestWrapperList){
    //     List<DoorRequestWrapperClass> doorRequestWrapperList = (List<DoorRequestWrapperClass>)JSON.deserialize(serializedDoorRequestWrapperList, List<DoorRequestWrapperClass>.class);
    //     if(doorRequestWrapperList != null && doorRequestWrapperList.size() > 0){
    //         DoorRequestWrapperClass doorRequestWrapperClass = doorRequestWrapperList[0];
    //         String questionId = doorRequestWrapperClass.uniqueCode;
    //         String endPointNew = endPoint + 'questions/' + questionId;
    //         DoorRequestFormatClass doorRequestFormatClass = new DoorRequestFormatClass();
    //         doorRequestFormatClass.answer = doorRequestWrapperClass.answer;
    //         doorRequestFormatClass.status = 'Ready to Publish';
    //         doorRequestFormatClass.overwriteTable = true;
    //         HttpRequest req = new HttpRequest();
    //         req.setEndpoint(endPointNew);
    //         req.setHeader('X-Auth-Token', accessToken);
    //         req.setHeader('Content-type', 'application/json');
    //         req.setMethod('POST');
    //         req.setBody(JSON.serialize(doorRequestFormatClass));
    //         Http http = new Http();        
    //         HttpResponse res = new HttpResponse();
    //         res = http.send(req);
    //         if(res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 202){
    //             String response = res.getBody();
    //             DoorResponseWrapperClass doorResponse = (DoorResponseWrapperClass)JSON.deserialize(response, DoorResponseWrapperClass.class);
    //             if(doorResponse != null){
    //                 updateResponsesInAvnio(doorResponse,questionId);
    //             }
    //         }
    //         doorRequestWrapperList.remove(0);
    //         if(doorRequestWrapperList.size() > 0){
    //             System.enqueueJob(new ResponseTriggerForDoorController.PushDataToDoorQueue(endPoint,accessToken,JSON.serialize(doorRequestWrapperList)));
    //         }
    //     }
    // }

    // public static void updateResponsesInAvnio(DoorResponseWrapperClass doorResponse, String questionId){
    //     if(doorResponse.success != null && doorResponse.success){
    //         List<avnio__Response__c> responsesListToUpdate = [SELECT id, Door_Question_Id__c, Synced_to_Door__c, avnio__Status__c FROM avnio__Response__c WHERE avnio__Status__c = 'Published' AND Door_Question_Id__c =: questionId LIMIT 49999];
    //         if(responsesListToUpdate != null && responsesListToUpdate.size() > 0){
    //             for(avnio__Response__c singleResponse : responsesListToUpdate){
    //                 singleResponse.Synced_to_Door__c = true;
    //             }
    //             Database.update(responsesListToUpdate);
    //         }
    //     }
    // }
    
    public class DoorRequestWrapperClass {
		public String uniqueCode;
        public String isin;
		public String status;
		public String answer;
        public String footnote;
	}

    public class DoorTableRequestWrapperClass {
		public String uniqueCode;
        public String isin;
		public String status;
		public Map<String,Object> answer;
        public String footnote;
	}

    public class DoorRequestFormatClass {
        public String answer;
		public String status;
		public Boolean overwriteTable;
	}

    public class DoorResponseWrapperClass {
		public String message;
		public Boolean success;
	}

    public class DoorResponseBulkWrapperClass {
        public String uniqueCode;
        public String isin;
		public String message;
		public Boolean success;
	}
}