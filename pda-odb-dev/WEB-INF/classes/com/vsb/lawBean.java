package com.vsb;

import com.db.DbUtils;

public class lawBean extends formBean {
  private String law = "";

  public String getLaw() {
    return law;
  }

  public void setLaw(String law) {
    this.law = DbUtils.cleanString(law);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.law = "";
  }
}
