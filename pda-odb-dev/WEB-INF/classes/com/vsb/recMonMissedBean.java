package com.vsb;

import com.db.DbUtils;

public class recMonMissedBean extends formBean {
  private String confirm = "";
  private String jsessionid = "";

  public String getConfirm() {
    return confirm;
  }

  public void setConfirm(String confirm) {
    this.confirm = DbUtils.cleanString(confirm);
  }

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
    this.confirm = "";
    this.jsessionid = "";
  }
}
