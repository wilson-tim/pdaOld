package com.vsb;

import com.db.DbUtils;

public class contractBean extends formBean {
  private String wo_contract_ref = "";

  public String getWo_contract_ref() {
    return wo_contract_ref;
  }

  public void setWo_contract_ref(String wo_contract_ref) {
    this.wo_contract_ref = DbUtils.cleanString(wo_contract_ref);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.wo_contract_ref = "";
  }
}
