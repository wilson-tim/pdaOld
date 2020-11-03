<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.avStatusBean, com.vsb.avMultiStatusBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>

<jsp:useBean id="avStatusBean" scope="session" class="com.vsb.avStatusBean" />
<jsp:useBean id="avMultiStatusBean" scope="session" class="com.vsb.avMultiStatusBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="avStatus" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="avStatus" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <%-- Clear input data only --%>
    <jsp:setProperty name="avStatusBean" property="all" value="clear" />
    <jsp:setProperty name="avStatusBean" property="*" />

    <%-- Add the new values to the record --%>
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="avStatusBean" property="error" value="" />

<%-- clear form fields if coming from previous form --%>
<sess:equalsAttribute name="input" match="avAddDetails" >
  <jsp:setProperty name="avStatusBean" property="action" value="" />
  <jsp:setProperty name="avStatusBean" property="all" value="clear" />
  <jsp:setProperty name="avMultiStatusBean" property="all" value="clear" />
  <jsp:setProperty name="avStatusBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form --%>
<sess:equalsAttribute name="input" match="inspDate" >
  <jsp:setProperty name="avStatusBean" property="action" value="" />
  <jsp:setProperty name="avStatusBean" property="all" value="clear" />
  <jsp:setProperty name="avMultiStatusBean" property="all" value="clear" />
  <jsp:setProperty name="avStatusBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if returning from addEnforcement --%>
<sess:equalsAttribute name="input" match="addEnforcement" >
  <jsp:setProperty name="avStatusBean" property="all" value="clear" />
  <%-- <jsp:setProperty name="avMultiStatusBean" property="all" value="clear" /> --%>
  <%
    int size = avMultiStatusBean.size();
    int ix = size - 1;
    String ref = avMultiStatusBean.getStatusByIx(ix);
    avStatusBean.setStatus_ref(ref);
    String text = avMultiStatusBean.getTextByIx(ix);
    avStatusBean.setText(text);
    avMultiStatusBean.removeStatus(ix);
    avMultiStatusBean.removeText(ix);
    avMultiStatusBean.setStatus_count(ix);
  %>
</sess:equalsAttribute>

<%-- clear form fields if returning from W/O --%>
<sess:equalsAttribute name="input" match="contract" >
  <jsp:setProperty name="avStatusBean" property="all" value="clear" />
  <%-- <jsp:setProperty name="avMultiStatusBean" property="all" value="clear" /> --%>
  <%
    int size = avMultiStatusBean.size();
    int ix = size - 1;
    String ref = avMultiStatusBean.getStatusByIx(ix);
    avStatusBean.setStatus_ref(ref);
    String text = avMultiStatusBean.getTextByIx(ix);
    avStatusBean.setText(text);
    avMultiStatusBean.removeStatus(ix);
    avMultiStatusBean.removeText(ix);
    avMultiStatusBean.setStatus_count(ix);
  %>
</sess:equalsAttribute>
<sess:equalsAttribute name="input" match="suffix" >
  <jsp:setProperty name="avStatusBean" property="all" value="clear" />
  <%-- <jsp:setProperty name="avMultiStatusBean" property="all" value="clear" /> --%>
  <%
    int size = avMultiStatusBean.size();
    int ix = size - 1;
    String ref = avMultiStatusBean.getStatusByIx(ix);
    avStatusBean.setStatus_ref(ref);
    String text = avMultiStatusBean.getTextByIx(ix);
    avStatusBean.setText(text);
    avMultiStatusBean.removeStatus(ix);
    avMultiStatusBean.removeText(ix);
    avMultiStatusBean.setStatus_count(ix);
  %>
</sess:equalsAttribute>
<sess:equalsAttribute name="input" match="woType" >
  <jsp:setProperty name="avStatusBean" property="all" value="clear" />
  <%-- <jsp:setProperty name="avMultiStatusBean" property="all" value="clear" /> --%>
  <%
    int size = avMultiStatusBean.size();
    int ix = size - 1;
    String ref = avMultiStatusBean.getStatusByIx(ix);
    avStatusBean.setStatus_ref(ref);
    String text = avMultiStatusBean.getTextByIx(ix);
    avStatusBean.setText(text);
    avMultiStatusBean.removeStatus(ix);
    avMultiStatusBean.removeText(ix);
    avMultiStatusBean.setStatus_count(ix);
  %>
</sess:equalsAttribute>
<sess:equalsAttribute name="input" match="woTask" >
  <jsp:setProperty name="avStatusBean" property="all" value="clear" />
  <%-- <jsp:setProperty name="avMultiStatusBean" property="all" value="clear" /> --%>
  <%
    int size = avMultiStatusBean.size();
    int ix = size - 1;
    String ref = avMultiStatusBean.getStatusByIx(ix);
    avStatusBean.setStatus_ref(ref);
    String text = avMultiStatusBean.getTextByIx(ix);
    avStatusBean.setText(text);
    avMultiStatusBean.removeStatus(ix);
    avMultiStatusBean.removeText(ix);
    avMultiStatusBean.setStatus_count(ix);
  %>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="avStatus" >
  <if:IfTrue cond='<%= avStatusBean.getAction().equals("Finish") ||
                       avStatusBean.getAction().equals("Add Another Status") ||
                       avStatusBean.getAction().equals("W/O") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= avStatusBean.getStatus_ref() == null || avStatusBean.getStatus_ref().trim().equals("") %>' >
      <jsp:setProperty name="avStatusBean" property="error"
        value="Please choose a Status." />
      <jsp:forward page="avStatusView.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond='<%= avStatusBean.getAction().equals("Add Another Status") %>' >
      <%-- Check to see if the new status closes the complaint --%>
      <% boolean closeComp = false; %>
      <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con1">
        <sql:query>
          SELECT closed_yn
            FROM av_status
          WHERE status_ref = '<%= avStatusBean.getStatus_ref() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="closed_yn" />
          <if:IfTrue cond='<%= helperBean.isNotValid( pageContext.getAttribute("closed_yn") ) %>'>
            <% pageContext.setAttribute("closed_yn", ""); %>
          </if:IfTrue>
          <if:IfTrue cond='<%= ((String)pageContext.getAttribute("closed_yn")).trim().equals("Y") %>'>
            <% closeComp = true; %>
          </if:IfTrue>
        </sql:resultSet>
      </sql:statement>
      <sql:closeConnection conn="con1"/>
      <if:IfTrue cond='<%= closeComp %>' >
        <jsp:setProperty name="avStatusBean" property="error"
          value="The current status will close the complaint.<br/>No further statuses can be selected." />
        <jsp:forward page="avStatusView.jsp" />
      </if:IfTrue>
    </if:IfTrue>

    <%-- Valid entry --%>
    <%
      avMultiStatusBean.setStatuses(avStatusBean.getStatus_ref());

      // Get rid of newline and carriage return chars from the notes
      String tempTextIn = avStatusBean.getText();
      tempTextIn = tempTextIn.replace('\n',' ');
      tempTextIn = tempTextIn.replace('\r',' ');      
      avMultiStatusBean.setTexts(tempTextIn);

      // Increment status_count
      int status_count = avMultiStatusBean.getStatus_count();
      status_count++;
      avMultiStatusBean.setStatus_count(status_count);
    %>
  </if:IfTrue>
  
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= avStatusBean.getAction().equals("Add Another Status") %>' >
    <%
      // Get ready to display the form again      
      avStatusBean.setStatus_ref("");
      avStatusBean.setText("");
    %>
    <jsp:forward page="avStatusView.jsp" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= avStatusBean.getAction().equals("Finish") && !recordBean.getAction_flag().equals("W") %>' >
    <%-- Add the new values to the record --%>
    <%
      // recordBean.setAv_status_ref(avStatusBean.getStatus_ref());

      String tempTextIn = avStatusBean.getText();
      tempTextIn = tempTextIn.replace('\n',' ');
      tempTextIn = tempTextIn.replace('\r',' ');      
      avStatusBean.setText(tempTextIn);
      // recordBean.setAv_notes(tempTextIn);
    %>
    <%-- Indicate if we want to set up a Works Order, or just complete the AV --%>
    <% recordBean.setAv_action_flag("S"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">avStatus</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">addEnforcement</sess:setAttribute>
    <c:redirect url="addEnforcementScript.jsp" />
  </if:IfTrue>

  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= avStatusBean.getAction().equals("W/O") || (avStatusBean.getAction().equals("Finish") && recordBean.getAction_flag().equals("W")) %>' >
    <%-- Add the new values to the record --%>
    <%
      // recordBean.setAv_status_ref(avStatusBean.getStatus_ref());

      String tempTextIn = avStatusBean.getText();
      tempTextIn = tempTextIn.replace('\n',' ');
      tempTextIn = tempTextIn.replace('\r',' ');      
      avStatusBean.setText(tempTextIn);
      // recordBean.setAv_notes(tempTextIn);
    %>
    <%-- Indicate if we want to set up a Works Order, or just complete the AV --%>
    <% recordBean.setAv_action_flag("W"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">avStatus</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">contract</sess:setAttribute>
    <c:redirect url="contractScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= avStatusBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">avStatus</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>
  
  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= avStatusBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">avStatus</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>
 
  <%-- Previous view --%>
  <if:IfTrue cond='<%= avStatusBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">avStatus</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= avStatusBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${avStatusBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="avStatusView.jsp" />
