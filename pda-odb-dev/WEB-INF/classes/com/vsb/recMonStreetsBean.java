package com.vsb;

import com.db.DbUtils;

public class recMonStreetsBean extends formBean {

  private String monitor_source  = "";
  private String location_c      = "";

  // Monitor Source Getter/Setter methods
  public void setMonitor_source(String monitor_source){
    this.monitor_source = DbUtils.cleanString(monitor_source);
  }
  public String getMonitor_source(){
    return monitor_source;
  }

  // Location_c Getter/Setter methods
  public void setLocation_c( String location_c ){
    this.location_c = DbUtils.cleanString(location_c);
  }
  public String getLocation_c(){
    return location_c;
  }
  
  /**
  * Required by bean framework
  */
  public String getAll() {
    return "";
  }

  /**
  * Required by bean framework
  */
  public void setAll(String all) {
    monitor_source = "";
    location_c = "";
  }
        
}
