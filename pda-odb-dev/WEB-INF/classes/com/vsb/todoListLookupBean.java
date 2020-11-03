package com.vsb;

import com.db.DbUtils;

public class todoListLookupBean extends formBean {
  private String list_ref = "";
  private String job_ref  = "";
  
  public String getList_ref() {
    return list_ref;
  }

  public void setList_ref(String list_ref) {
    this.list_ref = DbUtils.cleanString(list_ref);
  }

  public String getJob_ref() {
    return job_ref;
  }

  public void setJob_ref(String job_ref) {
    this.job_ref = DbUtils.cleanString(job_ref);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.list_ref = "";
    this.job_ref = "";
  }
}
