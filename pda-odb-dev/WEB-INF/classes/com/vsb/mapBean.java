package com.vsb;

import com.db.DbUtils;

public class mapBean extends formBean {
  private String YWorldCenter = "";
  private String XWorldCenter = "";
  private String zoom = "";
  private String asset_type = "";
  private boolean connected = false;

  public String getYWorldCenter() {
    return YWorldCenter;
  }

  public void setYWorldCenter(String YWorldCenter) {
    this.YWorldCenter = DbUtils.cleanString(YWorldCenter);
  }

  public String getXWorldCenter() {
    return XWorldCenter;
  }

  public void setXWorldCenter(String XWorldCenter) {
    this.XWorldCenter = DbUtils.cleanString(XWorldCenter);
  }

  public String getZoom() {
    return zoom;
  }

  public void setZoom(String zoom) {
    this.zoom = DbUtils.cleanString(zoom);
  }

  public boolean isConnected() {
    return connected;
  }

  public void setConnected(boolean connected) {
    this.connected = connected;
  }

  public String getAsset_type() {
    return asset_type;
  }

  public void setAsset_type(String asset_type) {
    this.asset_type = DbUtils.cleanString(asset_type);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.YWorldCenter = "";
    this.XWorldCenter = "";
    this.zoom = "";
    this.asset_type = "";
    this.connected = false;
  }
}
