package com.vsb;

import com.db.DbUtils;

public class custLocSearchBean extends formBean {
  private String customerLoc = "";
  private String customerPostCode = "";
  private String customerBuildingName = "";
  private String customerHouseNo = "";

  public String getCustomerLoc() {
    return customerLoc;
  }

  public void setCustomerLoc(String customerLoc) {
    this.customerLoc = DbUtils.cleanString(customerLoc);
  }

  public String getCustomerPostCode() {
    return customerPostCode;
  }

  public void setCustomerPostCode(String customerPostCode) {
    this.customerPostCode = DbUtils.cleanString(customerPostCode);
  }

  public String getCustomerBuildingName() {
    return customerBuildingName;
  }

  public void setCustomerBuildingName(String customerBuildingName) {
    this.customerBuildingName = DbUtils.cleanString(customerBuildingName);
  }

  public String getCustomerHouseNo() {
    return customerHouseNo;
  }

  public void setCustomerHouseNo(String customerHouseNo) {
    this.customerHouseNo = DbUtils.cleanString(customerHouseNo);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.customerLoc = "";
    this.customerPostCode = "";
    this.customerBuildingName = "";
    this.customerHouseNo = "";
  }
}
