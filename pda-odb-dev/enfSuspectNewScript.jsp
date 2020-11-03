<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfSuspectNewBean, com.vsb.recordBean, com.vsb.enfSuspectMainBean" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="enfSuspectNewBean" scope="session" class="com.vsb.enfSuspectNewBean" />
<jsp:useBean id="enfSuspectMainBean" scope="session" class="com.vsb.enfSuspectMainBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfSuspectNew" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="enfSuspectNew" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="enfSuspectNewBean" property="all" value="clear" />
    <jsp:setProperty name="enfSuspectNewBean" property="*" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="sus_title" value='<%= enfSuspectNewBean.getSus_title() %>' />
    <jsp:setProperty name="recordBean" property="sus_surname" value='<%= enfSuspectNewBean.getSus_surname() %>' />
    <jsp:setProperty name="recordBean" property="sus_fstname" value='<%= enfSuspectNewBean.getSus_fstname() %>' />
    <jsp:setProperty name="recordBean" property="sus_midname" value='<%= enfSuspectNewBean.getSus_midname() %>' />
    <jsp:setProperty name="recordBean" property="sus_age" value='<%= enfSuspectNewBean.getSus_age() %>' />
    <jsp:setProperty name="recordBean" property="sus_sex" value='<%= enfSuspectNewBean.getSus_sex() %>' />
    <jsp:setProperty name="recordBean" property="sus_build_no" value='<%= enfSuspectNewBean.getSus_build_no() %>' />
    <jsp:setProperty name="recordBean" property="sus_build_name" value='<%= enfSuspectNewBean.getSus_build_name() %>' />
    <jsp:setProperty name="recordBean" property="sus_addr1" value='<%= enfSuspectNewBean.getSus_addr1() %>' />
    <jsp:setProperty name="recordBean" property="sus_addr2" value='<%= enfSuspectNewBean.getSus_addr2() %>' />
    <jsp:setProperty name="recordBean" property="sus_addr3" value='<%= enfSuspectNewBean.getSus_addr3() %>' />
    <jsp:setProperty name="recordBean" property="sus_postcode" value='<%= enfSuspectNewBean.getSus_postcode() %>' />
    <jsp:setProperty name="recordBean" property="sus_homeno" value='<%= enfSuspectNewBean.getSus_homeno() %>' />
    <jsp:setProperty name="recordBean" property="sus_workno" value='<%= enfSuspectNewBean.getSus_workno() %>' />
    <jsp:setProperty name="recordBean" property="sus_mobno" value='<%= enfSuspectNewBean.getSus_mobno() %>' />
    <jsp:setProperty name="recordBean" property="sus_company" value='<%= enfSuspectNewBean.getSus_company() %>' />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="enfSuspectNewBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="enfSuspectMain" >
  <jsp:setProperty name="enfSuspectNewBean" property="action" value="" />
  <jsp:setProperty name="enfSuspectNewBean" property="all" value="clear" />
  <jsp:setProperty name="enfSuspectNewBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <%-- populate the surname and company name from the enfSuspectMain form --%>
  <jsp:setProperty name="enfSuspectNewBean" property="sus_company"
    value="<%= enfSuspectMainBean.getSuspect_company().replace('%','*') %>" />
  <jsp:setProperty name="enfSuspectNewBean" property="sus_surname"
    value="<%= enfSuspectMainBean.getSuspect_surname().replace('%','*') %>" />
</sess:equalsAttribute>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="enfSuspectNew" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>
<%
  boolean check = true;
  if(enfSuspectNewBean.getDay_ob().equals("") && enfSuspectNewBean.getMonth_ob().equals("") && enfSuspectNewBean.getYear_ob().equals(""))
  {
    check = true;
    recordBean.setDob_date("");
  }
  else if (enfSuspectNewBean.getDay_ob().equals("") || enfSuspectNewBean.getMonth_ob().equals("") || enfSuspectNewBean.getYear_ob().equals(""))
  {
    check = false;
%>
    <jsp:setProperty name="enfSuspectNewBean" property="error" value="Please Enter all the date fields" />
<%
  }
  else {
    // Re-Inspection date
    GregorianCalendar d_date = new GregorianCalendar();
    int day = Integer.parseInt(enfSuspectNewBean.getDay_ob());
    int month = Integer.parseInt(enfSuspectNewBean.getMonth_ob());
    int year = Integer.parseInt(enfSuspectNewBean.getYear_ob());

    // Create string representation of forms date (yyyy-MM-dd)
    String dob_date = enfSuspectNewBean.getYear_ob() + "-" +
                      enfSuspectNewBean.getMonth_ob() + "-" +
                      enfSuspectNewBean.getDay_ob();
    // Create new simple date format (yyyy-MM-dd). This is not controlled by the context-param db_date_fmt
    // as it is just being used to turn a string date (dob_date) into a real date.
    SimpleDateFormat formatDate = new SimpleDateFormat("yyyy-MM-dd");
    // This simple date format does need to be controlled by the context-param db_date_fmt as it formats
    // the converted dob_date back into a string but in the database format.
    SimpleDateFormat formatDbDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
    // Create completion date from string 
    Date tempDate = formatDate.parse(dob_date);
    dob_date = formatDbDate.format(tempDate);

    if(day > 30 && (month == 4 || month == 6 || month == 9 || month == 11)) {
      check = false;
%>
      <jsp:setProperty name="enfSuspectNewBean" property="error" value="Please review the Date" />
<%
    }
    else if((d_date.isLeapYear(year) && month == 2 && day > 29) || (!(d_date.isLeapYear(year))&&(month == 2 && day > 28)))
    {
      check = false;
%>
      <jsp:setProperty name="enfSuspectNewBean" property="error" value="Please review the Date" />
<%
    }

    //add the dob date to the record bean
    recordBean.setDob_date(dob_date);
  }
%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="enfSuspectNew" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= enfSuspectNewBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= (enfSuspectNewBean.getSus_surname() == null || enfSuspectNewBean.getSus_surname().equals("")) && (enfSuspectNewBean.getSus_company() == null || enfSuspectNewBean.getSus_company().equals("")) %>' >
      <jsp:setProperty name="enfSuspectNewBean" property="error"
        value="You must provide a Surname or a Company name." />
      <jsp:forward page="enfSuspectNewView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= check == false %>'>
      <jsp:forward page="enfSuspectNewView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <if:IfTrue cond='<%= !enfSuspectNewBean.getSus_company().equals("") && enfSuspectNewBean.getSus_company() != null %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">enfSuspectNew</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">enfSuspectNewCo</sess:setAttribute>
      <c:redirect url="enfSuspectNewCoScript.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= enfSuspectNewBean.getSus_company().equals("") || enfSuspectNewBean.getSus_company() == null %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">enfSuspectNew</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">enfSuspectText</sess:setAttribute>
      <c:redirect url="enfSuspectTextScript.jsp" />
    </if:IfTrue>
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= enfSuspectNewBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectNew</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= enfSuspectNewBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectNew</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= enfSuspectNewBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectNew</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= enfSuspectNewBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${enfSuspectNewBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="enfSuspectNewView.jsp" />
