package com.vsb;

import com.db.DbUtils;

public class enfSuspectTextBean extends formBean {
  private String sus_text = "";
  private String jsessionid = "";
  private String textOut = "";

  public String getSus_text() {
    return sus_text;
  }

  public void setSus_text(String sus_text) {
    this.sus_text = DbUtils.cleanString(sus_text);
  }

  public String getJsessionid() {
    return jsessionid;
  }

  public void setJsessionid(String jsessionid) {
    this.jsessionid = DbUtils.cleanString(jsessionid);
  }

  public String getTextOut() {
    return textOut;
  }

  public void setTextOut(String textOut) {
    this.textOut = DbUtils.cleanString(textOut);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.sus_text = "";
    this.jsessionid = "";
    this.textOut = "";
  }
}
