package com.vsb;

import com.db.DbUtils;

public class pitchDetailsBean extends formBean {
  private String jsessionid = "";
  private String pitch_no = "";
  private String trader_ref = "";
  private String agreement_no = "";
  private String textCommodities = "";
  private String textAdditionalNotes = "";

  public String getJsessionid() {
    return jsessionid;
  }

  public void setJsessionid(String jsessionid) {
    this.jsessionid = DbUtils.cleanString(jsessionid);
  }

  public String getPitch_no() {
    return pitch_no;
  }

  public void setPitch_no(String pitch_no) {
    this.pitch_no = DbUtils.cleanString(pitch_no);
  }

  public String getTrader_ref() {
    return trader_ref;
  }

  public void setTrader_ref(String trader_ref) {
    this.trader_ref = DbUtils.cleanString(trader_ref);
  }

  public String getAgreement_no() {
    return agreement_no;
  }

  public void setAgreement_no(String agreement_no) {
    this.agreement_no = DbUtils.cleanString(agreement_no);
  }

  public String getTextCommodities() {
    return textCommodities;
  }

  public void setTextCommodities(String textCommodities) {
    this.textCommodities = DbUtils.cleanString(textCommodities);
  }

  public String getTextAdditionalNotes() {
    return textAdditionalNotes;
  }

  public void setTextAdditionalNotes(String textAdditionalNotes) {
    this.textAdditionalNotes = DbUtils.cleanString(textAdditionalNotes);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.jsessionid = "";
    this.pitch_no = "";
    this.trader_ref = "";
    this.agreement_no = "";
    this.textCommodities = "";
    this.textAdditionalNotes = "";
  }
}
