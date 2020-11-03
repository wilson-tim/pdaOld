package com.vsb;

import com.db.DbUtils;

public class pickActiveOfficerBean extends formBean {
  private String user_name = "";

  public String getUser_name() {
    return user_name;
  }

  public void setUser_name(String user_name) {
    this.user_name = DbUtils.cleanString(user_name);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.user_name = "";
  }
}
