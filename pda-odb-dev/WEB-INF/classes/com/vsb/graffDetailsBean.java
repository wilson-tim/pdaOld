package com.vsb;

import com.db.DbUtils; 

public class graffDetailsBean extends formBean {
  private String volume_ref          = "";
  private String tag_offensive       = "";
  private String tag_visible         = "";
  private String tag_recognisable    = "";
  private String tag_known_offender  = "";
  private String tag_offender_info   = "";
  private String tag_repeat_offence  = "";
  private String tag_offences_ref    = "";
  private String rem_workforce_ref   = "";
  private String wo_est_cost         = "0";
  private String tag                 = "";
  private String refuse_pay          = "";
  private String est_duration_h      = "";
  private String est_duration_m      = "";
  private String graffiti_level_ref  = "";
  private String indemnity_response  = "";
  private String indemnity_date      = "";
  private String indemnity_day       = "";
  private String indemnity_month     = "";
  private String indemnity_year      = "";
  private String indemnity_time_h    = "";
  private String indemnity_time_m    = "";
  private String cust_responsible    = "";
  private String landlord_perm_date  = "";
  private String landlord_perm_day   = "";
  private String landlord_perm_month = "";
  private String landlord_perm_year  = "";
  private String[] ref_ertmat;
  private String[] ref_ertoff;
  private String[] ref_ertact;
  private String[] ref_abuse;
  private String[] ref_ertmet;
  private String[] ref_ertequ;
  private String[] ref_ertlev;
  private String[] ref_ertsur;
  private String[] ref_ertown;
  private String[] ref_ertopp;
  private String[] ref_ertitm;

  public String getTag_recognisable() {
    return tag_recognisable;
  }
  public void setTag_recognisable(String tag_recognisable) {
    this.tag_recognisable = DbUtils.cleanString(tag_recognisable);
  }

  public String getVolume_ref() {
    return volume_ref;
  }
  public void setVolume_ref(String volume_ref) {
    this.volume_ref = DbUtils.cleanString(volume_ref);
  }

  public String getTag_offensive() {
    return tag_offensive;
  }
  public void setTag_offensive(String tag_offensive) {
    this.tag_offensive = DbUtils.cleanString(tag_offensive);
  }

  public String getTag_visible() {
    return tag_visible;
  }
  public void setTag_visible(String tag_visible) {
    this.tag_visible = DbUtils.cleanString(tag_visible);
  }

  public String getTag_repeat_offence() {
    return tag_repeat_offence;
  }
  public void setTag_repeat_offence(String tag_repeat_offence) {
    this.tag_repeat_offence = DbUtils.cleanString(tag_repeat_offence);
  }

  public String getTag_offender_info() {
    return tag_offender_info;
  }
  public void setTag_offender_info(String tag_offender_info) {
    this.tag_offender_info = DbUtils.cleanString(tag_offender_info);
  }

  public String getWo_est_cost() {
    return wo_est_cost;
  }
  public void setWo_est_cost(String wo_est_cost) {
    this.wo_est_cost = DbUtils.cleanString(wo_est_cost);
  }

  public String getTag_offences_ref() {
    return tag_offences_ref;
  }
  public void setTag_offences_ref(String tag_offences_ref) {
    this.tag_offences_ref = DbUtils.cleanString(tag_offences_ref);
  }

  public String getRem_workforce_ref() {
    return rem_workforce_ref;
  }
  public void setRem_workforce_ref(String rem_workforce_ref) {
    this.rem_workforce_ref = DbUtils.cleanString(rem_workforce_ref);
  }

  public String getTag() {
    return tag;
  }
  public void setTag(String tag) {
    this.tag = DbUtils.cleanString(tag);
  }

  public String getTag_known_offender() {
    return tag_known_offender;
  }
  public void setTag_known_offender(String tag_known_offender) {
    this.tag_known_offender = DbUtils.cleanString(tag_known_offender);
  }

  public String getRefuse_pay() {
    return refuse_pay;
  }
  public void setRefuse_pay(String refuse_pay) {
    this.refuse_pay = DbUtils.cleanString(refuse_pay);
  }

  public String getEst_duration_h() {
    return est_duration_h;
  }
  public void setEst_duration_h(String est_duration_h) {
    this.est_duration_h = DbUtils.cleanString(est_duration_h);
  }

  public String getEst_duration_m() {
    return est_duration_m;
  }
  public void setEst_duration_m(String est_duration_m) {
    this.est_duration_m = DbUtils.cleanString(est_duration_m);
  }

  public String getGraffiti_level_ref() {
    return graffiti_level_ref;
  }
  public void setGraffiti_level_ref(String graffiti_level_ref) {
    this.graffiti_level_ref = DbUtils.cleanString(graffiti_level_ref);
  }

  public String getIndemnity_response() {
    return indemnity_response;
  }
  public void setIndemnity_response(String indemnity_response) {
    this.indemnity_response = DbUtils.cleanString(indemnity_response);
  }

  public String getIndemnity_date() {
    return indemnity_date;
  }
  public void setIndemnity_date(String indemnity_date) {
    this.indemnity_date = DbUtils.cleanString(indemnity_date);
  }

  public String getIndemnity_day() {
    return indemnity_day;
  }
  public void setIndemnity_day(String indemnity_day) {
    this.indemnity_day = DbUtils.cleanString(indemnity_day);
  }

  public String getIndemnity_month() {
    return indemnity_month;
  }
  public void setIndemnity_month(String indemnity_month) {
    this.indemnity_month = DbUtils.cleanString(indemnity_month);
  }

  public String getIndemnity_year() {
    return indemnity_year;
  }
  public void setIndemnity_year(String indemnity_year) {
    this.indemnity_year = DbUtils.cleanString(indemnity_year);
  }
  
  public String getIndemnity_time_h() {
    return indemnity_time_h;
  }
  public void setIndemnity_time_h(String indemnity_time_h) {
    this.indemnity_time_h = DbUtils.cleanString(indemnity_time_h);
  }

  public String getIndemnity_time_m() {
    return indemnity_time_m;
  }
  public void setIndemnity_time_m(String indemnity_time_m) {
    this.indemnity_time_m = DbUtils.cleanString(indemnity_time_m);
  }
  
  public String getCust_responsible() {
    return cust_responsible;
  }
  public void setCust_responsible(String cust_responsible) {
    this.cust_responsible = DbUtils.cleanString(cust_responsible);
  }

  public String getLandlord_perm_date() {
    return landlord_perm_date;
  }
  public void setLandlord_perm_date(String landlord_perm_date) {
    this.landlord_perm_date = DbUtils.cleanString(landlord_perm_date);
  }

  public String getLandlord_perm_day() {
    return landlord_perm_day;
  }
  public void setLandlord_perm_day(String landlord_perm_day) {
    this.landlord_perm_day = DbUtils.cleanString(landlord_perm_day);
  }

  public String getLandlord_perm_month() {
    return landlord_perm_month;
  }
  public void setLandlord_perm_month(String landlord_perm_month) {
    this.landlord_perm_month = DbUtils.cleanString(landlord_perm_month);
  }

  public String getLandlord_perm_year() {
    return landlord_perm_year;
  }
  public void setLandlord_perm_year(String landlord_perm_year) {
    this.landlord_perm_year = DbUtils.cleanString(landlord_perm_year);
  }
  
  public String[] getRef_ertmat() {
    return ref_ertmat;
  }
  public void setRef_ertmat(String[] ref_ertmat) {
    this.ref_ertmat = ref_ertmat;
  }

  public String[] getRef_ertoff() {
    return ref_ertoff;
  }
  public void setRef_ertoff(String[] ref_ertoff) {
    this.ref_ertoff = ref_ertoff;
  }

  public String[] getRef_ertact() {
    return ref_ertact;
  }
  public void setRef_ertact(String[] ref_ertact) {
    this.ref_ertact = ref_ertact;
  }

  public String[] getRef_abuse() {
    return ref_abuse;
  }
  public void setRef_abuse(String[] ref_abuse) {
    this.ref_abuse = ref_abuse;
  }

  public String[] getRef_ertmet() {
    return ref_ertmet;
  }
  public void setRef_ertmet(String[] ref_ertmet) {
    this.ref_ertmet = ref_ertmet;
  }

  public String[] getRef_ertequ() {
    return ref_ertequ;
  }
  public void setRef_ertequ(String[] ref_ertequ) {
    this.ref_ertequ = ref_ertequ;
  }

  public String[] getRef_ertlev() {
    return ref_ertlev;
  }
  public void setRef_ertlev(String[] ref_ertlev) {
    this.ref_ertlev = ref_ertlev;
  }

  public String[] getRef_ertsur() {
    return ref_ertsur;
  }
  public void setRef_ertsur(String[] ref_ertsur) {
    this.ref_ertsur = ref_ertsur;
  }

  public String[] getRef_ertown() {
    return ref_ertown;
  }
  public void setRef_ertown(String[] ref_ertown) {
    this.ref_ertown = ref_ertown;
  }

  public String[] getRef_ertopp() {
    return ref_ertopp;
  }
  public void setRef_ertopp(String[] ref_ertopp) {
    this.ref_ertopp = ref_ertopp;
  }

  public String[] getRef_ertitm() {
    return ref_ertitm;
  }
  public void setRef_ertitm(String[] ref_ertitm) {
    this.ref_ertitm = ref_ertitm;
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.tag_recognisable    = "";
    this.volume_ref          = "";
    this.tag_offensive       = "";
    this.tag_visible         = "";
    this.tag_repeat_offence  = "";
    this.tag_offender_info   = "";
    this.wo_est_cost         = "0";
    this.tag_offences_ref    = "";
    this.rem_workforce_ref   = "";
    this.tag                 = "";
    this.tag_known_offender  = "";
    this.refuse_pay          = "";
    this.est_duration_h      = "";
    this.est_duration_m      = "";
    this.graffiti_level_ref  = "";
    this.indemnity_response  = "";
    this.indemnity_date      = "";
    this.indemnity_day       = "";
    this.indemnity_month     = "";
    this.indemnity_year      = "";
    this.indemnity_time_h    = "";
    this.indemnity_time_m    = "";
    this.cust_responsible    = "";
    this.landlord_perm_date  = "";
    this.landlord_perm_day   = "";
    this.landlord_perm_month = "";
    this.landlord_perm_year  = "";
    this.ref_ertmat = null;
    this.ref_ertoff = null;
    this.ref_ertact = null;
    this.ref_abuse  = null;
    this.ref_ertmet = null;
    this.ref_ertequ = null;
    this.ref_ertlev = null;
    this.ref_ertsur = null;
    this.ref_ertown = null;
    this.ref_ertopp = null;
    this.ref_ertitm = null;
  }
}
