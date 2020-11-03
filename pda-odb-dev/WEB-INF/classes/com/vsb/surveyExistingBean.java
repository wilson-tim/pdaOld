package com.vsb;

import com.db.DbUtils;

public class surveyExistingBean extends formBean {

	private String transect = "";


  public String getTransect() {
    return transect;
  }
  public void setTransect(String transect) {
    this.transect = DbUtils.cleanString(transect);
  }


  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.transect = "";

  }
}
