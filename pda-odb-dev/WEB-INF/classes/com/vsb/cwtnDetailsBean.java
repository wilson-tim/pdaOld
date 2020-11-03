package com.vsb;

import com.db.DbUtils;

public class cwtnDetailsBean extends formBean {
  private String jsessionid = "";

  public String getJsessionid() {
    return jsessionid;
  }

  public void setJsessionid(String jsessionid) {
    this.jsessionid = DbUtils.cleanString(jsessionid);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.jsessionid = "";
  }
}
