package com.vsb;

import com.db.DbUtils;

public class avStatusBean extends formBean {
  private String text = "";
  private String status_ref = "";

  public String getStatus_ref() {
    return status_ref;
  }

  public void setStatus_ref(String status_ref) {
    this.status_ref = DbUtils.cleanString(status_ref);
  }
  
  public String getText() {
    return text;
  }

  public void setText(String text) {
    this.text = DbUtils.cleanString(text);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.text = "";
    this.status_ref = "";
  }
}
