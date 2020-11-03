package com.vsb;

import com.db.DbUtils;

public abstract class formBean {
  private String action = "";
  private String error = "";
  private String uniqueId = "";
  private String savedPreviousForm = "";

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
    this.error = DbUtils.cleanString(error);
  }

  public String getUniqueId() {
    return uniqueId;
  }

  public void setUniqueId(String uniqueId) {
    this.uniqueId = uniqueId;
  }

  public String getSavedPreviousForm() {
    return savedPreviousForm;
  }

  public void setSavedPreviousForm(String savedPreviousForm) {
    this.savedPreviousForm = savedPreviousForm;
  }
}

