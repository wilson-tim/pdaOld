package com.vsb;

import com.db.DbUtils;

public class streetLengthBean extends formBean {
  private String default_algorithm = "";

  public String getDefault_algorithm() {
    return default_algorithm;
  }

  public void setDefault_algorithm(String default_algorithm) {
    this.default_algorithm = DbUtils.cleanString(default_algorithm);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.default_algorithm = "";
  }
}
