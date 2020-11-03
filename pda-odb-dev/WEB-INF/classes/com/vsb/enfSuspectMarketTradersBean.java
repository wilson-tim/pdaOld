package com.vsb;

import com.db.DbUtils;

public class enfSuspectMarketTradersBean extends formBean {
  private String page_number = "";
  private String trader_ref = "";
  private String jsessionid = "";

  public String getPage_number() {
    return page_number;
  }

  public void setPage_number(String page_number) {
    this.page_number = DbUtils.cleanString(page_number);
  }

  public String getTrader_ref() {
    return trader_ref;
  }

  public void setTrader_ref(String trader_ref) {
    this.trader_ref = DbUtils.cleanString(trader_ref);
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
    this.page_number = "";
    this.trader_ref = "";
    this.jsessionid = "";
  }
}
