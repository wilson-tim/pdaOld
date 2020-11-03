package com.vsb;

import com.db.DbUtils;

public class enfSuspectNewCoBean extends formBean {
  private String sus_newco = "";
  private String enfcompany = "";

  public String getSus_newco() {
    return sus_newco;
  }

  public void setSus_newco(String sus_newco) {
    this.sus_newco = DbUtils.cleanString(sus_newco);
  }

  public String getEnfcompany() {
    return enfcompany;
  }

  public void setEnfcompany(String enfcompany) {
    this.enfcompany = DbUtils.cleanString(enfcompany);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.sus_newco = "";
    this.enfcompany = "";
  }
}
