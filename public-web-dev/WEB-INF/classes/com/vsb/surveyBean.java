package com.vsb;

import java.util.ArrayList;

public class surveyBean extends formBean {

    private ArrayList survey = new ArrayList();

    public void add(String question, String answer) {
        this.survey.add(new ValuePair(question, answer));
    }
    
    public int size(){
        return this.survey.size();
    }
    
    public String getQuestionByIndex(int index){
        if(this.survey.size()<=index) return "";
        return ((ValuePair)this.survey.get(index)).vkey;
    }

    public String getAnswerByIndex(int index){
        if(this.survey.size()<=index) return "";
        return ((ValuePair)this.survey.get(index)).vvalue;
    }
    
    public void clear(){
        this.survey = new ArrayList();
    }
}
