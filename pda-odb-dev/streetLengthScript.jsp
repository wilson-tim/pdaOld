<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.streetLengthBean, com.vsb.recordBean, com.vsb.surveyGradingBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="streetLengthBean" scope="session" class="com.vsb.streetLengthBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="streetLength" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="streetLength" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="streetLengthBean" property="all" value="clear" />
    <jsp:setProperty name="streetLengthBean" property="*" />
    
    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="algorithm" value='<%= streetLengthBean.getDefault_algorithm() %>' />
    
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="streetLengthBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="pickFault1" >
  <jsp:setProperty name="streetLengthBean" property="action" value="" />
  <jsp:setProperty name="streetLengthBean" property="all" value="clear" />
  <jsp:setProperty name="streetLengthBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="text" >
  <jsp:setProperty name="streetLengthBean" property="action" value="" />
  <jsp:setProperty name="streetLengthBean" property="all" value="clear" />
  <jsp:setProperty name="streetLengthBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="surveyAddDefault" >
  <jsp:setProperty name="streetLengthBean" property="action" value="" />
  <jsp:setProperty name="streetLengthBean" property="all" value="clear" />
  <jsp:setProperty name="streetLengthBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="graffDetails" >
  <jsp:setProperty name="streetLengthBean" property="action" value="" />
  <jsp:setProperty name="streetLengthBean" property="all" value="clear" />
  <jsp:setProperty name="streetLengthBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="flyCapUpdate" >
  <jsp:setProperty name="streetLengthBean" property="action" value="" />
  <jsp:setProperty name="streetLengthBean" property="all" value="clear" />
  <jsp:setProperty name="streetLengthBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Check to see if we should show the VIEW or go to the next SCRIPT, --%>
<%-- but only the first time through the SCRIPT --%>
<sess:equalsAttribute name="input" match="streetLength" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals("pickFault1") ||
                       ((String)session.getAttribute("input")).equals("text") || 
                       ((String)session.getAttribute("input")).equals("flyCapUpdate") || 
                       ((String)session.getAttribute("input")).equals("graffDetails") ||
                       ((String)session.getAttribute("input")).equals("surveyAddDefault") %>' >

    <%-- Set the default_level to 1 for use in later forms --%>
    <% recordBean.setDefault_level("1"); %>
    <% recordBean.setDefault_occ("1"); %>

    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
      <% recordBean.setShow_view("0"); %>
      <sql:query>
        select count(*)
        from defa
        where item_type = '<%= recordBean.getItem_type() %>'
        and   notice_rep_no = '<%= recordBean.getNotice_no() %>'
      </sql:query>
      <sql:resultSet id="rset">
         <sql:getColumn position="1" to="count" />
         <% recordBean.setShow_view(((String) pageContext.getAttribute("count")).trim()); %>
      </sql:resultSet>
      
      <%-- Only 1 result so set this as the algorithm --%>
      <if:IfTrue cond='<%= recordBean.getShow_view().equals("1") %>' >
        <sql:query>
          select default_algorithm
          from defa
          where item_type = '<%= recordBean.getItem_type() %>'
          and   notice_rep_no = '<%= recordBean.getNotice_no() %>'
        </sql:query>
        <sql:resultSet id="rset">
           <sql:getColumn position="1" to="algorithm" />
           <% recordBean.setAlgorithm(((String) pageContext.getAttribute("algorithm")).trim()); %>
        </sql:resultSet>

        <sql:query>
          select count(*)
          from defa, defp1, pda_algorithm
          where defa.item_type = '<%= recordBean.getItem_type() %>'
          and   defa.notice_rep_no = '<%= recordBean.getNotice_no() %>'
          and   defp1.algorithm = defa.default_algorithm
          and   defp1.default_level = '<%= recordBean.getDefault_level() %>'
          and   defp1.item_type = '<%= recordBean.getItem_type() %>'
          and   defp1.contract_ref = '<%= recordBean.getContract_ref() %>'
          and   defp1.priority = '<%= recordBean.getPriority() %>'
          and   pda_algorithm.algorithm = defa.default_algorithm
          and   pda_algorithm.item_type = '<%= recordBean.getItem_type() %>'
          and   pda_algorithm.contract_ref = '<%= recordBean.getContract_ref() %>'
          and   pda_algorithm.priority = '<%= recordBean.getPriority() %>'
         </sql:query>
         <sql:resultSet id="rset">
           <sql:getColumn position="1" to="count" />
           <% recordBean.setShow_view(((String) pageContext.getAttribute("count")).trim()); %>
         </sql:resultSet>
      </if:IfTrue>

    </sql:statement>
    <sql:closeConnection conn="con"/>

    <if:IfTrue cond='<%= recordBean.getShow_view().equals("1") %>' >
      <%-- nothing to do in this form so move to the next --%>
      <%-- Indicate that the input section has been passed through --%>
      <sess:setAttribute name="input">streetLength</sess:setAttribute>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm"><%= streetLengthBean.getSavedPreviousForm() %></sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">defaultDate</sess:setAttribute>
      <c:redirect url="defaultDateScript.jsp" />
    </if:IfTrue>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="streetLength" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= streetLengthBean.getAction().equals("Finish") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=streetLengthBean.getDefault_algorithm() == null || streetLengthBean.getDefault_algorithm().equals("") %>' >
      <jsp:setProperty name="streetLengthBean" property="error"
        value="Please choose an algorithm." />
      <jsp:forward page="streetLengthView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">streetLength</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">defaultDate</sess:setAttribute>
    <c:redirect url="defaultDateScript.jsp" />
  </if:IfTrue>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= streetLengthBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">streetLength</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= streetLengthBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">streetLength</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= streetLengthBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">streetLength</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= streetLengthBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${streetLengthBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="streetLengthView.jsp" />
