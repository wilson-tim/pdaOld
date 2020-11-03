<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.custLocSearchBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="custLocSearchBean" scope="session" class="com.vsb.custLocSearchBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="custLocSearch" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="custLocSearch" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="custLocSearchBean" property="all" value="clear" />
    <jsp:setProperty name="custLocSearchBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="custLocSearchBean" property="error" value="" />

<%-- clear form fields if coming from previous form --%>
<sess:equalsAttribute name="input" match="enterCustDetails" >
  <jsp:setProperty name="custLocSearchBean" property="action" value="" />
  <jsp:setProperty name="custLocSearchBean" property="all" value="clear" />
  <jsp:setProperty name="custLocSearchBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>
<%-- If the user has used '*' in the input then make sure they see them as '*'s --%>
<%-- and not as '%'s symbols because of the change to '%' for matching using --%>
<%-- 'like' in the sql in locLookup, see later in the code. --%>
<%
  String tempText1 = "";
  tempText1 = custLocSearchBean.getCustomerPostCode();
  custLocSearchBean.setCustomerPostCode(tempText1.replace('%','*'));
  tempText1 = custLocSearchBean.getCustomerHouseNo();
  custLocSearchBean.setCustomerHouseNo(tempText1.replace('%','*'));
  tempText1 = custLocSearchBean.getCustomerBuildingName();
  custLocSearchBean.setCustomerBuildingName(tempText1.replace('%','*'));
  tempText1 = custLocSearchBean.getCustomerLoc();
  custLocSearchBean.setCustomerLoc(tempText1.replace('%','*'));
%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="custLocSearch" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= custLocSearchBean.getAction().equals("Search") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue
      cond='<%= (custLocSearchBean.getCustomerLoc() == null || custLocSearchBean.getCustomerLoc().equals("")) &&
        (custLocSearchBean.getCustomerPostCode() == null || custLocSearchBean.getCustomerPostCode().equals("")) %>' >
      <jsp:setProperty name="custLocSearchBean" property="error"
        value="Please supply postcode/street name search criteria." />
      <jsp:forward page="custLocSearchView.jsp" />
    </if:IfTrue>

    <if:IfTrue
      cond='<%= custLocSearchBean.getCustomerLoc() != null && !(custLocSearchBean.getCustomerLoc().equals("")) &&
        custLocSearchBean.getCustomerPostCode() != null && !(custLocSearchBean.getCustomerPostCode().equals("")) %>' >
      <jsp:setProperty name="custLocSearchBean" property="error"
        value="Please supply only postcode OR street name search criteria, NOT both." />
      <jsp:forward page="custLocSearchView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- If the user has used '*' in the input then change them to '%' for --%>
    <%-- matching using 'like' in the sql in locLookup --%>
    <%
      String tempText2 = "";
      tempText2 = custLocSearchBean.getCustomerPostCode();
      custLocSearchBean.setCustomerPostCode(tempText2.replace('*','%'));
      tempText2 = custLocSearchBean.getCustomerHouseNo();
      custLocSearchBean.setCustomerHouseNo(tempText2.replace('*','%'));
      tempText2 = custLocSearchBean.getCustomerBuildingName();
      custLocSearchBean.setCustomerBuildingName(tempText2.replace('*','%'));
      tempText2 = custLocSearchBean.getCustomerLoc();
      custLocSearchBean.setCustomerLoc(tempText2.replace('*','%'));
    %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">custLocSearch</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">custLocLookup</sess:setAttribute>
    <c:redirect url="custLocLookupScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= custLocSearchBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">custLocSearch</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= custLocSearchBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">custLocSearch</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= custLocSearchBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">custLocSearch</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= custLocSearchBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${custLocSearchBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="custLocSearchView.jsp" />
