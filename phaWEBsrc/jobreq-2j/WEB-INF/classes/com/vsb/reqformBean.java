package com.vsb;

public class reqformBean extends formBean {
  private String userContact = "";
  private String problemDetails1 = "";
  private String problemDetails2 = "";
  private String problemDetails3 = "";
  private String problemDetails4 = "";
  private String userEmail = "";
  private String uniqueId = "";
  private String userName = "";
  private String jobType = "";
  private String assetId = "";

  // Parameters used by the form
  private String userContactError = "";
  private String userNameError = "";
  private String problemDetails1Error = "";
  private String problemDetails2Error = "";
  private String problemDetails3Error = "";
  private String problemDetails4Error = "";
  private String userEmailError = "";
  private String assetIdError = "";
  private String nextCwJobId = "";

  public String getUserContact() {
    return userContact;
  }

  public void setUserContact(String userContact) {
    this.userContact = userContact;
  }

  public String getUserEmail() {
    return userEmail;
  }

  public void setUserEmail(String userEmail) {
    this.userEmail = userEmail;
  }

  public String getProblemDetails1() {
    return problemDetails1;
  }

  public void setProblemDetails1(String problemDetails1) {
    this.problemDetails1 = problemDetails1;
  }

  public String getProblemDetails2() {
    return problemDetails2;
  }

  public void setProblemDetails2(String problemDetails2) {
    this.problemDetails2 = problemDetails2;
  }

  public String getProblemDetails3() {
    return problemDetails3;
  }

  public void setProblemDetails3(String problemDetails3) {
    this.problemDetails3 = problemDetails3;
  }

  public String getProblemDetails4() {
    return problemDetails4;
  }

  public void setProblemDetails4(String problemDetails4) {
    this.problemDetails4 = problemDetails4;
  }

  public String getUniqueId() {
    return uniqueId;
  }

  public void setUniqueId(String uniqueId) {
    this.uniqueId = uniqueId;
  }

  public String getUserName() {
    return userName;
  }

  public void setUserName(String userName) {
    this.userName = userName;
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

  public String getProblemDetails1Error() {
    return problemDetails1Error;
  }

  public void setProblemDetails1Error(String problemDetails1Error) {
    this.problemDetails1Error = problemDetails1Error;
  }
  
  public String getProblemDetails2Error() {
    return problemDetails2Error;
  }

  public void setProblemDetails2Error(String problemDetails2Error) {
    this.problemDetails2Error = problemDetails2Error;
  }

  public String getProblemDetails3Error() {
    return problemDetails3Error;
  }

  public void setProblemDetails3Error(String problemDetails3Error) {
    this.problemDetails3Error = problemDetails3Error;
  }

  public String getProblemDetails4Error() {
    return problemDetails4Error;
  }

  public void setProblemDetails4Error(String problemDetails4Error) {
    this.problemDetails4Error = problemDetails4Error;
  }

  public String getAssetIdError() {
    return assetIdError;
  }

  public void setAssetIdError(String assetIdError) {
    this.assetIdError = assetIdError;
  }

  public String getUserEmailError() {
    return userEmailError;
  }

  public void setUserEmailError(String userEmailError) {
    this.userEmailError = userEmailError;
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
    this.userEmail = "";
    this.problemDetails1 = "";
    this.problemDetails2 = "";
    this.problemDetails3 = "";
    this.problemDetails4 = "";
    this.uniqueId = "";
    this.userName = "";
    this.jobType = "";
    this.assetId = "";
  }
}
