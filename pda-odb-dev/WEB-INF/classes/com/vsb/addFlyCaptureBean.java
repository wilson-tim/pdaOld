package com.vsb;

import com.db.DbUtils;

public class addFlyCaptureBean extends formBean {
  private String confirm = "";

  public String getConfirm() {
    return confirm;
  }

  public void setConfirm(String confirm) {
    this.confirm = DbUtils.cleanString(confirm);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.confirm = "";
  }
}
