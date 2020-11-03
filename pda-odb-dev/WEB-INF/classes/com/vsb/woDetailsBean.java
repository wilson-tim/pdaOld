package com.vsb;

import com.db.DbUtils;
import java.util.HashMap;

public class woDetailsBean extends formBean {
  private String exact_location   = "";
  private String remarks   = "";
  private String comp_text   = "";
  private String text   = "";
  private String day   = "";
  private String year  = "";
  private String month = "";
  private HashMap wo_task_details = new HashMap();

  public String getExact_location() {
    return exact_location;
  }

  public void setExact_location(String exact_location) {
    this.exact_location = DbUtils.cleanString(exact_location);
  }

  public String getRemarks() {
    return remarks;
  }

  public void setRemarks(String remarks) {
    this.remarks = DbUtils.cleanString(remarks);
  }

  public String getComp_text() {
    return comp_text;
  }

  public void setComp_text(String comp_text) {
    this.comp_text = DbUtils.cleanString(comp_text);
  }

  public String getText() {
    return text;
  }

  public void setText(String text) {
    this.text = DbUtils.cleanString(text);
  }

  public String getDay() {
    return day;
  }

  public void setDay(String day) {
    this.day = DbUtils.cleanString(day);
  }

  public String getYear() {
    return year;
  }

  public void setYear(String year) {
    this.year = DbUtils.cleanString(year);
  }

  public String getMonth() {
    return month;
  }

  public void setMonth(String month) {
    this.month = DbUtils.cleanString(month);
  }
  
  public void add( String task_ref, String[] details ) {
    wo_task_details.put( task_ref, details );
  }
  
  public String getWoi_task_desc( String task_ref ) {
    String[] details = (String[])wo_task_details.get( task_ref );
    return details[0];
  }

  public void setWoi_task_desc( String task_ref, String task_desc ) {
    String[] details = (String[])wo_task_details.get( task_ref );
    details[0] = task_desc;
    wo_task_details.put( task_ref, details );
  }

  public String getWoi_task_rate( String task_ref ) {
    String[] details = (String[])wo_task_details.get( task_ref );
    return details[1];
  }

  public void setWoi_task_rate( String task_ref, String task_rate ) {
    String[] details = (String[])wo_task_details.get( task_ref );
    details[1] = task_rate;
    wo_task_details.put( task_ref, details );
  }

  public String getWoi_task_volume( String task_ref ) {
    String[] details = (String[])wo_task_details.get( task_ref );
    return details[2];
  }

  public void setWoi_task_volume( String task_ref, String task_volume ) {
    String[] details = (String[])wo_task_details.get( task_ref );
    details[2] = task_volume;
    wo_task_details.put( task_ref, details );
  }

  public String getLine_total( String task_ref ) {
    String[] details = (String[])wo_task_details.get( task_ref );
    return details[3];
  }

  public void setLine_total( String task_ref, String line_total ) {
    String[] details = (String[])wo_task_details.get( task_ref );
    details[3] = line_total;
    wo_task_details.put( task_ref, details );
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    if( all.equals("bean") ) {
      this.exact_location   = "";
      this.remarks   = "";
      this.comp_text   = "";
      this.text   = "";
      this.day   = "";
      this.year  = "";
      this.month = "";
      this.wo_task_details = new HashMap();
    } else if( all.equals("clear") ) {
      this.exact_location   = "";
      this.remarks   = "";
      this.comp_text   = "";
      this.text   = "";
      this.day   = "";
      this.year  = "";
      this.month = "";
    }
  }
}
