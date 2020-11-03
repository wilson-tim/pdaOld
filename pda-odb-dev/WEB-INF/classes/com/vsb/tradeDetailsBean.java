package com.vsb;

import com.db.DbUtils;

public class tradeDetailsBean extends formBean {
  private String agreement_name = "";
  private String agreement_no   = "";
  
  public String getAgreement_name() {
    return agreement_name;
  }

  public void setAgreement_name( String agreement_name ) {
    this.agreement_name = DbUtils.cleanString( agreement_name );
  }

  public String getAgreement_no() {
    return agreement_no;
  }

  public void setAgreement_no( String agreement_no ) {
    this.agreement_no = DbUtils.cleanString( agreement_no );
  }  
  
  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    agreement_name = "";
    agreement_no   = "";
  }
}
