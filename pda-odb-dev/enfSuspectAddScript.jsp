<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfSuspectAddBean, com.vsb.enfSuspectMainBean, com.vsb.recordBean, com.vsb.systemKeysBean" %>
<%@ page import="com.db.*, javax.sql.*, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="systemKeysBean" scope="session" class="com.vsb.systemKeysBean" />
<jsp:useBean id="enfSuspectAddBean" scope="session" class="com.vsb.enfSuspectAddBean" />
<jsp:useBean id="enfSuspectMainBean" scope="session" class="com.vsb.enfSuspectMainBean" />
<jsp:useBean id="enfSuspectAddPageSet" scope="session" class="com.db.PageSet" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfSuspectAdd" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="enfSuspectAdd" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="enfSuspectAddBean" property="all" value="clear" />
    <jsp:setProperty name="enfSuspectAddBean" property="*" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="suspect_ref" value='<%=enfSuspectAddBean.getSuspect_ref()%>' />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="enfSuspectAddBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="enfSuspectMain" >
  <jsp:setProperty name="enfSuspectAddBean" property="action" value="" />
  <jsp:setProperty name="enfSuspectAddBean" property="all" value="clear" />
  <jsp:setProperty name="enfSuspectAddBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>
<sess:equalsAttribute name="input" match="enfSuspectAdd" value="false">
  <sess:equalsAttribute name="input" match="enfSuspectMain">
    <%-- set the number of records per page --%>
    <% enfSuspectAddPageSet.setRecordsOnPage(30); %>

    <%-- Connect to the database using the context and datasource --%>
    <%
      DbSQL connection = new DbSQL();

      connection.connect("java:comp/env", "jdbc/pda");
      
      // 05/07/2010  TW  Additional checks for default suspect reference search

      if (!(enfSuspectMainBean.getDefault_search().equals("Y")) &&
          !(enfSuspectMainBean.getSuspect_surname() == null) &&
          !(enfSuspectMainBean.getSuspect_surname().equals("")))
      {
        String queryString = " select suspect_ref, fstname, midname, surname, company_name " +
                 " from enf_suspect, enf_company " +
                 " where surname like '" + enfSuspectMainBean.getSuspect_surname().toUpperCase() +"' " +
                 " and enf_suspect.company_ref = enf_company.company_ref " +
                 " union " +
                 " select suspect_ref, fstname, midname, surname, '' " +
                 " from enf_suspect " +
                 " where surname like '" + enfSuspectMainBean.getSuspect_surname().toUpperCase() +"' " +
                 " and   (company_ref is null or company_ref = '') " +
                 " order by 4";

        java.sql.ResultSet rs = connection.query(queryString);
        enfSuspectAddPageSet.setPageSet(rs, application.getInitParameter("db_date_fmt"));

        rs.close();
      }

      if (!(enfSuspectMainBean.getDefault_search().equals("Y")) &&
          !(enfSuspectMainBean.getSuspect_company() == null) &&
          !(enfSuspectMainBean.getSuspect_company().equals("")))
      {
        String queryString = " select suspect_ref, fstname, midname, surname, company_name " +
                 " from enf_company, enf_suspect " +
                 " where company_name like '" + enfSuspectMainBean.getSuspect_company().toUpperCase() +"' " +
                 " and enf_company.company_ref = enf_suspect.company_ref " +
                 " order by company_name";

        java.sql.ResultSet rs = connection.query(queryString);
        enfSuspectAddPageSet.setPageSet(rs, application.getInitParameter("db_date_fmt"));

        rs.close();
      }

      if (enfSuspectMainBean.getDefault_search().equals("Y"))
      {
        String queryString = " select suspect_ref, fstname, midname, surname " +
                 " from enf_suspect " +
                 " where suspect_ref = " + systemKeysBean.getDefault_suspect_ref() ;
        java.sql.ResultSet rs = connection.query(queryString);
        enfSuspectAddPageSet.setPageSet(rs, application.getInitParameter("db_date_fmt"));

        rs.close();
      }

      connection.disconnect();
    %>
  </sess:equalsAttribute>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="enfSuspectAdd" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= enfSuspectAddBean.getAction().equals("|<<") %>' >
    <% enfSuspectAddPageSet.first(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="enfSuspectAddView.jsp" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= enfSuspectAddBean.getAction().equals(">>|") %>' >
    <% enfSuspectAddPageSet.last(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="enfSuspectAddView.jsp" />
  </if:IfTrue>

  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= enfSuspectAddBean.getAction().equals(" < ") %>' >
    <% enfSuspectAddPageSet.previous(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="enfSuspectAddView.jsp" />
  </if:IfTrue>

  <%-- Next view 4 --%>
  <if:IfTrue cond='<%= enfSuspectAddBean.getAction().equals(" > ") %>' >
    <% enfSuspectAddPageSet.next(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="enfSuspectAddView.jsp" />
  </if:IfTrue>

  <%-- Next view 5 --%>
  <if:IfTrue cond='<%= enfSuspectAddBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=enfSuspectAddBean.getSuspect_ref() == null || enfSuspectAddBean.getSuspect_ref().equals("") %>' >
      <jsp:setProperty name="enfSuspectAddBean" property="error"
        value="Please choose a Suspect." />
      <jsp:forward page="enfSuspectAddView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectAdd</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">enfSuspectText</sess:setAttribute>
    <c:redirect url="enfSuspectTextScript.jsp" />
  </if:IfTrue>

  <%-- Next view 6 --%>
  <if:IfTrue cond='<%= enfSuspectAddBean.getAction().equals("Details") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=enfSuspectAddBean.getSuspect_ref() == null || enfSuspectAddBean.getSuspect_ref().equals("") %>' >
      <jsp:setProperty name="enfSuspectAddBean" property="error"
        value="Please choose a Suspect." />
      <jsp:forward page="enfSuspectAddView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectAdd</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">enfSuspectDetails</sess:setAttribute>
    <c:redirect url="enfSuspectDetailsScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= enfSuspectAddBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectAdd</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= enfSuspectAddBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectAdd</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= enfSuspectAddBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectAdd</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= enfSuspectAddBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${enfSuspectAddBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="enfSuspectAddView.jsp" />
