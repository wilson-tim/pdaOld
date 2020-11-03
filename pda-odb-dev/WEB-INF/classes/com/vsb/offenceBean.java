package com.vsb;

import com.db.DbUtils;

public class offenceBean extends formBean {
  private String offence = "";

  public String getOffence() {
    return offence;
  }

  public void setOffence(String offence) {
    this.offence = DbUtils.cleanString(offence);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.offence = "";
  }
}
