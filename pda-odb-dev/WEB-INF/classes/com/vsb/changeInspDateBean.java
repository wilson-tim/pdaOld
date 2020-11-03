package com.vsb;

import com.db.DbUtils;

public class changeInspDateBean extends formBean {
  private String jsessionid = "";
  private String day = "";
  private String year = "";
  private String month = "";

  public String getJsessionid() {
    return jsessionid;
  }

  public void setJsessionid(String jsessionid) {
    this.jsessionid = DbUtils.cleanString(jsessionid);
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

  public String getMonth() {
    return month;
  }

  public void setMonth(String month) {
    this.month = DbUtils.cleanString(month);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.jsessionid = "";
    this.day = "";
    this.year = "";
    this.month = "";
  }
}
