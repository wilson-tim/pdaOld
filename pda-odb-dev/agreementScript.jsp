<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.agreementBean, com.vsb.recordBean, com.vsb.loginBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="agreementBean" scope="session" class="com.vsb.agreementBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="agreement" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="agreement" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="agreementBean" property="all" value="clear" />
    <jsp:setProperty name="agreementBean" property="*" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="ta_no" param="agreement_no" />    

  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="agreementBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="locLookup" >
  <jsp:setProperty name="agreementBean" property="action" value="" />
  <jsp:setProperty name="agreementBean" property="all" value="clear" />
  <jsp:setProperty name="agreementBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="agreement" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= agreementBean.getAction().equals("Tasks") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= agreementBean.getAgreement_no() == null || agreementBean.getAgreement_no().equals("") %>' >
      <jsp:setProperty name="agreementBean" property="error"
                      value="Please choose an item." />
      <jsp:forward page="agreementView.jsp" />
    </if:IfTrue>
    
    <%-- valid entry--%>
    <%-- Get the agreements name and number --%>
    <sql:connection id="conn1" jndiName="java:comp/env/jdbc/pda"/>
    <sql:statement id="stmt1" conn="conn1">
      <sql:query>
        SELECT agreement_name
          FROM agreement
         WHERE agreement_no = <%= recordBean.getTa_no() %>
      </sql:query>
      <sql:resultSet id="rset8">
        <sql:getColumn position="1" to="agreement_name" />
        <% recordBean.setTa_name((String) pageContext.getAttribute("agreement_name")); %>      
      </sql:resultSet>
    </sql:statement>
    <sql:closeConnection conn="conn1"/>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">agreement</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">taskAgreement</sess:setAttribute>
    <c:redirect url="taskAgreementScript.jsp" />    
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= agreementBean.getAction().equals("CWTN") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= agreementBean.getAgreement_no() == null || agreementBean.getAgreement_no().equals("") %>' >
      <jsp:setProperty name="agreementBean" property="error"
                      value="Please choose an item." />
      <jsp:forward page="agreementView.jsp" />
    </if:IfTrue>
    
    <%-- valid entry--%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">agreement</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">cwtnDetails</sess:setAttribute>
    <c:redirect url="cwtnDetailsScript.jsp" />    
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= agreementBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">agreement</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= agreementBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">agreement</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>
  
  <%-- Previous view --%>
  <if:IfTrue cond='<%= agreementBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">agreement</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= agreementBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${agreementBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="agreementView.jsp" />
