package com.vsb;

import com.db.DbUtils;

public class serviceBean extends formBean {
  private String service_c = "";

  public String getService_c() {
    return service_c;
  }

  public void setService_c(String service_c) {
    this.service_c = DbUtils.cleanString(service_c);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.service_c = "";
  }
}
