package com.vsb;

import com.db.DbUtils;
import java.util.ArrayList;

// 21/07/2010  TW  New bean for avStatus enabling input of multiple statuses

public class avMultiStatusBean extends formBean {
  private String text = "";
  private String status_ref = "";
  private int status_count = 0;
  private ArrayList statuses = new ArrayList();
  private ArrayList texts = new ArrayList();

  public String getStatus_ref() {
    return status_ref;
  }

  public void setStatus_ref(String status_ref) {
    this.status_ref = DbUtils.cleanString(status_ref);
  }
  
  public String getText() {
    return text;
  }

  public void setText(String text) {
    this.text = DbUtils.cleanString(text);
  }

  public void setStatuses(String status_ref) {
    this.statuses.add(DbUtils.cleanString(status_ref) );
  }
  
  public String[] getStatuses() {
    return (String[])statuses.toArray();
  }

  public String getStatusByIx(int i) {
    return (String)statuses.get(i);
  }
  
  public void setTexts(String text) {
    this.texts.add(DbUtils.cleanString(text) );
  }
  
  public String[] getTexts() {
    return (String[])texts.toArray();
  }

  public String getTextByIx(int i) {
    return (String)texts.get(i);
  }
  
  public void removeStatus(int i) {
    this.statuses.remove(i);
  }
  
  public void removeText(int i) {
    this.texts.remove(i);
  }
  
  public int size() {
    return statuses.size();
  }
  
  public int getStatus_count() {
    return status_count;
  }

  public void setStatus_count(int status_count) {
    this.status_count = status_count;
  }
  
  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.text = "";
    this.status_ref = "";
    this.status_count = 0;
    this.statuses = new ArrayList();
    this.texts = new ArrayList();
  }
}
