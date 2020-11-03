package com.dmn;

import java.text.SimpleDateFormat;
import java.util.*;
import javax.sql.*;
import java.sql.*;

public class InspListDaemon extends Thread {
  private String dbDateFmt = "yyyy-MM-dd";
  private int sleepTime = 300000;
  private String insertDefaults = "N";
  private String insertInspections = "N";
  private String insertSamples = "N";
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
  private ResultSet site_rs = null;
  private ResultSet def_cont_i_rs = null;
  private ResultSet defi_rect_rs = null;

  // Set the default time zone to where we are, as the time zone
  // returned from sco is GMT+00:00 which is fine but doesn't mentioned
  // BST. So the default timezone has to be set to "Europe/London".
  // Any objects which use the timezone (like SimpleDateFormat) will then
  // be using the correct timezone.
  private TimeZone dtz = TimeZone.getTimeZone("Europe/London");
  
  private GregorianCalendar gregDate = new GregorianCalendar();
  private SimpleDateFormat formatDate = new SimpleDateFormat(dbDateFmt);
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
      sqlCmd = " delete from insp_list " +
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

        status = status + "<br/>Getting system keys ...<br/>";
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

          status = status + "<br/><i>&nbsp;ADHOC_SAMPLE_FAULT equals " + adhoc_sample_fault + "</i><br/>";
          status = status + "<br/><i>&nbsp;MONITOR_SOURCE equals " + monitor_source + "</i><br/>";
          status = status + "<br/><i>&nbsp;MONITOR_FAULT equals " + monitor_fault + "</i><br/>";
        } catch (SQLException sqle) {
          error = "SQLException: Could not execute the query - " + sqle;
          status = status + "&nbsp;" + error + "<br/>";
        } catch (Exception e) {
          error = "Exception: An unknown error occurred - " + e;
          status = status + "&nbsp;" + error + "<br/>";
        }
  
        status = status + "<br/><i>&nbsp;Insert Defaults equals " + insertDefaults + "</i><br/>";
        status = status + "<br/><i>&nbsp;Insert Inspections equals " + insertInspections + "</i><br/>";
        status = status + "<br/><i>&nbsp;Insert Samples equals " + insertSamples + "</i><br/>";

        // Insert defaults, inspections, works orders, and samples if allowed to. 
        if (insertDefaults.equals("Y") || insertInspections.equals("Y") || insertSamples.equals("Y") ) {
          status = status + "<br/>Inserting defaults, inspections, works orders and samples ...<br/>";
          try {
            // Get all the complaints
            sqlCmd = "";
            if (insertDefaults.equals("Y")) {
              sqlCmd = sqlCmd + " select complaint_no, " +
                       "        dest_ref, " +
                       "        action_flag, " +
                       "        item_ref, " +
                       "        site_ref, " +
                       "        postcode, " +
                       "        recvd_by, " +
                       "        comp_code, " +
                       "        contract_ref, " +
                       "        feature_ref, " +
                       "        location_c, " +
                       "        date_entered, " +
                       "        ent_time_h, " +
                       "        ent_time_m, " +
                       "        pa_area " +
                       " from comp " +
                       " where date_closed is null " +
                       " and pa_area is not null " +
                       " and pa_area <> '' " +
                       " and (action_flag = 'D')";
            }
            if (insertInspections.equals("Y")) {
              if ( !sqlCmd.equals("") ); {
                sqlCmd = sqlCmd + " UNION ";
              }
              sqlCmd = sqlCmd + " select complaint_no, " +
                       "        dest_ref, " +
                       "        action_flag, " +
                       "        item_ref, " +
                       "        site_ref, " +
                       "        postcode, " +
                       "        recvd_by, " +
                       "        comp_code, " +
                       "        contract_ref, " +
                       "        feature_ref, " +
                       "        location_c, " +
                       "        date_entered, " +
                       "        ent_time_h, " +
                       "        ent_time_m, " +
                       "        pa_area " +
                       " from comp " +
                       " where date_closed is null " +
                       " and pa_area is not null " +
                       " and pa_area <> '' " +
                       " and ( " +
                       "   (action_flag = 'I' " +
                       "    and comp_code not in (" + monitor_fault + ")" +
                       "    and comp_code <> '" + adhoc_sample_fault + "')" +
                       " )";
            }
            if (insertSamples.equals("Y")) {
              if ( !sqlCmd.equals("") ); {
                sqlCmd = sqlCmd + " UNION ";
              }
              sqlCmd = sqlCmd + " select complaint_no, " +
                       "        dest_ref, " +
                       "        action_flag, " +
                       "        item_ref, " +
                       "        site_ref, " +
                       "        postcode, " +
                       "        recvd_by, " +
                       "        comp_code, " +
                       "        contract_ref, " +
                       "        feature_ref, " +
                       "        location_c, " +
                       "        date_entered, " +
                       "        ent_time_h, " +
                       "        ent_time_m, " +
                       "        pa_area " +
                       " from comp " +
                       " where date_closed is null " +
                       " and pa_area is not null " +
                       " and pa_area <> '' " +
                       " and ( " +
                       "   (action_flag = 'P' " +
                       "    and comp_code not in (" + monitor_fault + "))" +
                       " )";
            }
            if ( !sqlCmd.equals("") ); {
              sqlCmd = sqlCmd + ";";
            }
            comp_rs = comp_stmt.executeQuery(sqlCmd); 

            // Loop over complaints
            while (comp_rs != null && comp_rs.next()) {
              String comp__complaint_no = valueOrBlank(comp_rs.getString("complaint_no"));
              String comp__dest_ref = valueOrBlank(comp_rs.getString("dest_ref"));
              String comp__action_flag = valueOrBlank(comp_rs.getString("action_flag"));
              String comp__item_ref = valueOrBlank(comp_rs.getString("item_ref"));
              String comp__site_ref = valueOrBlank(comp_rs.getString("site_ref"));
              String comp__postcode = valueOrBlank(comp_rs.getString("postcode"));
              String comp__recvd_by = valueOrBlank(comp_rs.getString("recvd_by"));
              String comp__comp_code = valueOrBlank(comp_rs.getString("comp_code"));
              String comp__contract_ref = valueOrBlank(comp_rs.getString("contract_ref"));
              String comp__feature_ref = valueOrBlank(comp_rs.getString("feature_ref"));
              String comp__location_c = valueOrBlank(comp_rs.getString("location_c"));
              java.sql.Date comp__date_entered = comp_rs.getDate("date_entered");
              String comp__ent_time_h = valueOrBlank(comp_rs.getString("ent_time_h"));
              String comp__ent_time_m = valueOrBlank(comp_rs.getString("ent_time_m"));
              String comp__pa_area = valueOrBlank(comp_rs.getString("pa_area"));

              // Prepared statement
              sqlCmd = "insert into insp_list (" +
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
                "    feature_ref, " +
                "    location_c, " +
                "    pa_area)" +
                "  values (" +
                "    ?,'W',?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?" +
                "  );";
              pstmt = con.prepareStatement(sqlCmd);

              // Get all the pda_users and their patrol areas
              sqlCmd = " select pda_user.user_name, " +
                       "        pda_user.limit_list_flag " +
                       " from pda_user, patr_area " +
                       " where patr_area.po_code = pda_user.po_code " +
                       " and patr_area.pa_site_flag = 'P'" +
                       " and patr_area.area_c = '" + comp__pa_area + "';";
              pda_user_rs = pda_user_stmt.executeQuery(sqlCmd);
              
              // Loop over all the pda_users
              while (pda_user_rs != null && pda_user_rs.next()) {
                String pda_user__user_name = valueOrBlank(pda_user_rs.getString(1));
                String pda_user__limit_list_flag = valueOrBlank(pda_user_rs.getString(2));
    
                // If this is a default or an inspection then use the limit list
                // Get the given users limit list and check if the current comp_code is in it
                boolean ignoreComplaint = false;
                if (comp__action_flag.equals("D") || comp__action_flag.equals("I")  ) {
                  boolean inLimitList = false;
                  sqlCmd = " select comp_code " +
                           " from pda_limit_list " +
                           " where user_name = '" + pda_user__user_name + "' " +
                           " and item_ref = '" + comp__item_ref + "';";
                  rs = stmt.executeQuery(sqlCmd);
                  if (rs != null) {
                    while (rs.next()) {
                      if ( comp__comp_code.equals(valueOrBlank(rs.getString("comp_code"))) ) {
                        inLimitList = true;
                      }
                    }
                  } else {
                    inLimitList = false;
                  }
     
                  // Check what kind of pda_limit_list we are using and limit the complaints accordingly
                  if (pda_user__limit_list_flag == null || pda_user__limit_list_flag.equals("")) {
                    ignoreComplaint = false;
                  } else if (pda_user__limit_list_flag.equals("Y")) {
                    // Ignore complaint if NOT IN the limit_list
                    if (inLimitList == true) {
                      ignoreComplaint = false;
                    } else {
                      ignoreComplaint = true;
                    }
                  } else if (pda_user__limit_list_flag.equals("N")) {
                    // Ignore complaint if IN the limit_list
                    if (inLimitList == true) {
                      ignoreComplaint = true;
                    } else {
                      ignoreComplaint = false;
                    }
                  } else if (pda_user__limit_list_flag.equals("Z")) {
                    ignoreComplaint = false;
                  } else {
                    ignoreComplaint = false;
                  }
    
                  // Ignore the complaint if some of the details are missing.
                  // Ignore if complaint if it is a default and doesn't have a dest_ref
                  // 16/08/2010  TW  Bug fix comparing code with InspListDaemon version 1n
                  // if ( comp__dest_ref.equals("") ) {
                  if ( comp__action_flag.equals("D") && comp__dest_ref.equals("") ) {
                    ignoreComplaint = true;
                  }
                } // end if comp_action_flag "D" or "I"

                // Only process the complaint if not ignoring it
                if (ignoreComplaint == false) {

                  // If this is a default do the default specific stuff
                  String def_cont_i__action = "";
                  java.sql.Date defi_rect__rectify_date = null;
                  String defi_rect__rectify_time_h = "";
                  String defi_rect__rectify_time_m = "";
                  if (comp__action_flag.equals("D")) {
                    ignoreComplaint = true;
                    // get default_status
                    String default_status = "";
                    sqlCmd = " select default_status " +
                             "  from defh " +
                             "  where cust_def_no = " + comp__dest_ref + ";";
                    rs = stmt.executeQuery(sqlCmd);
                    if( rs != null && rs.next() ){
                      default_status = valueOrBlank(rs.getString("default_status"));
                    } else {
                      default_status = "";
                    }

                    // Only process default and complaint if default is still running
                    if ( default_status.equals("Y") ) {
                      ignoreComplaint = false;
                      // Get the def_cont_i.action for the given comp.dest_ref
                      sqlCmd = " select action " +
                               " from def_cont_i " +
                               " where cust_def_no = " + comp__dest_ref + ";";
                      def_cont_i_rs = stmt.executeQuery(sqlCmd);
                      if( def_cont_i_rs != null && def_cont_i_rs.next() ) {
                        def_cont_i__action = valueOrBlank(def_cont_i_rs.getString("action"));
                      }
    
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
                      if( defi_rect_rs != null && defi_rect_rs.next() ) {
                        defi_rect__rectify_date = defi_rect_rs.getDate("rectify_date");
                        defi_rect__rectify_time_h = valueOrBlank(defi_rect_rs.getString("rectify_time_h"));
                        defi_rect__rectify_time_m = valueOrBlank(defi_rect_rs.getString("rectify_time_m"));
                      }
                    } 
                  }

                  // Only process the complaint if not ignoring it
                  if (ignoreComplaint == false) {
                    // Get the site.site_name_1, site.ward_code for the given comp.site_ref
                    String site__site_name_1 = "";
                    String site__ward_code = "";
                    sqlCmd = " select site_name_1, ward_code " +
                             " from site " +
                             " where site_ref = '" + comp__site_ref + "';";
                    site_rs = stmt.executeQuery(sqlCmd); 
                    if( site_rs != null && site_rs.next() ) {
                      site__site_name_1 = valueOrBlank(site_rs.getString("site_name_1"));
                      site__ward_code = valueOrBlank(site_rs.getString("ward_code"));
                    }

                    if (comp__action_flag.equals("D")) {
                      // Add the default record to a preparedStatement Batch
                      pstmt.setInt(1, Integer.parseInt(comp__complaint_no));
                      pstmt.setString(2, valueOrNull(comp__action_flag));
                      pstmt.setString(3, valueOrNull(def_cont_i__action));
                      pstmt.setString(4, valueOrNull(comp__item_ref));
                      pstmt.setString(5, valueOrNull(comp__site_ref));
                      pstmt.setString(6, valueOrNull(comp__postcode));
                      pstmt.setString(7, valueOrNull(site__site_name_1));
                      pstmt.setString(8, valueOrNull(site__ward_code));
                      pstmt.setDate(9, defi_rect__rectify_date);
                      pstmt.setString(10, valueOrNull(defi_rect__rectify_time_h));
                      pstmt.setString(11, valueOrNull(defi_rect__rectify_time_m));
                      pstmt.setString(12, valueOrNull(defi_rect__rectify_time_h));
                      pstmt.setString(13, valueOrNull(defi_rect__rectify_time_m));
                      pstmt.setString(14, valueOrNull(comp__recvd_by));
                      pstmt.setString(15, valueOrNull(comp__comp_code));
                      pstmt.setString(16, valueOrNull(pda_user__user_name));
                      pstmt.setString(17, valueOrNull(comp__contract_ref));
                      pstmt.setString(18, valueOrNull(comp__feature_ref));
                      pstmt.setString(19, valueOrNull(comp__location_c));
                      pstmt.setString(20, valueOrNull(comp__pa_area));
                      pstmt.addBatch();      
                    } else if (comp__action_flag.equals("I")) {
                      // Add the inspect record to a preparedStatement Batch
                      pstmt.setInt(1, Integer.parseInt(comp__complaint_no));
                      pstmt.setString(2, valueOrNull(comp__action_flag));
                      pstmt.setString(3, valueOrNull(""));
                      pstmt.setString(4, valueOrNull(comp__item_ref));
                      pstmt.setString(5, valueOrNull(comp__site_ref));
                      pstmt.setString(6, valueOrNull(comp__postcode));
                      pstmt.setString(7, valueOrNull(site__site_name_1));
                      pstmt.setString(8, valueOrNull(site__ward_code));
                      pstmt.setDate(9, comp__date_entered);
                      pstmt.setString(10, valueOrNull(comp__ent_time_h));
                      pstmt.setString(11, valueOrNull(comp__ent_time_m));
                      pstmt.setString(12, valueOrNull(comp__ent_time_h));
                      pstmt.setString(13, valueOrNull(comp__ent_time_m));
                      pstmt.setString(14, valueOrNull(comp__recvd_by));
                      pstmt.setString(15, valueOrNull(comp__comp_code));
                      pstmt.setString(16, valueOrNull(pda_user__user_name));
                      pstmt.setString(17, valueOrNull(comp__contract_ref));
                      pstmt.setString(18, valueOrNull(comp__feature_ref));
                      pstmt.setString(19, valueOrNull(comp__location_c));
                      pstmt.setString(20, valueOrNull(comp__pa_area));
                      pstmt.addBatch();
                    } else if (comp__action_flag.equals("P")) {
                      // Add the sample record to a preparedStatement Batch
                      pstmt.setInt(1, Integer.parseInt(comp__complaint_no));
                      pstmt.setString(2, valueOrNull(comp__action_flag));
                      pstmt.setString(3, valueOrNull(""));
                      pstmt.setString(4, valueOrNull(comp__item_ref));
                      pstmt.setString(5, valueOrNull(comp__site_ref));
                      pstmt.setString(6, valueOrNull(comp__postcode));
                      pstmt.setString(7, valueOrNull(site__site_name_1));
                      pstmt.setString(8, valueOrNull(site__ward_code));
                      pstmt.setDate(9, comp__date_entered);
                      pstmt.setString(10, valueOrNull(""));
                      pstmt.setString(11, valueOrNull(""));
                      pstmt.setString(12, valueOrNull(""));
                      pstmt.setString(13, valueOrNull(""));
                      pstmt.setString(14, valueOrNull(comp__recvd_by));
                      pstmt.setString(15, valueOrNull(comp__comp_code));
                      pstmt.setString(16, valueOrNull(pda_user__user_name));
                      pstmt.setString(17, valueOrNull(comp__contract_ref));
                      pstmt.setString(18, valueOrNull(comp__feature_ref));
                      pstmt.setString(19, valueOrNull(comp__location_c));
                      pstmt.setString(20, valueOrNull(comp__pa_area));
                      pstmt.addBatch();
                    }

                  } // end if ignoreCompaint=false
                } // end if ignoreCompaint=false
                
              } // end pda_user loop

              // Process the preparedStatement Batch. 
              // This is what will do the insertions into the insp_list
              pstmt.executeBatch();

              // Release the memory used in the preparedStatement - I think
              if ( pstmt != null ) {
                pstmt.close();
              }

            } // end comp loop

          } catch (SQLException sqle) {
            error = "SQLException: Could not execute the query - " + sqle;
            status = status + error + "<br/>";
          } catch (Exception e) {
            error = "Exception: An unknown error occurred - " + e;
            status = status + error + "<br/>";
          }
        } // if (insertDefaults.equals("Y") || insertInspections.equals("Y") || insertSamples.equals("Y") )

        status = status + "<br/>Updating list:<br/>";

        status = status + "<br/><i>&nbsp;Setting state A/P to D ...</i><br/>";
        try {
          // do updates
          sqlCmd = " update insp_list set state = 'D' " +
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
          sqlCmd = " update insp_list set state = 'A' " +
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
          sqlCmd = " delete from insp_list " +
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
          if ( site_rs != null ) {
            site_rs.close();
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

  public void setInsertDefaults(String insertDefaults) {
    // If a insert defaults value is supplied then use it, othewise 
    // default to the initialization value of N.
    if (insertDefaults != null && ! insertDefaults.equals("")) {
      this.insertDefaults = insertDefaults.trim();
    }
  }

  public void setInsertInspections(String insertInspections) {
    // If a insert inspections value is supplied then use it, othewise 
    // default to the initialization value of N.
    if (insertInspections != null && ! insertInspections.equals("")) {
      this.insertInspections = insertInspections.trim();
    }
  }

  public void setInsertSamples(String insertSamples) {
    // If a insert samples value is supplied then use it, othewise 
    // default to the initialization value of N.
    if (insertSamples != null && ! insertSamples.equals("")) {
      this.insertSamples = insertSamples.trim();
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
      this.formatDate = new SimpleDateFormat(dbDateFmt);
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
