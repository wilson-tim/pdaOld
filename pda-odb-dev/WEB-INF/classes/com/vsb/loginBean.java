package com.vsb;

import com.db.DbUtils;

public class loginBean extends formBean {
  private String user_pass = "";
  private String user_name = "";

  public String getUser_pass() {
    return user_pass;
  }

  public void setUser_pass(String user_pass) {
    this.user_pass = DbUtils.cleanString(user_pass);
  }

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
    this.user_pass = "";
    this.user_name = "";
  }
}
