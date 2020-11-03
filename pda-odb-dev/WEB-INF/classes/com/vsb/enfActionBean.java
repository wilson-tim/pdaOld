package com.vsb;

import com.db.DbUtils;

public class enfActionBean extends formBean {
  private String action_time_m = "";
  private String enf_list_action_code = "";
  private String action_time_h = "";
  private String action_year = "";
  private String action_text = "";
  private String autOff = "";
  private String action_month = "";
  private String action_day = "";
  private String jsessionid = "";
  private String action_code = "";

  public String getAction_time_m() {
    return action_time_m;
  }

  public void setAction_time_m(String action_time_m) {
    this.action_time_m = DbUtils.cleanString(action_time_m);
  }

  public String getEnf_list_action_code() {
    return enf_list_action_code;
  }

  public void setEnf_list_action_code(String enf_list_action_code) {
    this.enf_list_action_code = DbUtils.cleanString(enf_list_action_code);
  }

  public String getAction_time_h() {
    return action_time_h;
  }

  public void setAction_time_h(String action_time_h) {
    this.action_time_h = DbUtils.cleanString(action_time_h);
  }

  public String getAction_year() {
    return action_year;
  }

  public void setAction_year(String action_year) {
    this.action_year = DbUtils.cleanString(action_year);
  }

  public String getAction_text() {
    return action_text;
  }

  public void setAction_text(String action_text) {
    this.action_text = DbUtils.cleanString(action_text);
  }

  public String getAutOff() {
    return autOff;
  }

  public void setAutOff(String autOff) {
    this.autOff = DbUtils.cleanString(autOff);
  }

  public String getAction_month() {
    return action_month;
  }

  public void setAction_month(String action_month) {
    this.action_month = DbUtils.cleanString(action_month);
  }

  public String getAction_day() {
    return action_day;
  }

  public void setAction_day(String action_day) {
    this.action_day = DbUtils.cleanString(action_day);
  }

  public String getJsessionid() {
    return jsessionid;
  }

  public void setJsessionid(String jsessionid) {
    this.jsessionid = DbUtils.cleanString(jsessionid);
  }

  public String getAction_code() {
    return action_code;
  }

  public void setAction_code(String action_code) {
    this.action_code = DbUtils.cleanString(action_code);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.action_time_m = "";
    this.enf_list_action_code = "";
    this.action_time_h = "";
    this.action_year = "";
    this.action_text = "";
    this.autOff = "";
    this.action_month = "";
    this.action_day = "";
    this.jsessionid = "";
    this.action_code = "";
  }
}
