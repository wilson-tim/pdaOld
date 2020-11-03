package com.vsb;

import com.db.DbUtils;

public class todoListBean extends formBean {
  private String list_desc = "";
  private String jsessionid = "";

  public String getList_desc() {
    return list_desc;
  }

  public void setList_desc(String list_desc) {
    this.list_desc = DbUtils.cleanString(list_desc);
  }

  public String getJsessionid() {
    return jsessionid;
  }

  public void setJsessionid(String jsessionid) {
    this.jsessionid = DbUtils.cleanString(jsessionid);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.list_desc = "";
    this.jsessionid = "";
  }
}
