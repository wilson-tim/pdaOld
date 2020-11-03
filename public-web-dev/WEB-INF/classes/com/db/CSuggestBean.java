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
  public void setResults()
    throws SQLException, NamingException, Exception{

    // Create a new connection object
    DBConnect connection = new DBConnect();
    
    // Connect to the database
    connection.connect();

    // Create a query to discover the size of the array
    // that will be needed to store the results data
    // String query = "SELECT COUNT(*) FROM locn";
    int numberOfResults = connection.getCount( countQuery );
    // Initialise the array to the size of the data
    results = new String[numberOfResults];    
    // Set the array index to 0
    int count = 0;
    
    // Create a query to select all the result values
    // query = "SELECT location_name FROM locn";
    // Get the resultSet
    ResultSet rs = connection.query(selectQuery);
    // While the resultSet has values, populate the array
    while( rs.next() ){
      // Get the result value
      String resultValue = rs.getString(columnName);
      // Clean the string
      resultValue        = DbUtils.cleanString( resultValue );
      // Check for nulls/blanks and insert into array
      if( resultValue != null && !resultValue.equals("") ){
        results[count] = resultValue;
      }
      // Increase the array index
      count++;
    }
    
    //Disconnect
    connection.disconnect();
  }          

}//End class
