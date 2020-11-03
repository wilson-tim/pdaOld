package com.vsb;

import com.db.DbUtils;

public class conScheduleListBean extends formBean {

  private String wo_key = "";
  
  public String getWo_key(){
    return wo_key;
  }

  public void setWo_key(String wo_key){
    this.wo_key = DbUtils.cleanString(wo_key);          
  }
          
  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    wo_key = "";
  }
}
