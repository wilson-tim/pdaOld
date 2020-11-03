package com.vsb;

import com.db.DbUtils;

public class addDefectBean extends formBean {
  private String confirm = "";
  private boolean isValidFaultCode = true;

  public String getConfirm() {
    return confirm;
  }

  public void setConfirm(String confirm) {
    this.confirm = DbUtils.cleanString(confirm);
  }

  public boolean getIsValidFaultCode() {
    return isValidFaultCode;
  }

  public void setIsValidFaultCode( boolean bool ) {
    this.isValidFaultCode = bool;
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.confirm = "";
    this.isValidFaultCode = true;
  }
}
