package com.vsb;

import com.db.DbUtils;

public class enfQueryBean extends formBean {
  private String enf_due_year = "";
  private String jsessionid = "";
  private String enf_due_month = "";
  private String enf_status = "";
  private String enf_action_date = "";
  private String enf_law = "";
  private String enf_officer = "";
  private String enf_site = "";
  private String enf_due_day = "";
  private String enf_due_date = "";
  private String enf_offence = "";
  private String enf_action_code = "";
  private String enf_action_day = "";
  private String enf_action_month = "";
  private String enf_action_year = "";
  private boolean is_due_date_completed = false;
  private boolean is_action_date_completed = false;

  public String getEnf_due_year() {
    return enf_due_year;
  }

  public void setEnf_due_year(String enf_due_year) {
    this.enf_due_year = DbUtils.cleanString(enf_due_year);
  }

  public String getJsessionid() {
    return jsessionid;
  }

  public void setJsessionid(String jsessionid) {
    this.jsessionid = DbUtils.cleanString(jsessionid);
  }

  public String getEnf_due_month() {
    return enf_due_month;
  }

  public void setEnf_due_month(String enf_due_month) {
    this.enf_due_month = DbUtils.cleanString(enf_due_month);
  }

  public String getEnf_status() {
    return enf_status;
  }

  public void setEnf_status(String enf_status) {
    this.enf_status = DbUtils.cleanString(enf_status);
  }

  public String getEnf_action_date() {
    return enf_action_date;
  }

  public void setEnf_action_date(String enf_action_date) {
    this.enf_action_date = DbUtils.cleanString(enf_action_date);
  }

  public String getEnf_law() {
    return enf_law;
  }

  public void setEnf_law(String enf_law) {
    this.enf_law = DbUtils.cleanString(enf_law);
  }

  public String getEnf_officer() {
    return enf_officer;
  }

  public void setEnf_officer(String enf_officer) {
    this.enf_officer = DbUtils.cleanString(enf_officer);
  }

  public String getEnf_site() {
    return enf_site;
  }

  public void setEnf_site(String enf_site) {
    this.enf_site = DbUtils.cleanString(enf_site);
  }

  public String getEnf_due_day() {
    return enf_due_day;
  }

  public void setEnf_due_day(String enf_due_day) {
    this.enf_due_day = DbUtils.cleanString(enf_due_day);
  }

  public String getEnf_due_date() {
    return enf_due_date;
  }

  public void setEnf_due_date(String enf_due_date) {
    this.enf_due_date = DbUtils.cleanString(enf_due_date);
  }

  public String getEnf_offence() {
    return enf_offence;
  }

  public void setEnf_offence(String enf_offence) {
    this.enf_offence = DbUtils.cleanString(enf_offence);
  }

  public String getEnf_action_code() {
    return enf_action_code;
  }

  public void setEnf_action_code(String enf_action_code) {
    this.enf_action_code = DbUtils.cleanString(enf_action_code);
  }

  public String getEnf_action_day() {
    return enf_action_day;
  }

  public void setEnf_action_day(String enf_action_day) {
    this.enf_action_day = DbUtils.cleanString(enf_action_day);
  }

  public String getEnf_action_month() {
    return enf_action_month;
  }

  public void setEnf_action_month(String enf_action_month) {
    this.enf_action_month = DbUtils.cleanString(enf_action_month);
  }

  public String getEnf_action_year() {
    return enf_action_year;
  }

  public void setEnf_action_year(String enf_action_year) {
    this.enf_action_year = DbUtils.cleanString(enf_action_year);
  }

  public void setIs_due_date_completed( boolean is_due_date_completed ) {
    this.is_due_date_completed = is_due_date_completed;
  }

  public boolean getIs_due_date_completed() {
    return is_due_date_completed;
  }

  public void setIs_action_date_completed( boolean is_action_date_completed ) {
    this.is_action_date_completed = is_action_date_completed;
  }

  public boolean getIs_action_date_completed() {
    return is_action_date_completed;
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.enf_due_year = "";
    this.jsessionid = "";
    this.enf_due_month = "";
    this.enf_status = "";
    this.enf_action_date = "";
    this.enf_law = "";
    this.enf_officer = "";
    this.enf_site = "";
    this.enf_due_day = "";
    this.enf_due_date = "";
    this.enf_offence = "";
    this.enf_action_code = "";
    this.enf_action_day = "";
    this.enf_action_month = "";
    this.enf_action_year = "";
    this.is_due_date_completed = false;
    this.is_action_date_completed = false;
  }
}
