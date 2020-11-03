package com.db;

import javax.naming.*;
import javax.sql.*;
import java.sql.*;

/******************************************************************************
* Generic Database class. Used to connect/disconnect with a given database.   *
* Offers different queries and update methods, some of which return           *
* resultSets others singe values.                                             *
*                                                                            */ 
public class DBConnect{

  private String     error;
  private Connection con;
  private Statement  stmt;
  private ResultSet  rs;

  /********************************************************
  * Constructor: Creates a single instance of             *
  * the DBConnect class.                                  *
  *                                                      */
  public DBConnect(){
    error = "";
    con   = null;
    stmt  = null;
    rs   = null;
  }
  
  /********************************************************
  * Method used to connect to a specific database, these  *
  * values are hard coded and will need to be altered if  *
  * the JNDI naming context of the database changes       *
  *                                                      */ 
  public void connect() throws NamingException,
                               SQLException,
                               Exception {
    try{
      Context initialContext = new InitialContext();
      Context envContext     = (Context) initialContext.lookup("java:comp/env");
      DataSource ds          = (DataSource) envContext.lookup("jdbc/pda");
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
  public ResultSet query(String query) 
    throws SQLException, Exception{
    if( stmt != null ){
      stmt.close();
    }
    if(rs != null){
      rs.close();
    }
    try{
      stmt = con.createStatement();
      rs   = stmt.executeQuery(query);
    }catch(SQLException e){
      error = "SQLException: Could not exexcute the query - " + e;
      throw new SQLException(error);
    }catch(Exception e){
      disconnect();
      error = "An unknown exception occured while retrieving data - " + e;
      throw new Exception(error);
    }
    return rs;
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
  
}//End of class
