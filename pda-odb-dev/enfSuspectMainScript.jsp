<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfSuspectMainBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="enfSuspectMainBean" scope="session" class="com.vsb.enfSuspectMainBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfSuspectMain" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="enfSuspectMain" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="enfSuspectMainBean" property="all" value="clear" />
    <jsp:setProperty name="enfSuspectMainBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="enfSuspectMainBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="enfEvidence" >
  <jsp:setProperty name="enfSuspectMainBean" property="action" value="" />
  <jsp:setProperty name="enfSuspectMainBean" property="all" value="clear" />
  <jsp:setProperty name="enfSuspectMainBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="enfDetails" >
  <jsp:setProperty name="enfSuspectMainBean" property="action" value="" />
  <jsp:setProperty name="enfSuspectMainBean" property="all" value="clear" />
  <jsp:setProperty name="enfSuspectMainBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <if:IfTrue cond='<%= recordBean.getEnf_list_flag().equals("Y") %>' >
    <%-- Fill in the suspect_surname/suspect_company if we are coming from the enfList --%>
    <%-- and the enforcement has a suspect. --%>
    <% String surname = ""; %>
    <% String company_ref = ""; %>
    <% String company_name = ""; %>
    <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con1">
      <if:IfTrue cond='<%= ! recordBean.getEnf_list_suspect_ref().equals("") %>' >
        <sql:query>
          SELECT surname, company_ref
            FROM enf_suspect
           WHERE suspect_ref = <%= recordBean.getEnf_list_suspect_ref() %>
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="surname" />
          <sql:wasNotNull>
            <% surname = ((String) pageContext.getAttribute("surname")).trim(); %>
          </sql:wasNotNull>
          <sql:getColumn position="2" to="company_ref" />
          <sql:wasNotNull>
            <% company_ref = ((String) pageContext.getAttribute("company_ref")).trim(); %>
          </sql:wasNotNull>
        </sql:resultSet>
      </if:IfTrue>
  
      <%-- only process if there is a company for this suspect --%>
      <if:IfTrue cond='<%= ! company_ref.equals("") %>' >
        <sql:query>
          SELECT company_name
            FROM enf_company
           WHERE company_ref = <%= company_ref %>
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="company_name" />
          <sql:wasNotNull>
            <% company_name = ((String) pageContext.getAttribute("company_name")).trim(); %>
          </sql:wasNotNull>
        </sql:resultSet>
      </if:IfTrue>
    </sql:statement>
    <sql:closeConnection conn="con1"/>
    
    <%-- Fill in the surname if it exists otherwise fill in the company name. --%>
    <if:IfTrue cond='<%= ! surname.equals("") %>' >
      <% enfSuspectMainBean.setSuspect_surname(surname); %> 
    </if:IfTrue>
    <if:IfTrue cond='<%= surname.equals("") %>' >
      <% enfSuspectMainBean.setSuspect_company(company_name); %> 
    </if:IfTrue>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>
<%
  String tempText1 = "";
  tempText1 = enfSuspectMainBean.getSuspect_company();
  enfSuspectMainBean.setSuspect_company(tempText1.replace('*','%'));
  tempText1 = enfSuspectMainBean.getSuspect_surname();
  enfSuspectMainBean.setSuspect_surname(tempText1.replace('*','%'));
%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="enfSuspectMain" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= enfSuspectMainBean.getAction().equals("Search/View") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= (enfSuspectMainBean.getSuspect_company() == null || enfSuspectMainBean.getSuspect_company().equals("")) && (enfSuspectMainBean.getSuspect_surname() == null || enfSuspectMainBean.getSuspect_surname().equals("")) %>' >
      <jsp:setProperty name="enfSuspectMainBean" property="error"
        value="Please enter company or surname search criteria for the suspect." />
      <jsp:forward page="enfSuspectMainView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= enfSuspectMainBean.getSuspect_company() != null && !(enfSuspectMainBean.getSuspect_company().equals("")) && enfSuspectMainBean.getSuspect_surname() != null && !(enfSuspectMainBean.getSuspect_surname().equals("")) %>' >
      <jsp:setProperty name="enfSuspectMainBean" property="error"
        value="Please supply only company OR surname search criteria, NOT both." />
      <jsp:forward page="enfSuspectMainView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <% recordBean.setNew_suspect_flag("N"); %>
    <% enfSuspectMainBean.setDefault_search("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectMain</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">enfSuspectAdd</sess:setAttribute>
    <c:redirect url="enfSuspectAddScript.jsp" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= enfSuspectMainBean.getAction().equals("New") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <% recordBean.setNew_suspect_flag("Y"); %>
    <% enfSuspectMainBean.setDefault_search("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectMain</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">enfSuspectNew</sess:setAttribute>
    <c:redirect url="enfSuspectNewScript.jsp" />
  </if:IfTrue>

  <%-- Next view 3 --%>
  <%-- 05/07/2010  TW  New button to display search form using a default suspect reference --%>
  <if:IfTrue cond='<%= enfSuspectMainBean.getAction().equals("Default") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <% recordBean.setNew_suspect_flag("N"); %>
    <% enfSuspectMainBean.setDefault_search("Y"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectMain</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">enfSuspectAdd</sess:setAttribute>
    <c:redirect url="enfSuspectAddScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= enfSuspectMainBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectMain</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= enfSuspectMainBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectMain</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= enfSuspectMainBean.getAction().equals("Back") %>' >
    <% recordBean.setNew_suspect_flag("N"); %>
    <% recordBean.setSuspect_flag("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectMain</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= enfSuspectMainBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${enfSuspectMainBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="enfSuspectMainView.jsp" />
