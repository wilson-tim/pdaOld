package com.vsb;

import com.db.DbUtils;

public class schedOrCompBean extends formBean {
  private String wardenBuildingName = "";
  private String wardenHouseNo = "";
  private String wardenPostCode = "";
  private String wardenLoc = "";
  private String businessName = "";

  public String getWardenBuildingName() {
    return wardenBuildingName;
  }

  public void setWardenBuildingName(String wardenBuildingName) {
    this.wardenBuildingName = DbUtils.cleanString(wardenBuildingName);
  }

  public String getWardenHouseNo() {
    return wardenHouseNo;
  }

  public void setWardenHouseNo(String wardenHouseNo) {
    this.wardenHouseNo = DbUtils.cleanString(wardenHouseNo);
  }

  public String getWardenPostCode() {
    return wardenPostCode;
  }

  public void setWardenPostCode(String wardenPostCode) {
    this.wardenPostCode = DbUtils.cleanString(wardenPostCode);
  }

  public String getWardenLoc() {
    return wardenLoc;
  }

  public void setWardenLoc(String wardenLoc) {
    this.wardenLoc = DbUtils.cleanString(wardenLoc);
  }

  public String getBusinessName() {
    return businessName;
  }

  public void setBusinessName(String businessName) {
    this.businessName = DbUtils.cleanString(businessName);
  }  

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.wardenBuildingName = "";
    this.wardenHouseNo = "";
    this.wardenPostCode = "";
    this.wardenLoc = "";
    this.businessName = "";
  }
}
