package com.vsb;

import com.db.DbUtils;

public class doorstepFaultBean extends formBean {
  private String lookup_code = "";

  public String getLookup_code() {
    return lookup_code;
  }

  public void setLookup_code(String lookup_code) {
    this.lookup_code = DbUtils.cleanString(lookup_code);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.lookup_code = "";
  }
}
