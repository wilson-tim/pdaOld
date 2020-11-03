package com.vsb;

import com.db.DbUtils;

public class defectSizeBean extends formBean {
  private String x = "0";
  private String y = "0";

  public String getX() {
    return x;
  }
  
  public void setX(String x) {
    this.x = DbUtils.cleanString(x);
  }

  public String getY() {
    return y;
  }
  
  public void setY(String y) {
    this.y = DbUtils.cleanString(y);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.x = "0";
    this.y = "0";
  }
}
