package com.vsb;

import com.db.DbUtils;

public class surveyAddDefaultBean extends formBean {

  // Fault code
  private String lookup_code = "";
  // Current BV199 Default Item
  private String bv_name = "";

  // Getter/Setter methods for fault code
  public void setLookup_code( String lookup_code ){
    this.lookup_code = DbUtils.cleanString( lookup_code );
  }
  public String getLookup_code(){
    return lookup_code;
  }

  public void setBv_name( String bv_name ){
    this.bv_name = bv_name;
  }
  public String getBv_name(){
    return bv_name;
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    if( all.equals("clear") ){
      this.lookup_code = "";
    }
    if( all.equals("bean") ){
      this.lookup_code = "";
      this.bv_name = "";
    }
  }
  

}
