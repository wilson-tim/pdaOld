<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.serviceBean, com.vsb.recordBean, com.vsb.addCustDetailsBean" %>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="serviceBean" scope="session" class="com.vsb.serviceBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="addCustDetailsBean" scope="session" class="com.vsb.addCustDetailsBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="service" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="service" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="serviceBean" property="all" value="clear" />
    <jsp:setProperty name="serviceBean" property="*" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="service_c" param="service_c" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="serviceBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="locLookup" >
  <jsp:setProperty name="serviceBean" property="action" value="" />
  <jsp:setProperty name="serviceBean" property="all" value="clear" />
  <jsp:setProperty name="serviceBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="updateStatus" >
  <jsp:setProperty name="serviceBean" property="action" value="" />
  <jsp:setProperty name="serviceBean" property="all" value="clear" />
  <jsp:setProperty name="serviceBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
<sql:statement id="stmt" conn="con">
  <%-- The module is inspectors --%>
  <app:equalsInitParameter name="module" match="pda-in" >
    <sql:query>
      select c_field
      from keys
      where service_c = 'ALL'
      and   keyname = 'PDA_INSPECTOR_ROLE'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="pda_role" />
      <% recordBean.setPda_role((String) pageContext.getAttribute("pda_role")); %>
    </sql:resultSet>
  </app:equalsInitParameter>

  <%-- The module is town warden --%>
  <app:equalsInitParameter name="module" match="pda-tw" >
    <sql:query>
      select c_field
      from keys
      where service_c = 'ALL'
      and   keyname = 'PDA_WARDEN_ROLE'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="pda_role" />
      <% recordBean.setPda_role((String) pageContext.getAttribute("pda_role")); %>
    </sql:resultSet>
  </app:equalsInitParameter>

  <sql:query>
    select c_field
    from keys
    where keyname = 'AV_SERVICE'
    and   service_c = 'ALL'
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="av_service" />
    <% recordBean.setAv_service((String) pageContext.getAttribute("av_service")); %>
  </sql:resultSet>

  <sql:query>
    select c_field
    from keys
    where keyname = 'HWAY_SERVICE'
    and   service_c = 'ALL'
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="hway_service" />
    <% recordBean.setHway_service((String) pageContext.getAttribute("hway_service")); %>
  </sql:resultSet>

  <sql:query>
    select c_field
    from keys
    where keyname = 'TREES_SERVICE'
    and   service_c = 'ALL'
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="trees_service" />
    <% recordBean.setTrees_service((String) pageContext.getAttribute("trees_service")); %>
  </sql:resultSet>

  <sql:query>
    select c_field
    from keys
    where keyname = 'ENF_SERVICE'
    and   service_c = 'ALL'
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="enf_service" />
    <% recordBean.setEnf_service((String) pageContext.getAttribute("enf_service")); %>
  </sql:resultSet>

  <%-- Check to see if Contender is running the Trees service--%>
  <% String trees_installation = "N"; %>
  <sql:query>
    SELECT c_field
    FROM keys
    WHERE keyname = 'TREES_INSTALLATION'
    AND service_c = 'ALL'
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="trees_installation" />
    <sql:wasNull>
      <% pageContext.setAttribute("trees_installation","N"); %>
    </sql:wasNull>
    <% trees_installation = ((String)pageContext.getAttribute("trees_installation")).trim(); %>
  </sql:resultSet>
  <sql:wasEmpty>
    <% trees_installation = "N"; %>
  </sql:wasEmpty>
  <% recordBean.setTrees_inst(trees_installation); %>

  <sql:query>
    select count(distinct service_c)
    from pda_lookup
    where role_name = '<%= recordBean.getPda_role() %>'
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="service_count" />
    <% recordBean.setService_count((String) pageContext.getAttribute("service_count")); %>
  </sql:resultSet>
</sql:statement>
<sql:closeConnection conn="con"/>

<%-- Skip View Section --%>
<%-- Only allow skip if allowed --%>
<app:equalsInitParameter name="use_property_service_skip" match="Y">
  <%-- if only one record found then skip to the next page, by faking it so that it appears the user --%>
  <%-- has just selected the one item and clicked the next page button. --%>
  <%-- Do backwards skip first, as forward skip sets the 'input' session variable --%>
  <sess:equalsAttribute name="input" match="locLookup" value="false">
    <if:IfTrue cond='<%= recordBean.getService_count().equals("1") %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">service</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form"><%= serviceBean.getSavedPreviousForm() %></sess:setAttribute>
      <c:redirect url="${serviceBean.savedPreviousForm}Script.jsp" />
    </if:IfTrue>
  </sess:equalsAttribute>
  <%-- Do forwards skip --%>
  <sess:equalsAttribute name="input" match="locLookup" >
    <if:IfTrue cond='<%= recordBean.getService_count().equals("1") %>' >
      <%-- This section mimics the 'input' section at the top of the script --%>
      <%-- manually imitating a user interaction with the view, but without showing the view --%>
  
      <%-- Indicate which form we are in/just-come-from --%>
      <sess:setAttribute name="input">service</sess:setAttribute>
  
      <%-- Setup the bean with the forms data manually --%>
      <jsp:setProperty name="serviceBean" property="all" value="clear" />
      <jsp:setProperty name="serviceBean" property="action" value="Item" />
  
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
        <sql:query>
          select distinct service_c
          from pda_lookup
          where role_name = '<%= recordBean.getPda_role() %>'
          order by service_c
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="service_c" />
          <% recordBean.setService_c((String) pageContext.getAttribute("service_c")); %>
          <% serviceBean.setService_c((String) pageContext.getAttribute("service_c")); %>
        </sql:resultSet>
      </sql:statement>
      <sql:closeConnection conn="con"/>
    </if:IfTrue>
  </sess:equalsAttribute>
</app:equalsInitParameter>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="service" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= serviceBean.getAction().equals("Item") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= serviceBean.getService_c() == null || serviceBean.getService_c().equals("") %>' >
      <jsp:setProperty name="serviceBean" property="error"
        value="Please choose a service." />
      <jsp:forward page="serviceView.jsp" />
    </if:IfTrue>    
    <if:IfTrue cond='<%= serviceBean.getService_c() == recordBean.getTrees_service() &&
                         recordBean.getTrees_inst().equals("N") %>' >
      <jsp:setProperty name="serviceBean" property="error"
        value="Trees service is not installed." />
      <jsp:forward page="serviceView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Allow user to add abandoned vehicle information if the --%>
    <%-- service is abandoned vehicle and the module is town warden --%>
    <if:IfTrue cond='<%= serviceBean.getService_c().equals(recordBean.getAv_service()) &&
                         application.getInitParameter("module").equals("pda-tw") %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">service</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">make</sess:setAttribute>
      <c:redirect url="makeScript.jsp" />
    </if:IfTrue>
    <%-- Allow user to add abandoned vehicle information if the --%>
    <%-- service is abandoned vehicle and the AV module is switched on --%>
    <if:IfTrue cond='<%= serviceBean.getService_c().equals(recordBean.getAv_service()) &&
                         application.getInitParameter("use_av").equals("Y") %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">service</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">avMake</sess:setAttribute>
      <c:redirect url="avMakeScript.jsp" />
    </if:IfTrue>
    <%-- Send the user to the trees list if the service is Trees --%>
    <if:IfTrue cond='<%= serviceBean.getService_c().equals(recordBean.getTrees_service()) %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">service</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">treesList</sess:setAttribute>
      <c:redirect url="treesListScript.jsp" />
    </if:IfTrue>
    <%-- Send the user to the enforcement section if the service is Enforcemenets --%>
    <if:IfTrue cond='<%= serviceBean.getService_c().equals(recordBean.getEnf_service()) %>' >
      <%-- Set all the flags to the correct values --%>
      <% addCustDetailsBean.setConfirm("No"); %>
      <% recordBean.setAction_flag("N"); %>
      <% recordBean.setEnf_list_flag("N"); %>
      <% recordBean.setEnforce_flag("Y"); %>
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
        <%-- Get the ENFORCE's patrol area --%>
        <sql:query>
          SELECT pa_area
          FROM site_pa
          WHERE site_ref = '<%= recordBean.getSite_ref() %>'
          AND   pa_func = 'ENFORC'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="pa_area" />
          <% recordBean.setPa_area((String) pageContext.getAttribute("pa_area")); %>
        </sql:resultSet>
      </sql:statement>
      <sql:closeConnection conn="con"/>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">service</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">law</sess:setAttribute>
      <c:redirect url="lawScript.jsp" />
    </if:IfTrue>    
    <%-- All other services use the same pages --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">service</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">itemLookup</sess:setAttribute>
    <c:redirect url="itemLookupScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= serviceBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">service</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= serviceBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">service</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= serviceBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">service</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= serviceBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${serviceBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="serviceView.jsp" />
