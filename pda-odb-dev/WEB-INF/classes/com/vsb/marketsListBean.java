package com.vsb;

import com.db.DbUtils;

public class marketsListBean extends formBean {
  private String market_ref = "";
  private String page_number = "";
  private String jsessionid = "";

  public String getMarket_ref() {
    return market_ref;
  }

  public void setMarket_ref(String market_ref) {
    this.market_ref = DbUtils.cleanString(market_ref);
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
    this.page_number = "";
    this.jsessionid = "";
  }
}