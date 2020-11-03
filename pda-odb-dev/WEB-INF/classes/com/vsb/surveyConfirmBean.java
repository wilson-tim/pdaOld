package com.vsb;

import com.db.DbUtils;

public class surveyConfirmBean extends formBean {

  private String survey_text = "";

	public String getSurvey_text() {
    return survey_text;
  }

  public void setSurvey_text(String survey_text) {
    this.survey_text = DbUtils.cleanString(survey_text);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.survey_text = "";
  }
}
