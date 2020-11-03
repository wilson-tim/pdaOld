package com.vsb;

import com.db.DbUtils;

public class enfStatusBean extends formBean {
  private String status_code = "";
  private String jsessionid = "";

  public String getStatus_code() {
    return status_code;
  }

  public void setStatus_code(String status_code) {
    this.status_code = DbUtils.cleanString(status_code);
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
    this.status_code = "";
    this.jsessionid = "";
  }
}
