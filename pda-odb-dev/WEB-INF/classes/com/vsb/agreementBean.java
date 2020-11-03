package com.vsb;

import com.db.DbUtils;

public class agreementBean extends formBean {
  private String agreement_no = "";

  public String getAgreement_no() {
    return agreement_no;
  }

  public void setAgreement_no(String agreement_no) {
    this.agreement_no = DbUtils.cleanString(agreement_no);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.agreement_no = "";
  }
}
