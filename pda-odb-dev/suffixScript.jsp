<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.suffixBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="suffixBean" scope="session" class="com.vsb.suffixBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="suffix" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="suffix" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="suffixBean" property="all" value="clear" />
    <jsp:setProperty name="suffixBean" property="*" />
    
    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="wo_suffix" param="wo_suffix" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="suffixBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="contract" >
  <jsp:setProperty name="suffixBean" property="action" value="" />
  <jsp:setProperty name="suffixBean" property="all" value="clear" />
  <jsp:setProperty name="suffixBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>


<% 
  String defect_suffix = "";
  String tree_suffix = "";
  boolean tree_flag = false;
  if(recordBean.getService_c().equals(recordBean.getTrees_service())) {
    tree_flag = true;
  };
%>

<sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
<sql:statement id="stmt" conn="con">
  <%-- Checking suffix count --%>
  <sql:query>
    select count(distinct wo_suffix)
    from wo_s
    where contract_ref = '<%= recordBean.getWo_contract_ref() %>'
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="suffix_count" />
    <% recordBean.setSuffix_count((String) pageContext.getAttribute("suffix_count")); %>
  </sql:resultSet>

  <%-- Checking defect suffix --%>
  <sql:query>
    select distinct wo_suffix
    from measurement_task
    where priority = '<%= recordBean.getDefect_priority() %>'
    and   contract_ref = '<%= recordBean.getWo_contract_ref() %>'
    and   item_ref = '<%= recordBean.getItem_ref() %>'
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="defect_suffix" />
    <sql:wasNotNull>
      <% defect_suffix = ((String) pageContext.getAttribute("defect_suffix")).trim(); %>
    </sql:wasNotNull>
  </sql:resultSet>

  <%-- Checking trees suffix --%>
  <if:IfTrue cond='<%= tree_flag %>' >
    <% int tree_height_ref = 0; %>
    <sql:query>
      select height_ref
      from trees
      where tree_ref = '<%= recordBean.getTree_ref() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="height_ref" />
      <sql:wasNotNull>
        <% tree_height_ref = Integer.parseInt((String) pageContext.getAttribute("height_ref")); %>
      </sql:wasNotNull>
    </sql:resultSet>
    
    <if:IfTrue cond='<%= tree_height_ref != 0 %>' >
      <sql:query>
        select distinct wo_suffix
        from tree_suffix_link
        where height_ref = <%= tree_height_ref %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="tree_suffix" />
        <sql:wasNotNull>
          <% tree_suffix = ((String) pageContext.getAttribute("tree_suffix")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>
    </if:IfTrue>
  </if:IfTrue>
</sql:statement>
<sql:closeConnection conn="con"/>

<%-- Skip View Section --%>
<%-- Set up a variable to to show if defects are being used --%>
<% 
  boolean defect_flag = false;
  if(recordBean.getDefect_flag().equals("Y") || recordBean.getDefect_flag().equals("A") || recordBean.getDefect_flag().equals("I")) {
   defect_flag = true;
  };
%>  
<%-- Don't skip if coming from the view --%>
<sess:equalsAttribute name="input" match="suffix" value="false">
  <%-- if only one record found then skip to the next page, by faking it so that it appears the user --%>
  <%-- has just selected the one item and clicked the next page button. --%>
  <%-- Do backwards skip first, as forward skip sets the 'input' session variable --%>
  <sess:equalsAttribute name="input" match="contract" value="false">
    <if:IfTrue cond='<%= (!defect_flag && recordBean.getSuffix_count().equals("1")) || (defect_flag && !defect_suffix.equals("")) || (tree_flag && !tree_suffix.equals("")) %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">suffix</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form"><%= suffixBean.getSavedPreviousForm() %></sess:setAttribute>
      <c:redirect url="${suffixBean.savedPreviousForm}Script.jsp" />
    </if:IfTrue>
  </sess:equalsAttribute>
  <%-- Do forwards skip --%>
  <sess:equalsAttribute name="input" match="contract" >
    <if:IfTrue cond='<%= (!defect_flag && recordBean.getSuffix_count().equals("1")) || (defect_flag && !defect_suffix.equals(""))  || (tree_flag && !tree_suffix.equals("")) %>' >
      <%-- This section mimics the 'input' section at the top of the script --%>
      <%-- manually imitating a user interaction with the view, but without showing the view --%>
  
      <%-- Indicate which form we are in/just-come-from --%>
      <sess:setAttribute name="input">suffix</sess:setAttribute>
  
      <%-- Setup the bean with the forms data manually --%>
      <jsp:setProperty name="suffixBean" property="all" value="clear" />
      <jsp:setProperty name="suffixBean" property="action" value="Next" />
  
      <if:IfTrue cond='<%= !defect_flag && !tree_flag && recordBean.getSuffix_count().equals("1") %>' >
        <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
        <sql:statement id="stmt" conn="con">
          <sql:query>
            select distinct wo_suffix
            from wo_s
            where contract_ref = '<%= recordBean.getWo_contract_ref() %>'
            order by wo_suffix
          </sql:query>
          <sql:resultSet id="rset">
            <sql:getColumn position="1" to="wo_suffix" />
            <% recordBean.setWo_suffix((String) pageContext.getAttribute("wo_suffix")); %>
            <% suffixBean.setWo_suffix((String) pageContext.getAttribute("wo_suffix")); %>
          </sql:resultSet>
        </sql:statement>
        <sql:closeConnection conn="con"/>
      </if:IfTrue>
      <if:IfTrue cond='<%= defect_flag && !defect_suffix.equals("") %>' >
        <% recordBean.setWo_suffix(defect_suffix); %>
        <% suffixBean.setWo_suffix(defect_suffix); %>
      </if:IfTrue>
      <if:IfTrue cond='<%= tree_flag && !tree_suffix.equals("") %>' >
        <% recordBean.setWo_suffix(tree_suffix); %>
        <% suffixBean.setWo_suffix(tree_suffix); %>
      </if:IfTrue>
    </if:IfTrue>
  </sess:equalsAttribute>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="suffix" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= suffixBean.getAction().equals("Next") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= suffixBean.getWo_suffix() == null || suffixBean.getWo_suffix().equals("") %>' >
      <jsp:setProperty name="suffixBean" property="error"
        value="Please choose a suffix." />
      <jsp:forward page="suffixView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">suffix</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">woType</sess:setAttribute>
    <c:redirect url="woTypeScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= suffixBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">suffix</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= suffixBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">suffix</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= suffixBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">suffix</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= suffixBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${suffixBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="suffixView.jsp" />
