package com.vsb;

import com.db.DbUtils;

public class marketDetailsBean extends formBean {
  private String market_ref = "";
  private String pitch_no = "";
  private String page_number = "";
  private String jsessionid = "";

  public String getMarket_ref() {
    return market_ref;
  }

  public void setMarket_ref(String market_ref) {
    this.market_ref = DbUtils.cleanString(market_ref);
  }

  public String getPitch_no() {
    return pitch_no;
  }

  public void setPitch_no(String pitch_no) {
    this.pitch_no = DbUtils.cleanString(pitch_no);
  }

  public String getPage_number() {
    return page_number;
  }

  public void setPage_number(String page_number) {
    this.page_number = DbUtils.cleanString(page_number);
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
    this.market_ref = "";
    this.pitch_no = "";
    this.page_number = "";
    this.jsessionid = "";
  }
}
