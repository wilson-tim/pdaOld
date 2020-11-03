package com.vsb;

import com.db.DbUtils;

public class flyCapUpdateBean extends formBean {
  private String load_qty = "";
  private String dom_waste_qty = "";
  private String land_type = "";
  private String dom_waste_type = "";
  private String load_size = "";

  public String getLoad_qty() {
    return load_qty;
  }

  public void setLoad_qty(String load_qty) {
    this.load_qty = DbUtils.cleanString(load_qty);
  }

  public String getDom_waste_qty() {
    return dom_waste_qty;
  }

  public void setDom_waste_qty(String dom_waste_qty) {
    this.dom_waste_qty = DbUtils.cleanString(dom_waste_qty);
  }

  public String getLand_type() {
    return land_type;
  }

  public void setLand_type(String land_type) {
    this.land_type = DbUtils.cleanString(land_type);
  }

  public String getDom_waste_type() {
    return dom_waste_type;
  }

  public void setDom_waste_type(String dom_waste_type) {
    this.dom_waste_type = DbUtils.cleanString(dom_waste_type);
  }

  public String getLoad_size() {
    return load_size;
  }

  public void setLoad_size(String load_size) {
    this.load_size = DbUtils.cleanString(load_size);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.load_qty = "";
    this.dom_waste_qty = "";
    this.land_type = "";
    this.dom_waste_type = "";
    this.load_size = "";
  }
}
