package com.db;

import java.util.*;
import java.math.*;

// PRIVATE METHODS:
//  void calculatePage()
//
// PUBLIC METHODS:
//   void clear()
//   void setRecordsOnPage(int recs):
//   int getRecordCount()
//   void setRecordCount(int record_count)
//   int getMinRecordInPage()
//   int getMaxRecordInPage()
//   int getPageCount()
//   int getCurrentPageNum()
//   void setCurrentPageNum (int page_number)
//   void next()
//   void previous()
//   void first()
//   void last()
//
public class PagingBean {

  int pageCount = 0;
  int minRecordInPage = 0;
  int maxRecordInPage = 0;
  int currentPage = 1;
  int recordsOnPage = 10;
  int recordCount = 0;


  // calculatePage():
  // Resetting the maxRecordInPage, minRecordInPagecurrentPage, and pageCount variables. 
  // The page calculation is done around the currentPage unless the recordCount is 0, then
  // recordsOnPage variable is just set to the value requested.
  //
  private void calculatePage() {
    if(recordCount != 0) {
      pageCount = (int)Math.ceil((double)recordCount/recordsOnPage);
      maxRecordInPage = currentPage * recordsOnPage;
      minRecordInPage = (maxRecordInPage - recordsOnPage) + 1;
      if (maxRecordInPage > recordCount) {
        maxRecordInPage = recordCount;
      }
    }
  }

  
  // clear():
  // Clear the RowSet and reset the recordCount and currentPage
  //
  public void clear () {
    pageCount = 0;
    minRecordInPage = 0;
    maxRecordInPage = 0;
    currentPage = 1;
    recordCount = 0;
  }
  
  
  // setRecordsOnPage(int recs):
  // Set the number of records included in each page.
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
    return recordCount;
  }
  

  // setRecordCount(int record_count):
  // Set the valule of the total number of records.
  //
  public void setRecordCount (int record_count) {
      recordCount = record_count;
      calculatePage();
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


  // getCurrentPageNum():
  // Return the value of the current page number as an integer.
  //
  public int getCurrentPageNum () {
    return currentPage;
  }
  
  
  // setCurrentPageNum(int page_number):
  // Set the value of the current page number.
  //
  public void setCurrentPageNum ( int page_number ) {
    // page_count is too small, set it to 1
    if((page_number <= 0) && (recordCount != 0)) {
      currentPage = 1;
    // page_count is too big, set it to max i.e pageCount
    } else if((page_number > pageCount) && (recordCount != 0)) {
      currentPage = pageCount;
    // if it is within the page limits, set page to page_number
    } else if((page_number <= pageCount) && (page_number > 0) && (recordCount != 0)) {
      currentPage = page_number;
    }
    calculatePage();
  }
  
  
  // next():
  // Move to the next page by incrementing the currentPage.
  // The current Page index will go no higher than the pageCount.
  //
  public void next () {
    if ((currentPage < pageCount) && (recordCount != 0)) {
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
    if (recordCount != 0) {
      currentPage = pageCount;
      calculatePage();
    }
  }
}
