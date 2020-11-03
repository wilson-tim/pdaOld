package com.db;

import javax.naming.*;
import javax.sql.*;
import java.sql.*;

public class DbSQL {

  String error;
  Connection con = null;
  ResultSet rs = null;
  Statement stmt = null;
  
  //
  // An example dbContext and dbDataSource would be:
  // "java:comp/env" and "jdbc/pda"
  //
  public void connect(String dbContext, String dbDataSource) throws NamingException,
                                                                    SQLException,
                                                                    Exception {
    try {
      Context initCtx = new InitialContext();
      Context envCtx = (Context) initCtx.lookup(dbContext);
      DataSource ds = (DataSource) envCtx.lookup(dbDataSource);
      con = ds.getConnection();
    } catch (NamingException cnfe) {
      error = "NamingException: " + cnfe;
      throw new NamingException(error);
    } catch (SQLException cnfe) {
      error = "SQLException: Could not connect to database - " + cnfe;
      throw new SQLException(error);
    } catch (Exception e) {
      error = "Exception: An unkown error occurred while connecting to database - " + e;
      throw new Exception(error);
    }
  }
  
  
  public void disconnect() throws SQLException {
    try {
      if ( rs != null ) {
        rs.close();
      }
      if ( stmt != null ) {
        stmt.close();
      }
      if ( con != null ) {
        con.close();
      }
    } catch (SQLException sqle) {
      error = "SQLException: Unable to close the database connection - " + sqle;
      throw new SQLException(error);
    }
  }
  
  
  public ResultSet query (String dbQuery) throws SQLException, Exception {
    // Run query
    try  {
      stmt = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
      rs = stmt.executeQuery(dbQuery);
    } catch (SQLException sqle) {
      // Disconnect from the database
      disconnect();
      error = "SQLException: Could not execute the query - " + sqle;
      throw new SQLException(error);
    } catch (Exception e) {
      // Disconnect from the database
      disconnect();
      error = "Exception: An unknown error occurred while retrieving data - " + e;
      throw new Exception(error);			 
    }
    
    return rs;
  }
  
}
 
