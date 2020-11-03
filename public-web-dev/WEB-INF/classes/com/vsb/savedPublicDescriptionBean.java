package com.vsb;

import java.util.ArrayList;

public class savedPublicDescriptionBean extends formBean {

    private ArrayList pages = new ArrayList();

    public void setPage(String page, String value) {
        boolean fountit=false;
        for (int i=0;i<this.pages.size();i++) {
            if(((ValuePair)this.pages.get(i)).vkey.equals(page)){
                ((ValuePair)this.pages.get(i)).vvalue=value;
                fountit=true;
            }
        }
        if(! fountit) this.pages.add(new ValuePair(page, value));
    }
    public String getPage(String page) {
        for (int i=0;i<this.pages.size();i++) {
            if(((ValuePair)this.pages.get(i)).vkey.equals(page)){
                return ((ValuePair)this.pages.get(i)).vvalue;
            }
        }
        return "";
    }
    
    public int size(){
        return this.pages.size();
    }
    
    public String getPageByIndex(int index){
        return ((ValuePair)this.pages.get(index)).vkey;
    }

    public String getValueByIndex(int index){
        return ((ValuePair)this.pages.get(index)).vvalue;
    }
    
    public void clear(){
        this.pages = new ArrayList();
    }
    
    public String pad(String s,int len){
        String n="";
        n=s;
        while(n.length()<len) n=n+" ";
        return n;
    }
}
