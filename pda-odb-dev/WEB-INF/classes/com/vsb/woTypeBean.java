package com.vsb;

import com.db.DbUtils;

public class woTypeBean extends formBean {
  private String del_phone = "";
  private String wo_type_f = "";
  private String del_contact = "";

  public String getDel_phone() {
    return del_phone;
  }

  public void setDel_phone(String del_phone) {
    this.del_phone = DbUtils.cleanString(del_phone);
  }

  public String getWo_type_f() {
    return wo_type_f;
  }

  public void setWo_type_f(String wo_type_f) {
    this.wo_type_f = DbUtils.cleanString(wo_type_f);
  }

  public String getDel_contact() {
    return del_contact;
  }

  public void setDel_contact(String del_contact) {
    this.del_contact = DbUtils.cleanString(del_contact);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.del_phone = "";
    this.wo_type_f = "";
    this.del_contact = "";
  }
}
