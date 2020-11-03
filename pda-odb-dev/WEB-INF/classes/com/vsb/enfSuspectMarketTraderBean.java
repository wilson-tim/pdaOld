package com.vsb;

import com.db.DbUtils;

public class enfSuspectMarketTraderBean extends formBean {
  private String jsessionid = "";
  private String traderNotes = "";

  public String getJsessionid() {
    return jsessionid;
  }

  public void setJsessionid(String jsessionid) {
    this.jsessionid = DbUtils.cleanString(jsessionid);
  }

  public String getTraderNotes() {
    return traderNotes;
  }

  public void setTraderNotes(String traderNotes) {
    this.traderNotes = DbUtils.cleanString(traderNotes);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.jsessionid = "";
    this.traderNotes = "";
  }
}
