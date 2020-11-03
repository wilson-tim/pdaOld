package com.vsb;

public abstract class formBean {
  private String action = "";
  private String error = "";
  private String uniqueId = "";
  
  public String getAction() {
    return action;
  }
  
  public void setAction(String action) {
    this.action = action;
  }

  public String getError() {
    return error;
  }
  
  public void setError(String error) {
    this.error = error;
  }
  
  public String getUniqueId() {
    return uniqueId;
  }

  public void setUniqueId(String uniqueId) {
    this.uniqueId = uniqueId;
  }
}
 
