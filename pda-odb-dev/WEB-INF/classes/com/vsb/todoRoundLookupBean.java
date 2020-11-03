package com.vsb;

import com.db.DbUtils;

public class todoRoundLookupBean extends formBean {
  private String round_c = "";

  public String getRound_c() {
    return round_c;
  }

  public void setRound_c(String round_c) {
    this.round_c = DbUtils.cleanString(round_c);
  }

  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.round_c = "";
  }
}
