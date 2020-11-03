package com.vsb;

import com.db.DbUtils;

public class locationSearchBean extends formBean {

  private String postcode = "";
  private String streetname = "";
  private String houseno = "";
  private String uprn = "";
  private String Townname="";

  public String getTownname() {
    return Townname;
  }

  public void setTownname(String Townname) {
    this.Townname = DbUtils.cleanString(Townname);
  }

  public String getPostcode() {
    return postcode;
  }

  public void setPostcode(String postcode) {
    this.postcode = DbUtils.cleanString(postcode);
  }

  public String getStreetname() {
    return streetname;
  }

  public void setStreetname(String streetname) {
    this.streetname = DbUtils.cleanString(streetname);
  }

  public String getHouseno() {
    return houseno;
  }

  public void setHouseno(String houseno) {
    this.houseno = DbUtils.cleanString(houseno);
  }

  public String getUprn() {
    return uprn;
  }

  public void setUprn(String postcode) {
    this.postcode = DbUtils.cleanString(uprn);
  }


  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.postcode = "";
    this.streetname = "";
    this.houseno = "";
    this.uprn = "";
    this.Townname="";
  }
}
