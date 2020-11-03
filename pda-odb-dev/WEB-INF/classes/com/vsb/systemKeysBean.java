package com.vsb;

import com.db.DbUtils;

public class systemKeysBean {
  private String contender_version = "";
  private String generate_supersites = "";
  private String default_suspect_ref = "";

  public String getContender_version() {
    return contender_version;
  }

  public void setContender_version(String contender_version) {
    this.contender_version = DbUtils.cleanString(contender_version);
  }

  public String getGenerate_supersites() {
    return generate_supersites;
  }

  public void setGenerate_supersites(String generate_supersites) {
    this.generate_supersites = DbUtils.cleanString(generate_supersites);
  }

  public String getDefault_suspect_ref() {
    return default_suspect_ref;
  }

  public void setDefault_suspect_ref(String default_suspect_ref) {
    this.default_suspect_ref = DbUtils.cleanString(default_suspect_ref);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.contender_version = "";
    this.generate_supersites = "";
    this.default_suspect_ref = "";
  }
}
