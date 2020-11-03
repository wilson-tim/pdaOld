package com.vsb;

import com.db.DbUtils;

public class defaultAdditionalBean extends formBean {
  private String def_volume = "";
  private String points = "";
  private String value = "";

  public String getDef_volume() {
    return def_volume;
  }

  public void setDef_volume(String def_volume) {
    this.def_volume = DbUtils.cleanString(def_volume);
  }

  public String getPoints() {
    return points;
  }

  public void setPoints(String points) {
    this.points = DbUtils.cleanString(points);
  }

  public String getValue() {
    return value;
  }

  public void setValue(String value) {
    this.value = DbUtils.cleanString(value);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.def_volume = "";
    this.points = "";
    this.value = "";
  }
}
