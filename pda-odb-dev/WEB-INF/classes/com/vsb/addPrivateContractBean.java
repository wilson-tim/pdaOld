package com.vsb;

import com.db.DbUtils;

public class addPrivateContractBean extends formBean {
  private String status = "";
  private String cwtn_start_day = "";
  private String exact_location = "";
  private String pa_area = "";
  private String cwtn_start_year = "";
  private String cwtn_end_year = "";
  private String business_cat = "";
  private String notes = "";
  private String recvd_by = "";
  private String cwtn_start_month = "";
  private String disposer_ref = "";
  private String cwtn_end_month = "";
  private String waste_type = "";
  private String disposal_method = "";
  private String contact_mobile = "";
  private String jsessionid = "";
  private String business_name = "";
  private String ta_name = "";
  private String contact_tel = "";
  private String contact_email = "";
  private String contact_title = "";
  private String contract_size = "";
  private String contact_name = "";
  private String cwtn_end_day = "";
  private String origin = "";

  public String getStatus() {
    return status;
  }

  public void setStatus(String status) {
    this.status = DbUtils.cleanString(status);
  }

  public String getCwtn_start_day() {
    return cwtn_start_day;
  }

  public void setCwtn_start_day(String cwtn_start_day) {
    this.cwtn_start_day = DbUtils.cleanString(cwtn_start_day);
  }

  public String getExact_location() {
    return exact_location;
  }

  public void setExact_location(String exact_location) {
    this.exact_location = DbUtils.cleanString(exact_location);
  }

  public String getPa_area() {
    return pa_area;
  }

  public void setPa_area(String pa_area) {
    this.pa_area = DbUtils.cleanString(pa_area);
  }

  public String getCwtn_start_year() {
    return cwtn_start_year;
  }

  public void setCwtn_start_year(String cwtn_start_year) {
    this.cwtn_start_year = DbUtils.cleanString(cwtn_start_year);
  }

  public String getCwtn_end_year() {
    return cwtn_end_year;
  }

  public void setCwtn_end_year(String cwtn_end_year) {
    this.cwtn_end_year = DbUtils.cleanString(cwtn_end_year);
  }

  public String getBusiness_cat() {
    return business_cat;
  }

  public void setBusiness_cat(String business_cat) {
    this.business_cat = DbUtils.cleanString(business_cat);
  }

  public String getNotes() {
    return notes;
  }

  public void setNotes(String notes) {
    this.notes = DbUtils.cleanString(notes);
  }

  public String getRecvd_by() {
    return recvd_by;
  }

  public void setRecvd_by(String recvd_by) {
    this.recvd_by = DbUtils.cleanString(recvd_by);
  }

  public String getCwtn_start_month() {
    return cwtn_start_month;
  }

  public void setCwtn_start_month(String cwtn_start_month) {
    this.cwtn_start_month = DbUtils.cleanString(cwtn_start_month);
  }

  public String getDisposer_ref() {
    return disposer_ref;
  }

  public void setDisposer_ref(String disposer_ref) {
    this.disposer_ref = DbUtils.cleanString(disposer_ref);
  }

  public String getCwtn_end_month() {
    return cwtn_end_month;
  }

  public void setCwtn_end_month(String cwtn_end_month) {
    this.cwtn_end_month = DbUtils.cleanString(cwtn_end_month);
  }

  public String getWaste_type() {
    return waste_type;
  }

  public void setWaste_type(String waste_type) {
    this.waste_type = DbUtils.cleanString(waste_type);
  }

  public String getDisposal_method() {
    return disposal_method;
  }

  public void setDisposal_method(String disposal_method) {
    this.disposal_method = DbUtils.cleanString(disposal_method);
  }

  public String getContact_mobile() {
    return contact_mobile;
  }

  public void setContact_mobile(String contact_mobile) {
    this.contact_mobile = DbUtils.cleanString(contact_mobile);
  }

  public String getJsessionid() {
    return jsessionid;
  }

  public void setJsessionid(String jsessionid) {
    this.jsessionid = DbUtils.cleanString(jsessionid);
  }

  public String getBusiness_name() {
    return business_name;
  }

  public void setBusiness_name(String business_name) {
    this.business_name = DbUtils.cleanString(business_name);
  }

  public String getTa_name() {
    return ta_name;
  }

  public void setTa_name(String ta_name) {
    this.ta_name = DbUtils.cleanString(ta_name);
  }

  public String getContact_tel() {
    return contact_tel;
  }

  public void setContact_tel(String contact_tel) {
    this.contact_tel = DbUtils.cleanString(contact_tel);
  }

  public String getContact_email() {
    return contact_email;
  }

  public void setContact_email(String contact_email) {
    this.contact_email = DbUtils.cleanString(contact_email);
  }

  public String getContact_title() {
    return contact_title;
  }

  public void setContact_title(String contact_title) {
    this.contact_title = DbUtils.cleanString(contact_title);
  }

  public String getContract_size() {
    return contract_size;
  }

  public void setContract_size(String contract_size) {
    this.contract_size = DbUtils.cleanString(contract_size);
  }

  public String getContact_name() {
    return contact_name;
  }

  public void setContact_name(String contact_name) {
    this.contact_name = DbUtils.cleanString(contact_name);
  }

  public String getCwtn_end_day() {
    return cwtn_end_day;
  }

  public void setCwtn_end_day(String cwtn_end_day) {
    this.cwtn_end_day = DbUtils.cleanString(cwtn_end_day);
  }

  public String getOrigin() {
    return origin;
  }

  public void setOrigin(String origin) {
    this.origin = DbUtils.cleanString(origin);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.status = "";
    this.cwtn_start_day = "";
    this.exact_location = "";
    this.pa_area = "";
    this.cwtn_start_year = "";
    this.cwtn_end_year = "";
    this.business_cat = "";
    this.notes = "";
    this.recvd_by = "";
    this.cwtn_start_month = "";
    this.disposer_ref = "";
    this.cwtn_end_month = "";
    this.waste_type = "";
    this.disposal_method = "";
    this.contact_mobile = "";
    this.jsessionid = "";
    this.business_name = "";
    this.ta_name = "";
    this.contact_tel = "";
    this.contact_email = "";
    this.contact_title = "";
    this.contract_size = "";
    this.contact_name = "";
    this.cwtn_end_day = "";
    this.origin = "";
  }
}
