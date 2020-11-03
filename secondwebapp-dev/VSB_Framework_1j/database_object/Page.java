package com.db;

import java.util.*;

// PUBLIC METHODS:
//   void setPage(ArrayList list, int fieldCount)
//   ArrayList getRecord()
//   String getField (int field)
//   boolean next()
//
// The record pointer is set to before the first record so that a next() is required
// to move the pointer to the first record.
// The pointer will move after the last record to show that the last record has been
// found.
// The above are the same as for a ResultSet, and allow easy looping through all the
// records with a while() statement.
//
// e.g.
//
//   Page thePage = pageSet.getCurrentPage();
//   while (thePage.next()) {
//     ... Do things with the current record
//   }
//
public class Page {

  ArrayList list;
  int recordCount = 0;
  int fieldCount = 0;
  int currentRecord = 0;
  
  
  // setPage(ArrayList list, int fieldCount):
  // an ArrayList is passed from a RowSet, along with the number of
  // fields the records in the ArrayList have.
  //
  public void setPage (ArrayList recordList, int fieldCount) {
    list = recordList;
    recordCount = list.size();
    this.fieldCount = fieldCount;
  }
  
  
  // getRecord():
  // using currentRecord. Returns the record specified by the currentRecord as an ArrayList.
  //
  public ArrayList getRecord () {
    if (recordCount != 0 && currentRecord >= 1 && currentRecord <= recordCount) {
      return (ArrayList)list.get(currentRecord - 1);
    } else {
      return new ArrayList();
    }
  }
  
  
  // getField (int field):
  // using currentRecord and field indexed from 1. Returns the field specified by field
  // and currentRecord as a String.
  //
  public String getField (int field) {
    if (field > fieldCount) {
      field = fieldCount;
    } else if (field < 1) {
      field = 1;
    }
    
    if (recordCount != 0 && currentRecord >= 1 && currentRecord <= recordCount) {
      return (String)((ArrayList)list.get(currentRecord - 1)).get(field - 1);
    } else {
      return new String();
    }
  }
  
  
  // next():
  // Move to the next record by incrementing the currentRecord.
  // The current record index will go no higher than the recordCount + 1.
  // Returns true until currentRecord is after last record.
  //
  public boolean next () {
    if (recordCount != 0) { 
      if(currentRecord < recordCount) {
        currentRecord++;
        return true;
      } else if (currentRecord == recordCount) {
        currentRecord++;
        return false;
      }
    }
    
    return false;
  }
}