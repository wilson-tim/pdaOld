package com.db;

import java.sql.ResultSet;
import java.util.*;
import javax.naming.NamingException;
import java.sql.SQLException;

/******************************************************************************
* Public class that populates an array of the street names within the         *
* database. This class is intended to be instatiated only once using the      *
* setter method, and then called upon everytime the street names are needed   *
* using the getter method.                                                    *
*                                                                            */
public class CSuggestBean{

  private String[] results;
  private String countQuery;
  private String selectQuery;
  private String columnName;
  private int    columnNumber;

  /********************************************************
  *  Getter and setter methods for countQuery String      *
  *                                                      */
  private String getCountQuery(){
    return countQuery;
  }
  public void setCountQuery( String countQuery ){
    this.countQuery = countQuery;
  }

  /********************************************************
  *  Getter and setter methods for selectQuery String     *
  *                                                      */
  private String getSelectQuery(){
    return selectQuery;
  }
  public void setSelectQuery( String selectQuery ){
    this.selectQuery = selectQuery;
  }

  /********************************************************
  *  Getter and setter methods for columnName String      *
  *                                                      */
  private String getColumnName(){
    return columnName;
  }
  public void setColumnName( String columnName ){
    this.columnName = columnName;
  }

  /********************************************************
  *  Getter and setter methods for columnNumber int       *
  *                                                      */
  private int getColumnNumber(){
    return columnNumber;
  }
  public void setColumnNumber( int columnNumber ){
    this.columnNumber = columnNumber;
  }   
  
  /********************************************************
  *  This method will return the array results            *
  *                                                      */
  public String[] getResults(){
    return results;
  }
  
  /********************************************************
  * This method will add all the result names to the      *
  * array results. It creates its own connection to the   *
  * database using the DBConnect object.                  *
  *                                                      */
  public void setResults( String intContext, String context, String db_date_fmt )
    throws SQLException, NamingException, Exception{

    // Create a new connection object
    DbQueryHandler dbHandle = new DbQueryHandler();
    
    // Connect to the database
    dbHandle.connect( intContext, context );
    
    // Run the selection query
    dbHandle.query(selectQuery, db_date_fmt);

    // Get the array of Objects from the query
    results = (String[])dbHandle.getColumn( columnNumber );    

    //Disconnect
    dbHandle.disconnect();
  }          

}//End class
