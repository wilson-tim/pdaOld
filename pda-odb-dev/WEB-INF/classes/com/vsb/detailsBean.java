package com.vsb;

import com.db.DbUtils;

public class detailsBean extends formBean {
  private String colour_desc = "";
  private String model_desc = "";
  private String car_id = "";

  public String getColour_desc() {
    return colour_desc;
  }

  public void setColour_desc(String colour_desc) {
    this.colour_desc = DbUtils.cleanString(colour_desc);
  }

  public String getModel_desc() {
    return model_desc;
  }

  public void setModel_desc(String model_desc) {
    this.model_desc = DbUtils.cleanString(model_desc);
  }

  public String getCar_id() {
    return car_id;
  }

  public void setCar_id(String car_id) {
    this.car_id = DbUtils.cleanString(car_id);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.colour_desc = "";
    this.model_desc = "";
    this.car_id = "";
  }
}
