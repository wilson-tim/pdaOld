package com.vsb;

import com.db.DbUtils;

public class surveySiteLookupBean extends formBean {
  private String site_ref = "";

  public String getSite_ref() {
    return site_ref;
  }

  public void setSite_ref(String site_ref) {
    this.site_ref = DbUtils.cleanString(site_ref);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.site_ref = "";
  }
}
