package com.vsb;

import com.db.DbUtils;

public class wasteTypesBean extends formBean {
  private String[] waste_types;
  private String[] waste_qtys;
  private String[] waste_type_list;

  public String[] getWaste_types() {
    return waste_types;
  }

  public void setWaste_types(String[] waste_types) {
    this.waste_types = waste_types;
  }

  public String[] getWaste_qtys() {
    return waste_qtys;
  }

  public void setWaste_qtys(String[] waste_qtys) {
    this.waste_qtys = waste_qtys;
  }

  public String[] getWaste_type_list() {
    return waste_type_list;
  }

  public void setWaste_type_list(String[] waste_type_list) {
    this.waste_type_list = waste_type_list;
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.waste_types = null;
    this.waste_qtys = null;
    this.waste_type_list = null;
  }
}
