<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.reqformBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/datetime-1.0" prefix="date" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>

<jsp:useBean id="reqformBean" scope="session" class="com.vsb.reqformBean" />

<!-- Disable the browser back button -->
<script>window.history.go(1);</script>

<%-- Make sure this is the form we are supposed to be on --%>
<sess:equalsAttribute name="form" match="reqform" value="false">
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Create unique ID --%>
<sess:session id="ss"/>
<sess:setAttribute name="uniqueId"><jsp:getProperty name="ss" property="sessionId"/><date:currentTime/></sess:setAttribute>

<html>
<head>
	<title>reqform</title>
  <style type="text/css">
		@import URL("global.css");
	</style>
</head>

<body>
  <form action="reqformScript.jsp" method="post">
    <table>
      <tr>
        <td align="center" colspan="2"><h1>Request Logging Form</h1></td>
      </tr>
  		<tr><td colspan="2"><hr></td></tr>
  		<tr><td colspan="2"><font color="#ff6565"><b><jsp:getProperty name="reqformBean" property="error" /></b></font></td></tr>
      <tr><td>&nbsp;</td></tr>
      <tr bgcolor="<%=reqformBean.getUserNameError()%>" >
        <td><b>Name:</b></td>
        <td>
          <input type="text" name="userName" maxlength="30" size="30" 
            value="<%=reqformBean.getUserName()%>" >
        </td>
      </tr>
      <tr bgcolor="<%=reqformBean.getUserContactError()%>" >
        <td><b>Contact No.:</b></td>
        <td>
          <input type="text" name="userContact" maxlength="15" size="15"
            value="<%=reqformBean.getUserContact()%>" >
        </td>
      </tr>
      <tr bgcolor="<%=reqformBean.getUserEmailError()%>" >
        <td><b>Email:</b></td>
        <td>
          <input type="text" name="userEmail" maxlength="40" size="40"
            value="<%=reqformBean.getUserEmail()%>" >
        </td>
      </tr>
      <tr><td>&nbsp;</td></tr>
      <tr bgcolor="<%=reqformBean.getAssetIdError()%>" >
        <td><b>Asset ID:</b></td>
        <td>
          <input type="text" name="assetId" maxlength="6" size="6"
            value="<%=reqformBean.getAssetId()%>" >
        </td>
      </tr>
      <tr>
        <td><b>Job Type:</b></td>
        <td>
          <select name="jobType">
            <%-- Get the list of job types --%>
            <%-- Open the database via the jndi connection pool --%>
            <sql:connection id="con" jndiName="java:comp/env/jdbc/pharaoh" />
            <sql:statement id="stmt" conn="con">
              <sql:query>
                select job_type_code, descript from jb_type
              </sql:query>
              <sql:resultSet id="rset">
                <%-- Create the option list --%>
                <sql:getColumn position="1" to="jobTypeMatch" />
                <if:IfTrue cond='<%= pageContext.getAttribute("jobTypeMatch").equals(reqformBean.getJobType()) %>' >
                  <option value="<sql:getColumn position="1" />" selected>
                    <sql:getColumn position="1" /> | <sql:getColumn position="2" />
                  </option>
                </if:IfTrue>
                <if:IfTrue cond='<%= !(pageContext.getAttribute("jobTypeMatch").equals(reqformBean.getJobType())) %>' >
                  <option value="<sql:getColumn position="1" />" >
                    <sql:getColumn position="1" /> | <sql:getColumn position="2" />
                  </option>
                </if:IfTrue>
              </sql:resultSet>
              <%-- Unlock jb_type as the dbtags lock the records found with a select query --%>
              <sql:query>
                unlock jb_type
              </sql:query>
              <sql:execute />
            </sql:statement>
            <%-- Close the database --%>
            <sql:closeConnection conn="con" />
          </select>
        </td>
      </tr>
      <tr><td>&nbsp;</td></tr>
      <tr>
        <td colspan="2"><b>Problem<br>Details:</b></td>
      </tr>
      <tr bgcolor="<%=reqformBean.getProblemDetails1Error()%>" >
        <td colspan="2">
          <input type="text" name="problemDetails1" maxlength="50" size="50"
            value="<%=reqformBean.getProblemDetails1()%>" >
        </td>
      </tr>
      <tr bgcolor="<%=reqformBean.getProblemDetails2Error()%>" >
        <td colspan="2">
          <input type="text" name="problemDetails2" maxlength="50" size="50"
            value="<%=reqformBean.getProblemDetails2()%>" >
        </td>
      </tr>
      <tr bgcolor="<%=reqformBean.getProblemDetails3Error()%>" >
        <td colspan="2">
          <input type="text" name="problemDetails3" maxlength="50" size="50"
            value="<%=reqformBean.getProblemDetails3()%>" >
        </td>
      </tr>
      <tr bgcolor="<%=reqformBean.getProblemDetails4Error()%>" >
        <td colspan="2">
          <input type="text" name="problemDetails4" maxlength="50" size="50"
            value="<%=reqformBean.getProblemDetails4()%>" >
        </td>
      </tr>
      <tr><td>&nbsp;</td></tr>
  	  <tr><td colspan="2"><hr></td></tr>
      <tr><td>&nbsp;</td></tr>
      <tr>
        <td colspan="2">
          <jsp:include page="include/new_submit_buttons.jsp" flush="true" />
        <td>
      <tr>
      <tr>
        <td colspan="2" align="right">
          <jsp:include page="include/footer.jsp" flush="true" />
        <td>
      <tr>
    </table>
    <input type="hidden" name="uniqueId" value='<sess:attribute name="uniqueId" />'>
	  <input type="hidden" name="input" value="reqform" >
  </form>
</body>
</html>
