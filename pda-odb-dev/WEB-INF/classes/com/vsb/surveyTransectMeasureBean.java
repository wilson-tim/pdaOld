package com.vsb;

import com.db.DbUtils;

public class surveyTransectMeasureBean extends formBean {

	private String sl_switch = "";
	private String hn_count = "";
	private String start_post = "";
	private String end_post = "";
	private String start_house = "";
	private String end_house = "";
	private String transect_desc = "";


  public String getSl_switch() {
    return sl_switch;
  }
  public void setSl_switch(String sl_switch) {
    this.sl_switch = DbUtils.cleanString(sl_switch);
  }

  public String getHn_count() {
    return hn_count;
  }
  public void setHn_count(String hn_count) {
    this.hn_count = DbUtils.cleanString(hn_count);
  }

  public String getStart_post() {
    return start_post;
  }
  public void setStart_post(String start_post) {
    this.start_post = DbUtils.cleanString(start_post);
  }

  public String getEnd_post() {
    return end_post;
  }
  public void setEnd_post(String end_post) {
    this.end_post = DbUtils.cleanString(end_post);
  }

  public String getStart_house() {
    return start_house;
  }
  public void setStart_house(String start_house) {
    this.start_house = DbUtils.cleanString(start_house);
  }

  public String getEnd_house() {
    return end_house;
  }
  public void setEnd_house(String end_house) {
    this.end_house = DbUtils.cleanString(end_house);
  }

  public String getTransect_desc() {
    return transect_desc;
  }
  public void setTransect_desc(String transect_desc) {
    this.transect_desc = DbUtils.cleanString(transect_desc);
  }


  public String getAll() {
    return "";
  }

  public void setAll(String all) {
		this.sl_switch = "";
		this.hn_count = "";
		this.start_post = "";
		this.end_post = "";
		this.start_house = "";
		this.end_house = "";
		this.transect_desc = "";
  }
}
