package com.vsb;

import com.db.DbUtils;

public class defectFaultBean extends formBean {
  private String defect_code = "";

  public String getDefect_code() {
    return defect_code;
  }
  
  public void setDefect_code(String defect_code) {
    this.defect_code = DbUtils.cleanString(defect_code);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.defect_code = "";
  }
}
