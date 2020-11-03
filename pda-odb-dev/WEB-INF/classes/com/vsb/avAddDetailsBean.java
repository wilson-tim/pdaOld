package com.vsb;

import com.db.DbUtils;

public class avAddDetailsBean extends formBean {
  private String av_tax_date = "";
  private String av_tax_day = "";
  private String av_stick_day = "";
  private String jsessionid = "";
  private String av_stick_time_h = "";
  private String colour_ref = "";
  private String no_id = "";
  private String car_id = "";
  private String av_stick_date = "";
  private String av_tax_month = "";
  private String av_tax_year = "";
  private String av_stick_time_m = "";
  private String is_taxed = "";
  private String is_stickered = "";
  private String vin = "";
  private String av_stick_year = "";
  private String av_stick_month = "";
  private String model_ref = "";
  private String actionTaken = "";

  public String getAv_tax_date() {
    return av_tax_date;
  }

  public void setAv_tax_date(String av_tax_date) {
    this.av_tax_date = DbUtils.cleanString(av_tax_date);
  }

  public String getAv_tax_day() {
    return av_tax_day;
  }

  public void setAv_tax_day(String av_tax_day) {
    this.av_tax_day = DbUtils.cleanString(av_tax_day);
  }

  public String getAv_stick_day() {
    return av_stick_day;
  }

  public void setAv_stick_day(String av_stick_day) {
    this.av_stick_day = DbUtils.cleanString(av_stick_day);
  }

  public String getJsessionid() {
    return jsessionid;
  }

  public void setJsessionid(String jsessionid) {
    this.jsessionid = DbUtils.cleanString(jsessionid);
  }

  public String getAv_stick_time_h() {
    return av_stick_time_h;
  }

  public void setAv_stick_time_h(String av_stick_time_h) {
    this.av_stick_time_h = DbUtils.cleanString(av_stick_time_h);
  }

  public String getColour_ref() {
    return colour_ref;
  }

  public void setColour_ref(String colour_ref) {
    this.colour_ref = DbUtils.cleanString(colour_ref);
  }

  public String getNo_id() {
    return no_id;
  }

  public void setNo_id(String no_id) {
    this.no_id = DbUtils.cleanString(no_id);
  }

  public String getCar_id() {
    return car_id;
  }

  public void setCar_id(String car_id) {
    this.car_id = DbUtils.cleanString(car_id);
  }

  public String getAv_stick_date() {
    return av_stick_date;
  }

  public void setAv_stick_date(String av_stick_date) {
    this.av_stick_date = DbUtils.cleanString(av_stick_date);
  }

  public String getAv_tax_month() {
    return av_tax_month;
  }

  public void setAv_tax_month(String av_tax_month) {
    this.av_tax_month = DbUtils.cleanString(av_tax_month);
  }

  public String getAv_tax_year() {
    return av_tax_year;
  }

  public void setAv_tax_year(String av_tax_year) {
    this.av_tax_year = DbUtils.cleanString(av_tax_year);
  }

  public String getAv_stick_time_m() {
    return av_stick_time_m;
  }

  public void setAv_stick_time_m(String av_stick_time_m) {
    this.av_stick_time_m = DbUtils.cleanString(av_stick_time_m);
  }

  public String getIs_taxed() {
    return is_taxed;
  }

  public void setIs_taxed(String is_taxed) {
    this.is_taxed = DbUtils.cleanString(is_taxed);
  }

  public String getIs_stickered() {
    return is_stickered;
  }

  public void setIs_stickered(String is_stickered) {
    this.is_stickered = DbUtils.cleanString(is_stickered);
  }

  public String getVin() {
    return vin;
  }

  public void setVin(String vin) {
    this.vin = DbUtils.cleanString(vin);
  }

  public String getAv_stick_year() {
    return av_stick_year;
  }

  public void setAv_stick_year(String av_stick_year) {
    this.av_stick_year = DbUtils.cleanString(av_stick_year);
  }

  public String getAv_stick_month() {
    return av_stick_month;
  }

  public void setAv_stick_month(String av_stick_month) {
    this.av_stick_month = DbUtils.cleanString(av_stick_month);
  }

  public String getModel_ref() {
    return model_ref;
  }

  public void setModel_ref(String model_ref) {
    this.model_ref = DbUtils.cleanString(model_ref);
  }

  public String getActionTaken() {
    return actionTaken;
  }

  public void setActionTaken(String actionTaken) {
    this.actionTaken = DbUtils.cleanString(actionTaken);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.av_tax_date = "";
    this.av_tax_day = "";
    this.av_stick_day = "";
    this.jsessionid = "";
    this.av_stick_time_h = "";
    this.colour_ref = "";
    this.no_id = "";
    this.car_id = "";
    this.av_stick_date = "";
    this.av_tax_month = "";
    this.av_tax_year = "";
    this.av_stick_time_m = "";
    this.is_taxed = "";
    this.is_stickered = "";
    this.vin = "";
    this.av_stick_year = "";
    this.av_stick_month = "";
    this.model_ref = "";
    this.actionTaken = "";
  }
}
