package com.vsb;

import com.db.DbUtils;

public class enfEvidenceBean extends formBean {
  private String evidence = "";
  private String jsessionid = "";
  private String previousEvidence = "";

  public String getEvidence() {
    return evidence;
  }

  public void setEvidence(String evidence) {
    this.evidence = DbUtils.cleanString(evidence);
  }

  public String getJsessionid() {
    return jsessionid;
  }

  public void setJsessionid(String jsessionid) {
    this.jsessionid = DbUtils.cleanString(jsessionid);
  }

  public String getPreviousEvidence() {
    return previousEvidence;
  }

  public void setPreviousEvidence(String previousEvidence) {
    this.previousEvidence = DbUtils.cleanString(previousEvidence);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.evidence = "";
    this.jsessionid = "";
    this.previousEvidence = "";
  }
}
