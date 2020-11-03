<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.pickFault1Bean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>

<jsp:useBean id="pickFault1Bean" scope="session" class="com.vsb.pickFault1Bean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="pickFault1" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="pickFault1" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="pickFault1Bean" property="all" value="clear" />
    <jsp:setProperty name="pickFault1Bean" property="*" />
    
    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="fault_code" value='<%= pickFault1Bean.getLookup_code() %>' />
    
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
      <sql:query>
        select lookup_text, lookup_num
        from allk
        where lookup_func = 'DEFRN'
        and   lookup_code = '<%= recordBean.getFault_code() %>'
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
<jsp:setProperty name="pickFault1Bean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="compSampDetails" >
  <jsp:setProperty name="pickFault1Bean" property="action" value="" />
  <jsp:setProperty name="pickFault1Bean" property="all" value="clear" />
  <jsp:setProperty name="pickFault1Bean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="pickFault1" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= pickFault1Bean.getAction().equals("Finish") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=pickFault1Bean.getLookup_code() == null || pickFault1Bean.getLookup_code().equals("") %>' >
      <jsp:setProperty name="pickFault1Bean" property="error"
        value="Please choose a fault." />
      <jsp:forward page="pickFault1View.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- indicate the route which will be taken to get to defaultAdditional --%>
    <% recordBean.setDefault_route("pickFault1"); %> 
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">pickFault1</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">streetLength</sess:setAttribute>
    <c:redirect url="streetLengthScript.jsp" />
  </if:IfTrue>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= pickFault1Bean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">pickFault1</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= pickFault1Bean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">pickFault1</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= pickFault1Bean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">pickFault1</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= pickFault1Bean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${pickFault1Bean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="pickFault1View.jsp" />
