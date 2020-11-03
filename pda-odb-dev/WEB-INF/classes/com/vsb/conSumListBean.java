package com.vsb;

import com.db.DbUtils;

public class conSumListBean extends formBean {
  private String complaint_no = "";

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
    this.complaint_no = "";
  }
}