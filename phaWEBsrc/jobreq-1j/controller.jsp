<%@ page errorPage="error.jsp" import="java.sql.*, java.io.*, java.util.*, java.text.SimpleDateFormat, pharaoh.web.databases.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/mailer-1.0" prefix="mail" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/datetime-1.0" prefix="date" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>

<%-- Standard variable declarations --%>
<%
  int numTries;
  int timeTries;
  String message;
  String mailServer;
  String helpdesk;
  
  String userNameError;
  String userContactError;
  String assetIdError;
  String problemDetailsError;
  
  String userName = request.getParameter("userName");
  String userContact = request.getParameter("userContact");
  String assetId = request.getParameter("assetId");
  String jobType = request.getParameter("jobType");
  String problemDetails = request.getParameter("problemDetails");

  // Set up the colours for the fields
  userNameError = "#ffffff";
  userContactError = "#ffffff";
  assetIdError = "#ffffff";
  problemDetailsError = "#ffffff";
  
  int nextCwJobId;
  
  boolean formCorrect = true;
  boolean noAsset = false;
  
  String reqUniqueId = request.getParameter("reqUniqueId");
  String sessUniqueId = (String) session.getAttribute("uniqueId");
%>

<jsp:useBean id="jobreq" class="pharaoh.web.databases.jobreq" />

<%-- Open the database --%>
<% jobreq.connect(); %>

<%-- Remove all illegal characters |~*\ --%>
<%-- and replace ' single quote with ` tick --%>
<%
  userName = jobreq.illegal(userName);
  userContact = jobreq.illegal(userContact);
  assetId = jobreq.illegal(assetId);
  problemDetails = jobreq.illegal(problemDetails);
%>

<%--
  The user is sent to fill in the faultform as
  they have come straight to the controller
--%>
<% if (reqUniqueId == null) { %>
  <%-- Close the database --%>
  <% jobreq.disconnect(); %>

  <jsp:forward page="reqform.jsp">
    <jsp:param name="userName" value="" />
    <jsp:param name="userContact" value="" />
    <jsp:param name="assetId" value="" />
    <jsp:param name="jobType" value="" />
    <jsp:param name="problemDetails" value="" />
    
    <jsp:param name="userNameError" value="<%=userNameError%>" />
    <jsp:param name="userContactError" value="<%=userContactError%>" />
    <jsp:param name="assetIdError" value="<%=assetIdError%>" />
    <jsp:param name="problemDetailsError" value="<%=problemDetailsError%>" />
    
    <jsp:param name="formCorrect" value="<%=formCorrect%>" />
    <jsp:param name="noAsset" value="<%=noAsset%>" />
  </jsp:forward>
<% } %>

<%-- Set up the colours for any error fields --%>
<%   
  if (userName == null || userName.length() == 0) {
    userNameError = "#ff6565";
    formCorrect = false;
  }
  if (userContact == null || userContact.length() == 0) {
    userContactError = "#ff6565";
    formCorrect = false;
  }
  if (assetId == null || assetId.length() == 0) {
    assetIdError = "#ff6565";
    formCorrect = false;
  }
  if (problemDetails == null || problemDetails.length() == 0) {
    problemDetailsError = "#ff6565";
    formCorrect = false;
  }
%>

<%-- Check for a valid asset_id --%>
<%
  if (assetId != null && assetId.length() > 0) { 
    boolean nA = jobreq.controller1(assetId);
    if (nA == true) {
      assetIdError = "#ff6565";
      formCorrect = false;
      noAsset = true;
    }
  }
%>

<%--
  The user is sent back to fill in the faultform again
  if they haven't entered the data correctly
--%>
<% if (formCorrect == false) { %>
  <%-- Close the database --%>
  <% jobreq.disconnect(); %>

  <jsp:forward page="reqform.jsp">
    <jsp:param name="userName" value="<%=userName%>" />
    <jsp:param name="userContact" value="<%=userContact%>" />
    <jsp:param name="assetId" value="<%=assetId%>" />
    <jsp:param name="jobType" value="<%=jobType%>" />
    <jsp:param name="problemDetails" value="<%=problemDetails%>" />
    
    <jsp:param name="userNameError" value="<%=userNameError%>" />
    <jsp:param name="userContactError" value="<%=userContactError%>" />
    <jsp:param name="assetIdError" value="<%=assetIdError%>" />
    <jsp:param name="problemDetailsError" value="<%=problemDetailsError%>" />
    
    <jsp:param name="formCorrect" value="<%=formCorrect%>" />
    <jsp:param name="noAsset" value="<%=noAsset%>" />
  </jsp:forward>
<% } %>

<%-- Fault already logged --%>
<% if (!reqUniqueId.equals(sessUniqueId)) { %>
  <%-- Close the database --%>
  <% jobreq.disconnect(); %>
  
  <jsp:forward page="dataexpired.jsp">
    <jsp:param name="uniqueId" value="<%=reqUniqueId%>" />
  </jsp:forward>
<% } %>

<%-- process the request if everything is OK --%>
<%-- Close the database --%>
<%
  numTries = Integer.parseInt((String) getServletContext().getInitParameter("numTries"));
  timeTries = Integer.parseInt((String) getServletContext().getInitParameter("timeTries"));
  nextCwJobId = jobreq.controller2(userName, userContact, assetId, jobType, problemDetails, numTries, timeTries);
  jobreq.disconnect();
%>

<%-- Email section --%>
<%-- Send mail if using mail --%>
<app:equalsInitParameter name="useMail" match="yes">
  <%-- Creating the email message --%>
  <%
    message = "Raised By: " + userName + 
              "\nContact Number: " + userContact +
              "\n\nAsset Id: " + assetId +
              "\nJob Type: " + jobType +
              "\n\nProblem: " + problemDetails;
              
    mailServer = (String) getServletContext().getInitParameter("mailServer");
    helpdesk = (String) getServletContext().getInitParameter("helpdesk");
  %>
  <mail:mail server="<%=mailServer%>">
    <mail:setrecipient type="to"><%=helpdesk%></mail:setrecipient>
    <mail:from>FaultLog</mail:from>
    <mail:subject>New fault - Job Id: <%=nextCwJobId%></mail:subject>
    <mail:message><%=message%></mail:message>
    <mail:send/>
  </mail:mail>
</app:equalsInitParameter>

<%-- Create unique ID --%>
<sess:session id="ss"/>
<sess:setAttribute name="uniqueId"><jsp:getProperty name="ss" property="sessionId"/><date:currentTime/></sess:setAttribute>

<%-- The user is sent to the newreq screen --%>
<jsp:forward page="newreq.jsp">
  <jsp:param name="cwJobId" value="<%=nextCwJobId%>" />
</jsp:forward>

<html>
<head>
  <title>Pharaoh - Controller</title>
</head>

<body>
  
</body>
</html>
