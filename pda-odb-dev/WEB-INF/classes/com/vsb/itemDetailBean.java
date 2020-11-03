package com.vsb;

import com.db.DbUtils;

public class itemDetailBean extends formBean {
  private String actionTaken = "";

  public String getActionTaken() {
    return actionTaken;
  }

  public void setActionTaken(String actionTaken) {
    this.actionTaken = DbUtils.cleanString(actionTaken);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.actionTaken = "";
  }
}
