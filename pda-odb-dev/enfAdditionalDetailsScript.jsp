<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfAdditionalDetailsBean, com.vsb.recordBean, com.vsb.loginBean" %>
<%@ page import="com.vsb.helperBean" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="enfAdditionalDetailsBean" scope="session" class="com.vsb.enfAdditionalDetailsBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfAdditionalDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="enfAdditionalDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="enfAdditionalDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="enfAdditionalDetailsBean" property="*" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="invOff" value='<%= enfAdditionalDetailsBean.getInvOff() %>' />
    <jsp:setProperty name="recordBean" property="enfOff" value='<%= enfAdditionalDetailsBean.getEnfOff() %>' />
    <jsp:setProperty name="recordBean" property="vehicle_reg" value='<%= enfAdditionalDetailsBean.getVehicle_reg() %>' />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="enfAdditionalDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="offence" >
  <jsp:setProperty name="enfAdditionalDetailsBean" property="action" value="" />
  <jsp:setProperty name="enfAdditionalDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="enfAdditionalDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <%-- Clear the date held in the recordBean's offence_date, as it is used in the view. --%>
  <jsp:setProperty name="recordBean" property="offence_date" value="" />
  <jsp:setProperty name="recordBean" property="offence_time_h" value="" />
  <jsp:setProperty name="recordBean" property="offence_time_m" value="" />
  <%-- reset the inv and enf officers --%>
  <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con">
    <sql:query>
      select po_code
      from pda_user
      where user_name = '<%= loginBean.getUser_name() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="po_code" />
      <sql:wasNotNull>
        <% enfAdditionalDetailsBean.setInvOff(((String)pageContext.getAttribute("po_code")).trim().toUpperCase()); %>
        <% enfAdditionalDetailsBean.setEnfOff(((String)pageContext.getAttribute("po_code")).trim().toUpperCase()); %>
      </sql:wasNotNull>
      <sql:wasNull>
        <% enfAdditionalDetailsBean.setInvOff(""); %>
        <% enfAdditionalDetailsBean.setEnfOff(""); %>
      </sql:wasNull>
    </sql:resultSet>
    <sql:wasEmpty>
      <% enfAdditionalDetailsBean.setInvOff(""); %>
      <% enfAdditionalDetailsBean.setEnfOff(""); %>
    </sql:wasEmpty>
  </sql:statement>
  <sql:closeConnection conn="con"/>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="enfAdditionalDetails" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
    <% enfAdditionalDetailsBean.setVehicle_reg(recordBean.getAv_car_id()); %>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="enfAdditionalDetails" >
  <%
    // Get rid of all spaces in the car_id
    recordBean.setVehicle_reg(helperBean.removeSpaces(recordBean.getVehicle_reg()));

    // Offence date
    GregorianCalendar off_date = new GregorianCalendar();
    int day = Integer.parseInt(enfAdditionalDetailsBean.getOffence_day());
    int month = Integer.parseInt(enfAdditionalDetailsBean.getOffence_month());
    int year = Integer.parseInt(enfAdditionalDetailsBean.getOffence_year());

    // Save todays date
    Date todaysDate = new java.util.Date();

    // Create string representation of forms date (yyyy-MM-dd)
    String offence_date = enfAdditionalDetailsBean.getOffence_year() + "-" +
                          enfAdditionalDetailsBean.getOffence_month() + "-" +
                          enfAdditionalDetailsBean.getOffence_day();
    // Create new simple date format (yyyy-MM-dd). This is not controlled by the context-param db_date_fmt
    // as it is just being used to turn a string date (offence_date) into a real date.
    SimpleDateFormat formatStDate = new SimpleDateFormat("yyyy-MM-dd");
    // This simple date format does need to be controlled by the context-param db_date_fmt as it formats
    // the converted offence_date back into a string but in the database format.
    SimpleDateFormat formatDbDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
    // Create completion date from string 
    Date tempDate = formatStDate.parse(offence_date);
    offence_date = formatDbDate.format(tempDate);

    // Add the offence date to the record bean
    recordBean.setOffence_date(offence_date); 

    // Add offence_time_X to the record bean
    recordBean.setOffence_time_h(enfAdditionalDetailsBean.getOffence_time_h()); 
    recordBean.setOffence_time_m(enfAdditionalDetailsBean.getOffence_time_m()); 
  %>

  <%-- Validation for "Evid/Sus" and "Add Text" button --%>
  <if:IfTrue cond='<%= enfAdditionalDetailsBean.getAction().equals("Evid/Sus") || enfAdditionalDetailsBean.getAction().equals("Add Text") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond="<%= day > 30 && (month == 4 || month == 6 || month == 9 || month == 11) %>">
      <jsp:setProperty name="enfAdditionalDetailsBean" property="error"
        value="You have entered an invalid date.<br/>Please try again" />
      <jsp:forward page="enfAdditionalDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond="<%= (off_date.isLeapYear(year) && month == 2 && day > 29) || (!(off_date.isLeapYear(year))&& month == 2 && day > 28) %>">
      <jsp:setProperty name="enfAdditionalDetailsBean" property="error"
        value="You have entered an invalid date.<br/>Please try again" />
      <jsp:forward page="enfAdditionalDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond="<%= tempDate.after(todaysDate) %>">
      <jsp:setProperty name="enfAdditionalDetailsBean" property="error"
        value="The offence date cannot be in the future.<br/>Please try again" />
      <jsp:forward page="enfAdditionalDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond="<%= enfAdditionalDetailsBean.getInvOff() == null || enfAdditionalDetailsBean.getInvOff().trim().equals("") %>">
      <jsp:setProperty name="enfAdditionalDetailsBean" property="error"
        value="You must enter an investigative officer." />
      <jsp:forward page="enfAdditionalDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond="<%= enfAdditionalDetailsBean.getEnfOff() == null || enfAdditionalDetailsBean.getEnfOff().trim().equals("") %>">
      <jsp:setProperty name="enfAdditionalDetailsBean" property="error"
        value="You must enter an enforcement officer." />
      <jsp:forward page="enfAdditionalDetailsView.jsp" />
    </if:IfTrue>

    <%-- Validating the time --%>
    <%-- checking that if the hours have been added then the mins should have been as well and vice versa --%>
    <if:IfTrue cond="<%= enfAdditionalDetailsBean.getOffence_time_h() != null &&
                         !enfAdditionalDetailsBean.getOffence_time_h().equals("") &&
                         (enfAdditionalDetailsBean.getOffence_time_m() == null ||
                          enfAdditionalDetailsBean.getOffence_time_m().equals("")) %>">
      <jsp:setProperty name="enfAdditionalDetailsBean" property="error"
        value="If supplying a time, you must supply the hours AND mins." />
      <jsp:forward page="enfAdditionalDetailsView.jsp" />
    </if:IfTrue>

    <%-- checking that if the mins have been added then the hours should have been as well --%>
    <if:IfTrue cond="<%= enfAdditionalDetailsBean.getOffence_time_m() != null &&
                         !enfAdditionalDetailsBean.getOffence_time_m().equals("") &&
                         (enfAdditionalDetailsBean.getOffence_time_h() == null ||
                          enfAdditionalDetailsBean.getOffence_time_h().equals("")) %>">
      <jsp:setProperty name="enfAdditionalDetailsBean" property="error"
        value="If supplying a time, you must supply the hours AND mins." />
      <jsp:forward page="enfAdditionalDetailsView.jsp" />
    </if:IfTrue>

    <%-- Validating the hours --%>
    <if:IfTrue cond="<%= enfAdditionalDetailsBean.getOffence_time_h() != null &&
                        !enfAdditionalDetailsBean.getOffence_time_h().equals("") &&
                        !helperBean.isStringInt(enfAdditionalDetailsBean.getOffence_time_h()) %>">
      <jsp:setProperty name="enfAdditionalDetailsBean" property="error"
        value="If supplying a time (hrs), it must be an integer." />
      <jsp:forward page="enfAdditionalDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond="<%= enfAdditionalDetailsBean.getOffence_time_h() != null &&
                        !enfAdditionalDetailsBean.getOffence_time_h().equals("") &&
                        Integer.parseInt(enfAdditionalDetailsBean.getOffence_time_h()) < 0 %>">
      <jsp:setProperty name="enfAdditionalDetailsBean" property="error"
        value="If supplying a time (hrs), it must NOT be less than zero." />
      <jsp:forward page="enfAdditionalDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond="<%= enfAdditionalDetailsBean.getOffence_time_h() != null &&
                        !enfAdditionalDetailsBean.getOffence_time_h().equals("") &&
                        Integer.parseInt(enfAdditionalDetailsBean.getOffence_time_h()) > 23 %>">
      <jsp:setProperty name="enfAdditionalDetailsBean" property="error"
        value="If supplying a time (hrs), it must NOT be greater than 23." />
      <jsp:forward page="enfAdditionalDetailsView.jsp" />
    </if:IfTrue>

    <%-- Validating the minutes --%>
    <if:IfTrue cond="<%= enfAdditionalDetailsBean.getOffence_time_m() != null &&
                        !enfAdditionalDetailsBean.getOffence_time_m().equals("") &&
                        !helperBean.isStringInt(enfAdditionalDetailsBean.getOffence_time_m()) %>">
      <jsp:setProperty name="enfAdditionalDetailsBean" property="error"
        value="If supplying a time (mins), it must be an integer." />
      <jsp:forward page="enfAdditionalDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond="<%= enfAdditionalDetailsBean.getOffence_time_m() != null &&
                        !enfAdditionalDetailsBean.getOffence_time_m().equals("") &&
                        Integer.parseInt(enfAdditionalDetailsBean.getOffence_time_m()) < 0 %>">
      <jsp:setProperty name="enfAdditionalDetailsBean" property="error"
        value="If supplying a time (mins), it must NOT be less than zero." />
      <jsp:forward page="enfAdditionalDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond="<%= enfAdditionalDetailsBean.getOffence_time_m() != null &&
                        !enfAdditionalDetailsBean.getOffence_time_m().equals("") &&
                        Integer.parseInt(enfAdditionalDetailsBean.getOffence_time_m()) > 59 %>">
      <jsp:setProperty name="enfAdditionalDetailsBean" property="error"
        value="If supplying a time (mins), it must less than 60." />
      <jsp:forward page="enfAdditionalDetailsView.jsp" />
    </if:IfTrue>

  </if:IfTrue>

  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= enfAdditionalDetailsBean.getAction().equals("Evid/Sus") %>' >
    <%-- Invalid entry --%>
    <%-- See Above --%>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfAdditionalDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">enfEvidence</sess:setAttribute>
    <c:redirect url="enfEvidenceScript.jsp" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= enfAdditionalDetailsBean.getAction().equals("Add Text") %>' >
    <%-- Invalid entry --%>
    <%-- See Above --%>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfAdditionalDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">text</sess:setAttribute>
    <c:redirect url="textScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= enfAdditionalDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfAdditionalDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= enfAdditionalDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfAdditionalDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= enfAdditionalDetailsBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfAdditionalDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= enfAdditionalDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${enfAdditionalDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="enfAdditionalDetailsView.jsp" />
