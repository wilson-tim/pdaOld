package com.vsb;

import com.db.DbUtils;

public class surveyLandUseBean extends formBean {
  private String landuse = "";
  private String ward = "";
  private String lowdensity = "";
  private String jsessionid = "";

  public String getLanduse() {
    return landuse;
  }

  public void setLanduse(String landuse) {
    this.landuse = DbUtils.cleanString(landuse);
  }

  public String getWard() {
    return ward;
  }

  public void setWard(String ward) {
    this.ward = DbUtils.cleanString(ward);
  }

  public String getLowdensity() {
    return lowdensity;
  }

  public void setLowdensity(String lowdensity) {
    this.lowdensity = DbUtils.cleanString(lowdensity);
  }

  public String getJsessionid() {
    return jsessionid;
  }

  public void setJsessionid(String jsessionid) {
    this.jsessionid = DbUtils.cleanString(jsessionid);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.landuse = "";
    this.ward = "";
    this.lowdensity = "";
    this.jsessionid = "";
  }
}
