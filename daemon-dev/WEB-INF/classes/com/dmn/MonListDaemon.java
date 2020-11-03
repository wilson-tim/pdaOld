package com.dmn;

import java.text.SimpleDateFormat;
import java.util.*;
import javax.sql.*;
import java.sql.*;

public class MonListDaemon extends Thread {
  private String dbDateFmt = "yyyy-MM-dd";
  private int wakeupTime = 9;
  private String action = "run";
  private String error = "";
  private String status = "";
  private String statusW = "";
  private String sqlCmd = "";
  private DataSource ds = null;
  private Connection con = null;
  private Statement stmt = null;
  private ResultSet rs = null;

  // Set the default time zone to where we are, as the time zone
  // returned from sco is GMT+00:00 which is fine but doesn't mentioned
  // BST. So the default timezone has to be set to "Europe/London".
  // Any objects which use the timezone (like SimpleDateFormat) will then
  // be using the correct timezone.
  private TimeZone dtz = TimeZone.getTimeZone("Europe/London");
  
  private GregorianCalendar gregDate = new GregorianCalendar();
  private SimpleDateFormat formatDate = null;
  private java.util.Date date = null;


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
      sqlCmd = " delete from mon_list " +
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
      status = status + error + "<br/>";
    }

    // This is the first time through
    boolean firstTime = true;

    // Flag to make sure that the SQL is only fired once when wakeupTime is arrived at.
    boolean sqlFired = false;

    // loop forever
    while (true) {
      status = status + "<br/>Daemon wake-up hour <i>" + 
        wakeupTime + "</i> (24hr clock) ...<br/>";

      status = status + "<br/>Current daemon time <i>" + 
        (new java.util.Date()).toString() + "</i> ...<br/>";

      GregorianCalendar greg_date = new GregorianCalendar();
      int hour = greg_date.get(Calendar.HOUR_OF_DAY);

      status = status + "<br/>Daemon wake-up test <i>" + 
        (hour == wakeupTime) + "</i> ...<br/>";

      // only do updates if action is set to "run" ie. skip if set to "pause"
      // and this is the wakeup hour or is the first time through.
      if (action.equals("run") && ((hour == wakeupTime && sqlFired == false) || firstTime == true)) {
        // statusW holds all the status reports within this if statement
        // This is so that they can be kept when the conditional is not
        // firing, allowing the user to see the info of the last time it was fired.
        statusW = "";

        statusW = statusW + "<br/>Last triggered start time <i>" + 
          (new java.util.Date()).toString() + "</i> ...<br/>";

        statusW = statusW + "<br/>Creating connection ...<br/>";
        try {
          // create connection
          con = ds.getConnection();
        } catch (SQLException cnfe) {
          error = "SQLException: Could not connect to database - " + cnfe;
          statusW = statusW + error + "<br/>";
        } catch (Exception e) {
          error = "Exception: An unkown error occurred while connecting to database - " + e;
          statusW = statusW + error + "<br/>";
        }
              
        statusW = statusW + "<br/>Creating statement ...<br/>";
        try {
          // create statement
          stmt = con.createStatement();
        } catch (SQLException sqle) {
          error = "SQLException: Could not execute the query - " + sqle;
          statusW = statusW + error + "<br/>";
        } catch (Exception e) {
          error = "Exception: An unknown error occurred - " + e;
          statusW = statusW + error + "<br/>";
        }

        statusW = statusW + "<br/>Getting system keys ...<br/>";
        String adhoc_sample_fault = "";
        String monitor_source = "";
        String monitor_fault = "";
        try {
          // get adhoc_sample_fault
          sqlCmd = " select c_field " +
            "  from keys " +
            "  where service_c = 'ALL' " +
            "  and   keyname = 'ADHOC_SAMPLE_FAULT';";
          rs = stmt.executeQuery(sqlCmd);
          if( rs.next() ){
            adhoc_sample_fault = rs.getString(1).trim();
          }else{
            adhoc_sample_fault = ""; 
          }

          // get monitor_source
          sqlCmd = " select c_field " +
            "  from keys " +
            "  where service_c = 'ALL' " +
            "  and   keyname = 'MONITOR_SOURCE';";
          rs = stmt.executeQuery(sqlCmd);
          if( rs.next() ){
            monitor_source = rs.getString(1).trim();
          }else{
            monitor_source = ""; 
          }

          // get monitor_fault
          sqlCmd = " select c_field " +
            "  from keys " +
            "  where service_c = 'ALL' " +
            "  and   keyname = 'MONITOR_FAULT';";
          rs = stmt.executeQuery(sqlCmd);
          if( rs.next() ){
            String monitor_faults = rs.getString(1).trim();
            if( ! monitor_faults.equals("") ){
              StringTokenizer st = new StringTokenizer(monitor_faults, ",");
              while (st.hasMoreTokens()) {
                String nextFault = st.nextToken();
                if( ! nextFault.equals("") ) {
                  monitor_fault = monitor_fault + "'" + nextFault + "',";
                }
              }
            }
            monitor_fault = monitor_fault.substring(0, monitor_fault.length() - 1);
          }else{
            monitor_fault = ""; 
          }

          statusW = statusW + "<br/><i>&nbsp;ADHOC_SAMPLE_FAULT equals " + adhoc_sample_fault + "</i><br/>";
          statusW = statusW + "<br/><i>&nbsp;MONITOR_SOURCE equals " + monitor_source + "</i><br/>";
          statusW = statusW + "<br/><i>&nbsp;MONITOR_FAULT equals " + monitor_fault + "</i><br/>";
        } catch (SQLException sqle) {
          error = "SQLException: Could not execute the query - " + sqle;
          statusW = statusW + "&nbsp;" + error + "<br/>";
        } catch (Exception e) {
          error = "Exception: An unknown error occurred - " + e;
          statusW = statusW + "&nbsp;" + error + "<br/>";
        }
  
        statusW = statusW + "<br/>Inserting samples ...<br/>";
        try {
          // samples
          sqlCmd = "insert into mon_list (" +
            "    complaint_no," +
            "    state," +
            "    action_flag," +
            "    action," +
            "    item_ref," +
            "    site_ref," +
            "    postcode," +
            "    site_name_1," +
            "    ward_code," +
            "    do_date," +
            "    end_time_h," +
            "    end_time_m," +
            "    start_time_h," +
            "    start_time_m," +
            "    recvd_by," +
            "    comp_code," +
            "    user_name," +
            "    contract_ref," +
            "    feature_ref," +
            "    location_c)" +
            "  select comp.complaint_no," +
            "         'W'," +
            "         comp.action_flag," +
            "         ''," +
            "         comp.item_ref," +
            "         comp.site_ref," +
            "         comp.postcode," +
            "         site.site_name_1," +
            "         site.ward_code," +
            "         comp.date_entered," +
            "         ''," +
            "         ''," +
            "         ''," +
            "         ''," +
            "         comp.recvd_by," +
            "         comp.comp_code," +
            "         pda_user.user_name," +
            "         comp.contract_ref, " +
            "         comp.feature_ref, " +
            "         comp.location_c " +
            "  from  comp, patr_area, pda_user, site" +
            "  where comp.action_flag = 'P'" +
            "  and   comp.date_closed is null" +
            "  and   comp.recvd_by = '" + monitor_source + "'" +
            "  and   patr_area.po_code = pda_user.po_code" +
            "  and   patr_area.pa_site_flag = 'P'" +
            "  and   comp.pa_area = patr_area.area_c" +
            "  and   site.site_ref = comp.site_ref;";
          stmt.executeUpdate(sqlCmd);
        } catch (SQLException sqle) {
          error = "SQLException: Could not execute the query - " + sqle;
          statusW = statusW + error + "<br/>";
        } catch (Exception e) {
          error = "Exception: An unknown error occurred - " + e;
          statusW = statusW + error + "<br/>";
        }

        statusW = statusW + "<br/>Updating list:<br/>";

        statusW = statusW + "<br/><i>&nbsp;Setting state A/P to D ...</i><br/>";
        try {
          // do updates
          sqlCmd = " update mon_list set state = 'D' " +
            "  where (state = 'A' or state = 'P');";
          stmt.executeUpdate(sqlCmd);
        } catch (SQLException sqle) {
          error = "SQLException: Could not execute the query - " + sqle;
          statusW = statusW + "&nbsp;" + error + "<br/>";
        } catch (Exception e) {
          error = "Exception: An unknown error occurred - " + e;
          statusW = statusW + "&nbsp;" + error + "<br/>";
        }

        statusW = statusW + "<br/><i>&nbsp;Setting state W to A ...</i><br/>";
        try {
          // do updates
          sqlCmd = " update mon_list set state = 'A' " +
            "  where state = 'W';";
          stmt.executeUpdate(sqlCmd);
        } catch (SQLException sqle) {
          error = "SQLException: Could not execute the query - " + sqle;
          statusW = statusW + "&nbsp;" + error + "<br/>";
        } catch (Exception e) {
          error = "Exception: An unknown error occurred - " + e;
          statusW = statusW + "&nbsp;" + error + "<br/>";
        }

        statusW = statusW + "<br/><i>&nbsp;Deleting status D ...</i><br/>";
        try {
          // do updates
          sqlCmd = " delete from mon_list " +
            "  where state = 'D';";
          stmt.executeUpdate(sqlCmd);
        } catch (SQLException sqle) {
          error = "SQLException: Could not execute the query - " + sqle;
          statusW = statusW + "&nbsp;" + error + "<br/>";
        } catch (Exception e) {
          error = "Exception: An unknown error occurred - " + e;
          statusW = statusW + "&nbsp;" + error + "<br/>";
        }
       
        statusW = statusW + "<br/>Closing database connection ...<br/>";
        try {
          // disconnecting
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
          statusW = statusW + error + "<br/>";
        }

        statusW = statusW + "<br/>Last triggered end time <i>" + 
          (new java.util.Date()).toString() + "</i> ...<br/>";

        // Indicate that the sql has been fired 
        sqlFired = true;
      }

      // no longer the first time through
      firstTime = false;

      // Include the statusW info
      status = status + statusW;

      // sleep for 5mins (300 seconds - in milliseconds)
      status = status + "<br/>Sleeping (300000 milliseconds) ...<br/>";
      try {
        Thread.currentThread().sleep(300000);
      } catch (InterruptedException ie) {
        error = "InterruptedException: Unable to sleep - " + ie;
        status = status + error + "<br/>";
      }

      // The wakeupTime has passed so reset the sqlFired for the next wakeupTime
      if (hour != wakeupTime) {
        sqlFired = false;
      }

      // blank status - but not statusW as need to keep this so we can see the info on when 
      // it was last triggered.
      status = "";
    }

  }

  public void setDataSource(DataSource ds) {
    this.ds = ds;
  }

  public void setWakeupTime(String wakeupTime) {
    // If a wakeup time value is supplied then use it, othewise 
    // default to the initialization value of 9 (9am).
    if (wakeupTime != null && ! wakeupTime.equals("") && 
         Integer.parseInt(wakeupTime) >= 0 && Integer.parseInt(wakeupTime) < 24) {
      this.wakeupTime = Integer.parseInt(wakeupTime);
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

  public String getDbDateFmt() {
    return this.dbDateFmt;
  }

  public void setDbDateFmt(String dbDateFmt) {
    // If an db_date_fmt value is supplied then use it, othewise 
    // default to the initialization value of "yyyy-MM-dd".
    if (dbDateFmt != null && ! dbDateFmt.equals("")) {
      this.dbDateFmt = dbDateFmt;
    }
  }

  // This method returns an occur_day format given a date. The format
  // of the occur_day string is "DDDDDDD" where "D" is
  // either "X" or "A" - "X" indicates a day of the week, "A" indicates
  // which day of the week the supplied due_date corresponds to.
  // The string returned represents a week (Monday to Sunday).
  private String getOccur_day (GregorianCalendar due_date) {
    String occurDay = "";
    // get the day of the week as an int from 1 to 7
    // 1 = Sunday, 7 = Saturday.
    int index = due_date.get(Calendar.DAY_OF_WEEK);
    // make the day of the week run from Monday to Sunday
    index = index - 1;
    if (index == 0) {
      index = 7;
    }
    // create the occur_day string Monday to Sunday
    for (int i=1; i <= 7; i++) {
      if (i == index) {
        occurDay = occurDay + "A";
      } else {
        occurDay = occurDay + "X";
      }
    }
    
    return occurDay;
  }

}
