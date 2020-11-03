package com.vsb;

import com.db.DbUtils;

public class page2Bean extends formBean {
  private String jsessionid = "";
  private String location_name = "";

  public String getJsessionid() {
    return jsessionid;
  }

  public void setJsessionid(String jsessionid) {
    this.jsessionid = DbUtils.cleanString(jsessionid);
  }

  public String getLocation_name() {
    return location_name;
  }

  public void setLocation_name(String location_name) {
    this.location_name = DbUtils.cleanString(location_name);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.jsessionid = "";
    this.location_name = "";
  }
}
