package com.vsb;

import com.db.DbUtils;

public class inspListBean extends formBean {
  private String complaint_no = "";
  private String page_number  = "";

  public String getComplaint_no() {
    return complaint_no;
  }

  public void setComplaint_no(String complaint_no) {
    this.complaint_no = DbUtils.cleanString(complaint_no);
  }

  public String getPage_number() {
    return page_number;
  }

  public void setPage_number(String page_number) {
    this.page_number = DbUtils.cleanString(page_number);
  }
  
  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.complaint_no = "";
    this.page_number  = "";
  }
}
