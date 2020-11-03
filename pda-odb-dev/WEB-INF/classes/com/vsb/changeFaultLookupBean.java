package com.vsb;

import com.db.DbUtils;

public class changeFaultLookupBean extends formBean {
  private String lookup_code = "";
  private String jsessionid = "";

  public String getLookup_code() {
    return lookup_code;
  }

  public void setLookup_code(String lookup_code) {
    this.lookup_code = DbUtils.cleanString(lookup_code);
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
    this.lookup_code = "";
    this.jsessionid = "";
  }
}
