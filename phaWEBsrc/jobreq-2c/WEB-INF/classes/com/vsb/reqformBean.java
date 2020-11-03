package com.vsb;

public class reqformBean extends formBean {
  // User input parameters from the form
  private String userContact = "";
  private String userName = "";
  private String problemDetails = "";
  private String jobType = "";
  private String assetId = "";
  
  // Parameters used by the form
  private String userContactError = "";
  private String userNameError = "";
  private String problemDetailsError = "";
  private String assetIdError = "";
  private String nextCwJobId = "";

  public String getUserContact() {
    return userContact;
  }

  public void setUserContact(String userContact) {
    this.userContact = userContact;
  }

  public String getUserName() {
    return userName;
  }

  public void setUserName(String userName) {
    this.userName = userName;
  }

  public String getProblemDetails() {
    return problemDetails;
  }

  public void setProblemDetails(String problemDetails) {
    this.problemDetails = problemDetails;
  }

  public String getJobType() {
    return jobType;
  }

  public void setJobType(String jobType) {
    this.jobType = jobType;
  }

  public String getAssetId() {
    return assetId;
  }

  public void setAssetId(String assetId) {
    this.assetId = assetId;
  }

  public String getUserContactError() {
    return userContactError;
  }

  public void setUserContactError(String userContactError) {
    this.userContactError = userContactError;
  }

  public String getUserNameError() {
    return userNameError;
  }

  public void setUserNameError(String userNameError) {
    this.userNameError = userNameError;
  }

  public String getProblemDetailsError() {
    return problemDetailsError;
  }

  public void setProblemDetailsError(String problemDetailsError) {
    this.problemDetailsError = problemDetailsError;
  }

  public String getAssetIdError() {
    return assetIdError;
  }

  public void setAssetIdError(String assetIdError) {
    this.assetIdError = assetIdError;
  }
  
  public String getNextCwJobId() {
    return nextCwJobId;
  }

  public void setNextCwJobId(String nextCwJobId) {
    this.nextCwJobId = nextCwJobId;
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.userContact = "";
    this.userName = "";
    this.problemDetails = "";
    this.jobType = "";
    this.assetId = "";
    this.nextCwJobId = "";
  }
}
