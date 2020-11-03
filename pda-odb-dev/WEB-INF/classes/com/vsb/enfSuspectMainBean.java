package com.vsb;

import com.db.DbUtils;

public class enfSuspectMainBean extends formBean {
  private String suspect_surname = "";
  private String suspect_company = "";
  private String default_search = "";

  public String getSuspect_surname() {
    return suspect_surname;
  }

  public void setSuspect_surname(String suspect_surname) {
    this.suspect_surname = DbUtils.cleanString(suspect_surname);
  }

  public String getSuspect_company() {
    return suspect_company;
  }

  public void setSuspect_company(String suspect_company) {
    this.suspect_company = DbUtils.cleanString(suspect_company);
  }

  public String getDefault_search() {
    return default_search;
  }

  public void setDefault_search(String default_search) {
    this.default_search = DbUtils.cleanString(default_search);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.suspect_surname = "";
    this.suspect_company = "";
    this.default_search = "";
  }
}
