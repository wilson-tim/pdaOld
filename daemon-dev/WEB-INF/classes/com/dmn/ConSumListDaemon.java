package com.dmn;

import java.util.*;
import javax.sql.*;
import java.sql.*;

public class ConSumListDaemon extends Thread {
  private int sleepTime = 300000;
  private String action = "run";
  private String error = "";
  private String status = "";
  private String sqlCmd = "";
  private DataSource ds = null;
  private Connection con = null;
  private Statement stmt = null;
  private Statement pda_user_stmt = null;
  private Statement comp_stmt = null;
  private PreparedStatement pstmt = null;
  private ResultSet rs = null;
  private ResultSet pda_user_rs = null;
  private ResultSet comp_rs = null;
  private ResultSet defi_rs = null;
  private ResultSet def_cont_i_rs = null;
  private ResultSet defi_rect_rs = null;


  // Set the default time zone to where we are, as the time zone
  // returned from sco is GMT+00:00 which is fine but doesn't mentioned
  // BST. So the default timezone has to be set to "Europe/London".
  // Any objects which use the timezone (like SimpleDateFormat) will then
  // be using the correct timezone.
  private TimeZone dtz = TimeZone.getTimeZone("Europe/London");

  public void run() {
    // Set up TimeZone
    TimeZone.setDefault(dtz);

    // First time through clear the table
    status = status + "<br/>Creating initial connection ...<br/>";
    try {
      // create connection
      con = ds.getConnection();
    } catch (SQLException cnfe) {
      error = "SQLException: Could not connect to database - " + cnfe;
      status = status + error + "<br/>";
    } catch (Exception e) {
      error = "Exception: An unkown error occurred while connecting to database - " + e;
      status = status + error + "<br/>";
    }
          
    status = status + "<br/>Creating initial statement ...<br/>";
    try {
      // create statement
      stmt = con.createStatement();
    } catch (SQLException sqle) {
      error = "SQLException: Could not execute the query - " + sqle;
      status = status + error + "<br/>";
    } catch (Exception e) {
      error = "Exception: An unknown error occurred - " + e;
      status = status + error + "<br/>";
    }

    status = status + "<br/>Clearing table ...<br/>";
    try {
      // clear table
      sqlCmd = " delete from con_sum_list " +
        "  where 1 = 1;";
      stmt.executeUpdate(sqlCmd);
    } catch (SQLException sqle) {
      error = "SQLException: Could not execute the query - " + sqle;
      status = status + "&nbsp;" + error + "<br/>";
    } catch (Exception e) {
      error = "Exception: An unknown error occurred - " + e;
      status = status + "&nbsp;" + error + "<br/>";
    }
   
    status = status + "<br/>Closing initial database connection ...<br/>";
    try {
      // disconnecting
      if ( stmt != null ) {
        stmt.close();
      }
      if ( con != null ) {
        con.close();
      }
    } catch (SQLException sqle) {
      error = "SQLException: Unable to close the database connection - " + sqle;
      status = status + error + "<br/>";
    }

    // loop forever
    while (true) {
      status = status + "<br/>Current daemon time <i>" +
        (new java.util.Date()).toString() + "</i> ...<br/>";

      // only do updates if action is set to "run" ie. skip if set to "pause"
      if (action.equals("run")) {
        status = status + "<br/>Creating connection ...<br/>";
        try {
          // create connection
          con = ds.getConnection();
        } catch (SQLException cnfe) {
          error = "SQLException: Could not connect to database - " + cnfe;
          status = status + error + "<br/>";
        } catch (Exception e) {
          error = "Exception: An unkown error occurred while connecting to database - " + e;
          status = status + error + "<br/>";
        }
              
        status = status + "<br/>Creating statement ...<br/>";
        try {
          // create statement
          stmt = con.createStatement();
          pda_user_stmt = con.createStatement();
          comp_stmt = con.createStatement();
        } catch (SQLException sqle) {
          error = "SQLException: Could not execute the query - " + sqle;
          status = status + error + "<br/>";
        } catch (Exception e) {
          error = "Exception: An unknown error occurred - " + e;
          status = status + error + "<br/>";
        }
  
        status = status + "<br/>Inserting defaults ...<br/>";
        try {
          // defaults
          sqlCmd = "insert into con_sum_list (" +
            "    complaint_no," +
            "    state," +
            "    action_flag," +
            "    site_ref," +
            "    contract_ref," +
            "    dest_ref," +
            "    dest_suffix," +
            "    item_ref," +
            "    do_date," +
            "    start_time_h," +
            "    start_time_m," +
            "    wo_stat," +
            "    def_action," +
            "    user_name)" +
            "  values (" +
            "    ?,'W',?,?,?,?,'',?,?,?,?,'',?,?" +
            "  );";
          pstmt = con.prepareStatement(sqlCmd);

          // Get all the pda_users and their patrol areas
          sqlCmd = " select pda_user.user_name, " +
                   "        patr_area.area_c, " +
                   "        pda_user.limit_list_flag " +
                   " from pda_user, patr_area " +
                   " where patr_area.po_code = pda_user.po_code " +
                   " and patr_area.pa_site_flag = 'P';";
          pda_user_rs = pda_user_stmt.executeQuery(sqlCmd);
          
          // Loop over all the pda_users
          while (pda_user_rs.next()) {
            String pda_user__user_name = valueOrBlank(pda_user_rs.getString(1));
            String patr_area__area_c = valueOrBlank(pda_user_rs.getString(2));
            String pda_user__limit_list_flag = valueOrBlank(pda_user_rs.getString(3));

            // Get all the complaints for the given users patrol area
            sqlCmd = " select complaint_no, " +
                     "        dest_ref, " +
                     "        action_flag, " +
                     "        site_ref, " +
                     "        contract_ref, " +
                     "        pa_area " +
                     " from comp " +
                     " where action_flag = 'D' " +
                     " and date_closed is null " +
                     " and pa_area = '" + patr_area__area_c + "';";
            comp_rs = comp_stmt.executeQuery(sqlCmd); 

            // Loop over complaints
            while (comp_rs.next()) {
              String comp__complaint_no = valueOrBlank(comp_rs.getString("complaint_no"));
              String comp__dest_ref = valueOrBlank(comp_rs.getString("dest_ref"));
              String comp__action_flag = valueOrBlank(comp_rs.getString("action_flag"));
              String comp__site_ref = valueOrBlank(comp_rs.getString("site_ref"));
              String comp__contract_ref = valueOrBlank(comp_rs.getString("contract_ref"));
              String comp__pa_area = valueOrBlank(comp_rs.getString("pa_area"));

              // Ignore the complaint if some of the details are missing.
              // Ignore if complaint doesn't have a dest_ref
              boolean ignoreComplaint = false;
              if ( comp__dest_ref.equals("") ) {
                ignoreComplaint = true;
              }

              // Only process the complaint if not ignoring it
              if (ignoreComplaint == false) {
                // Get the defi.item_ref for the given comp.dest_ref
                sqlCmd = " select item_ref " +
                         " from defi " +
                         " where default_no = " + comp__dest_ref + ";";
                defi_rs = stmt.executeQuery(sqlCmd); 
                defi_rs.next();
                String defi__item_ref = valueOrBlank(defi_rs.getString("item_ref"));

                // get default_status
                String default_status = "";
                sqlCmd = " select default_status " +
                         "  from defh " +
                         "  where cust_def_no = " + comp__dest_ref + ";";
                rs = stmt.executeQuery(sqlCmd);
                if( rs.next() ){
                  default_status = valueOrBlank(rs.getString("default_status"));
                } else {
                  default_status = "";
                }

                // Only process default and complaint if default is still running
                if ( default_status.equals("Y") ) {
                  // Get the def_cont_i.action for the given comp.dest_ref
                  sqlCmd = " select action " +
                           " from def_cont_i " +
                           " where cust_def_no = " + comp__dest_ref + ";";
                  def_cont_i_rs = stmt.executeQuery(sqlCmd); 
                  def_cont_i_rs.next();
                  String def_cont_i__action = valueOrBlank(def_cont_i_rs.getString("action"));
                 
                  // Get the defi_rect values for the given comp.dest_ref
                  sqlCmd = " select rectify_date, rectify_time_h, rectify_time_m " +
                           " from defi_rect " +
                           " where default_no = " + comp__dest_ref + " " +
                           " and seq_no = " +
                           "     ( select max(seq_no) " +
                           "       from defi_rect " +
                           "       where default_no = " + comp__dest_ref + " " +
                           "     );";
                  defi_rect_rs = stmt.executeQuery(sqlCmd); 
                  defi_rect_rs.next();
                  java.sql.Date defi_rect__rectify_date = defi_rect_rs.getDate("rectify_date");
                  String defi_rect__rectify_time_h = valueOrBlank(defi_rect_rs.getString("rectify_time_h"));
                  String defi_rect__rectify_time_m = valueOrBlank(defi_rect_rs.getString("rectify_time_m"));
                 
                  // Add the record to a preparedStatement Batch
                  pstmt.setInt(1, Integer.parseInt(comp__complaint_no));
                  pstmt.setString(2, valueOrNull(comp__action_flag));
                  pstmt.setString(3, valueOrNull(comp__site_ref));
                  pstmt.setString(4, valueOrNull(comp__contract_ref));
                  pstmt.setString(5, valueOrNull(comp__dest_ref));
                  pstmt.setString(6, valueOrNull(defi__item_ref));
                  pstmt.setDate(7, defi_rect__rectify_date);
                  pstmt.setString(8, valueOrNull(defi_rect__rectify_time_h));
                  pstmt.setString(9, valueOrNull(defi_rect__rectify_time_m));
                  pstmt.setString(10, valueOrNull(def_cont_i__action));
                  pstmt.setString(11, valueOrNull(pda_user__user_name));
                  pstmt.addBatch();      

                } // end if default_status=Y
              } // end if ignoreCompaint=false
              
            } // end comp loop
          } // end pda_user loop

          // Process the preparedStatement Batch. 
          // This is what will do the insertions into the con_sum_list
          pstmt.executeBatch();

        } catch (SQLException sqle) {
          error = "SQLException: Could not execute the query - " + sqle;
          status = status + error + "<br/>";
        } catch (Exception e) {
          error = "Exception: An unknown error occurred - " + e;
          status = status + error + "<br/>";
        }

        status = status + "<br/>Inserting Works Orders ...<br/>";
        try {
          // works orders
          sqlCmd = "insert into con_sum_list (" +
            "    complaint_no," +
            "    state," +
            "    action_flag," +
            "    site_ref," +
            "    contract_ref," +
            "    dest_ref," +
            "    dest_suffix," +
            "    item_ref," +
            "    do_date," +
            "    start_time_h," +
            "    start_time_m," +
            "    wo_stat," +
            "    def_action," +
            "    user_name)" +
            "  values (" +
            "    ?,'W',?,?,?,?,?,'',?,'','',?,'',?" +
            "  );";
          pstmt = con.prepareStatement(sqlCmd);

          // Get all the pda_users and their patrol areas
          sqlCmd = " select pda_user.user_name, " +
                   "        patr_area.area_c, " +
                   "        pda_user.limit_list_flag " +
                   " from pda_user, patr_area " +
                   " where patr_area.po_code = pda_user.po_code " +
                   " and patr_area.pa_site_flag = 'P';";
          pda_user_rs = pda_user_stmt.executeQuery(sqlCmd);

          // Loop over all the pda_users
          while (pda_user_rs.next()) {
            String pda_user__user_name = valueOrBlank(pda_user_rs.getString(1));
            String patr_area__area_c = valueOrBlank(pda_user_rs.getString(2));
            String pda_user__limit_list_flag = valueOrBlank(pda_user_rs.getString(3));

            // Get all the complaints for the given users patrol area
            sqlCmd = " select complaint_no, " +
                     "        dest_ref, " +
                     "        dest_suffix, " +
                     "        action_flag, " +
                     "        site_ref, " +
                     "        contract_ref, " +
                     "        pa_area " +
                     " from comp " +
                     " where action_flag = 'W' " +
                     " and date_closed is null " +
                     " and pa_area = '" + patr_area__area_c + "';";
            comp_rs = comp_stmt.executeQuery(sqlCmd); 

            // Loop over complaints
            while (comp_rs.next()) {
              String comp__complaint_no = valueOrBlank(comp_rs.getString("complaint_no"));
              String comp__dest_ref = valueOrBlank(comp_rs.getString("dest_ref"));
              String comp__dest_suffix = valueOrBlank(comp_rs.getString("dest_suffix"));
              String comp__action_flag = valueOrBlank(comp_rs.getString("action_flag"));
              String comp__site_ref = valueOrBlank(comp_rs.getString("site_ref"));
              String comp__contract_ref = valueOrBlank(comp_rs.getString("contract_ref"));
              String comp__pa_area = valueOrBlank(comp_rs.getString("pa_area"));

              // Ignore the complaint if some of the details are missing.
              // Ignore if complaint doesn't have a dest_ref
              boolean ignoreComplaint = false;
              if ( comp__dest_ref.equals("") ) {
                ignoreComplaint = true;
              }

              // Only process the complaint if not ignoring it
              if (ignoreComplaint == false) {
                // Get the wo_h values for the given comp.dest_ref
                String wo_h__wo_h_stat = "";
                java.sql.Date wo_h__wo_date_due = new java.sql.Date(0);
                sqlCmd = " select wo_h_stat, wo_date_due " +
                         "  from wo_h " +
                         "  where wo_ref = " + comp__dest_ref + 
                         "  and wo_h_stat = 'I' " +
                         "  and wo_suffix = '" + comp__dest_suffix + "';";
                rs = stmt.executeQuery(sqlCmd);
                if(rs.next()) {
                  wo_h__wo_h_stat = valueOrBlank(rs.getString("wo_h_stat"));
                  wo_h__wo_date_due = rs.getDate("wo_date_due");
                } else {
                  wo_h__wo_h_stat = "";
                }

                // Only process works order and complaint if works order exists
                if ( wo_h__wo_h_stat.equals("I") ) {
                  // Add the record to a preparedStatement Batch
                  pstmt.setInt(1, Integer.parseInt(comp__complaint_no));
                  pstmt.setString(2, valueOrNull(comp__action_flag));
                  pstmt.setString(3, valueOrNull(comp__site_ref));
                  pstmt.setString(4, valueOrNull(comp__contract_ref));
                  pstmt.setString(5, valueOrNull(comp__dest_ref));
                  pstmt.setString(6, valueOrNull(comp__dest_suffix));
                  pstmt.setDate(7, wo_h__wo_date_due);
                  pstmt.setString(8, valueOrNull(wo_h__wo_h_stat));
                  pstmt.setString(9, valueOrNull(pda_user__user_name));
                  pstmt.addBatch();      

                } // end if wo_h_stat = 'I'
              } // end if ignoreCompaint=false
              
            } // end comp loop
          } // end pda_user loop

          // Process the preparedStatement Batch. 
          // This is what will do the insertions into the con_sum_list
          pstmt.executeBatch();

        } catch (SQLException sqle) {
          error = "SQLException: Could not execute the query - " + sqle;
          status = status + error + "<br/>";
        } catch (Exception e) {
          error = "Exception: An unknown error occurred - " + e;
          status = status + error + "<br/>";
        }
        
        status = status + "<br/>Updating list:<br/>";

        status = status + "<br/><i>&nbsp;Setting state A/P to D ...</i><br/>";
        try {
          // do updates
          sqlCmd = " update con_sum_list set state = 'D' " +
            "  where (state = 'A' or state = 'P');";
          stmt.executeUpdate(sqlCmd);
        } catch (SQLException sqle) {
          error = "SQLException: Could not execute the query - " + sqle;
          status = status + "&nbsp;" + error + "<br/>";
        } catch (Exception e) {
          error = "Exception: An unknown error occurred - " + e;
          status = status + "&nbsp;" + error + "<br/>";
        }

        status = status + "<br/><i>&nbsp;Setting state W to A ...</i><br/>";
        try {
          // do updates
          sqlCmd = " update con_sum_list set state = 'A' " +
            "  where state = 'W';";
          stmt.executeUpdate(sqlCmd);
        } catch (SQLException sqle) {
          error = "SQLException: Could not execute the query - " + sqle;
          status = status + "&nbsp;" + error + "<br/>";
        } catch (Exception e) {
          error = "Exception: An unknown error occurred - " + e;
          status = status + "&nbsp;" + error + "<br/>";
        }

        status = status + "<br/><i>&nbsp;Deleting status D ...</i><br/>";
        try {
          // do updates
          sqlCmd = " delete from con_sum_list " +
            "  where state = 'D';";
          stmt.executeUpdate(sqlCmd);
        } catch (SQLException sqle) {
          error = "SQLException: Could not execute the query - " + sqle;
          status = status + "&nbsp;" + error + "<br/>";
        } catch (Exception e) {
          error = "Exception: An unknown error occurred - " + e;
          status = status + "&nbsp;" + error + "<br/>";
        }
       
        status = status + "<br/>Closing database connection ...<br/>";
        try {
          // disconnecting
          if ( rs != null ) {
            rs.close();
          }
          if ( pda_user_rs != null ) {
            pda_user_rs.close();
          }
          if ( comp_rs != null ) {
            comp_rs.close();
          }
          if ( defi_rs != null ) {
            defi_rs.close();
          }
          if ( def_cont_i_rs != null ) {
            def_cont_i_rs.close();
          }
          if ( defi_rect_rs != null ) {
            defi_rect_rs.close();
          }
          if ( stmt != null ) {
            stmt.close();
          }
          if ( pda_user_stmt != null ) {
            pda_user_stmt.close();
          }
          if ( comp_stmt != null ) {
            comp_stmt.close();
          }
          if ( pstmt != null ) {
            pstmt.close();
          }
          if ( con != null ) {
            con.close();
          }
        } catch (SQLException sqle) {
          error = "SQLException: Unable to close the database connection - " + sqle;
          status = status + error + "<br/>";
        }
      }

      status = status + "<br/>Current daemon time <i>" +
        (new java.util.Date()).toString() + "</i> ...<br/>";

      // sleep for 5 minutes (300 seconds - in milliseconds)
      status = status + "<br/>Sleeping (" + Integer.toString(sleepTime) + " milliseconds) ...<br/>";
      try {
        Thread.currentThread().sleep(sleepTime);
      } catch (InterruptedException ie) {
        error = "InterruptedException: Unable to sleep - " + ie;
        status = status + error + "<br/>";
      }

      // blank status
      status = "";
    }

  }

  public void setDataSource(DataSource ds) {
    this.ds = ds;
  }

  public void setSleepTime(String sleepTime) {
    // If a sleep time value is supplied then use it, othewise 
    // default to the initialization value of 300000 (5 mins).
    if (sleepTime != null && ! sleepTime.equals("")) {
      this.sleepTime = Integer.parseInt(sleepTime);
    }
  }

  public String getStatus() {
    return this.status;
  }

  public String getAction() {
    return this.action;
  }

  public void setAction(String action) {
    // If an action value is supplied then use it, othewise 
    // default to the initialization value of "run".
    if (action != null && ! action.equals("")) {
      this.action = action;
    }
  }

  // This method returns the trimmed argument value or a blank
  // String if null.
  private String valueOrBlank (String value) {
    String returnedValue = "";
   
    if (value == null) {
      returnedValue = "";
    } else {
      returnedValue = value.trim();
    }
 
    return returnedValue;
  }

  // This method returns the trimmed argument value or a null 
  // String if null.
  private String valueOrNull (String value) {
    String returnedValue = "";
   
    if (value == null || value.trim().equals("")) {
      returnedValue = null;
    } else {
      returnedValue = value.trim();
    }
 
    return returnedValue;
  }

}
