package pharaoh.web.databases;

import javax.naming.*;
import javax.sql.*;
import java.sql.*;
import java.util.*;
import org.apache.regexp.*;
import java.text.SimpleDateFormat;

public class jobreq {

  String error;
  Connection con = null;
  ResultSet rs = null;
  Statement stmt = null;
  String queryString;
  boolean noAsset;
  
  String lastCwJobId;
  int nextCwJobId;
  
  public boolean illegal (String illegalString) {
    // flag |~*\ illegal chars
    String nextChar = "";
    int textLength = illegalString.length();
    if (textLength > 0) {
      int i=0;
      int j=1;
      do {
        nextChar = illegalString.substring(i,j);
        if (nextChar.equals("|") || 
            nextChar.equals("~") || 
            nextChar.equals("*") ||
            nextChar.equals("\\") ||
            nextChar.equals("\'")) {
          return true;
        } 
        i++;
        j++;
      } while (i < textLength);
    }

    return false;
  }
  
  public void connect() throws NamingException,
                               SQLException,
                               Exception {
    try {
      Context initCtx = new InitialContext();
      Context envCtx = (Context) initCtx.lookup("java:comp/env");
      DataSource ds = (DataSource) envCtx.lookup("jdbc/pharaoh");
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
  
  public boolean controller1(String assetId) throws SQLException, Exception {
    //Check for a valid asset_id
    try  {
      queryString = ("select asset_id from as_dets where asset_id = '" + assetId + "';");
      stmt = con.createStatement();
      rs = stmt.executeQuery(queryString);
      if (! rs.next()) {
        noAsset = true;
      } else {
        noAsset = false;
      }
      rs.close();     
      stmt.close();

      //Unlock the as_dets table
      queryString = ("unlock as_dets;");
      stmt = con.createStatement();
      stmt.executeUpdate(queryString);
      stmt.close();
    } catch (SQLException sqle) {
      //Disconnect from the database
      disconnect();
      error = "SQLException: Could not execute the query (1) - " + sqle;
      throw new SQLException(error);
    } catch (Exception e) {
      //Disconnect from the database
      disconnect();
      error = "An exception occured while retrieving data (1) - " + e;
      throw new Exception(error);			 
    }
    return noAsset;
  }
  
  public int controller2(String userName,
                         String userContact,
                         String assetId,
                         String jobType,
                         String problemDetails,
                         int numTries,
                         int timeTries) throws SQLException, Exception {
    java.util.Date currentDate;
    String date;
    String time;
    SimpleDateFormat formatDate = new SimpleDateFormat("dd/MM/yy");
    SimpleDateFormat formatTime = new SimpleDateFormat("hh:mm");
    boolean nextTry;
    
    // Compile expression. Rememeber \\ equals a single \ as the string eats one.
    // Used to check for database error -1003
    RE r1003 = new RE("Unable to grant lock request; object locked by another user or transaction\\. \\(-1003\\)");
    
    do {
      nextTry = false;
      try  {
        //Lock the control table
        queryString = ("xlock control;");
        stmt = con.createStatement();
        stmt.executeUpdate(queryString);
        stmt.close();
        
        //Get the last cw_job_id and create next one
        queryString = ("select last_cw_job_id from control;");
        stmt = con.createStatement();
        rs = stmt.executeQuery(queryString);
        while (rs.next()) {
          lastCwJobId = rs.getString(1);
        }
        rs.close();
        stmt.close();
        nextCwJobId = Integer.parseInt(lastCwJobId) + 1;
        currentDate = new java.util.Date();
        date = formatDate.format(currentDate);
        time = formatTime.format(currentDate);
  
        //Insert the fault job into current work
        queryString = ("insert into cw_job (cw_job_id, reported_by, date_reported, time_reported, status_flag, logged_by, log_date, log_time, site_code, building_code, locat_code, access_code, account_code, allowce_time_hrs, asset_cost_cent, asset_id, asset_name, asset_no, asset_type, category, charg_cost_cent, comp_time_plan, contract_code, contract_type, dckt_iss_yn, delay_time_comp, delay_time_comp_a, delay_time_resp, delay_time_resp_a, docket_no, dorc_flag, down_serv_level, downtime_hours, estimated_cost, estimated_hrs, failure_yn, fault_code, frequency, grade_1, grade_2, grade_3, grade_4, job_id_req_no, job_type_code, labour_cost, maintenance_plan, management_unit, materials_cost, out_of_seq_flag, phoenix_code, priority_code, project_code, purch_order_flag, quantity_1, quantity_2, quantity_3, quantity_4, reason_for_delay, resp_serv_level, resp_time_plan, rev_allow_time, rev_wk_cont_time, safety_permit_yn, series, statutory_job, sub_asset_no, time_resp, time_resp_a, time_to_repr_hrs, tot_hours_compl, trade, usr_ref_fld, week_planned, wk_cont_time_hrs, work_type, workshop, wrk_done_summary) values ('" + nextCwJobId + "', '" + userName + "', " + date + ", " + time + ", '1', 'faultlog', " + date + ", " + time + ", '', '', '', '', '', 0.00, '', '" + assetId + "', '', '', '', '', '', 00:00, '', '', 'N', 00:00, 0.00, 00:00, 0.00, '', '', '', 0.00, 0.00, 0.00, '', '', 0, '', '', '', '', '', '" + jobType + "', 0.00, '', '', 0.00, 'N','', '', '', '', 0, 0, 0, 0, '', '', 00:00, 0.00, 0.00, '', 0, '', '', 00:00, 0.00, 0.00, 0.00, '', '', '', 0.00, 'F', '', '');");
        stmt = con.createStatement();
        stmt.executeUpdate(queryString);
        stmt.close();
        
        //Insert the fault job details into current work
        queryString = ("insert into cw_dets (cw_dets_job_id, detail_1, detail_2, detail_3, detail_4, detail_5, detail_6, detail_7) values ('" + nextCwJobId + "', '" + problemDetails + "', 'Contact Number: " + userContact + "', '', '', '', '', '');");
        stmt = con.createStatement();
        stmt.executeUpdate(queryString);
        stmt.close();
        
        //Update control with the cw_job_id used and release the locks
        queryString = ("update control set last_cw_job_id = '" + nextCwJobId + "';");
        stmt = con.createStatement();
        stmt.executeUpdate(queryString);
        stmt.close();

        //Unlock the cw_dets table
        queryString = ("unlock cw_dets;");
        stmt = con.createStatement();
        stmt.executeUpdate(queryString);
        stmt.close();
       
        //Unlock the cw_job table
        queryString = ("unlock cw_job;");
        stmt = con.createStatement();
        stmt.executeUpdate(queryString);
        stmt.close();

        //Unlock the control table
        queryString = ("unlock control;");
        stmt = con.createStatement();
        stmt.executeUpdate(queryString);
        stmt.close();
      } catch (SQLException sqle) {
        if (r1003.match(sqle.getMessage()) && numTries > 0) {
          nextTry = true;
        } else {
          nextTry = false;
          //Disconnect from the database
          disconnect();
          error = "SQLException: Could not execute the query (2) - " + sqle;
          throw new SQLException(error);
        }
      } catch (Exception e) {
        //Disconnect from the database
        disconnect();
        error = "An exception occured while retrieving data (2) - " + e;
        throw new Exception(error);			 
      }
      
      if (nextTry == true){
        // Try do the sql again.
        try {
          // Number of Milliseconds To Sleep
          Thread.sleep(timeTries);
        } catch (InterruptedException e) {
          // do nothing
        }
        numTries = numTries - 1;
      }
      
    } while (nextTry == true);
    
    return nextCwJobId;
  }
  
}
 
