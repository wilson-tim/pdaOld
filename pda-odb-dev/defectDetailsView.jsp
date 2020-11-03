<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.defectDetailsBean, com.vsb.defectSizeBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"          prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"       prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0"     prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="defectDetailsBean" scope="session" class="com.vsb.defectDetailsBean" />
<jsp:useBean id="defectSizeBean"    scope="session" class="com.vsb.defectSizeBean" />
<jsp:useBean id="recordBean"        scope="session" class="com.vsb.recordBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="defectDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

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
  <title>defectDetails</title>
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
  <form onSubmit="return singleclick();" action="defectDetailsScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Defect Details</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="defectDetailsBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade /></td></tr>
    </table>
    <%-- Site Name --%>
    <table width="100%">
      <tr>
        <td align="center"><b><%= recordBean.getSite_name_1() %></b></td>
      </tr>
      <tr><td><hr size="1" noshade="noshade" /></td></tr>
    </table>
    <table width="100%">
      <tr bgcolor="#ecf5ff">
        <td><b>X Value</b></td>
        <td>
          <%= defectSizeBean.getX() %>
        </td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Y Value</b></td>
        <td>
          <%= defectSizeBean.getY() %>
        </td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Linear</b></td>
        <td>
          <input type="text" 
                 id="linear" 
                 name="linear" 
                 value="<%= defectDetailsBean.getLinear() %>" 
                 size="12" 
                 maxlength="12"
          />
        </td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Area</b></td>
        <td>
          <%= defectDetailsBean.getArea() %>
          <input type="hidden" name="area" id="area" value="<%= defectDetailsBean.getArea() %>"/>
        </td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Urgency</b></td>
        <td>
          <select name="priority">
          <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
          <sql:statement id="stmt" conn="con">    
            <sql:query>
              SELECT lookup_code
                FROM allk
               WHERE lookup_func = 'URGENT'
            </sql:query>
            <% String lookup_code = ""; %>
            <sql:resultSet id="rset1">
              <sql:getColumn position="1" to="lookup_code" />
              <sql:wasNotNull>
                <% lookup_code = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
                <if:IfTrue cond='<%= lookup_code.equals(defectDetailsBean.getPriority())%>'>
                  <option selected="selected"><%= lookup_code %></option>
                </if:IfTrue>
                <if:IfTrue cond='<%= !lookup_code.equals(defectDetailsBean.getPriority())%>'>
                  <option><%= lookup_code %></option>
                </if:IfTrue>
              </sql:wasNotNull>
            </sql:resultSet>
          </sql:statement>
          <sql:closeConnection conn="con"/>
          </select>
        </td>
      </tr>
      <%-- Only display the position and text fields if we are coming from the Inspections route --%>
      <if:IfTrue cond='<%= recordBean.getDefect_flag().equals("I") %>'>
        <tr><td colspan="2"><b>Position</b></td></tr>
        <tr>
          <td colspan="2">
            <input type="text" id="position" name="position" value="<%= defectDetailsBean.getPosition() %>" size="24" maxlength="70"/>
          </td>
        </tr>
        <tr>
          <td colspan="2">
            <b>Text</b><br/>
            <textarea rows="4" cols="28" name="text" ><jsp:getProperty name="defectDetailsBean" property="text" /></textarea>
          </td>
        </tr>
      </if:IfTrue>
    </table>
    <if:IfTrue cond='<%= recordBean.getDefect_flag().equals("A") %>'>
      <jsp:include page="include/back_wo_finish_buttons.jsp" flush="true" />
    </if:IfTrue>
    <if:IfTrue cond='<%= ! recordBean.getDefect_flag().equals("A") %>'>
      <jsp:include page="include/back_wo_buttons.jsp" flush="true" />
    </if:IfTrue>
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="defectDetails" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
