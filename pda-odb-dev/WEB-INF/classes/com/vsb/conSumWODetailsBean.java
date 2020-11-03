package com.vsb;

import com.db.DbUtils;

public class conSumWODetailsBean extends formBean {
  private String cont_rem1 = "";
  private String cont_rem2 = "";
  private String text = "";
  private String textOut = "";
  private String actionTaken = "";

  public String getCont_rem1() {
    return cont_rem1;
  }

  public void setCont_rem1(String cont_rem1) {
    this.cont_rem1 = DbUtils.cleanString(cont_rem1);
  }

  public String getCont_rem2() {
    return cont_rem2;
  }

  public void setCont_rem2(String cont_rem2) {
    this.cont_rem2 = DbUtils.cleanString(cont_rem2);
  }
  
  public String getText() {
    return text;
  }

  public void setText(String text) {
    this.text = DbUtils.cleanString(text);
  }

  public String getTextOut() {
    return textOut;
  }

  public void setTextOut(String textOut) {
    this.textOut = DbUtils.cleanString(textOut);
  }

  public String getActionTaken() {
    return actionTaken;
  }

  public void setActionTaken(String actionTaken) {
    this.actionTaken = DbUtils.cleanString(actionTaken);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.cont_rem1 = "";
    this.cont_rem2 = "";
    this.text = "";
    this.textOut = "";
    this.actionTaken = "";
  }
}
