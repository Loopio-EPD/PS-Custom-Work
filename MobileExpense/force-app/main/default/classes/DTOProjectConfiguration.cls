/*
* Author : Avnio
* Created Date : 4th January 2022
* Class Name : DTOProjectConfiguration
* Details : Wrapper class for project configuration
* Modification Log: 
* Ver   Date          Author    Modification
* 1.0   04-01-2023    Avnio     Initial Version
*/

public class DTOProjectConfiguration{
    
    public SheetConfigMap sheetConfigMap;
	public ReviewerConfig reviewerConfig;
	public ProjectConfig projectConfig;
	public FileConfigMap fileConfigMap;
    
    public class SheetConfigMap{
        
    }
    
    public class ReviewerConfig{
        public Boolean readOnlyCompletedQuestion;
        public String projectQuestionReviewType;
        public Boolean projectOwnerAsReviewer;
        public Boolean projectOwnerAsAssignee;
        public Boolean enableProjectQuestionReview;
        public Boolean assigneeToComplete;
        public Boolean allowReviewerToEdit;
        public Boolean allowReviewerToComplete;
    }
    
    public class ProjectConfig{
		public Retrivefilters retrivefilters;
        public String QuestionPath;
        public List<Compliances> compliances;
        public String AnswerReferencePaths;
        public String AnswerPath;        
    }
    
    public class FileConfigMap{
        
    }
    
    public class Retrivefilters{
        public String filter;
        public Category category;
    }
    public class Category{
        public List<String> items;
        public String filter;
    }
    public class Compliances{
        public String value;
        public String type;
        public String scope;
        public Boolean required;
        public String order;
        public List<Option> options;
        public String label;
        public String id;
        public String helpText;
        public String cellAddressExact;
        public String cellAddress;
    }
    
    public class Option{
        public String value;
        public String label;
    }
}