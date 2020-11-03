package com.vsb;

import com.db.DbUtils;

public class faultLookupBean extends formBean {
  private String lookup_code = "";
  private String jsessionid = "";
  private String actionTaken = "";
  private String comp_action_error = "";

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

  public String getActionTaken() {
    return actionTaken;
  }

  public void setActionTaken(String actionTaken) {
    this.actionTaken = DbUtils.cleanString(actionTaken);
  }

  public String getComp_action_error() {
    return comp_action_error;
  }

  public void setComp_action_error(String comp_action_error) {
    this.comp_action_error = DbUtils.cleanString(comp_action_error);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.lookup_code = "";
    this.jsessionid = "";
    this.actionTaken = "";
    this.comp_action_error = "";
  }
}
