package com.vsb;

import com.db.DbUtils;

public class treesListBean extends formBean {
  private String tree_ref = "";
  private String page_number  = "";

  public String getTree_ref() {
    return tree_ref;
  }

  public void setTree_ref(String tree_ref) {
    this.tree_ref = DbUtils.cleanString(tree_ref);
  }

  public String getPage_number() {
    return page_number;
  }

  public void setPage_number(String page_number) {
    this.page_number = DbUtils.cleanString(page_number);
  }
  
  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.tree_ref = "";
    this.page_number  = "";
  }
}
