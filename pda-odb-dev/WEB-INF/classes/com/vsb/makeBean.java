package com.vsb;

import com.db.DbUtils;

public class makeBean extends formBean {
  private String make_ref = "";

  public String getMake_ref() {
    return make_ref;
  }

  public void setMake_ref(String make_ref) {
    this.make_ref = DbUtils.cleanString(make_ref);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.make_ref = "";
  }
}
