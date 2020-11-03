package com.db;

import javax.naming.*;
import javax.sql.*;
import java.sql.*;
import com.db.RowSet;

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
  private RowSet     rows;
  private Object[]   col;
  private boolean    wasLastIntNull;

  /********************************************************
  * Constructor: Creates a single instance of             *
  * the DBConnect class.                                  *
  *                                                      */
  public DbQueryHandler(){
    error = "";
    con   = null;
    stmt  = null;
    rs    = null;
    rows  = null;
    wasLastIntNull = false;
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
      if( rows != null ){
        rows = null;
      }
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
  public void query(String query, String db_date_fmt) 
    throws SQLException, Exception{
    if( stmt != null ){
      stmt.close();
    }
    if(rs != null){
      rs.close();
    }
    if(rows != null){
      rows = null;
    }
    try{
      stmt = con.createStatement();
      rs   = stmt.executeQuery(query);
      rows = new RowSet();
      rows.setRowSet(rs, db_date_fmt);
      // set the current record to 1, as by default it is set to 0 for the use of the
      // next() method, which we don't use here
      rows.setCurrentRecord(1);
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
    if(rows != null){
      rows = null;
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
      result = DbUtils.cleanString( rows.getField( row, column ) );
    }
    catch( Exception e )
    {
      error = "Exception: Unable to get string in row " + row + " and column " + column;
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
      result = DbUtils.cleanString( rows.getField( column ) );
    }
    catch( Exception e )
    {
      error = "Exception: Unable to get string in column " + column;
      throw new Exception( error );
    }
    return result;
  }


  /***************************************************************
  * Retrieves the integer in the result set located at the given *
  * column number. 0 returned if null value is found             *
  *                                                             */
  public int getInt( int column ) throws Exception{
    int resultInt = 0;
    String resultString = "";
    try
    {
      resultString = DbUtils.cleanString( rows.getField( column ) );
      if (resultString.trim().equals("") ){
        wasLastIntNull = true;
        resultInt = 0;
      } else {
        wasLastIntNull = false;
        resultInt = Integer.parseInt(resultString);
      } 
    }
    catch( Exception e )
    {
      error = "Exception: Unable to get int in column " + column;
      throw new Exception( error );
    }

    return resultInt;
  }


  /**************************************************************
  * Retrieves the number of rows in the result set by setting   *
  * the cursor to the last row and then requesting the rows     *
  * number.                                                    */ 
  public int getCount() throws Exception{
    return rows.getRecordCount();
  }

  /**************************************************************
  * Checks to see if there are any rows in the result set. If   *
  * there are return true, otherwise return false. The last()   *
  * method in ResultSet encapsulates this functionality.       */ 
  public boolean isEmpty() throws Exception{
    boolean isEmpty = true;
 
    if ( rows == null || rows.getRecordCount() == 0 ) {
      isEmpty = true;
    } else {
      isEmpty = false;
    }

    return isEmpty;
  }

  /**************************************************************
  * Checks to see if the last column value returned from the    *
  * result set was SQL null. This is just a wrapper for the     *
  * wasNull() method of ResultSet                              */ 
  public boolean wasIntNull() throws Exception{
    return wasLastIntNull;
  }

  /**************************************************************
  * Get all the results for a column as an arraylist of strings * 
  * and return an iterator for that arraylist.                  *
  *                                                            */
  public Object[] getColumn( int column ) throws Exception{
    if( col != null ){
      col = null;
    }    
    // Get the number of rows in this resultSet
    int count = getCount();
  
    // Create a new array of Strings the size of the resultSet
    col = new String[count];
    for( int i=0; i<count; i++ ){
      col[i] = rows.getField( i+1, column);
    }
      
    return col;
  }
  
}//End of class

