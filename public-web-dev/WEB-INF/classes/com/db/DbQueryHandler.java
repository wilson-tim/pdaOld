package com.db;

import javax.naming.*;
import javax.sql.*;
import java.sql.*;

/******************************************************************************
* Generic Database class. Used to connect/disconnect with a given database.   *
* Offers different queries and update methods, some of which return           *
* resultSets others singe values.                                             *
*                                                                            */ 
public class DbQueryHandler{

  private String     error;
  private Connection con;
  private Statement  stmt;
  private ResultSet  rs;
  private Object[]   col;

  /********************************************************
  * Constructor: Creates a single instance of             *
  * the DBConnect class.                                  *
  *                                                      */
  public DbQueryHandler(){
    error = "";
    con   = null;
    stmt  = null;
    rs    = null;
  }
  
  /********************************************************
  * Method used to connect to a specific database, these  *
  * values are hard coded and will need to be altered if  *
  * the JNDI naming context of the database changes       *
  *                                                      */ 
  public void connect(String intContext, String context) throws NamingException,
                               SQLException,
                               Exception {
    try{
      Context initialContext = new InitialContext();
      Context envContext     = (Context) initialContext.lookup( intContext );
      DataSource ds          = (DataSource) envContext.lookup( context );
      con = ds.getConnection();
    }catch(NamingException e){
      error = "NamingException: " + e;
      throw new NamingException(error);
    }catch(SQLException e){
      error = "SQLException: Could not connect to database - " + e;
      throw new SQLException(error);
    }catch(Exception e){
      error = "Exception: An unknown error occured while connecting to the database - " + e;
      throw new Exception(error);
    }
  }//End of connect

  /********************************************************
  * Method that releases all resources from the database. *
  * This method is normaly called internaly by most       *
  * methods, apart from the queries that return a         *  
  * resultSet, as the connection and statement need to    * 
  * remain open so that external objects still have       *
  * access to the data.                                   *
  *                                                      */
  public void disconnect() throws SQLException{
    try{
      if( rs != null ){
        rs.close();
      }
      if( stmt != null ){
        stmt.close();
      }
      if( con != null ){
        con.close();
      }
    }catch( SQLException e){
      error = "SQLException: Unable to close the database connection - " + e;
      throw new SQLException(error);
    }
  }//End of disconnect

  /********************************************************
  * Method that takes an update style query and executes  *
  * the query against the database. No results are        *
  * returned. Should look at making this method return a  *
  * boolean value in the future.                          *
  *                                                      */
  public void update(String query) 
    throws SQLException, Exception{
    try{
      stmt = con.createStatement();
      stmt.executeUpdate(query);
      stmt.close();
    }catch(SQLException e){
      error = "SQLException: Could not exexcute the query - " + e;
      throw new SQLException(error);
    }catch(Exception e){
      // Disconnect from database
      disconnect();
      error = "An unknown exception occured while retrieving data - " + e;
      throw new Exception(error);
    }
  }//End of update


  /********************************************************
  * Method which returns a resultSet of data given a      *
  * select style query. This method does not call the     *
  * disconnect method above, as the statment and          *
  * resultSet need to remain open while an external       *
  * object is using the resultSet. Users must remember to *
  * call the disconect method from outside, once they     *
  * have finished with the resultSet.                     *
  *                                                      */
  public void query(String query) 
    throws SQLException, Exception{
    if( stmt != null ){
      stmt.close();
    }
    if(rs != null){
      rs.close();
    }
    try{
      stmt = con.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
      rs   = stmt.executeQuery(query);
    }catch(SQLException e){
      error = "SQLException: Could not exexcute the query - " + e;
      throw new SQLException(error);
    }catch(Exception e){
      disconnect();
      error = "An unknown exception occured while retrieving data - " + e;
      throw new Exception(error);
    }
  }//End of query

  /********************************************************
  * Method used to retrieve a single integer value from   *
  * the database. This has been designed to be used for   *
  * collecting sequence numbers or count fields. The      *
  * column name needs to be passed in along with the      *
  * query string. Possibly create similar methods for     *
  * String values in the future                           *
  *                                                      */  
  public int getCount( String query ) 
    throws SQLException, Exception{
    int value = 0;
    if( stmt != null ){
      stmt.close();
    }
    if(rs != null){
      rs.close();
    }
    try{
      stmt = con.createStatement();
      rs   = stmt.executeQuery(query);
      if( rs.next() ){
        value = rs.getInt(1);
      }else{
        value = 0;
      }
      stmt.close();
    }catch(SQLException e){
      error = "SQLException: Could not exexcute the query - " + e;
      throw new SQLException(error);
    }catch(Exception e){
      // Disconnect from database
      disconnect();
      error = "An unknown exception occured while retrieving data - " + e;
      throw new Exception(error);
    }
    return value;
  }//End of query

  /**************************************************************
  * Retrieves the string in the result set located at the given *
  * row and column number. Empty string is returned if null     *
  * value is found.                                            */ 
  public String getString( int row, int column ) throws Exception{
    String result = "";
    try
    {
      if( rs.absolute( row ) )
      {
        try
        {
          result = DbUtils.cleanString( rs.getString( column ) );
        }
        catch( SQLException e )
        {
          error = "SQL Exception: Unable to get string in column " + column;
          throw new Exception( error );
        }
        try
        {
          if( rs.wasNull() ){
            result = "";
          }
        }
        catch( SQLException e)
        {
          error = "SQL Exception: Unable to discover if last request was null";
          throw new Exception( error );
        }
      }
    }
    catch( SQLException e )
    {
      error = "SQL Exception: Unable to move cursor to row number " + row;
      throw new Exception( error );
    }
    return result;
  }

  /**************************************************************
  * Retrieves the string in the result set located at the given *
  * column number. Empty string is returned if null value is    *
  * found.                                                     */ 
  public String getString( int column ) throws Exception{
    String result = "";
    try
    {
      if( rs.first() )
      {
        try
        {
          result = DbUtils.cleanString( rs.getString( column ) );
        }
        catch( SQLException e )
        {
          error = "SQL Exception: Unable to get string in column " + column;
          throw new Exception( error );
        }
        try
        {
          if( rs.wasNull() ){
            result = "";
          }
        }
        catch( SQLException e)
        {
          error = "SQL Exception: Unable to discover if last request was null";
          throw new Exception( error );
        }
      }
    }
    catch( SQLException e )
    {
      error = "SQL Exception: Unable to move cursor to first row";
      throw new Exception( error );
    }
    return result;
  }


  /***************************************************************
  * Retrieves the integer in the result set located at the given *
  * column number. 0 returned if null value is found             *
  *                                                             */
  public int getInt( int column ) throws Exception{
    int result = 0;
    try
    {
      if( rs.first() )
      {
        try
        {
          result = rs.getInt( column );
        }
        catch( SQLException e )
        {
          error = "SQL Exception: Unable to get integer in column " + column;
          throw new Exception( error );
        }
        try
        {
          if( rs.wasNull() ){
            result = 0;
          }
        }
        catch( SQLException e)
        {
          error = "SQL Exception: Unable to discover if last request was null";
          throw new Exception( error );
        }
      }
    }
    catch( SQLException e )
    {
      error = "SQL Exception: Unable to move cursor to first row";
      throw new Exception( error );
    }
    return result;
  }

  /**************************************************************
  * Retrieves the number of rows in the result set by setting   *
  * the cursor to the last row and then requesting the rows     *
  * number.                                                    */ 
  public int getCount() throws Exception{
    int count = 0;
    try
    {
      if( rs.last() )
      {
        try
        {
          count = rs.getRow();
        }
        catch( SQLException e )
        {
          error = "Unable to get the last rows number";
          throw new Exception( error );
        }
      }
    }
    catch( SQLException e )
    {
      error = "Unable to move result set cursor to the last row";
      throw new Exception( error );
    }
    return count;
  }

  /**************************************************************
  * Checks to see if there are any rows in the result set. If   *
  * there are return true, otherwise return false. The last()   *
  * method in ResultSet encapsulates this functionality.       */ 
  public boolean isEmpty() throws Exception{
    boolean isEmpty = true;
    try
    {
      isEmpty =  !rs.last();
    }
    catch( SQLException e )
    {
      error = "Unable to check if result set was empty";
      throw new Exception( error );
    }
    return isEmpty;
  }

  /**************************************************************
  * Checks to see if the last column value returned from the    *
  * result set was SQL null. This is just a wrapper for the     *
  * wasNull() method of ResultSet                              */ 
  public boolean wasNull() throws Exception{
    boolean wasNull = true;
    try
    {
      wasNull =  rs.wasNull();
    }
    catch( SQLException e )
    {
      error = "Unable to check if last result was null";
      throw new Exception( error );
    }
    return wasNull;
  }

  /**************************************************************
  * Get all the results for a column as an arraylist of strings * 
  * and return an iterator for that arraylist.                  *
  *                                                            */
  public Object[] getColumn( int column ) throws Exception{
    if( col != null ){
      col = null;
    }    
    try
    {
      rs.first();
    }
    catch( SQLException e )
    {
      error = "SQL Exception: Unable to move cursor to first row";
      throw new Exception( error );
    }
    try
    { 
      // Get the number of rows in this resultSet
      int count = getCount();
    
      // Create a new array of Strings the size of the resultSet
      col = new String[count];
      for( int i=0; i<count; i++ ){
        rs.absolute( i+1 );
        col[i] = rs.getString( column );
      }      
    }
    catch( SQLException e )
    {
      error = "SQL Exception: Unable to get column as an array of objects" + e;
      throw new Exception( error );
    }
    return col;
  }
  
}//End of class

