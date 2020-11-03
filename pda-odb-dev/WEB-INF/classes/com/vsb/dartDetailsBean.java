package com.vsb;

import com.db.DbUtils;

public class dartDetailsBean extends formBean {
  private String wo_est_cost = "0";
  private String rep_needle_qty = "0";
  private String rep_crack_pipe_qty = "0";
  private String rep_condom_qty = "0";
  private String col_needle_qty = "0";
  private String col_crack_pipe_qty = "0";
  private String col_condom_qty = "0";
  private String[] rep_cats;
  private String[] drug_para;
  private String[] asww_cats;
  private String[] abuse_cats;
  private String refuse_pay = "";
  private String est_duration_h = "";
  private String est_duration_m = "";

  public String getWo_est_cost() {
    return wo_est_cost;
  }

  public void setWo_est_cost(String wo_est_cost) {
    this.wo_est_cost = DbUtils.cleanString(wo_est_cost);
  }

  public String getCol_condom_qty() {
    return col_condom_qty;
  }

  public void setCol_condom_qty(String col_condom_qty) {
    this.col_condom_qty = DbUtils.cleanString(col_condom_qty);
  }

  public String getRep_condom_qty() {
    return rep_condom_qty;
  }

  public void setRep_condom_qty(String rep_condom_qty) {
    this.rep_condom_qty = DbUtils.cleanString(rep_condom_qty);
  }

  public String getRep_crack_pipe_qty() {
    return rep_crack_pipe_qty;
  }

  public void setRep_crack_pipe_qty(String rep_crack_pipe_qty) {
    this.rep_crack_pipe_qty = DbUtils.cleanString(rep_crack_pipe_qty);
  }

  public String getCol_crack_pipe_qty() {
    return col_crack_pipe_qty;
  }

  public void setCol_crack_pipe_qty(String col_crack_pipe_qty) {
    this.col_crack_pipe_qty = DbUtils.cleanString(col_crack_pipe_qty);
  }

  public String getCol_needle_qty() {
    return col_needle_qty;
  }

  public void setCol_needle_qty(String col_needle_qty) {
    this.col_needle_qty = DbUtils.cleanString(col_needle_qty);
  }

  public String getRep_needle_qty() {
    return rep_needle_qty;
  }

  public void setRep_needle_qty(String rep_needle_qty) {
    this.rep_needle_qty = DbUtils.cleanString(rep_needle_qty);
  }

  public String[] getRep_cats() {
    return rep_cats;
  }

  public void setRep_cats(String[] rep_cats) {
    this.rep_cats = rep_cats;
  }

  public String[] getDrug_para() {
    return drug_para;
  }

  public void setDrug_para(String[] drug_para) {
    this.drug_para = drug_para;
  }

  public String[] getAsww_cats() {
    return asww_cats;
  }

  public void setAsww_cats(String[] asww_cats) {
    this.asww_cats = asww_cats;
  }

  public String[] getAbuse_cats() {
    return abuse_cats;
  }

  public void setAbuse_cats(String[] abuse_cats) {
    this.abuse_cats = abuse_cats;
  }


  public String getRefuse_pay() {
    return refuse_pay;
  }

  public void setRefuse_pay(String refuse_pay) {
    this.refuse_pay = DbUtils.cleanString(refuse_pay);
  }

  public String getEst_duration_h() {
    return est_duration_h;
  }

  public void setEst_duration_h(String est_duration_h) {
    this.est_duration_h = DbUtils.cleanString(est_duration_h);
  }

  public String getEst_duration_m() {
    return est_duration_m;
  }

  public void setEst_duration_m(String est_duration_m) {
    this.est_duration_m = DbUtils.cleanString(est_duration_m);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.wo_est_cost = "0";
    this.rep_needle_qty = "0";
    this.rep_crack_pipe_qty = "0";
    this.rep_condom_qty = "0";
    this.col_needle_qty = "0";
    this.col_crack_pipe_qty = "0";
    this.col_condom_qty = "0";
    this.rep_cats = null;
    this.drug_para = null;
    this.asww_cats = null;
    this.abuse_cats = null;
    this.refuse_pay = "";
    this.est_duration_h = "";
    this.est_duration_m = "";
  }
}
