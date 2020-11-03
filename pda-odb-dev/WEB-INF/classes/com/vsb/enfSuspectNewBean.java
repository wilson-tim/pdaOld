package com.vsb;

import com.db.DbUtils;

public class enfSuspectNewBean extends formBean {
  private String sus_fstname = "";
  private String sus_midname = "";
  private String sus_title = "";
  private String sus_workno = "";
  private String sus_postcode = "";
  private String year_ob = "";
  private String sus_age = "";
  private String sus_mobno = "";
  private String month_ob = "";
  private String sus_addr1 = "";
  private String sus_sex = "";
  private String sus_addr2 = "";
  private String sus_build_name = "";
  private String sus_build_no = "";
  private String sus_addr3 = "";
  private String sus_homeno = "";
  private String sus_surname = "";
  private String jsessionid = "";
  private String sus_company = "";
  private String day_ob = "";

  public String getSus_fstname() {
    return sus_fstname;
  }

  public void setSus_fstname(String sus_fstname) {
    this.sus_fstname = DbUtils.cleanString(sus_fstname);
  }

  public String getSus_midname() {
    return sus_midname;
  }

  public void setSus_midname(String sus_midname) {
    this.sus_midname = DbUtils.cleanString(sus_midname);
  }

  public String getSus_title() {
    return sus_title;
  }

  public void setSus_title(String sus_title) {
    this.sus_title = DbUtils.cleanString(sus_title);
  }

  public String getSus_workno() {
    return sus_workno;
  }

  public void setSus_workno(String sus_workno) {
    this.sus_workno = DbUtils.cleanString(sus_workno);
  }

  public String getSus_postcode() {
    return sus_postcode;
  }

  public void setSus_postcode(String sus_postcode) {
    this.sus_postcode = DbUtils.cleanString(sus_postcode);
  }

  public String getYear_ob() {
    return year_ob;
  }

  public void setYear_ob(String year_ob) {
    this.year_ob = DbUtils.cleanString(year_ob);
  }

  public String getSus_age() {
    return sus_age;
  }

  public void setSus_age(String sus_age) {
    this.sus_age = DbUtils.cleanString(sus_age);
  }

  public String getSus_mobno() {
    return sus_mobno;
  }

  public void setSus_mobno(String sus_mobno) {
    this.sus_mobno = DbUtils.cleanString(sus_mobno);
  }

  public String getMonth_ob() {
    return month_ob;
  }

  public void setMonth_ob(String month_ob) {
    this.month_ob = DbUtils.cleanString(month_ob);
  }

  public String getSus_addr1() {
    return sus_addr1;
  }

  public void setSus_addr1(String sus_addr1) {
    this.sus_addr1 = DbUtils.cleanString(sus_addr1);
  }

  public String getSus_sex() {
    return sus_sex;
  }

  public void setSus_sex(String sus_sex) {
    this.sus_sex = DbUtils.cleanString(sus_sex);
  }

  public String getSus_addr2() {
    return sus_addr2;
  }

  public void setSus_addr2(String sus_addr2) {
    this.sus_addr2 = DbUtils.cleanString(sus_addr2);
  }

  public String getSus_build_name() {
    return sus_build_name;
  }

  public void setSus_build_name(String sus_build_name) {
    this.sus_build_name = DbUtils.cleanString(sus_build_name);
  }

  public String getSus_build_no() {
    return sus_build_no;
  }

  public void setSus_build_no(String sus_build_no) {
    this.sus_build_no = DbUtils.cleanString(sus_build_no);
  }

  public String getSus_addr3() {
    return sus_addr3;
  }

  public void setSus_addr3(String sus_addr3) {
    this.sus_addr3 = DbUtils.cleanString(sus_addr3);
  }

  public String getSus_homeno() {
    return sus_homeno;
  }

  public void setSus_homeno(String sus_homeno) {
    this.sus_homeno = DbUtils.cleanString(sus_homeno);
  }

  public String getSus_surname() {
    return sus_surname;
  }

  public void setSus_surname(String sus_surname) {
    this.sus_surname = DbUtils.cleanString(sus_surname);
  }

  public String getJsessionid() {
    return jsessionid;
  }

  public void setJsessionid(String jsessionid) {
    this.jsessionid = DbUtils.cleanString(jsessionid);
  }

  public String getSus_company() {
    return sus_company;
  }

  public void setSus_company(String sus_company) {
    this.sus_company = DbUtils.cleanString(sus_company);
  }

  public String getDay_ob() {
    return day_ob;
  }

  public void setDay_ob(String day_ob) {
    this.day_ob = DbUtils.cleanString(day_ob);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.sus_fstname = "";
    this.sus_midname = "";
    this.sus_title = "";
    this.sus_workno = "";
    this.sus_postcode = "";
    this.year_ob = "";
    this.sus_age = "";
    this.sus_mobno = "";
    this.month_ob = "";
    this.sus_addr1 = "";
    this.sus_sex = "";
    this.sus_addr2 = "";
    this.sus_build_name = "";
    this.sus_build_no = "";
    this.sus_addr3 = "";
    this.sus_homeno = "";
    this.sus_surname = "";
    this.jsessionid = "";
    this.sus_company = "";
    this.day_ob = "";
  }
}
