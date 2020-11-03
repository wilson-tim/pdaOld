package com.vsb;

import com.db.DbUtils;

public class recordBean {
  private String user_remarks = "";
  private String area_c = "";
  private String complaint_no = "";
  private String site_name_1 = "";
  private String site_ref = "";
  private String complaint_no_sel = "";
  private String location_name = "";

  public String getUser_remarks() {
    return user_remarks;
  }

  public void setUser_remarks(String user_remarks) {
    this.user_remarks = DbUtils.cleanString(user_remarks);
  }

  public String getArea_c() {
    return area_c;
  }

  public void setArea_c(String area_c) {
    this.area_c = DbUtils.cleanString(area_c);
  }

  public String getComplaint_no() {
    return complaint_no;
  }

  public void setComplaint_no(String complaint_no) {
    this.complaint_no = DbUtils.cleanString(complaint_no);
  }

  public String getSite_name_1() {
    return site_name_1;
  }

  public void setSite_name_1(String site_name_1) {
    this.site_name_1 = DbUtils.cleanString(site_name_1);
  }

  public String getSite_ref() {
    return site_ref;
  }

  public void setSite_ref(String site_ref) {
    this.site_ref = DbUtils.cleanString(site_ref);
  }

  public String getComplaint_no_sel() {
    return complaint_no_sel;
  }

  public void setComplaint_no_sel(String complaint_no_sel) {
    this.complaint_no_sel = DbUtils.cleanString(complaint_no_sel);
  }

  public String getLocation_name() {
    return location_name;
  }

  public void setLocation_name(String location_name) {
    this.location_name = DbUtils.cleanString(location_name);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.user_remarks = "";
    this.area_c = "";
    this.complaint_no = "";
    this.site_name_1 = "";
    this.site_ref = "";
    this.complaint_no_sel = "";
    this.location_name = "";
  }
}
