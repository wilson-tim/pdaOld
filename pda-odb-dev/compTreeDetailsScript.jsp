<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.compTreeDetailsBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req"  %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c"    %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if"   %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"      prefix="sql"  %>

<jsp:useBean id="compTreeDetailsBean" scope="session" class="com.vsb.compTreeDetailsBean" />
<jsp:useBean id="recordBean"      scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="compTreeDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="compTreeDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="compTreeDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="compTreeDetailsBean" property="*" />

  </if:IfParameterEquals>
</req:existsParameter>
    
<%-- clear errors --%>
<jsp:setProperty name="compTreeDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="compSampDetails" >
  <jsp:setProperty name="compTreeDetailsBean" property="action" value="" />
  <jsp:setProperty name="compTreeDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="compTreeDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="defaultDetails" >
  <jsp:setProperty name="compTreeDetailsBean" property="action" value="" />
  <jsp:setProperty name="compTreeDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="compTreeDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="compTreeDetails" value="false">
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
      <sql:query>
        SELECT tree_desc,
               tr_no,
               position,
               position_ref,
               species_ref,
               height_ref,
               age_ref,
               crown_ref,
               dbh_ref,
               condition_ref,
               vigour_ref,
               pavement_ref,
               boundary_ref,
               building_ref,
               issue_ref,
               easting,
               northing
          FROM trees
         WHERE tree_ref = <%= recordBean.getTree_ref() %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="tree_desc" />
        <sql:wasNotNull>
          <% compTreeDetailsBean.setTree_desc( (String)pageContext.getAttribute("tree_desc") ); %>
        </sql:wasNotNull>
        <sql:getColumn position="2" to="tr_no" />
        <sql:wasNotNull>
          <% compTreeDetailsBean.setTr_no( (String)pageContext.getAttribute("tr_no") ); %>
        </sql:wasNotNull>
        <sql:getColumn position="3" to="position" />
        <sql:wasNotNull>
          <% compTreeDetailsBean.setPosition( (String)pageContext.getAttribute("position") ); %>
        </sql:wasNotNull>
        <sql:getColumn position="4" to="position_ref" />
        <sql:wasNotNull>
          <% compTreeDetailsBean.setPosition_ref( (String)pageContext.getAttribute("position_ref") ); %>
        </sql:wasNotNull>        
        <sql:getColumn position="5" to="species_ref" />
        <sql:wasNotNull>
          <% compTreeDetailsBean.setSpecies_ref( (String)pageContext.getAttribute("species_ref") ); %>
        </sql:wasNotNull>
        <sql:getColumn position="6" to="height_ref" />
        <sql:wasNotNull>
          <% compTreeDetailsBean.setHeight_ref( (String)pageContext.getAttribute("height_ref") ); %>
        </sql:wasNotNull>
        <sql:getColumn position="7" to="age_ref" />
        <sql:wasNotNull>
          <% compTreeDetailsBean.setAge_ref( (String)pageContext.getAttribute("age_ref") ); %>
        </sql:wasNotNull>
        <sql:getColumn position="8" to="crown_ref" />
        <sql:wasNotNull>
          <% compTreeDetailsBean.setCrown_ref( (String)pageContext.getAttribute("crown_ref") ); %>
        </sql:wasNotNull>
        <sql:getColumn position="9" to="dbh_ref" />
        <sql:wasNotNull>
          <% compTreeDetailsBean.setDbh_ref( (String)pageContext.getAttribute("dbh_ref") ); %>
        </sql:wasNotNull>
        <sql:getColumn position="10" to="condition_ref" />
        <sql:wasNotNull>
          <% compTreeDetailsBean.setCondition_ref( (String)pageContext.getAttribute("condition_ref") ); %>
        </sql:wasNotNull>
        <sql:getColumn position="11" to="vigour_ref" />
        <sql:wasNotNull>
          <% compTreeDetailsBean.setVigour_ref( (String)pageContext.getAttribute("vigour_ref") ); %>
        </sql:wasNotNull>
        <sql:getColumn position="12" to="pavement_ref" />
        <sql:wasNotNull>
          <% compTreeDetailsBean.setPavement_ref( (String)pageContext.getAttribute("pavement_ref") ); %>
        </sql:wasNotNull>
        <sql:getColumn position="13" to="boundary_ref" />
        <sql:wasNotNull>
          <% compTreeDetailsBean.setBoundary_ref( (String)pageContext.getAttribute("boundary_ref") ); %>
        </sql:wasNotNull>
        <sql:getColumn position="14" to="building_ref" />
        <sql:wasNotNull>
          <% compTreeDetailsBean.setBuilding_ref( (String)pageContext.getAttribute("building_ref") ); %>
        </sql:wasNotNull>
        <sql:getColumn position="15" to="issue_ref" />
        <sql:wasNotNull>
          <% compTreeDetailsBean.setIssue_ref( (String)pageContext.getAttribute("issue_ref") ); %>
        </sql:wasNotNull>
        <sql:getColumn position="16" to="easting" />
        <sql:wasNotNull>
          <% compTreeDetailsBean.setEasting( (String)pageContext.getAttribute("easting") ); %>          
        </sql:wasNotNull>
        <sql:getColumn position="17" to="northing" />
        <sql:wasNotNull>
          <% compTreeDetailsBean.setNorthing( (String)pageContext.getAttribute("northing") ); %>
        </sql:wasNotNull>
      </sql:resultSet>
    </sql:statement>
    <sql:closeConnection conn="con"/>    
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="compTreeDetails" >
  <%-- Next view --%>
  <%-- NONE --%>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= compTreeDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">compTreeDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= compTreeDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">compTreeDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= compTreeDetailsBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">compTreeDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= compTreeDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${compTreeDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="compTreeDetailsView.jsp" />
