package com.vsb;

import com.db.DbUtils;

public class surveyTransectMethodBean extends formBean {

	private String transectMethod;

	public String getTransectMethod() {
    return transectMethod;
  }

  public void setTransectMethod(String transectMethod) {
    this.transectMethod = DbUtils.cleanString(transectMethod);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
  this.transectMethod = "";
  }
}
