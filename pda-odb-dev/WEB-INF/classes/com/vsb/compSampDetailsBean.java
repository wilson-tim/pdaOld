package com.vsb;

import com.db.DbUtils;

public class compSampDetailsBean extends formBean {
  private String exact_location = "";
  private String remarks = "";
  private String jsessionid = "";
  private String text = "";
  private String textOut = "";

  public String getExact_location() {
    return exact_location;
  }

  public void setExact_location(String exact_location) {
    this.exact_location = DbUtils.cleanString(exact_location);
  }

  public String getRemarks() {
    return remarks;
  }

  public void setRemarks(String remarks) {
    this.remarks = DbUtils.cleanString(remarks);
  }

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
    this.exact_location = "";
    this.remarks = "";
    this.jsessionid = "";
    this.text = "";
    this.textOut = "";
  }
}
