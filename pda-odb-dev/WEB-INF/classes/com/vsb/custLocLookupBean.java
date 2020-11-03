package com.vsb;

import com.db.DbUtils;

public class custLocLookupBean extends formBean {
  private String compl_build_name = "";
  private String compl_build_no = "";
  private String compl_postcode = "";
  private String compl_addr2 = "";
  private String site_ref = "";
  private String compl_addr4 = "";
  private String wasEmpty = "";

  public String getCompl_build_name() {
    return compl_build_name;
  }

  public void setCompl_build_name(String compl_build_name) {
    this.compl_build_name = DbUtils.cleanString(compl_build_name);
  }

  public String getCompl_build_no() {
    return compl_build_no;
  }

  public void setCompl_build_no(String compl_build_no) {
    this.compl_build_no = DbUtils.cleanString(compl_build_no);
  }

  public String getCompl_postcode() {
    return compl_postcode;
  }

  public void setCompl_postcode(String compl_postcode) {
    this.compl_postcode = DbUtils.cleanString(compl_postcode);
  }

  public String getCompl_addr2() {
    return compl_addr2;
  }

  public void setCompl_addr2(String compl_addr2) {
    this.compl_addr2 = DbUtils.cleanString(compl_addr2);
  }

  public String getSite_ref() {
    return site_ref;
  }

  public void setSite_ref(String site_ref) {
    this.site_ref = DbUtils.cleanString(site_ref);
  }

  public String getCompl_addr4() {
    return compl_addr4;
  }

  public void setCompl_addr4(String compl_addr4) {
    this.compl_addr4 = DbUtils.cleanString(compl_addr4);
  }

  public String getWasEmpty() {
    return wasEmpty;
  }

  public void setWasEmpty(String wasEmpty) {
    this.wasEmpty = DbUtils.cleanString(wasEmpty);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.compl_build_name = "";
    this.compl_build_no = "";
    this.compl_postcode = "";
    this.compl_addr2 = "";
    this.site_ref = "";
    this.compl_addr4 = "";
    this.wasEmpty = "";
  }
}
