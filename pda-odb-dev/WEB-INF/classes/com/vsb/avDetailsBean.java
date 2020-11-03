package com.vsb;

import com.db.DbUtils;

public class avDetailsBean extends formBean {
  private String colour_desc  = "";
  private String model_desc   = "";
  private String car_id       = "";
  private String is_stickered = "";
  private String is_taxed     = "";
  private String text         = "";
  private String status       = "";
  private String vin          = "";
  private String av_stick_date = "";
  private String av_stick_day = "";
  private String av_stick_month = "";
  private String av_stick_year = "";
  private String av_stick_time_h = "";
  private String av_stick_time_m = "";

  public String getColour_desc() {
    return colour_desc;
  }

  public void setColour_desc(String colour_desc) {
    this.colour_desc = DbUtils.cleanString(colour_desc);
  }

  public String getModel_desc() {
    return model_desc;
  }

  public void setModel_desc(String model_desc) {
    this.model_desc = DbUtils.cleanString(model_desc);
  }

  public String getCar_id() {
    return car_id;
  }

  public void setCar_id(String car_id) {
    this.car_id = DbUtils.cleanString(car_id);
  }

  public String getIs_stickered() {
    return is_stickered;
  }

  public void setIs_stickered(String is_stickered) {
    this.is_stickered = DbUtils.cleanString(is_stickered);
  }

  public String getIs_taxed() {
    return is_taxed;
  }

  public void setIs_taxed(String is_taxed) {
    this.is_taxed= DbUtils.cleanString(is_taxed);
  }

  public String getText() {
    return text;
  }

  public void setText(String text) {
    this.text= DbUtils.cleanString(text);
  }

  public String getStatus() {
    return status;
  }

  public void setStatus(String status) {
    this.status= DbUtils.cleanString(status);
  }

  public String getVin() {
    return vin;
  }

  public void setVin(String vin) {
    this.vin= DbUtils.cleanString(vin);
  }

  public String getAv_stick_date() {
    return av_stick_date;
  }

  public void setAv_stick_date(String av_stick_date) {
    this.av_stick_date = DbUtils.cleanString(av_stick_date);
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

  public String getAv_stick_day() {
    return av_stick_day;
  }

  public void setAv_stick_day(String av_stick_day) {
    this.av_stick_day = DbUtils.cleanString(av_stick_day);
  }

  public String getAv_stick_time_h() {
    return av_stick_time_h;
  }

  public void setAv_stick_time_h(String av_stick_time_h) {
    this.av_stick_time_h = DbUtils.cleanString(av_stick_time_h);
  }

  public String getAv_stick_time_m() {
    return av_stick_time_m;
  }

  public void setAv_stick_time_m(String av_stick_time_m) {
    this.av_stick_time_m = DbUtils.cleanString(av_stick_time_m);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.colour_desc  = "";
    this.model_desc   = "";
    this.car_id       = "";
    this.is_stickered = "";
    this.is_taxed     = "";
    this.text         = "";
    this.status       = "";
    this.vin          = "";
    this.av_stick_date = "";
    this.av_stick_day = "";
    this.av_stick_month = "";
    this.av_stick_year = "";
    this.av_stick_time_h = "";
    this.av_stick_time_m = "";
  }
}
