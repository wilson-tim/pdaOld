<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfSuspectDetailsBean, com.vsb.recordBean, com.vsb.enfSuspectAddBean" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="enfSuspectDetailsBean" scope="session" class="com.vsb.enfSuspectDetailsBean" />
<jsp:useBean id="enfSuspectAddBean" scope="session" class="com.vsb.enfSuspectAddBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfSuspectDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="enfSuspectDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="enfSuspectDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="enfSuspectDetailsBean" property="*" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="sus_title" value='<%= enfSuspectDetailsBean.getSus_title() %>' />
    <jsp:setProperty name="recordBean" property="sus_surname" value='<%= enfSuspectDetailsBean.getSus_surname() %>' />
    <jsp:setProperty name="recordBean" property="sus_fstname" value='<%= enfSuspectDetailsBean.getSus_fstname() %>' />
    <jsp:setProperty name="recordBean" property="sus_midname" value='<%= enfSuspectDetailsBean.getSus_midname() %>' />
    <jsp:setProperty name="recordBean" property="sus_age" value='<%= enfSuspectDetailsBean.getSus_age() %>' />
    <jsp:setProperty name="recordBean" property="sus_sex" value='<%= enfSuspectDetailsBean.getSus_sex() %>' />
    <jsp:setProperty name="recordBean" property="sus_build_no" value='<%= enfSuspectDetailsBean.getSus_build_no() %>' />
    <jsp:setProperty name="recordBean" property="sus_build_name" value='<%= enfSuspectDetailsBean.getSus_build_name() %>' />
    <jsp:setProperty name="recordBean" property="sus_addr1" value='<%= enfSuspectDetailsBean.getSus_addr1() %>' />
    <jsp:setProperty name="recordBean" property="sus_addr2" value='<%= enfSuspectDetailsBean.getSus_addr2() %>' />
    <jsp:setProperty name="recordBean" property="sus_addr3" value='<%= enfSuspectDetailsBean.getSus_addr3() %>' />
    <jsp:setProperty name="recordBean" property="sus_postcode" value='<%= enfSuspectDetailsBean.getSus_postcode() %>' />
    <jsp:setProperty name="recordBean" property="sus_homeno" value='<%= enfSuspectDetailsBean.getSus_homeno() %>' />
    <jsp:setProperty name="recordBean" property="sus_workno" value='<%= enfSuspectDetailsBean.getSus_workno() %>' />
    <jsp:setProperty name="recordBean" property="sus_mobno" value='<%= enfSuspectDetailsBean.getSus_mobno() %>' />
    <jsp:setProperty name="recordBean" property="update_flag" value='<%= enfSuspectDetailsBean.getUpdate_flag() %>' />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="enfSuspectDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="enfSuspectAdd" >
  <jsp:setProperty name="enfSuspectDetailsBean" property="action" value="" />
  <jsp:setProperty name="enfSuspectDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="enfSuspectDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<sess:equalsAttribute name="input" match="enfSuspectAdd" >
  <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con">
    <sql:query>
      select surname, fstname, midname, addr1, addr2, addr3, postcode, home_phone, work_phone,
      mobile, est_age, dob, sex, title, build_no, build_name
      from enf_suspect where suspect_ref = <%= enfSuspectAddBean.getSuspect_ref() %>
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="sus_surname" />
      <% enfSuspectDetailsBean.setSus_surname((String)pageContext.getAttribute("sus_surname")); %>

      <sql:getColumn position="2" to="sus_fstname" />
      <% enfSuspectDetailsBean.setSus_fstname((String)pageContext.getAttribute("sus_fstname")); %>
      
      <sql:getColumn position="3" to="sus_midname" />
      <% enfSuspectDetailsBean.setSus_midname((String)pageContext.getAttribute("sus_midname")); %>

      <sql:getColumn position="4" to="sus_addr1" />
      <% enfSuspectDetailsBean.setSus_addr1((String)pageContext.getAttribute("sus_addr1")); %>

      <sql:getColumn position="5" to="sus_addr2" />
      <% enfSuspectDetailsBean.setSus_addr2((String)pageContext.getAttribute("sus_addr2")); %>

      <sql:getColumn position="6" to="sus_addr3" />
      <% enfSuspectDetailsBean.setSus_addr3((String)pageContext.getAttribute("sus_addr3")); %>
      
      <sql:getColumn position="7" to="sus_postcode" />
      <% enfSuspectDetailsBean.setSus_postcode((String)pageContext.getAttribute("sus_postcode")); %>
      
      <sql:getColumn position="8" to="sus_homeno" />
      <% enfSuspectDetailsBean.setSus_homeno((String)pageContext.getAttribute("sus_homeno")); %>
      
      <sql:getColumn position="9" to="sus_workno" />
      <% enfSuspectDetailsBean.setSus_workno((String)pageContext.getAttribute("sus_workno")); %>
      
      <sql:getColumn position="10" to="sus_mobno" />
      <% enfSuspectDetailsBean.setSus_mobno((String)pageContext.getAttribute("sus_mobno")); %>
      
      <sql:getColumn position="11" to="sus_age" />
      <% enfSuspectDetailsBean.setSus_age((String)pageContext.getAttribute("sus_age")); %>
      
      <sql:getDate position="12" to="sus_dob" format="<%= application.getInitParameter("db_date_fmt") %>" />
      <% recordBean.setDob_date((String)pageContext.getAttribute("sus_dob")); %>

      <sql:getColumn position="13" to="sus_sex" />
      <% enfSuspectDetailsBean.setSus_sex((String)pageContext.getAttribute("sus_sex")); %>
      
      <sql:getColumn position="14" to="sus_title" />
      <% enfSuspectDetailsBean.setSus_title((String)pageContext.getAttribute("sus_title")); %>
      
      <sql:getColumn position="15" to="sus_build_no" />
      <% enfSuspectDetailsBean.setSus_build_no((String)pageContext.getAttribute("sus_build_no")); %>
      
      <sql:getColumn position="16" to="sus_build_name" />
      <% enfSuspectDetailsBean.setSus_build_name((String)pageContext.getAttribute("sus_build_name")); %>
    </sql:resultSet>
  </sql:statement>
  <sql:closeConnection conn="con"/>
</sess:equalsAttribute>

<%
  boolean check = true;

  if(enfSuspectDetailsBean.getDay().equals("") && enfSuspectDetailsBean.getMonth().equals("") && enfSuspectDetailsBean.getYear().equals(""))
  {
    check = true;
    recordBean.setDob_date("");
  }
  else if (enfSuspectDetailsBean.getDay().equals("") || enfSuspectDetailsBean.getMonth().equals("") || enfSuspectDetailsBean.getYear().equals(""))
  {
    check = false;
%>
    <jsp:setProperty name="enfSuspectDetailsBean" property="error"
      value="Please Enter all the date fields" />
<%
  }
  else
  {
    // Re-Inspection date
    GregorianCalendar dob_date = new GregorianCalendar();
    int day = Integer.parseInt(enfSuspectDetailsBean.getDay());
    int month = Integer.parseInt(enfSuspectDetailsBean.getMonth());
    int year = Integer.parseInt(enfSuspectDetailsBean.getYear());

    // Create string representation of forms date (yyyy-MM-dd)
    String dob = enfSuspectDetailsBean.getYear() + "-" + 
                 enfSuspectDetailsBean.getMonth() + "-" + 
                 enfSuspectDetailsBean.getDay();
    // Create new simple date format (yyyy-MM-dd). This is not controlled by the context-param db_date_fmt
    // as it is just being used to turn a string date (dob) into a real date.
    SimpleDateFormat formatDate = new SimpleDateFormat("yyyy-MM-dd");
    // This simple date format does need to be controlled by the context-param db_date_fmt as it formats
    // the converted dob back into a string but in the database format.
    SimpleDateFormat formatDbDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
    // Create completion date from string 
    Date tempDate = formatDate.parse(dob);
    dob = formatDbDate.format(tempDate);
    
    int nday = dob_date.get(dob_date.DAY_OF_MONTH);
    int nmonth = dob_date.get(dob_date.MONTH);
    int nyear = dob_date.get(dob_date.YEAR);

    if(day > 30 && (month == 4 || month == 6 || month == 9 || month == 11))
    {
      check = false;
%>
      <jsp:setProperty name="enfSuspectDetailsBean" property="error"
        value="Please review the Date" />
<%
    }
    else if((dob_date.isLeapYear(year) && month == 2 && day > 29) || (!(dob_date.isLeapYear(year))&&(month == 2 && day > 28)))
    {
      check = false;
%>
      <jsp:setProperty name="enfSuspectDetailsBean" property="error"
        value="Please review the Date" />
<%
    }
    else if (year == nyear && (month > nmonth || day > nday))
    {
      check = false;
%>
      <jsp:setProperty name="enfSuspectDetailsBean" property="error"
        value="You cannot enter a date later than today. Please try again" />
<%
    }

    //add the dob date to the record bean and the enfSuspectDetails Bean
    recordBean.setDob_date(dob);
  }
%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="enfSuspectDetails" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= enfSuspectDetailsBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond="<%= check == false %>">
      <jsp:forward page="enfSuspectDetailsView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">enfSuspectText</sess:setAttribute>
    <c:redirect url="enfSuspectTextScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= enfSuspectDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= enfSuspectDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= enfSuspectDetailsBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= enfSuspectDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${enfSuspectDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="enfSuspectDetailsView.jsp" />
