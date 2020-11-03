package com.vsb;

import com.db.DbUtils;

public class suffixBean extends formBean {
  private String wo_suffix = "";

  public String getWo_suffix() {
    return wo_suffix;
  }

  public void setWo_suffix(String wo_suffix) {
    this.wo_suffix = DbUtils.cleanString(wo_suffix);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.wo_suffix = "";
  }
}
