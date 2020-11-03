package com.vsb;

import com.db.DbUtils;

public class surveySiteSearchBean extends formBean {

  private String surveyPostCode = "";
  private String surveyHouseNo = "";
  private String surveyBuildingName = "";
  private String surveyLocation = "";

  public String getSurveyPostCode() {
    return surveyPostCode;
  }

  public void setSurveyPostCode(String surveyPostCode) {
    this.surveyPostCode = DbUtils.cleanString(surveyPostCode);
  }

  public String getSurveyHouseNo() {
    return surveyHouseNo;
  }

  public void setSurveyHouseNo(String surveyHouseNo) {
    this.surveyHouseNo = DbUtils.cleanString(surveyHouseNo);
  }

    public String getSurveyBuildingName() {
    return surveyBuildingName;
  }

  public void setSurveyBuildingName(String surveyBuildingName) {
    this.surveyBuildingName = DbUtils.cleanString(surveyBuildingName);
  }

    public String getSurveyLocation() {
    return surveyLocation;
  }

  public void setSurveyLocation(String surveyLocation) {
    this.surveyLocation = DbUtils.cleanString(surveyLocation);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {

    this.surveyPostCode = "";
    this.surveyHouseNo = "";
    this.surveyBuildingName = "";
    this.surveyLocation = "";
  }
}
