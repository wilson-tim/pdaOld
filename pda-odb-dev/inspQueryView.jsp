<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.inspQueryBean, com.vsb.recordBean" %>
<%@ page import="java.util.GregorianCalendar" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="inspQueryBean" scope="session" class="com.vsb.inspQueryBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="inspQuery" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%
  // Create calendar to create the year drop down boxes.
  GregorianCalendar gregDate = new GregorianCalendar();
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
  <title>inspQuery</title>
  <style type="text/css">
    @import URL("global.css");
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
  <form onSubmit="return singleclick();" action="inspQueryScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Search Inspections</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="inspQueryBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade /></td></tr>
    </table>
    <%-- Open a connection to the database to help create the view --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
    <%-- Due Date Table --%>
    <table width="100%">
      <tr bgcolor="#ecf5ff">
        <td width="25%" rowspan="2"><b>Due Date</b></td>
        <td width="25%"><b>Day</b></td>
        <td width="25%"><b>Month</b></td>
        <td width="25%"><b>Year</b></td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td>
          <select name="insp_due_day">
            <option value=""></option>
            <% int insp_due_day = 0; %>
            <if:IfTrue cond='<%= !inspQueryBean.getInsp_due_day().equals("") %>'>
              <% insp_due_day = new Integer(inspQueryBean.getInsp_due_day()).intValue(); %>
            </if:IfTrue>
            <%  for (int i=1; i<32; i++) { %>
              <if:IfTrue cond="<%= i == insp_due_day %>">
                <option value="<%= i %>" selected="selected"><%= i %></option>
              </if:IfTrue>
              <if:IfTrue cond="<%= i != insp_due_day %>">
                <option value="<%= i %>"><%= i %></option>
              </if:IfTrue>
            <%  } %>
          </select>
        </td>
        <td>
          <select name="insp_due_month">
            <option value=""></option>
            <% int insp_due_month = 0; %>
            <if:IfTrue cond='<%= !inspQueryBean.getInsp_due_month().equals("") %>'>
              <% insp_due_month = new Integer(inspQueryBean.getInsp_due_month()).intValue(); %>
            </if:IfTrue>
            <%  for (int i=1; i<13; i++) { %>
              <if:IfTrue cond="<%= i == insp_due_month %>">
                <option value="<%= i %>" selected="selected" ><%= i %></option>
              </if:IfTrue>
              <if:IfTrue cond="<%= i != insp_due_month %>">
                <option value="<%= i %>" ><%= i %></option>
              </if:IfTrue>
            <%  } %>
          </select>
        </td>
        <td>
          <select name="insp_due_year">
            <option value=""></option>
            <% int insp_due_year = 0; %>
            <if:IfTrue cond='<%= !inspQueryBean.getInsp_due_year().equals("") %>'>
              <% insp_due_year = new Integer(inspQueryBean.getInsp_due_year()).intValue(); %>
            </if:IfTrue>
            <%  for (int i=(gregDate.get(gregDate.YEAR)-1), k=i+3; i <= k; i++) { %>
              <if:IfTrue cond="<%= i == insp_due_year %>">
                <option value="<%= i %>" selected="selected" ><%= i %></option>
              </if:IfTrue>
              <if:IfTrue cond="<%= i != insp_due_year %>">
                <option value="<%= i %>" ><%= i %></option>
              </if:IfTrue>
            <%  } %>
          </select>
        </td>
      </tr>
    </table>
    <%-- Site Table --%>
    <table width="100%">
      <tr>
        <td width="80"><b>Site</b></td>
        <td>
         <input type="text" name="insp_site" size="18"
            value="<%= inspQueryBean.getInsp_site() %>" 
        </td>
      </tr>
    </table>
    <%-- Service Table --%>
    <table width="100%">
      <tr bgcolor="#ecf5ff">
        <td width="80"><b>Service</b></td>
        <td>
          <select name="insp_service">
            <option value=""></option>
            <sql:query>
              SELECT distinct service_c
              FROM pda_lookup
              WHERE role_name = '<%= recordBean.getPda_role() %>'
              ORDER BY service_c
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="insp_service" />
              <sql:wasNotNull>
                <% String insp_service = ((String)pageContext.getAttribute("insp_service")).trim(); %>
                <if:IfTrue cond='<%= insp_service.equals(inspQueryBean.getInsp_service())%>'>
                  <option value="<%= insp_service %>" selected="selected" ><%= insp_service %></option>
                </if:IfTrue>
                <if:IfTrue cond='<%= !insp_service.equals(inspQueryBean.getInsp_service())%>'>
                  <option value="<%= insp_service %>"><%= insp_service %></option>
                </if:IfTrue>
              </sql:wasNotNull>
            </sql:resultSet>
          </select>
        </td>
      </tr>
    </table>
    <%-- Enquiry Ref Table --%>
    <table width="100%">
      <tr>
        <td width="80"><b>Enquiry Ref</b></td>
        <td>
         <input type="text" name="complaint_no" size="18"
            value="<%= inspQueryBean.getComplaint_no() %>" 
        </td>
      </tr>
    </table>
    </sql:statement>
    <sql:closeConnection conn="con"/>
    <jsp:include page="include/back_submit_buttons.jsp" flush="true" />
    <%@ include file="include/sched_button.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="inspQuery" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
    <input type="hidden" name="insp_due_date" value="<%= inspQueryBean.getInsp_due_date() %>" />
  </form>
</body>
</html>
