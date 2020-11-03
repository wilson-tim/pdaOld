package com.vsb;

import com.db.DbUtils;

public class officerCoverBean extends formBean {
  private String cover_name = "";

  public String getCover_name() {
    return cover_name;
  }

  public void setCover_name(String cover_name) {
    this.cover_name = DbUtils.cleanString(cover_name);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.cover_name = "";
  }
}
