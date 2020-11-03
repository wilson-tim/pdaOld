package com.vsb;

import com.db.DbUtils;

public class enfFpnRefBean extends formBean {
  private String fpn_ref = "";

  public String getFpn_ref() {
    return fpn_ref;
  }

  public void setFpn_ref(String fpn_ref) {
    this.fpn_ref = DbUtils.cleanString(fpn_ref);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.fpn_ref = "";
  }
}
