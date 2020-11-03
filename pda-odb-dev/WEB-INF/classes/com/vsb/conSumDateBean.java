package com.vsb;

import com.db.DbUtils;

public class conSumDateBean extends formBean {
  private String month = "";
  private String hours = "";
  private String day = "";
  private String year = "";
  private String mins = "";

  public String getMonth() {
    return month;
  }

  public void setMonth(String month) {
    this.month = DbUtils.cleanString(month);
  }

  public String getHours() {
    return hours;
  }

  public void setHours(String hours) {
    this.hours = DbUtils.cleanString(hours);
  }

  public String getDay() {
    return day;
  }

  public void setDay(String day) {
    this.day = DbUtils.cleanString(day);
  }

  public String getYear() {
    return year;
  }

  public void setYear(String year) {
    this.year = DbUtils.cleanString(year);
  }

  public String getMins() {
    return mins;
  }

  public void setMins(String mins) {
    this.mins = DbUtils.cleanString(mins);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.month = "";
    this.hours = "";
    this.day = "";
    this.year = "";
    this.mins = "";
  }
}
