<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="com.vsb.conSumWODetailsBean, com.vsb.recordBean, com.vsb.helperBean, com.vsb.conScheduleListBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="conSumWODetailsBean" scope="session" class="com.vsb.conSumWODetailsBean" />
<jsp:useBean id="conScheduleListBean" scope="session" class="com.vsb.conScheduleListBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="conSumWODetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Set up the date variables --%>
<%-- Set up the date variables --%>
<%
  // Set the default time zone to where we are, as the time zone
  // returned from sco is GMT+00:00 which is fine but doesn't mentioned
  // BST. So the default timezone has to be set to "Europe/London".
  // Any objects which use the timezone (like SimpleDateFormat) will then
  // be using the correct timezone.
  TimeZone dtz = TimeZone.getTimeZone("Europe/London");
  TimeZone.setDefault(dtz);

  SimpleDateFormat formatDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
  Date date;

  // todays date
  Date currentDate = new java.util.Date();
  String now_date = formatDate.format(currentDate);
 
  // set the correct date to use in the form
  if (recordBean.getWo_due_date().equals("")) {
    // set the date to todays date
    date = new java.util.Date();
  } else {
    // set the date to the stored date as it exists
    date = formatDate.parse(recordBean.getWo_due_date());
  }
  
  GregorianCalendar gregDate = new GregorianCalendar();
  gregDate.setTime(date);
%>

<app:equalsInitParameter name="use_xhtml" match="Y">
  <html xmlns="http://www.w3.org/1999/xhtml">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <html>
</app:equalsInitParameter>
<head>
  <!-- Set iPhone OS Safari attributes -->
  <meta name = "viewport" content = "width = device-width">

  <%-- Stop the browser from caching the page --%>
  <meta http-equiv="Cache-Control" content="no-cache"/>
  <meta http-equiv="Pragma" content="no-cache"/>
  <%-- Stop any proxy servers from caching the page --%>
  <% response.addHeader("Cache-Control", "no-cache"); %>

  <meta http-equiv="Refresh" content="<app:initParameter name="refreshInterval"/>" />
  <app:equalsInitParameter name="use_xhtml" match="Y">
    <meta http-equiv="Content-Type" content="application/xhtml+xml" />
    <% response.setContentType("application/xhtml+xml"); %>
  </app:equalsInitParameter>
  <app:equalsInitParameter name="use_xhtml" match="Y" value="false">
    <meta http-equiv="Content-Type" content="text/html" />
  </app:equalsInitParameter>
  <title>conSumWODetails</title>
  <style type="text/css">
    @import url("global.css");
  </style>
  <!-- Disable the browser back button -->
  <script type="text/javascript">window.history.go(1);</script>
  <!-- Make all submit buttons single click only -->
  <script type="text/javascript">
    var allowed = true;
    function singleclick() {
      if (allowed == true ) {
        allowed = false;
        return true;
      } else {
        return false;
      }
    }
  </script>
</head>

<body onUnload="">
  <form onSubmit="return singleclick();" action="conSumWODetailsScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Works Order Details</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr>
        <td>
	        <font color="#ff6565">
	        <b><jsp:getProperty name="conSumWODetailsBean" property="error" /></b>
	        </font>
	      </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table width="100%">
      <tr>
        <td align="center" colspan="2">
          <b><jsp:getProperty name="recordBean" property="site_name_1" /></b>
        </td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Suffix</b></td>
        <td><jsp:getProperty name="recordBean" property="wo_suffix" /></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Ref.</b></td>
        <td><%= recordBean.getWo_ref() %></td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Service</b></td>
        <td><%= recordBean.getService_c() %></td>
      </tr>      
      <tr bgcolor="#ffffff">
        <td>
          <b>Status</b>
        </td>
        <td>
          <jsp:getProperty name="recordBean" property="wo_stat_desc" />
        </td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Date Raised</b></td>
        <td><%= helperBean.dispDate(recordBean.getStart_date(), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Time Raised</b></td>
        <td><%= recordBean.getStart_time_h() %>:<%= recordBean.getStart_time_m() %></td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Date Due</b></td>
        <td><%= helperBean.dispDate(recordBean.getWo_date_due(), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></td>
      </tr>      
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr>
        <td colspan="2">
          <b>Previous Text</b><br/>
          <textarea rows="4" cols="28" name="textOut" readonly="readonly" ><jsp:getProperty name="conSumWODetailsBean" property="textOut" /></textarea>
        </td>
      </tr>
      <tr>
        <td colspan="2">
          <b>Contractor Reminders</b>
	      </td>
      </tr>
      <tr>
        <td colspan="2">
          <input type="text" 
	         maxlength="70" 
		       name="cont_rem1"
	         size="24"	 
	         value="<%= recordBean.getCont_rem1() %>"
           <if:IfTrue cond='<%= conSumWODetailsBean.getSavedPreviousForm().equals("conScheduleList") %>'>           
           readonly="readonly"
           </if:IfTrue>
          />
	      </td>
      </tr>
      <tr>
       <td colspan="2">
          <input type="text" 
	         maxlength="70" 
    	     name="cont_rem2"
	         size="24"		 
           value="<%= recordBean.getCont_rem2() %>"
           <if:IfTrue cond='<%= conSumWODetailsBean.getSavedPreviousForm().equals("conScheduleList") %>'>           
           readonly="readonly"
           </if:IfTrue>
          />	  
        </td>
      </tr>
      <%-- Get all the associated tasks for this works order --%>
      <%-- This section will alter depending on where the W/O--%>
      <%-- has come from !!!--%>
      <tr><td>&nbsp;</td></tr>      
      <tr>
        <td align="center" colspan="2" bgcolor="#ff6600">
        <if:IfTrue cond='<%= conSumWODetailsBean.getSavedPreviousForm().equals("conSumList") %>'>     
          <h4><b>TASKS</b></h4>
        </if:IfTrue>
        <if:IfTrue cond='<%= conSumWODetailsBean.getSavedPreviousForm().equals("conScheduleList") %>'>     
          <h4><b>SCHEDULED ITEMS</b></h4>
        </td>
      <tr>
        <td>
          <b>ITEM</b>
        </td>
        <td align="right">
          <b>QTY</b>
        </td>
      </tr>            
        </if:IfTrue>        
      <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />

      <%-- !!! SECTION ONLY RUN WHEN COMING FROM CONTRACTOR SUMMARY LIST !!! --%>      
      <%-- Display wo_i task if coming from Contractor Summary --%>      
        <if:IfTrue cond='<%= conSumWODetailsBean.getSavedPreviousForm().equals("conSumList") %>'>           
          <sql:statement id="stmt" conn="con1">
            <sql:query>
              SELECT woi_task_ref,
	                   woi_volume
	              FROM wo_i
	             WHERE wo_ref    = <%= recordBean.getWo_ref() %>
	               AND wo_suffix = '<%= recordBean.getWo_suffix() %>'
  	        </sql:query>
            <sql:resultSet id="rset1">
              <sql:getColumn position="1" to="woi_task_ref" />
              <sql:getColumn position="2" to="woi_volume" />
        	    <sql:statement id="stmt2" conn="con1">
              
  	          <sql:query>
                SELECT task_desc,
                       unit_of_meas
                  FROM task
                 WHERE task_ref = '<%= ((String)pageContext.getAttribute("woi_task_ref")).trim() %>' 
  	          </sql:query>
  	          <sql:resultSet id="rset2">
                <sql:getColumn position="1" to="task_desc" />
                <sql:getColumn position="2" to="unit_of_meas" />
  	          </sql:resultSet>
              
              <sql:query>
                  SELECT cont_cycle_no
                  FROM c_da
                  WHERE contract_ref = '<%= recordBean.getWo_contract_ref() %>'
                  AND period_start <= '<%= now_date %>'
                  AND period_finish >= '<%= now_date %>'
              </sql:query>
              <sql:resultSet id="rset3">
                <sql:getColumn position="1" to="cont_cycle_no" />
              </sql:resultSet>
              
              <sql:query>
                SELECT task_rate
                  FROM ta_r
                 WHERE task_ref = '<%= ((String)pageContext.getAttribute("woi_task_ref")).trim() %>'
                   AND contract_ref = '<%= recordBean.getWo_contract_ref() %>'
                   AND rate_band_code = 'BUY'
                   AND cont_cycle_no = '<%= ((String)pageContext.getAttribute("cont_cycle_no")).trim() %>'
                   AND start_date = (
                   SELECT MAX(start_date)
                     FROM ta_r
                    WHERE task_ref = '<%= ((String)pageContext.getAttribute("woi_task_ref")).trim() %>'
                      AND contract_ref = '<%= recordBean.getWo_contract_ref() %>'
                      AND rate_band_code = 'BUY'
                      AND cont_cycle_no = '<%= ((String)pageContext.getAttribute("cont_cycle_no")).trim() %>'
                      AND start_date < '<%= now_date %>' 
                  )
              </sql:query>
              <sql:resultSet id="rset4">
                <sql:getColumn position="1" to="task_rate" />
                <sql:wasNull>
                  <% pageContext.setAttribute("task_rate", ""); %>
                </sql:wasNull>
                </sql:resultSet>
                <tr>
                  <td align="center" colspan="2"  bgcolor="#DDDDDD">
  	                <b><%= ((String)pageContext.getAttribute("task_desc")).trim() %></b>
                  </td>
                </tr>
                <tr bgcolor="#ffffff">
                  <td>
                    <b>Volume</b>
                  </td>
                  <td>
                    <%= ((String)pageContext.getAttribute("woi_volume")).trim() %>
  	              </td>
                </tr>
                <tr bgcolor="#ecf5ff">
                  <td>
                    <b>Rate</b>
                  </td>
  	              <td>
                    <%= ((String)pageContext.getAttribute("task_rate")).trim() %>
                  </td>
                </tr>
                <tr bgcolor="#ffffff">
                  <td>
                    <b>Unit of measure</b>
                  </td>
                  <td>
                    <%= ((String)pageContext.getAttribute("unit_of_meas")).trim() %>
                  </td>
                </tr>	      
                <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>	      
  	          </sql:statement>
            </sql:resultSet>	      
            <sql:wasEmpty>
              No tasks found
            </sql:wasEmpty>
          </sql:statement>

          <tr><td>&nbsp;</td></tr>
  
          <%-- Discover what actions the contractor can set from an ISSUED Works Order--%>
          <%-- This may need to be altered to allow for access to more than just ISSUED Works Orders--%>
          <sql:statement id="stmt3" conn="con1">
            <%-- Firstly retrieve which status's the --%>
            <%-- remote access (Contractor) is allowed to view --%>
  	      <sql:query>
            SELECT c_field
    	        FROM keys
    	       WHERE keyname = 'WO_STAT_REMOTE'
      	  </sql:query>
      	  <sql:resultSet id="keys">
      	    <sql:getColumn position="1" to="remote_access_stat" />
            <sql:wasNull>
              <% pageContext.setAttribute("remote_access_stat", ""); %>
            </sql:wasNull>
  	      </sql:resultSet>
  	      
          <%-- Next, retrieve which status's the Contractor can go --%>
  	      <%-- to from an ISSEUSED Works Order--%>
          <sql:query>
            SELECT wo_next_stat
  	         FROM wo_stat
  	        WHERE wo_h_stat = 'I'
          </sql:query>
          <sql:resultSet id="next_stat">
            <sql:getColumn position="1" to="wo_next_stat" />
            <sql:wasNull>
              <% pageContext.setAttribute("wo_next_stat", ""); %>
            </sql:wasNull>
          </sql:resultSet>
          <%-- Compare both strings and see if there are any matching characters --%>
          <%-- 
               This section is not written in tags so it has to be enclosed inside 
               a java if statement to stop it from running
          --%>
  	        <%
                 String remote_next_stat = helperBean.getMatchingChars(
                   ((String)pageContext.getAttribute("remote_access_stat")).trim(),
                   ((String)pageContext.getAttribute("wo_next_stat")).trim()
                 );
            %>
    	        <tr>
                <td colspan="2">
                  <b> Select Action </b>
            <% 
                 if(remote_next_stat == "" || remote_next_stat == null) { %>
                 No Actions Available
            <%   }else{ %>
                  <select name="actionTaken"> 			 
                  <option selected="selected" ></option>
            <%
                   char[] status = remote_next_stat.toCharArray();
                   for( int i=0; i<status.length; i++ ) {
            %>
            <sql:query>
    		      SELECT wo_stat_desc
    		        FROM wo_stat
    		       WHERE wo_h_stat = '<%= status[i] %>'
            </sql:query>
            <sql:resultSet id="stats">
              <sql:getColumn position="1" to="remote_status" />
                  <option>
                    <%= ((String)pageContext.getAttribute("remote_status")).trim() %>
                  </option>
              </sql:resultSet>    
    		    <%
                }
              }            
            %>
 	              </select>
  	          </td>
  	        </tr>	
          </sql:statement>
        </if:IfTrue>
        
        <%-- !!! SECTION ONLY RUN WHEN COMING FROM CONTRACTOR SCHEDULES LIST !!! --%>
        <%-- Display comp_sched_task if coming from Contractor Schedules List    --%>      
        <if:IfTrue cond='<%= conSumWODetailsBean.getSavedPreviousForm().equals("conScheduleList") %>'>           
          <sql:statement id="stmt" conn="con1">
            <sql:query>
            <%--
              STEP FOUR:
              For each works order return the collection details (items and quantity)
            --%>
              SELECT comp_sched_item.collection_item,
                     comp_sched_item.item_quantity
                FROM comp_sched_item
               WHERE comp_sched_item.complaint_no = '<%= recordBean.getComplaint_no() %>'
            </sql:query>
            <tr>
              <td colspan="2">                  
                <table width="100%">            
            <sql:resultSet id="rset9">
              <sql:getColumn position="1" to="collection_item" />
              <sql:getColumn position="2" to="item_quantity" />
              <sql:wasNotNull>              
                  <tr valign="top" bgcolor="#eeeeee">
                    <td>
                      <%= ((String)pageContext.getAttribute("collection_item")).trim() %>
                    </td>
                    <td align="right">
                      <%= ((String)pageContext.getAttribute("item_quantity")).trim() %>
                    </td>
                  </tr>
              </sql:wasNotNull>            
            </sql:resultSet>
                </table>
              </td>
            </tr>            
            <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
            <tr>
              <td>
                <b>Total</b>
              </td>
              <td align="right">
                <%= recordBean.getWo_volume() %>
              </td>
            </tr>
          </sql:statement>
        </if:IfTrue>
        </table>
        <tr><td>&nbsp;</td></tr>        
      <sql:closeConnection conn="con1"/>
    <%-- If we have come from Contractor Summary show the finish button --%>
    <if:IfTrue cond='<%= conSumWODetailsBean.getSavedPreviousForm().equals("conSumList") %>'>      
      <jsp:include page="include/back_finish_buttons.jsp" flush="true" />
    </if:IfTrue>
    <%-- If we have come from Contractor Schedule List only show the BACK button --%>    
    <if:IfTrue cond='<%= conSumWODetailsBean.getSavedPreviousForm().equals("conScheduleList") %>'>
      <jsp:include page="include/back_button.jsp" flush="true" />
    </if:IfTrue>    
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="conSumWODetails" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
