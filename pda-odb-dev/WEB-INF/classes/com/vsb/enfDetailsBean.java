package com.vsb;

import com.db.DbUtils;

public class enfDetailsBean extends formBean {
  private String jsessionid = "";
  private String text = "";
  private String textOut = "";

  public String getJsessionid() {
    return jsessionid;
  }

  public void setJsessionid(String jsessionid) {
    this.jsessionid = DbUtils.cleanString(jsessionid);
  }

  public String getText() {
    return text;
  }

  public void setText(String text) {
    this.text = DbUtils.cleanString(text);
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
    this.jsessionid = "";
    this.text = "";
    this.textOut = "";
  }
}
