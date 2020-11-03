package com.vsb;

import com.db.DbUtils;

public class enterCustDetailsBean extends formBean {
  private String compl_phone = "";
  private String compl_init = "";
  private String compl_name = "";
  private String compl_email = "";
  private String compl_surname = "";
  private String address_flag = "";
  private String int_ext_flag = "";

  public String getCompl_phone() {
    return compl_phone;
  }

  public void setCompl_phone(String compl_phone) {
    this.compl_phone = DbUtils.cleanString(compl_phone);
  }

  public String getCompl_init() {
    return compl_init;
  }

  public void setCompl_init(String compl_init) {
    this.compl_init = DbUtils.cleanString(compl_init);
  }

  public String getCompl_name() {
    return compl_name;
  }

  public void setCompl_name(String compl_name) {
    this.compl_name = DbUtils.cleanString(compl_name);
  }

  public String getCompl_email() {
    return compl_email;
  }

  public void setCompl_email(String compl_email) {
    this.compl_email = DbUtils.cleanString(compl_email);
  }

  public String getCompl_surname() {
    return compl_surname;
  }

  public void setCompl_surname(String compl_surname) {
    this.compl_surname = DbUtils.cleanString(compl_surname);
  }

  public String getAddress_flag() {
    return address_flag;
  }

  public void setAddress_flag(String address_flag) {
    this.address_flag = DbUtils.cleanString(address_flag);
  }

  public String getInt_ext_flag() {
    return int_ext_flag;
  }

  public void setInt_ext_flag(String int_ext_flag) {
    this.int_ext_flag = DbUtils.cleanString(int_ext_flag);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.compl_phone = "";
    this.compl_init = "";
    this.compl_name = "";
    this.compl_email = "";
    this.compl_surname = "";
    this.address_flag = "";
    this.int_ext_flag = "";
  }
}
