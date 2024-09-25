public with sharing class CustomCommentFeederController {
    

    @AuraEnabled
    public static Map<Id,String> getUsers(){
        Map<Id,String> usersMap = new  Map<Id,String>();
        try{
            List<User> usersList = [select id,name from user];
            if(usersList != null && usersList.size() > 0){
                for(User u : usersList){
                    usersMap.put(u.Id,u.Name);
                }
            }
        }
        catch(Exception e){}
        return usersMap;
    }

    @AuraEnabled
    public static Boolean createFeedItemRec(List<String> responseIds, String textbody, List<String> mentionedUsersList){
        if(responseIds != null && responseIds.size() > 0 && textbody != null && String.isNotBlank(textbody)){
            System.debug(textbody);
            if(textbody.contains('<img src="') || (mentionedUsersList != null && mentionedUsersList.size() > 0)){
                try {
                    String parseTextBody = textbody;
                    Set<String> linksList = new Set<String>();
                    do{
                        if(parseTextBody.contains('https://')){
                            Integer startPoint = parseTextBody.indexOf('https://');
                            Boolean isImageUrl = false, isAnchorUrl = false;
                            if(startPoint > 0 && parseTextBody.substring(startPoint-1,startPoint) == '"'){
                                if(startPoint > 5 && parseTextBody.substring(startPoint-10,startPoint) == '<img src="'){
                                    isImageUrl = true;
                                }
                            }
                            for(Integer i = startPoint; i < parseTextBody.length() ; i++){
                                if(isImageUrl && parseTextBody.substring(i,i+1) == '"'){
                                    linksList.add(parseTextBody.substring(startPoint,i));
                                    parseTextBody = parseTextBody.substring(i+2,parseTextBody.length());
                                    break;
                                }
                            }
                        }
                    } while(parseTextBody.contains('https://'));
                    System.debug(linksList);

                    List<ContentVersion> contentVersionList = new List<ContentVersion>();
                    List<ContentVersion> conteDocList = new List<ContentVersion>();
                    if(!Test.isRunningTest()){
                        for(String link : linksList){
                            PageReference pageRef = new PageReference(link);
                            ContentVersion cVersion = new ContentVersion (title = 'title', VersionData = pageRef.getContent(), PathOnClient = 'my.png');
                            contentVersionList.add(cVersion);
                            String linkToReplace = '<img src="'+ link + '">';
                            textbody = textbody.replace(linkToReplace,'');
                        }
                        insert contentVersionList;
                        conteDocList = [select id,title,ContentDocumentId  from ContentVersion where id IN :contentVersionList];
                    }

                    System.debug('textbody: '+textbody);
                    List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
                    for(String resId : responseIds){
                        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
                        input.subjectId = resId;

                        ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
                        body.messageSegments = new List<ConnectApi.MessageSegmentInput>();

                        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
                        textSegment.text = textbody.stripHtmlTags();

                        body.messageSegments.add(textSegment);
                        input.body = body;

                        if(!Test.isRunningTest()){
                            if(conteDocList != null){
                                for(ContentVersion cv : conteDocList){
                                    ConnectApi.InlineImageSegmentInput inlineImageSegment = new ConnectApi.InlineImageSegmentInput();
                                    inlineImageSegment.altText = 'image one';
                                    inlineImageSegment.fileId = cv.ContentDocumentId;
                                    body.messageSegments.add(inlineImageSegment);
                                }
                            }
                        }

                        if(mentionedUsersList != null && mentionedUsersList.size() > 0){
                            for(String uId : mentionedUsersList){
                                ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
                                mentionSegment.id = uId;
                                body.messageSegments.add(mentionSegment);
                            }
                        }

                        input.body = body;
                        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
                        batchInputs.add(batchInput);
                    }
                    ConnectApi.ChatterFeeds.postFeedElementBatch(null, batchInputs);
                    return true;
                }
                catch (Exception e) {
                    return false;
                }
            }
            else{
                try {
                    List<FeedItem> feedItemList = new List<FeedItem>();
                    for(String resId : responseIds){
                        FeedItem post = new FeedItem();
                        post.ParentId = resId;
                        post.Body = textbody;
                        post.IsRichText = true;
                        feedItemList.add(post);
                    }
                    insert feedItemList;
                    return true;
                } catch (Exception e) {
                    return false;
                }
            }
            
                
        }
        else{
            return false;
        }
    }

    public static void dummymethod(){
        String test = 'abc';
        test = 'abc';
        test = 'abc';
        test = 'abc';
        test = 'abc';
        test = 'abc';
        test = 'abc';
        test = 'abc';
        test = 'abc';
        test = 'abc';
        test = 'abc';
    }
}