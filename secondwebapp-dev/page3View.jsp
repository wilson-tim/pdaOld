<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.page3Bean,com.vsb.recordBean" %>
<%@ page import="com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="page3Bean" scope="session" class="com.vsb.page3Bean" />
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
<sess:equalsAttribute name="form" match="page3" value="false">
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
  <title>page3</title>
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
  <form onSubmit="return singleclick();" action="page3Script.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#9900FF" align="center">
          <h2><font color="white"><b>Test page 3</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="page3Bean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table cellpadding="2" cellspacing="0" width="100%">
      <% String color="#ffffff"; %>
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
      <sql:statement id="stmt" conn="con">
        <sql:query>
          select complaint_no, entered_by, location_name
          from comp
          <if:IfTrue cond='<%= helperBean.isValid(recordBean.getComplaint_no()) %>' >
            where complaint_no = <%= recordBean.getComplaint_no() %> 
            and location_name like '%<%= recordBean.getLocation_name() %>%'
          </if:IfTrue>
          <if:IfTrue cond='<%= helperBean.isNotValid(recordBean.getComplaint_no()) %>' >
            where location_name like '%<%= recordBean.getLocation_name() %>%'
          </if:IfTrue>
          order by complaint_no, location_name
        </sql:query>
        <sql:resultSet id="rset">
          <% 
            if(color=="#ffffff") {
              color = "#ecf5ff";
            } else if (color=="#ecf5ff") {
              color = "#ffffff";
            }
          %>
          <tr bgcolor="<%= color %>" valign="top" >
            <sql:getColumn position="1" to="complaint_no" />
            <td width="10">
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("complaint_no")).trim().equals(page3Bean.getComplaint_no()) %>' >
                <input type="radio" name="complaint_no" id="<sql:getColumn position="1" />" 
                  value="<%= ((String)pageContext.getAttribute("complaint_no")).trim() %>" checked="checked" />
              </if:IfTrue>
              <if:IfTrue cond='<%= !((String)pageContext.getAttribute("complaint_no")).trim().equals(page3Bean.getComplaint_no()) %>' >
                <input type="radio" name="complaint_no" id="<sql:getColumn position="1" />" 
                  value="<%= ((String)pageContext.getAttribute("complaint_no")).trim() %>" />
              </if:IfTrue>
            </td>
            <td>
              <label for="<sql:getColumn position="1" />"><b><%= ((String)pageContext.getAttribute("complaint_no")).trim() %></b></label>
            </td>
            <td>
              <sql:getColumn position="2" to="entered_by" />
              <label for="<sql:getColumn position="1" />"><%= ((String)pageContext.getAttribute("entered_by")).trim() %></label>
            </td>
            <td>
              <sql:getColumn position="3" to="location_name" />
              <label for="<sql:getColumn position="1" />"><%= ((String)pageContext.getAttribute("location_name")).trim() %></label>
            </td>
          </tr>
        </sql:resultSet>
        <sql:wasEmpty>
          <tr>
           <td colspan="3">
             <b>No records available</b>
           </td>
         </tr>
        </sql:wasEmpty>
        <sql:wasNotEmpty>
          <tr>
            <td colspan="3">
              <span class="subscript"><sql:rowCount /> Record(s) found</span>
            </td>
          </tr>
        </sql:wasNotEmpty>
      </sql:statement>
      <sql:closeConnection conn="con"/>
    </table>
    <jsp:include page="include/back_update_details_buttons.jsp" flush="true" />
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="page3" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
