package com.vsb;

import com.db.DbUtils;

public class compTreeDetailsBean extends formBean {
  private String tree_desc     = "";
  private String tr_no         = "";
  private String position      = "";
  private String position_ref  = "";
  private String species_ref   = "";
  private String height_ref    = "";
  private String age_ref       = "";
  private String crown_ref     = "";
  private String dbh_ref       = "";
  private String condition_ref = "";
  private String vigour_ref    = "";
  private String pavement_ref  = "";
  private String boundary_ref  = "";
  private String building_ref  = "";
  private String issue_ref     = "";
  private String easting       = "";
  private String northing      = "";  

  public String getTree_desc() {
    return tree_desc;
  }
  public void setTree_desc(String tree_desc) {
    this.tree_desc = DbUtils.cleanString(tree_desc);
  }

  public String getTr_no() {
    return tr_no;
  }
  public void setTr_no(String tr_no) {
    this.tr_no = DbUtils.cleanString(tr_no);
  }

  public String getPosition() {
    return position;
  }
  public void setPosition(String position) {
    this.position = DbUtils.cleanString(position);
  }

  public String getPosition_ref() {
    return position_ref;
  }
  public void setPosition_ref(String position_ref) {
    this.position_ref = DbUtils.cleanString(position_ref);
  }

  public String getSpecies_ref() {
    return species_ref;
  }
  public void setSpecies_ref(String species_ref) {
    this.species_ref = DbUtils.cleanString(species_ref);
  }

  public String getHeight_ref() {
    return height_ref;
  }
  public void setHeight_ref(String height_ref) {
    this.height_ref = DbUtils.cleanString(height_ref);
  }

  public String getAge_ref() {
    return age_ref;
  }
  public void setAge_ref(String age_ref) {
    this.age_ref = DbUtils.cleanString(age_ref);
  }
  
  public String getCrown_ref() {
    return crown_ref;
  }
  public void setCrown_ref(String crown_ref) {
    this.crown_ref = DbUtils.cleanString(crown_ref);
  }

  public String getDbh_ref() {
    return dbh_ref;
  }
  public void setDbh_ref(String dbh_ref) {
    this.dbh_ref = DbUtils.cleanString(dbh_ref);
  }  
  
  public String getCondition_ref() {
    return condition_ref;
  }
  public void setCondition_ref(String condition_ref) {
    this.condition_ref = DbUtils.cleanString(condition_ref);
  }

  public String getVigour_ref() {
    return vigour_ref;
  }
  public void setVigour_ref(String vigour_ref) {
    this.vigour_ref = DbUtils.cleanString(vigour_ref);
  }

  public String getPavement_ref() {
    return pavement_ref;
  }
  public void setPavement_ref(String pavement_ref) {
    this.pavement_ref = DbUtils.cleanString(pavement_ref);
  }

  public String getBoundary_ref() {
    return boundary_ref;
  }
  public void setBoundary_ref(String boundary_ref) {
    this.boundary_ref = DbUtils.cleanString(boundary_ref);
  }

  public String getBuilding_ref() {
    return building_ref;
  }
  public void setBuilding_ref(String building_ref) {
    this.building_ref = DbUtils.cleanString(building_ref);
  }

  public String getIssue_ref() {
    return issue_ref;
  }
  public void setIssue_ref(String issue_ref) {
    this.issue_ref = DbUtils.cleanString(issue_ref);
  }

  public String getEasting() {
    return easting;
  }
  public void setEasting(String easting) {
    this.easting = DbUtils.cleanString(easting);
  }

  public String getNorthing() {
    return northing;
  }
  public void setNorthing(String northing) {
    this.northing = DbUtils.cleanString(northing);
  }
  
  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    tree_desc     = "";
    tr_no         = "";
    position      = "";
    position_ref  = "";
    species_ref   = "";
    height_ref    = "";
    age_ref       = "";
    crown_ref     = "";
    dbh_ref       = "";
    condition_ref = "";
    vigour_ref    = "";
    pavement_ref  = "";
    boundary_ref  = "";
    building_ref  = "";
    issue_ref     = "";
    easting       = "";
    northing      = "";  
  }
}
