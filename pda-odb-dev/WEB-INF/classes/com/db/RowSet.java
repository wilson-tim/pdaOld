package com.db;

import java.util.*;
import java.sql.*;
import java.text.SimpleDateFormat;

// PUBLIC METHODS:
//   void setRowSet(ResultSet rs)
//   void addToRowSet(ResultSet rs)
//   void clear()
//   ArrayList getRecord(int record), ArrayList getRecord()
//   String getField (int record, int field), String getField (int field)
//   int getRecordCount()
//   int getFieldCount()
//   int getCurrentRecord()
//   void setCurrentRecord(int currentRecord)
//   boolean next()
//   boolean previous()
//   void first()
//   void last()
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
//   RowSet aRowSet = new RowSet();
//   aRowSet.setRowSet(... give a ResultSet ...);
//   while (aRowSet.next()) {
//     ... Do things with the current record
//   }
//
public class RowSet {

  ArrayList list = new ArrayList();
  int recordCount = 0;
  int fieldCount = 0;
  int currentRecord = 0;
  
  // setRowSet(ResultSet rs)
  // use a result set to populate a list. Each record is added
  // to the list as a seperate list. Each field is added as a string.
  //
  public void setRowSet (ResultSet rs, String db_date_fmt) throws SQLException {
    SimpleDateFormat dbFormatDate = new SimpleDateFormat(db_date_fmt);
    clear();
    ResultSetMetaData rsmd = rs.getMetaData();
    fieldCount = rsmd.getColumnCount();
    
    while (rs.next()) {
      ArrayList listRecord = new ArrayList();
      for (int num = 1; num <= fieldCount; num++) {
        // If the field is a DATE field need to make sure that the string representation
        // is in the database format.
        String stringOut = "";
        // 16/07/2010  TW  Check for types DATE (91) and TIMESTAMP (93)
        // if (rsmd.getColumnType(num) == java.sql.Types.DATE) {
        if ((rsmd.getColumnType(num) == java.sql.Types.DATE) || (rsmd.getColumnType(num) == java.sql.Types.TIMESTAMP)) {
          try {
            // 16/07/2010  TW  Returns jave.sql.Date
            // java.util.Date date = rs.getDate(num);
            java.sql.Date date = rs.getDate(num);
            stringOut = dbFormatDate.format(date);
          } catch (Exception e) {
            stringOut = "";
          }
        } else {
          stringOut = rs.getString(num);
        }
        listRecord.add(stringOut);
      }
      list.add(listRecord);
    }
    
    recordCount = list.size();
  }
  
  
  // addToRowSet(ResultSet rs):
  // use a result set to populate an already populated list. Each record is added
  // to the list as a seperate list and must ahve the same number of fields, as the
  // records already added to the list. Each field is added as a string. 
  //
  public void addToRowSet (ResultSet rs, String db_date_fmt) throws SQLException {
    SimpleDateFormat dbFormatDate = new SimpleDateFormat(db_date_fmt);
    ResultSetMetaData rsmd = rs.getMetaData();
    if (recordCount == 0 ) {
      fieldCount = rsmd.getColumnCount();
    }
    
    if (rsmd.getColumnCount() == fieldCount) {
      while (rs.next()) {
        ArrayList listRecord = new ArrayList();
        for (int num = 1; num <= fieldCount; num++) {
          // If the field is a DATE field need to make sure that the string representation
          // is in the database format.
          String stringOut = "";
          if (rsmd.getColumnType(num) == java.sql.Types.DATE) {
            try {
              java.util.Date date = rs.getDate(num);
              stringOut = dbFormatDate.format(date);
            } catch (Exception e) {
              stringOut = "";
            }
          } else {
            stringOut = rs.getString(num);
          }

          listRecord.add(stringOut);
        }
        list.add(listRecord);
      }
    
      recordCount = list.size();
    }
  }
  
  
  // clear():
  // Clear the list and reset the fieldCount, recordCount and currentRecord
  //
  public void clear () {
    list.clear();
    recordCount = 0;
    fieldCount = 0;
    currentRecord = 0;
  }
  
  
  // getRecord(int record), getRecord():
  // record indexed from 1. Returns the record specified by record as an ArrayList
  //
  public ArrayList getRecord (int record) {
    if (record > recordCount) {
      record = recordCount;
    } else if (record < 1) {
      record = 1;
    }
  
    if (recordCount != 0 ) {
      return (ArrayList)list.get(record - 1);
    } else {
      return new ArrayList();
    }
  }
  
  
  // getRecord(int record), getRecord():
  // using currentRecord. Returns the record specified by the currentRecord as an ArrayList.
  //
  public ArrayList getRecord () {
    if (recordCount != 0 && currentRecord >= 1 && currentRecord <= recordCount) {
      return (ArrayList)list.get(currentRecord - 1);
    } else {
      return new ArrayList();
    }
  }
  
  
  // getField (int record, int field), getField (int field):
  // record indexed from 1, field indexed from 1. Returns the field specified by field
  // and record as a String.
  //
  public String getField (int record, int field) {
    if (record > recordCount) {
      record = recordCount;
    } else if (record < 1) {
      record = 1;
    }
    
    if (field > fieldCount) {
      field = fieldCount;
    } else if (field < 1) {
      field = 1;
    }
    
    if (recordCount != 0 ) {
      return (String)((ArrayList)list.get(record - 1)).get(field - 1);
    } else {
      return new String();
    }
  }


  // getField (int record, int field), getField (int field):
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
  
  
  // getRecordCount():
  // Return the value of the total number of records as an integer.
  //
  public int getRecordCount () {
    return recordCount;
  }
  
  
  // getFieldCount():
  // Return the value of the total number of fields as an integer.
  //
  public int getFieldCount () {
    return fieldCount;
  }
  
  
  // getCurrentRecord():
  // indexed from 1 to recordCount. Return the index for the
  // current record as an integer.
  //
  public int getCurrentRecord () {
    return currentRecord;
  }
  
  
  // setCurrentRecord(int currentRecord):
  // indexed from 1 to recordCount. Set the index for the
  // current record.
  //
  public void setCurrentRecord (int currentRecord) {
    if (recordCount != 0) {
      if (currentRecord > (recordCount + 1)) {
        this.currentRecord = recordCount + 1;
      } else if (currentRecord < 0) {
        this.currentRecord = 0;
      } else {
        this.currentRecord = currentRecord;
      }
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
  
  
  // previous():
  // Move to the previous record by decrementing the currentRecord.
  // The current record index will go no lower than 0.
  // Returns true until currentRecord is after first record.
  //
  public boolean previous () {
    if (recordCount != 0) { 
      if(currentRecord > 1) {
        currentRecord--;
        return true;
      } else if (currentRecord == 1) {
        currentRecord--;
        return false;
      }
    }
    
    return false;
  }
  
  
  // first():
  // Move to the first record.
  //
  public void first () {
    if(recordCount != 0) {
      currentRecord = 1;
    }
  }
  
  
  // last():
  // Move to the last record.
  //
  public void last () {
    if (recordCount != 0) {
      currentRecord = recordCount;
    }
  }
}
