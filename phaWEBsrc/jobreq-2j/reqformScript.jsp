<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.reqformBean, java.sql.*, java.io.*, java.util.*, java.text.SimpleDateFormat, pharaoh.web.databases.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/mailer-1.0" prefix="mail" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/datetime-1.0" prefix="date" %>

<jsp:useBean id="reqformBean" scope="session" class="com.vsb.reqformBean" />
<jsp:useBean id="jobreq" class="pharaoh.web.databases.jobreq" />

<%-- Make sure this is the form we are supposed to be on --%>
<sess:equalsAttribute name="form" match="reqform" value="false">
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="reqform" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="reqformBean" property="all" value="clear" />
    <jsp:setProperty name="reqformBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="reqformBean" property="error" value="" />
<jsp:setProperty name="reqformBean" property="userContactError" value="" />
<jsp:setProperty name="reqformBean" property="userNameError" value="" />
<jsp:setProperty name="reqformBean" property="userEmailError" value="" />
<jsp:setProperty name="reqformBean" property="problemDetails1Error" value="" />
<jsp:setProperty name="reqformBean" property="problemDetails2Error" value="" />
<jsp:setProperty name="reqformBean" property="problemDetails3Error" value="" />
<jsp:setProperty name="reqformBean" property="problemDetails4Error" value="" />
<jsp:setProperty name="reqformBean" property="assetIdError" value="" />

<%-- clear form fields if coming from previous form --%>
<sess:equalsAttribute name="input" match="index" >
  <jsp:setProperty name="reqformBean" property="action" value="" />
  <jsp:setProperty name="reqformBean" property="all" value="clear" />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="newreq" >
  <jsp:setProperty name="reqformBean" property="action" value="" />
  <jsp:setProperty name="reqformBean" property="all" value="clear" />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="dataExpired" >
  <jsp:setProperty name="reqformBean" property="action" value="" />
  <jsp:setProperty name="reqformBean" property="all" value="clear" />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="reqform" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= reqformBean.getAction().equals("Submit") %>' >
    <%-- Standard variable declarations --%>
    <%
      int numTries;
      int timeTries;
      String message;
      String mailServer;
      String helpdesk;
      
      int nextCwJobId;
      
      boolean formCorrect = true;
      boolean illegalChars = false;
      boolean noAsset = false;
      
      String errorMessage = "";
    %>
      
    <%-- Open the database --%>
    <% jobreq.connect(); %>
  
    <%-- Invalid entry --%>
    <%-- Check for blank fields --%>
    <if:IfTrue cond='<%= reqformBean.getUserContact() == null || reqformBean.getUserContact().trim().equals("")%>' >
      <jsp:setProperty name="reqformBean" property="userContactError" value="#ff6565" />
      <% formCorrect = false; %>
    </if:IfTrue>
    <if:IfTrue cond='<%= reqformBean.getUserName() == null || reqformBean.getUserName().trim().equals("")%>' >
      <jsp:setProperty name="reqformBean" property="userNameError" value="#ff6565" />
      <% formCorrect = false; %>
    </if:IfTrue>
    <if:IfTrue cond='<%= reqformBean.getUserEmail() == null || reqformBean.getUserEmail().trim().equals("")%>' >
      <jsp:setProperty name="reqformBean" property="userEmailError" value="#ff6565" />
      <% formCorrect = false; %>
    </if:IfTrue>
    <if:IfTrue cond='<%= reqformBean.getProblemDetails1() == null || reqformBean.getProblemDetails1().trim().equals("")%>' >
      <jsp:setProperty name="reqformBean" property="problemDetails1Error" value="#ff6565" />
      <% formCorrect = false; %>
    </if:IfTrue>
    <if:IfTrue cond='<%= reqformBean.getAssetId() == null || reqformBean.getAssetId().trim().equals("")%>' >
      <jsp:setProperty name="reqformBean" property="assetIdError" value="#ff6565" />
      <% formCorrect = false; %>
    </if:IfTrue>
    
    <%-- Check for illegal chars --%>
    <if:IfTrue cond='<%= jobreq.illegal(reqformBean.getUserContact()) %>' >
      <jsp:setProperty name="reqformBean" property="userContactError" value="#ff6565" />
      <% formCorrect = false; %>
      <% illegalChars = true; %>
    </if:IfTrue>
    <if:IfTrue cond='<%= jobreq.illegal(reqformBean.getUserName()) %>' >
      <jsp:setProperty name="reqformBean" property="userNameError" value="#ff6565" />
      <% formCorrect = false; %>
      <% illegalChars = true; %>
    </if:IfTrue>
    <if:IfTrue cond='<%= jobreq.illegal(reqformBean.getUserEmail()) %>' >
      <jsp:setProperty name="reqformBean" property="userEmailError" value="#ff6565" />
      <% formCorrect = false; %>
      <% illegalChars = true; %>
    </if:IfTrue>
    <if:IfTrue cond='<%= jobreq.illegal(reqformBean.getProblemDetails1()) %>' >
      <jsp:setProperty name="reqformBean" property="problemDetails1Error" value="#ff6565" />
      <% formCorrect = false; %>
      <% illegalChars = true; %>
    </if:IfTrue>
    <if:IfTrue cond='<%= jobreq.illegal(reqformBean.getProblemDetails2()) %>' >
      <jsp:setProperty name="reqformBean" property="problemDetails2Error" value="#ff6565" />
      <% formCorrect = false; %>
      <% illegalChars = true; %>
    </if:IfTrue>
    <if:IfTrue cond='<%= jobreq.illegal(reqformBean.getProblemDetails3()) %>' >
      <jsp:setProperty name="reqformBean" property="problemDetails3Error" value="#ff6565" />
      <% formCorrect = false; %>
      <% illegalChars = true; %>
    </if:IfTrue>
    <if:IfTrue cond='<%= jobreq.illegal(reqformBean.getProblemDetails4()) %>' >
      <jsp:setProperty name="reqformBean" property="problemDetails4Error" value="#ff6565" />
      <% formCorrect = false; %>
      <% illegalChars = true; %>
    </if:IfTrue>
    <if:IfTrue cond='<%= jobreq.illegal(reqformBean.getAssetId())%>' >
      <jsp:setProperty name="reqformBean" property="assetIdError" value="#ff6565" />
      <% formCorrect = false; %>
      <% illegalChars = true; %>
    </if:IfTrue>
    
    <%-- Check for a valid asset_id --%>
    <if:IfTrue cond='<%= reqformBean.getAssetId() != null &&
                         !(reqformBean.getAssetId().trim().equals("")) &&
                         illegalChars == false %>' >
      <% boolean nA = jobreq.controller1(jobreq.apostrophe(reqformBean.getAssetId())); %>
      <if:IfTrue cond='<%= nA == true %>' >
        <jsp:setProperty name="reqformBean" property="assetIdError" value="#ff6565" />
        <% formCorrect = false; %>
        <% noAsset = true; %>
      </if:IfTrue>
    </if:IfTrue>
    
    <if:IfTrue cond='<%= formCorrect == false %>' >
      <% errorMessage = "All RED fields below must be filled in."; %>
      
      <if:IfTrue cond='<%= noAsset == true %>' >
        <% errorMessage = errorMessage + "<br>The Asset Id does not exist please use another one."; %>
      </if:IfTrue>
      
      <if:IfTrue cond='<%= illegalChars == true %>' >
        <% errorMessage = errorMessage + "<br>An illegal character;<br>&nbsp;&nbsp;&nbsp;*(asterisk), ~(tilde), |(pipe) or \\(backslash)<br>has been used in the input. Please remove before resubmitting."; %>
      </if:IfTrue>
      
      <%-- Set the error message --%>
      <jsp:setProperty name="reqformBean" property="error" value='<%= errorMessage %>' />
      
      <%-- Close the database --%>
      <% jobreq.disconnect(); %>
      
    	<jsp:forward page="reqformView.jsp" />
    </if:IfTrue>
    
  	<%-- Fault already logged --%>
  	<if:IfTrue cond='<%= !reqformBean.getUniqueId().equals(session.getAttribute("uniqueId")) %>' >
      <%-- Close the database --%>
      <% jobreq.disconnect(); %>
      
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">dataExpired</sess:setAttribute>
      <jsp:forward page="dataExpiredScript.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
  	<%-- process the request if everything is OK --%>
  	<%-- Replace '(apostrophe) with two e.g. '' This will result in one being entered in the database --%>
    <%
      numTries = Integer.parseInt((String) getServletContext().getInitParameter("numTries"));
      timeTries = Integer.parseInt((String) getServletContext().getInitParameter("timeTries"));
      nextCwJobId = jobreq.controller2(jobreq.apostrophe(reqformBean.getUserName()),
                                       jobreq.apostrophe(reqformBean.getUserContact()),
                                       jobreq.apostrophe(reqformBean.getAssetId()),
                                       jobreq.apostrophe(reqformBean.getJobType()),
                                       jobreq.apostrophe(reqformBean.getProblemDetails1()),
                                       jobreq.apostrophe(reqformBean.getProblemDetails2()),
                                       jobreq.apostrophe(reqformBean.getProblemDetails3()),
                                       jobreq.apostrophe(reqformBean.getProblemDetails4()),
                                       jobreq.apostrophe(reqformBean.getUserEmail()),
                                       numTries,
                                       timeTries);
      reqformBean.setNextCwJobId(String.valueOf(nextCwJobId));
    %>
  	
  	<%-- Close the database --%>
    <% jobreq.disconnect(); %>
    
    <%-- Email section --%>
    <%-- Send mail if using mail --%>
    <app:equalsInitParameter name="useMail" match="yes">
      <%-- Creating the email message --%>
      <%
        message = "Raised By: " + reqformBean.getUserName() + 
                  "\nContact Number: " + reqformBean.getUserContact() +
                  "\nEmail Address: " + reqformBean.getUserEmail() +
                  "\n\nAsset Id: " + reqformBean.getAssetId() +
                  "\nJob Type: " + reqformBean.getJobType() +
                  "\n\nProblem:\n" + 
                  reqformBean.getProblemDetails1() + "\n" +
                  reqformBean.getProblemDetails2() + "\n" +
                  reqformBean.getProblemDetails3() + "\n" +
                  reqformBean.getProblemDetails4();
                  
        mailServer = (String) getServletContext().getInitParameter("mailServer");
        helpdesk = (String) getServletContext().getInitParameter("helpdesk");
      %>
      <mail:mail server="<%=mailServer%>">
        <mail:setrecipient type="to"><%=helpdesk%></mail:setrecipient>
        <mail:from>FaultLog</mail:from>
        <mail:subject>New fault - Job Id: <%=reqformBean.getNextCwJobId()%></mail:subject>
        <mail:message><%=message%></mail:message>
        <mail:send/>
      </mail:mail>
    </app:equalsInitParameter>
    
    <%-- Create unique ID --%>
    <sess:session id="ss"/>
    <sess:setAttribute name="uniqueId"><jsp:getProperty name="ss" property="sessionId"/><date:currentTime/></sess:setAttribute>
    
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">newreq</sess:setAttribute>
  	<jsp:forward page="newreqScript.jsp" />
  </if:IfTrue>
  
  <%-- New request --%>
  <if:IfTrue cond='<%= reqformBean.getAction().equals("New Request") %>' >
    <%-- clear form fields --%>
    <jsp:setProperty name="reqformBean" property="action" value="" />
    <jsp:setProperty name="reqformBean" property="all" value="clear" />
  
  	<jsp:forward page="reqformView.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="reqformView.jsp" />
