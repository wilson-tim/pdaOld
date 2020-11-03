<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.doorstepFaultBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>

<jsp:useBean id="doorstepFaultBean" scope="session" class="com.vsb.doorstepFaultBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="doorstepFault" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>


<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="doorstepFault" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="doorstepFaultBean" property="all" value="clear" />
    <jsp:setProperty name="doorstepFaultBean" property="*" />
    
    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="default_fault_code" value='<%= doorstepFaultBean.getLookup_code() %>' />
    
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
     
      <sql:query>
        select lookup_text, lookup_num
        from allk
        where lookup_func = 'DEFRN'
        and   lookup_code = '<%= recordBean.getDefault_fault_code() %>'
      </sql:query>
      <sql:resultSet id="rset">
         <sql:getColumn position="1" to="lookup_text" />
         <% recordBean.setFault_desc((String) pageContext.getAttribute("lookup_text")); %>
         <sql:getColumn position="2" to="lookup_num" />
         <% recordBean.setNotice_no((String) pageContext.getAttribute("lookup_num")); %>
      </sql:resultSet>

    </sql:statement>
    <sql:closeConnection conn="con"/>
      
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="doorstepFaultBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="doorstepSurvey" >
  <jsp:setProperty name="doorstepFaultBean" property="action" value="" />
  <jsp:setProperty name="doorstepFaultBean" property="all" value="clear" />
  <jsp:setProperty name="doorstepFaultBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="doorstepFault" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= doorstepFaultBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=doorstepFaultBean.getLookup_code() == null || doorstepFaultBean.getLookup_code().equals("") %>' >
      <jsp:setProperty name="doorstepFaultBean" property="error"
        value="Please choose a fault." />
      <jsp:forward page="doorstepFaultView.jsp" />
    </if:IfTrue>    
    <%-- Valid entry --%>
    <%-- we are doing a default --%>
    <% recordBean.setAction_flag("D"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">doorstepFault</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">addEnforcement</sess:setAttribute>
    <c:redirect url="addEnforcementScript.jsp" />
  </if:IfTrue>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= doorstepFaultBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">doorstepFault</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= doorstepFaultBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">doorstepFault</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= doorstepFaultBean.getAction().equals("Back") %>' >
    <% recordBean.setFly_cap_flag("N"); %>
    <% recordBean.setAction_flag(""); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">doorstepFault</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= doorstepFaultBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${doorstepFaultBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="doorstepFaultView.jsp" />
