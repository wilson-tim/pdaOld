<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.tradeDetailsBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"      prefix="sql"  %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req"  %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if"   %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c"    %>

<jsp:useBean id="tradeDetailsBean" scope="session" class="com.vsb.tradeDetailsBean" />
<jsp:useBean id="recordBean"       scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean"       scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="tradeDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="tradeDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="tradeDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="tradeDetailsBean" property="*" />

  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="tradeDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="compSampDetails" >
  <jsp:setProperty name="tradeDetailsBean" property="action" value="" />
  <jsp:setProperty name="tradeDetailsBean" property="all"    value="clear" />
  <jsp:setProperty name="tradeDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>
<sess:equalsAttribute name="input" match="defaultDetails" >
  <jsp:setProperty name="tradeDetailsBean" property="action" value="" />
  <jsp:setProperty name="tradeDetailsBean" property="all"    value="clear" />
  <jsp:setProperty name="tradeDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="tradeDetails" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <sql:query>
        SELECT agreement_no
          FROM agree_task
         WHERE agree_task_no = <%= recordBean.getTat_no() %>
      </sql:query>
      <sql:resultSet id="rset1">
        <sql:getColumn position="1" to="agreement_no" />
        <% tradeDetailsBean.setAgreement_no((String) pageContext.getAttribute("agreement_no")); %>
      </sql:resultSet>

      <sql:query>
        SELECT agreement_name
          FROM agreement
         WHERE agreement_no = <%= tradeDetailsBean.getAgreement_no() %>
      </sql:query>
      <sql:resultSet id="rset1">
        <sql:getColumn position="1" to="agreement_name" />
        <% tradeDetailsBean.setAgreement_name((String) pageContext.getAttribute("agreement_name")); %>
      </sql:resultSet>
    </sql:statement>
    <sql:closeConnection conn="con"/>
  </if:IfTrue>
</sess:equalsAttribute>
  
<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="tradeDetails" >

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= tradeDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">tradeDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= tradeDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">tradeDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= tradeDetailsBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">tradeDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= tradeDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${tradeDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>  

</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="tradeDetailsView.jsp" />
