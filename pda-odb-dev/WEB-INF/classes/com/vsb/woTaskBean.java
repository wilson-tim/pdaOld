package com.vsb;

import com.db.DbUtils;
import java.util.ArrayList;
import java.util.Iterator;

public class woTaskBean extends formBean {
  private ArrayList woi_task_refs = new ArrayList();

  public void setWoi_task_refs(String[] woi_task_refs) {
    for( int i=0; i<woi_task_refs.length; i++ ) {
      this.woi_task_refs.add( i, DbUtils.cleanString(woi_task_refs[i]) );
    }
  }

  public String[] getWoi_task_refs() {
    return (String[])woi_task_refs.toArray();
  }

  public String getWoi_task_ref( int i ) {
    return (String)woi_task_refs.get(i);
  }

  public int size() {
    return woi_task_refs.size();
  }
  
  public boolean contains( String woi_task_ref ) {
    return woi_task_refs.contains( woi_task_ref );
  }

  public Iterator iterator() {
    return woi_task_refs.iterator();
  }
  
  public String getAll() {
    return "";
  }

  public void setAll(String all) {
    this.woi_task_refs = new ArrayList();
  }
}
