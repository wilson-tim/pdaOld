<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.*, java.text.*, java.text.SimpleDateFormat" %>
<%@ page import="com.vsb.woDetailsBean, com.vsb.woTaskBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"          prefix="sql"  %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"       prefix="if"   %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app"  %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0"     prefix="sess" %>

<jsp:useBean id="woDetailsBean" scope="session" class="com.vsb.woDetailsBean" />
<jsp:useBean id="woTaskBean"    scope="session" class="com.vsb.woTaskBean" />
<jsp:useBean id="recordBean"    scope="session" class="com.vsb.recordBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="woDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

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
  <title>woDetails</title>  
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
  <form onSubmit="return singleclick();" action="woDetailsScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Works Order Details</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="woDetailsBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table width="100%">
      <tr>
        <td align="center" colspan="2"><b><jsp:getProperty name="recordBean" property="site_name_1" /></b></td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <%-- Get all the selected task refs and display their details --%>
      <% Iterator woi_task_refs = woTaskBean.iterator();         %>
      <% while( woi_task_refs.hasNext() ) {                      %>
      <%   String woi_task_ref = (String)woi_task_refs.next();   %>
        <tr bgcolor="#ecf5ff">
          <td><b>Task</b></td>
          <td><%= woi_task_ref %></td>
        </tr>
        <tr>
          <td colspan="2"><%= woDetailsBean.getWoi_task_desc( woi_task_ref ) %></td>
        </tr>
   		  <tr bgcolor="#ecf5ff">
  				<td><b>Unit Price</b></td>
  				<td>
            <input type="text" 
                   name="<%= woi_task_ref %>|wo_item_price" 
                   maxlength="11" 
                   size="11"
    				       value='<%= woDetailsBean.getWoi_task_rate( woi_task_ref ) %>' 
            />
    		  </td>
  			</tr>
  			<tr>
  				<td><b>Quantity</b></td>
  				<td>
  				  <input type="text" 
                   name="<%= woi_task_ref %>|wo_volume" 
                   maxlength="10" 
                   size="11"
    				       value="<%= woDetailsBean.getWoi_task_volume( woi_task_ref ) %>" 
            />
    		  </td>
  			</tr>
        <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <% } //END While Loop woi_task_refs %>
      <%-- If the task_ref bean is empty then display no rows --%>
      <if:IfTrue cond='<%= woTaskBean.size() == 0 %>'>
        <tr><td colspan="2"><b>No task details found</b></td></tr>
        <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      </if:IfTrue>
      <tr>
        <td colspan="2">
          <b>Date Due:</b>
        </td>
      </tr>
      <tr>
        <td colspan="2">
          <table>
            <tr>
              <td width="33%"><b>Day</b></td>
              <td width="33%"><b>Month</b></td>
              <td width="33%"><b>Year</b></td>
            </tr>
            <tr>
              <td>
                <select name="day">
                <%  for (int i=1; i<32; i++) { 
                      if (i == gregDate.get(gregDate.DATE)) { %>
                         <option value="<% out.print(i); %>" selected="selected" ><% out.print(i); %></option>
                <%    } else { %>
                         <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                <%     }   
                     } %>
                </select>
              </td>
              <td>
                <select name="month">
                <%  for (int i=1; i<13; i++) {
                      if (i == gregDate.get(gregDate.MONTH) + 1) { %>
                         <option value="<% out.print(i); %>" selected="selected" ><% out.print(i); %></option>
                <%     } else { %>
                         <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                <%    } 
                    } %>
                </select>
              </td>
              <td>
                <select name="year">
                <%  for (int i=gregDate.get(gregDate.YEAR), k=i+2; i <= k; i++) {
                      if (i == gregDate.get(gregDate.YEAR)) { %>
                         <option value="<% out.print(i); %>" selected="selected" ><% out.print(i); %></option>
                <%     } else { %>
                        <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                <%   } 
                   } 
                %>
                </select>
              </td>
            </tr>
          </table>
        </td>
      </tr>
      <%-- Only allow adding of text here if this is a Hway Statuory Item, or a Trees item --%>
      <if:IfTrue cond='<%= (recordBean.getInsp_item_flag().equals("Y") && recordBean.getService_c().equals(recordBean.getHway_service())) || recordBean.getService_c().equals(recordBean.getTrees_service()) %>' >
        <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
        <tr>
          <td colspan="2">
            <%-- Get the name for the position field, default to 'Exact Location' --%>
            <% String position = "Exact Location"; %>
            <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
            <sql:statement id="stmt" conn="con">
              <sql:query>
                select c_field
                from keys
                where service_c = 'ALL'
                and   keyname = 'POSITION_TITLE'
              </sql:query>
              <sql:resultSet id="rset">
                <sql:getColumn position="1" to="c_field" />
                <sql:wasNotNull>
                  <% position = (String)pageContext.getAttribute("c_field"); %>
                </sql:wasNotNull>
                <sql:wasNull>
                  <% position = "Exact Location"; %>
                </sql:wasNull>
              </sql:resultSet>
              <sql:wasEmpty>
                <% position = "Exact Location"; %>
              </sql:wasEmpty>
            </sql:statement>
            <sql:closeConnection conn="con"/>
  
            <b><%= position %></b><br/>
            <input type="text" name="exact_location" maxlength="70" size="24"
              value="<%= woDetailsBean.getExact_location() %>" />
          </td>
        </tr>
        <tr>
          <td colspan="2">
            <b>Remarks</b><br/>
            <input type="text" name="remarks" maxlength="210" size="24"
              value="<%= woDetailsBean.getRemarks() %>" />
          </td>
        </tr>
        <tr>
          <td colspan="2">
            <b>Text Notes</b><br/>
            <textarea rows="4" cols="28" name="comp_text" ><jsp:getProperty name="woDetailsBean" property="comp_text" /></textarea>
          </td>
        </tr>
      </if:IfTrue>
      <%-- Only show the text box if the Works Order is going to have it's own text --%>
      <% String comp_text_to_wo = "Y"; %>
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
        <sql:query>
          select c_field
          from keys
          where service_c = '<%= recordBean.getService_c() %>'
          and   keyname = 'COMP_TEXT TO WO'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="c_field" />
          <sql:wasNotNull>
            <% comp_text_to_wo = ((String)pageContext.getAttribute("c_field")).trim(); %>
          </sql:wasNotNull>
        </sql:resultSet>
      </sql:statement>
      <sql:closeConnection conn="con"/>
      <if:IfTrue cond='<%= comp_text_to_wo.equals("N") %>'>
        <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
        <tr>
          <td colspan="2">
            <b>Works Order Text Notes</b><br/>
            <textarea rows="4" cols="28" name="text" ><jsp:getProperty name="woDetailsBean" property="text" /></textarea>
          </td>
        </tr>
      </if:IfTrue>
    </table>
    <%-- Check to see if this is a works order being generated from the 
         CompOrSched route, or the compSampDetails route --%>
    <%-- compSampDetails route --%>
    <if:IfTrue cond='<%= recordBean.getComingFromInspList().equals("Y") %>'>
        <jsp:include page="include/back_finish_buttons.jsp" flush="true" />
    </if:IfTrue>
    <%-- compOrSched route --%>
    <if:IfTrue cond='<%= !recordBean.getComingFromInspList().equals("Y") %>'>
      <%-- Hways statutory item, or Trees item --%>
      <if:IfTrue cond='<%= (recordBean.getInsp_item_flag().equals("Y") && recordBean.getService_c().equals(recordBean.getHway_service())) || recordBean.getService_c().equals(recordBean.getTrees_service()) %>' >
        <jsp:include page="include/back_submit_buttons.jsp" flush="true" />    
      </if:IfTrue>
      <%-- None Hways statutory item --%>
      <if:IfTrue cond='<%= ! (recordBean.getInsp_item_flag().equals("Y") && recordBean.getService_c().equals(recordBean.getHway_service())) && ! recordBean.getService_c().equals(recordBean.getTrees_service()) %>' >
        <jsp:include page="include/back_addtext_buttons.jsp" flush="true" />    
      </if:IfTrue>
    </if:IfTrue>
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="woDetails" />  
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
