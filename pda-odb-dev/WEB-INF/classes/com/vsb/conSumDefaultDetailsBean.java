package com.vsb;

import com.db.DbUtils;

public class conSumDefaultDetailsBean extends formBean {
  private String text = "";
  private String textOut = "";
  private String actionTaken = "";

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
    String actionCode = "";
    if(actionTaken.equals("Unjustified")){
      actionCode = "U";
    }else if(actionTaken.equals("Actioned")){
      actionCode = "A";
    }else if(actionTaken.equals("Not Actioned")){
      actionCode = "N";
    }else if(actionTaken.equals("Cleared")){
      actionCode = "Z";
    }else{
      actionCode = "";
    }
    return actionCode;
  }

  public void setActionTaken(String actionTaken) {
    this.actionTaken = DbUtils.cleanString(actionTaken);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.text = "";
    this.textOut = "";
    this.actionTaken = "";
  }
}
