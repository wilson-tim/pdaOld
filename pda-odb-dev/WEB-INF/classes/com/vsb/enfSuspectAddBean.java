package com.vsb;

import com.db.DbUtils;

public class enfSuspectAddBean extends formBean {
  private String suspect_ref = "";

  public String getSuspect_ref() {
    return suspect_ref;
  }

  public void setSuspect_ref(String suspect_ref) {
    this.suspect_ref = DbUtils.cleanString(suspect_ref);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.suspect_ref = "";
  }
}
