package com.db;

import java.util.*;
import java.sql.*;
import java.math.*;
import com.db.RowSet;
import com.db.Page;

// PRIVATE METHODS:
//  void calculatePage()
//
// PUBLIC METHODS:
//   void setPageSet(ResultSet rs)
//   void addToPageSet(ResultSet rs)
//   void clear()
//   Page getCurrentPage()
//   void setRecordsOnPage(int recs):
//   int getRecordCount()
//   int getMinRecordInPage()
//   int getMaxRecordInPage()
//   int getPageCount()
//   int getCurrentPageNum()
//   void next()
//   void previous()
//   void first()
//   void last()
//
public class PageSet {

  RowSet records = new RowSet();
  int pageCount = 0;
  int minRecordInPage = 0;
  int maxRecordInPage = 0;
  int currentPage = 1;
  int recordsOnPage = 10;
  
  
  // calculatePage():
  // Resetting the maxRecordInPage, minRecordInPagecurrentPage, and pageCount variables. 
  // The page calculation is done around the currentPage unless the recordCount is 0, then
  // recordsOnPage variable is just set to the value requested.
  //
  private void calculatePage() {
    if(records.getRecordCount() != 0) {
      pageCount = (int)Math.ceil((double)records.getRecordCount()/recordsOnPage);
      maxRecordInPage = currentPage * recordsOnPage;
      minRecordInPage = (maxRecordInPage - recordsOnPage) + 1;
      if (maxRecordInPage > records.getRecordCount()) {
        maxRecordInPage = records.getRecordCount();
      }
      
    }
  }
  
  
  // setPageSet(ResultSet rs):
  // use a result set to populate a RowSet.
  //
  public void setPageSet (ResultSet rs) throws SQLException {
    clear();
    records.setRowSet(rs);
    calculatePage();
  }
  
  
  // addToPageSet(ResultSet rs):
  // use a result set to populate an already populated RowSet.
  //
  public void addToPageSet (ResultSet rs) throws SQLException {
    records.addToRowSet(rs);
    calculatePage();
  }
  
  
  // clear():
  // Clear the RowSet and reset the recordCount and currentPage
  //
  public void clear () {
    records.clear();
    pageCount = 0;
    minRecordInPage = 0;
    maxRecordInPage = 0;
    currentPage = 1;
  }
  
  
  // getCurrentPage():
  // This will return a Page object containing the records of the current page.
  //
  public Page getCurrentPage () {
    Page aPage = new Page();
    if (records.getRecordCount() != 0) {
      ArrayList list = new ArrayList();
      for (int num = minRecordInPage; num <= maxRecordInPage; num++) {
        list.add(records.getRecord(num));
      }
      aPage.setPage(list, records.getFieldCount());
    }
    
    return aPage;
  }
  
  
  // setRecordsOnPage(int recs):
  // set the number of records included in each page.
  // Default is 10.
  //
  public void setRecordsOnPage (int recs) {
      recordsOnPage = recs;
      calculatePage();
  }
  
  
  // getRecordCount():
  // Return the value of the total number of records as an integer.
  //
  public int getRecordCount () {
    return records.getRecordCount();
  }
  

  // getMinRecordInPage():
  // Return the value of the lowest record number in the current page as an integer.
  //
  public int getMinRecordInPage () {
    return minRecordInPage;
  }


  // getMaxRecordInPage():
  // Return the value of the highest record number in the current page as an integer.
  //
  public int getMaxRecordInPage () {
    return maxRecordInPage;
  }


  // getPageCount():
  // Return the value of the total number of pages as an integer.
  //
  public int getPageCount () {
    return pageCount;
  }


  // setCurrentPageNum():
  // Return the value of the current page number as an integer.
  //
  public int getCurrentPageNum () {
    return currentPage;
  }
  
  
  // setCurrentPageNum( int page_number ):
  // Return the value of the current page number as an integer.
  //
  public void setCurrentPageNum ( int page_number ) {
    // page_count is too small, set it to 1
    if((page_number <= 0) && (records.getRecordCount() != 0)) {
      currentPage = 1;
    // page_count is too big, set it to max i.e pageCount
    } else if((page_number > pageCount) && (records.getRecordCount() != 0)) {
      currentPage = pageCount;
    // if it is within the page limits, set page to page_number
    } else if((page_number <= pageCount) && (page_number > 0) && (records.getRecordCount() != 0)) {
      currentPage = page_number;
    }
    calculatePage();
  }
  
  
  // next():
  // Move to the next page by incrementing the currentPage.
  // The current Page index will go no higher than the pageCount.
  //
  public void next () {
    if ((currentPage < pageCount) && (records.getRecordCount() != 0)) {
      currentPage++;
      calculatePage();
    }
  }
  
  
  // previous():
  // Move to the previous page by decrementing the currentPage.
  // The current page index will go no lower than 1.
  //
  public void previous () {
    if (currentPage > 1) {
      currentPage--;
      calculatePage();
    }
  }
  
  
  // first():
  // Move to the first Page.
  //
  public void first () {
    currentPage = 1;
    calculatePage();
  }
  
  
  // last():
  // Move to the last Page.
  //
  public void last () {
    if (records.getRecordCount() != 0) {
      currentPage = pageCount;
      calculatePage();
    }
  }
}
