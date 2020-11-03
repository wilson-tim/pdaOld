package com.vsb;

import com.db.DbUtils;

public class recMonPropertiesBean extends formBean {

  private String complaint_no = "";

  // Complaint_no Getter/Setter methods
  public void setComplaint_no( String complaint_no ){
    this.complaint_no = DbUtils.cleanString(complaint_no);
  }
  public String getComplaint_no(){
    return complaint_no;
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
    complaint_no = "";
  }
        
}
