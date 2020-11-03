package com.vsb;

import com.db.DbUtils;

public class enfAdditionalDetailsBean extends formBean {
  private String vehicle_reg = "";
  private String offence_time_h = "";
  private String offence_year = "";
  private String invOff = "";
  private String offence_month = "";
  private String enfOff = "";
  private String jsessionid = "";
  private String offence_day = "";
  private String offence_time_m = "";

  public String getVehicle_reg() {
    return vehicle_reg;
  }

  public void setVehicle_reg(String vehicle_reg) {
    this.vehicle_reg = DbUtils.cleanString(vehicle_reg);
  }

  public String getOffence_time_h() {
    return offence_time_h;
  }

  public void setOffence_time_h(String offence_time_h) {
    this.offence_time_h = DbUtils.cleanString(offence_time_h);
  }

  public String getOffence_year() {
    return offence_year;
  }

  public void setOffence_year(String offence_year) {
    this.offence_year = DbUtils.cleanString(offence_year);
  }

  public String getInvOff() {
    return invOff;
  }

  public void setInvOff(String invOff) {
    this.invOff = DbUtils.cleanString(invOff);
  }

  public String getOffence_month() {
    return offence_month;
  }

  public void setOffence_month(String offence_month) {
    this.offence_month = DbUtils.cleanString(offence_month);
  }

  public String getEnfOff() {
    return enfOff;
  }

  public void setEnfOff(String enfOff) {
    this.enfOff = DbUtils.cleanString(enfOff);
  }

  public String getJsessionid() {
    return jsessionid;
  }

  public void setJsessionid(String jsessionid) {
    this.jsessionid = DbUtils.cleanString(jsessionid);
  }

  public String getOffence_day() {
    return offence_day;
  }

  public void setOffence_day(String offence_day) {
    this.offence_day = DbUtils.cleanString(offence_day);
  }

  public String getOffence_time_m() {
    return offence_time_m;
  }

  public void setOffence_time_m(String offence_time_m) {
    this.offence_time_m = DbUtils.cleanString(offence_time_m);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.vehicle_reg = "";
    this.offence_time_h = "";
    this.offence_year = "";
    this.invOff = "";
    this.offence_month = "";
    this.enfOff = "";
    this.jsessionid = "";
    this.offence_day = "";
    this.offence_time_m = "";
  }
}
