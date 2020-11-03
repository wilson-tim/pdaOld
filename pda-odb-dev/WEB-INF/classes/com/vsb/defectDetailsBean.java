package com.vsb;

import com.db.DbUtils;

public class defectDetailsBean extends formBean {
  private String linear   = "0.00";
  private String area     = "0.00";
  private String priority = "";
  private String position = "";
  private String text     = "";

  public String getLinear() {
    return linear;
  }
  
  public void setLinear(String linear) {
    this.linear = DbUtils.cleanString(linear);
  }

  public String getArea() {
    return area;
  }
  
  public void setArea(String area) {
    this.area = DbUtils.cleanString(area);
  }

  public String getPriority() {
    return priority;
  }
  
  public void setPriority(String priority) {
    this.priority = DbUtils.cleanString(priority);
  }

  public String getPosition() {
    return position;
  }

  public void setPosition( String position ) {
    this.position = DbUtils.cleanString(position);
  }

  public String getText() {
    return text;
  }

  public void setText( String text ) {
    this.text = DbUtils.cleanString( text );
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.linear   = "0.00";
    this.area     = "0.00";
    this.priority = "";
    this.position = "";
    this.text     = "";    
  }
}
