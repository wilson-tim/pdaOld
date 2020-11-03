package com.dmn;

import java.util.*;
import javax.sql.*;
import java.sql.*;

public class EnfListDaemon extends Thread {
  private int sleepTime = 300000;
  private String action = "run";
  private String error = "";
  private String status = "";
  private String sqlCmd = "";
  private DataSource ds = null;
  private Connection con = null;
  private Statement stmt = null;

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
      sqlCmd = " delete from enf_list " +
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
        } catch (SQLException sqle) {
          error = "SQLException: Could not execute the query - " + sqle;
          status = status + error + "<br/>";
        } catch (Exception e) {
          error = "Exception: An unknown error occurred - " + e;
          status = status + error + "<br/>";
        }
  
        status = status + "<br/>Inserting Enforcements With Due Dates...<br/>";
        try {
          // Enforcements with due dates
          sqlCmd = "  INSERT INTO enf_list " +
            "  ( " +
            "    complaint_no, " +
            "    state, " +
            "    user_name, " +
            "    action_flag, " +
            "    item_ref, " +
            "    contract_ref, " +
            "    feature_ref, " +
            "    location_c, " +
            "    site_ref, " +
            "    site_name_1, " +
            "    postcode, " +
            "    comp_code, " +            
            "    recvd_by, " +            
            "    enf_officer, " +
            "    law_ref, " +
            "    offence_ref, " +
            "    action_seq, " +
            "    action_ref, " +
            "    action_date, " +
            "    aut_officer, " +
            "    enf_status, " +
            "    do_date  " +
            "  ) " +
            "    SELECT comp.complaint_no, " +
            "           'W', " +
            "           pda_user.user_name, " +
            "           comp.action_flag, " +
            "           comp.item_ref, " +
            "           comp.contract_ref, " +
            "           comp.feature_ref, " +
            "           comp.location_c, " +
            "           comp.site_ref, " +
            "           site.site_name_1, " +
            "           comp.postcode, " +
            "           comp.comp_code, " +
            "           comp.recvd_by, " +
            "           comp_enf.enf_officer, " +
            "           comp_enf.law_ref, " +
            "           comp_enf.offence_ref, " +
            "           comp_enf.action_seq, " +
            "           enf_action.action_ref, " +
            "           enf_action.action_date, " +
            "           enf_action.aut_officer, " +
            "           enf_action.enf_status, " +
            "           enf_action.due_date " +
            "      FROM comp, comp_enf, enf_action, site, pda_user, patr_area " +
            "     WHERE comp.action_flag    = 'N' " +
            "       AND comp.date_closed is null" +
            "       AND comp.pa_area = patr_area.area_c " +
            "       AND patr_area.po_code = pda_user.po_code " +
            "       AND patr_area.pa_site_flag = 'P' " +
            "       AND site.site_ref = comp.site_ref " +
            "       AND enf_action.action_seq = comp_enf.action_seq " +
            "       AND comp_enf.complaint_no = comp.complaint_no;";
          stmt.executeUpdate(sqlCmd);
        } catch (SQLException sqle) {
          error = "SQLException: Could not execute the query - " + sqle;
          status = status + error + "<br/>";
        } catch (Exception e) {
          error = "Exception: An unknown error occurred - " + e;
          status = status + error + "<br/>";
        }
        
        status = status + "<br/>Inserting Enforcements Without Due Dates...<br/>";
        try {
          // Enforcements without due dates
          sqlCmd = "  INSERT INTO enf_list " +
            "  ( " +
            "    complaint_no, " +
            "    state, " +
            "    user_name, " +
            "    action_flag, " +
            "    item_ref, " +
            "    contract_ref, " +
            "    feature_ref, " +
            "    location_c, " +
            "    site_ref, " +
            "    site_name_1, " +
            "    postcode, " +
            "    comp_code, " +            
            "    recvd_by, " +            
            "    enf_officer, " +
            "    law_ref, " +
            "    offence_ref, " +
            "    action_seq, " +
            "    action_ref, " +
            "    action_date, " +
            "    aut_officer, " +
            "    enf_status, " +
            "    do_date  " +
            "  ) " +
            "    SELECT comp.complaint_no, " +
            "           'W', " +
            "           pda_user.user_name, " +
            "           comp.action_flag, " +
            "           comp.item_ref, " +
            "           comp.contract_ref, " +
            "           comp.feature_ref, " +
            "           comp.location_c, " +
            "           comp.site_ref, " +
            "           site.site_name_1, " +
            "           comp.postcode, " +
            "           comp.comp_code, " +
            "           comp.recvd_by, " +
            "           comp_enf.enf_officer, " +
            "           comp_enf.law_ref, " +
            "           comp_enf.offence_ref, " +
            "           comp_enf.action_seq, " +
            "           '', " +
            "           comp.date_entered, " +
            "           '', " +
            "           '', " +
            "           comp.date_entered " +
            "      FROM comp, comp_enf, site, pda_user, patr_area " +
            "     WHERE comp.action_flag    = 'N' " +
            "       AND comp.date_closed is null" +
            "       AND comp.pa_area = patr_area.area_c " +
            "       AND patr_area.po_code = pda_user.po_code " +
            "       AND patr_area.pa_site_flag = 'P' " +
            "       AND site.site_ref = comp.site_ref " +
            "       AND comp_enf.complaint_no = comp.complaint_no" +
            "       AND comp_enf.action_seq is null;";
          stmt.executeUpdate(sqlCmd);
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
          sqlCmd = " update enf_list set state = 'D' " +
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
          sqlCmd = " update enf_list set state = 'A' " +
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
          sqlCmd = " delete from enf_list " +
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
}
