<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.schedOrCompBean, 
                 com.vsb.recordBean, 
                 com.vsb.systemKeysBean, 
                 com.db.*, 
                 java.io.*" %>
                 
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="schedOrCompBean" scope="session" class="com.vsb.schedOrCompBean" />
<jsp:useBean id="recordBean"      scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="systemKeysBean"  scope="session" class="com.vsb.systemKeysBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="schedOrComp" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="schedOrComp" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="schedOrCompBean" property="all" value="clear" />
    <jsp:setProperty name="schedOrCompBean" property="*" />

    <%-- Clear the previous record --%>
    <jsp:setProperty name="recordBean" property="all" value="clear" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="clearedDefault" value="N" />
    <jsp:setProperty name="recordBean" property="comingFromSchedComp" value="Y" />

    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <%-- get the graffiti service name --%>
      <sql:query>
        select c_field
        from keys
        where service_c = 'ALL'
        and   keyname = 'ERT_SERVICE'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="c_field" />
        <sql:wasNotNull>
          <% recordBean.setGraffiti_service((String) pageContext.getAttribute("c_field")); %>
        </sql:wasNotNull>
      </sql:resultSet>

      <%-- get the dart service name --%>
      <sql:query>
        select c_field
        from keys
        where service_c = 'ALL'
        and   keyname = 'DART_SERVICE'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="c_field" />
        <sql:wasNotNull>
          <% recordBean.setDart_service((String) pageContext.getAttribute("c_field")); %>
        </sql:wasNotNull>
      </sql:resultSet>

      <%-- get the Wansworth Housing relaxed search flag --%>
      <sql:query>
        select c_field
        from keys
        where service_c = 'ALL'
        and   keyname = 'PDA_RELAXED_SEARCH'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="pda_relaxed_search" />
        <sql:wasNotNull>
          <% recordBean.setRelaxed_search_flag((String) pageContext.getAttribute("pda_relaxed_search")); %>
        </sql:wasNotNull>
      </sql:resultSet>

      <%-- Find out what version of contender is being run against the database --%>
      <%-- 10/05/2010  TW  Read contender_version from systemKeysBean --%>
      <% recordBean.setContender_version( systemKeysBean.getContender_version() ); %>
    </sql:statement>
    <sql:closeConnection conn="con"/>

  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="schedOrCompBean" property="error" value="" />

<%-- clear form fields if coming from previous form via a menu jump --%>
<%-- and update savedPreviousForm as if we had just come from the mainMenu form. --%>
<%-- Also reset the menuJump session object. --%>
<sess:equalsAttribute name="menuJump" match="yes">
  <jsp:setProperty name="schedOrCompBean" property="action" value="" />
  <jsp:setProperty name="schedOrCompBean" property="all" value="clear" />
  <app:equalsInitParameter name="module" match="pda-in" >
    <jsp:setProperty name="schedOrCompBean" property="savedPreviousForm" value="mainMenu" />
  </app:equalsInitParameter>
  <app:equalsInitParameter name="module" match="pda-tw" >
    <jsp:setProperty name="schedOrCompBean" property="savedPreviousForm" value="login" />
  </app:equalsInitParameter>
  <sess:setAttribute name="menuJump">no</sess:setAttribute>
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="login" >
  <jsp:setProperty name="schedOrCompBean" property="action" value="" />
  <jsp:setProperty name="schedOrCompBean" property="all" value="clear" />
  <jsp:setProperty name="schedOrCompBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="mainMenu" >
  <jsp:setProperty name="schedOrCompBean" property="action" value="" />
  <jsp:setProperty name="schedOrCompBean" property="all" value="clear" />
  <jsp:setProperty name="schedOrCompBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="updateStatus" >
  <jsp:setProperty name="schedOrCompBean" property="action" value="" />
  <jsp:setProperty name="schedOrCompBean" property="all" value="clear" />
  <jsp:setProperty name="schedOrCompBean" property="savedPreviousForm" value="login" />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>
<%-- If the user has used '*' in the input then make sure they see them as '*'s --%>
<%-- and not as '%'s symbols because of the change to '%' for matching using --%>
<%-- 'like' in the sql in locLookup, see later in the code. --%>
<%
  String tempText1 = "";
  tempText1 = schedOrCompBean.getWardenPostCode();
  schedOrCompBean.setWardenPostCode(tempText1.replace('%','*'));
  tempText1 = schedOrCompBean.getWardenHouseNo();
  schedOrCompBean.setWardenHouseNo(tempText1.replace('%','*'));
  tempText1 = schedOrCompBean.getWardenBuildingName();
  schedOrCompBean.setWardenBuildingName(tempText1.replace('%','*'));
  tempText1 = schedOrCompBean.getWardenLoc();
  schedOrCompBean.setWardenLoc(tempText1.replace('%','*'));
  tempText1 = schedOrCompBean.getBusinessName();
  schedOrCompBean.setBusinessName(tempText1.replace('%','*'));  
%>


<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="schedOrComp" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= schedOrCompBean.getAction().equals("Property") ||
                       schedOrCompBean.getAction().equals("Trade")    ||
                       schedOrCompBean.getAction().equals("Search") %>' >
    <%-- Invalid entry --%>                       
    <if:IfTrue cond='<%= (schedOrCompBean.getBusinessName() == null ||
                          schedOrCompBean.getBusinessName().equals("")) %>'>    
      <%-- Allow search on building name only if to see if this is relaxed search --%>
      <if:IfTrue cond='<%= recordBean.getRelaxed_search_flag().equals("Y") %>' >
         <if:IfTrue
          cond='<%= (schedOrCompBean.getWardenLoc() == null || schedOrCompBean.getWardenLoc().equals("")) &&
            (schedOrCompBean.getWardenPostCode() == null || schedOrCompBean.getWardenPostCode().equals("")) &&
            (schedOrCompBean.getWardenBuildingName() == null || schedOrCompBean.getWardenBuildingName().equals("")) %>' >
          <jsp:setProperty name="schedOrCompBean" property="error"
            value="Please supply postcode/street/building name search criteria." />
          <jsp:forward page="schedOrCompView.jsp" />
        </if:IfTrue>
      </if:IfTrue>
      <if:IfTrue cond='<%= ! recordBean.getRelaxed_search_flag().equals("Y") %>' >
        <if:IfTrue
          cond='<%= (schedOrCompBean.getWardenLoc() == null || schedOrCompBean.getWardenLoc().equals("")) &&
            (schedOrCompBean.getWardenPostCode() == null || schedOrCompBean.getWardenPostCode().equals("")) %>' >
          <jsp:setProperty name="schedOrCompBean" property="error"
            value="Please supply postcode/street name search criteria." />
          <jsp:forward page="schedOrCompView.jsp" />
        </if:IfTrue>
      </if:IfTrue>
  
      <if:IfTrue
        cond='<%= schedOrCompBean.getWardenLoc() != null && !(schedOrCompBean.getWardenLoc().equals("")) &&
          schedOrCompBean.getWardenPostCode() != null && !(schedOrCompBean.getWardenPostCode().equals("")) %>' >
        <jsp:setProperty name="schedOrCompBean" property="error"
          value="Please supply only postcode OR street name search criteria, NOT both." />
        <jsp:forward page="schedOrCompView.jsp" />
      </if:IfTrue>
    </if:IfTrue>
    <%-- Not allowed a property search with Trade search criteria --%>
    <if:IfTrue cond='<%= !(schedOrCompBean.getBusinessName() == null ||
                           schedOrCompBean.getBusinessName().equals("")) %>'>
      <if:IfTrue cond='<%= schedOrCompBean.getAction().equals("Property") %>' >
        <jsp:setProperty name="schedOrCompBean" property="error"
          value="Please do not supply Trade search criteria with a Property Search." />
        <jsp:forward page="schedOrCompView.jsp" />      
      </if:IfTrue>
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- If the user has used '*' in the input then change them to '%' for --%>
    <%-- matching using 'like' in the sql in locLookup --%>
    <%
      String tempText2 = "";
      tempText2 = schedOrCompBean.getWardenPostCode();
      schedOrCompBean.setWardenPostCode(tempText2.replace('*','%'));
      tempText2 = schedOrCompBean.getWardenHouseNo();
      schedOrCompBean.setWardenHouseNo(tempText2.replace('*','%'));
      // Adds * to the beginning and the end of the search string if using
      // relaxed search and the *'s don't already exist.
      if (recordBean.getRelaxed_search_flag().equals("Y") &&
          !(schedOrCompBean.getWardenBuildingName().startsWith("*")) &&
          !(schedOrCompBean.getWardenBuildingName().endsWith("*"))) {
        tempText2 = "*" + schedOrCompBean.getWardenBuildingName() + "*";
      } else {
        tempText2 = schedOrCompBean.getWardenBuildingName();
      }
      schedOrCompBean.setWardenBuildingName(tempText2.replace('*','%'));
      tempText2 = schedOrCompBean.getWardenLoc();
      schedOrCompBean.setWardenLoc(tempText2.replace('*','%'));
      tempText2 = schedOrCompBean.getBusinessName();
      schedOrCompBean.setBusinessName(tempText2.replace('*','%'));      
    %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">schedOrComp</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">locLookup</sess:setAttribute>
    <c:redirect url="locLookupScript.jsp" />
  </if:IfTrue>

  <%-- Menu view --%>
  <if:IfTrue cond='<%= schedOrCompBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">schedOrComp</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= schedOrCompBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">schedOrComp</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= schedOrCompBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${schedOrCompBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="schedOrCompView.jsp" />
