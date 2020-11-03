package com.vsb;

import com.db.DbUtils;

public class changeItemLookupBean extends formBean {
  private String view_key = "";
  private String jsessionid = "";

  public String getView_key() {
    return view_key;
  }

  public void setView_key(String view_key) {
    this.view_key = DbUtils.cleanString(view_key);
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
    this.view_key = "";
    this.jsessionid = "";
  }
}