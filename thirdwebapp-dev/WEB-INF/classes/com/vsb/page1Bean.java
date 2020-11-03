package com.vsb;

import com.db.DbUtils;

public class page1Bean extends formBean {
  private String jsessionid = "";
  private String complaint_no = "";

  public String getJsessionid() {
    return jsessionid;
  }

  public void setJsessionid(String jsessionid) {
    this.jsessionid = DbUtils.cleanString(jsessionid);
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
    this.jsessionid = "";
    this.complaint_no = "";
  }
}
