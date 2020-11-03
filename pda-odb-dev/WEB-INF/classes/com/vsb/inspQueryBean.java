package com.vsb;

import com.db.DbUtils;

public class inspQueryBean extends formBean {
  private String insp_service = "";
  private String jsessionid = "";
  private String insp_site = "";
  private String insp_due_date = "";
  private String insp_due_day = "";
  private String insp_due_month = "";
  private String insp_due_year = "";
  private boolean is_due_date_completed = false;
  private String complaint_no = "";

  public String getInsp_service() {
    return insp_service;
  }

  public void setInsp_service(String insp_service) {
    this.insp_service = DbUtils.cleanString(insp_service);
  }

  public String getJsessionid() {
    return jsessionid;
  }
  public void setJsessionid(String jsessionid) {
    this.jsessionid = DbUtils.cleanString(jsessionid);
  }

  public String getInsp_site() {
    return insp_site;
  }

  public void setInsp_site(String insp_site) {
    this.insp_site = DbUtils.cleanString(insp_site);
  }

  public String getInsp_due_date() {
    return insp_due_date;
  }

  public void setInsp_due_date(String insp_due_date) {
    this.insp_due_date = DbUtils.cleanString(insp_due_date);
  }

  public String getInsp_due_day() {
    return insp_due_day;
  }

  public void setInsp_due_day(String insp_due_day) {
    this.insp_due_day = DbUtils.cleanString(insp_due_day);
  }

  public String getInsp_due_month() {
    return insp_due_month;
  }

  public void setInsp_due_month(String insp_due_month) {
    this.insp_due_month = DbUtils.cleanString(insp_due_month);
  }

  public String getInsp_due_year() {
    return insp_due_year;
  }

  public void setInsp_due_year(String insp_due_year) {
    this.insp_due_year = DbUtils.cleanString(insp_due_year);
  }

  public void setIs_due_date_completed( boolean is_due_date_completed ) {
    this.is_due_date_completed = is_due_date_completed;
  }

  public boolean getIs_due_date_completed() {
    return is_due_date_completed;
  }

  public String getComplaint_no() {
    return complaint_no;
  }

  public void setComplaint_no(String complaint_no) {
    this.complaint_no = DbUtils.cleanString(complaint_no);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.insp_service = "";
    this.jsessionid = "";
    this.insp_site = "";
    this.insp_due_date = "";
    this.insp_due_day = "";
    this.insp_due_month = "";
    this.insp_due_year = "";
    this.is_due_date_completed = false;
    this.complaint_no = "";
  }
}
