package com.vsb;

import com.db.DbUtils;

public class itemLookupBean extends formBean {
  private String actionTaken = "";
  private String view_key = "";

  public String getActionTaken() {
    return actionTaken;
  }

  public void setActionTaken(String actionTaken) {
    this.actionTaken = DbUtils.cleanString(actionTaken);
  }

  public String getView_key() {
    return view_key;
  }

  public void setView_key(String view_key) {
    this.view_key = DbUtils.cleanString(view_key);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.actionTaken = "";
    this.view_key = "";
  }
}
