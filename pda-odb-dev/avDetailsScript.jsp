<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.avDetailsBean, com.vsb.recordBean, com.vsb.helperBean" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="java.util.GregorianCalendar" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>

<jsp:useBean id="avDetailsBean" scope="session" class="com.vsb.avDetailsBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="avDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="avDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="avDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="avDetailsBean" property="*" />
    
    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="av_is_stickered" param="is_stickered" />
    <jsp:setProperty name="recordBean" property="av_status_ref" param="status_ref" />
    <jsp:setProperty name="recordBean" property="av_notes" param="text" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="avDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form --%>
<sess:equalsAttribute name="input" match="compSampDetails" >
  <jsp:setProperty name="avDetailsBean" property="action" value="" />
  <jsp:setProperty name="avDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="avDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% recordBean.setAv_status_ref(""); %>
  <% recordBean.setAv_notes(""); %>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="avDetails" >

  <%
    // Check if any fields are blank
    boolean isAvStickDateCompleted = false;
    if( (!avDetailsBean.getAv_stick_day().equals(""))   &&
        (!avDetailsBean.getAv_stick_month().equals("")) && 
        (!avDetailsBean.getAv_stick_year().equals("")) ) {
      isAvStickDateCompleted = true;
    }
    boolean isAvStickTimeCompleted = false;
    if( (!avDetailsBean.getAv_stick_time_h().equals(""))   &&
        (!avDetailsBean.getAv_stick_time_m().equals("")) ) {
      isAvStickTimeCompleted = true;
    }
    // Check if all the fields are blank
    boolean isAvStickDateBlank = false;
    if( (avDetailsBean.getAv_stick_day().equals(""))   && 
        (avDetailsBean.getAv_stick_month().equals("")) && 
        (avDetailsBean.getAv_stick_year().equals("")) ) {
      isAvStickDateBlank = true;
    }
    boolean isAvStickTimeBlank = false;
    if( (avDetailsBean.getAv_stick_time_h().equals(""))   && 
        (avDetailsBean.getAv_stick_time_m().equals("")) ) {
      isAvStickTimeBlank = true;
    }
  
    // Set the time zone
    TimeZone dtz = TimeZone.getTimeZone("Europe/London");
    TimeZone.setDefault(dtz);    

    int av_stick_day   = 0;
    int av_stick_month = 0;
    int av_stick_year  = 0;
    String av_stick_date_string = "";
    GregorianCalendar av_stick_date_gc = new GregorianCalendar();

    // Save todays date
    Date todaysDate = new java.util.Date();

    // Required for validations
    Date av_stick_date = todaysDate;
    
    // Create new simple date format (yyyy-MM-dd). This is not controlled by the context-param db_date_fmt
    // as it is just being used to turn a string date (string_date) into a real date.
    SimpleDateFormat formatStDate = new SimpleDateFormat("yyyy-MM-dd");
    // This simple date format does need to be controlled by the context-param db_date_fmt as it formats
    // the converted string_date back into a string but in the database format.
    SimpleDateFormat formatDbDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
      
    // Check to see if the av_stick_date is complete before attempting to convert to gregorian date
    if( isAvStickDateCompleted ) {
      // Get the forms integer date representation of day, month and year
      // These will be used to check if the user entry is valid, below.
      av_stick_day   = Integer.parseInt(avDetailsBean.getAv_stick_day());
      av_stick_month = Integer.parseInt(avDetailsBean.getAv_stick_month());
      av_stick_year  = Integer.parseInt(avDetailsBean.getAv_stick_year());

      // Create string representation of forms stickered date (yyyy-MM-dd)
      String string_stick_date = avDetailsBean.getAv_stick_year()  + "-" +
                                 avDetailsBean.getAv_stick_month() + "-" +
                                 avDetailsBean.getAv_stick_day();
      // Create stickered date from string 
      av_stick_date = formatStDate.parse(string_stick_date);
      av_stick_date_string = formatDbDate.format(av_stick_date);
    }
  %>
   
  <if:IfTrue cond='<%= avDetailsBean.getAction().equals("Finish") ||
                       avDetailsBean.getAction().equals("Add Another Status") ||
                       avDetailsBean.getAction().equals("W/O") %>' >

    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= helperBean.isNotValid( recordBean.getAv_status_ref() ) %>'>
      <jsp:setProperty name="avDetailsBean" property="error"
        value="Please select a new status for the AV." />
      <jsp:forward page="avDetailsView.jsp" />
    </if:IfTrue>
  
    <%-- STICKERED DATE VALIDATION --%>    
    <if:IfTrue cond="<%= isAvStickDateCompleted %>">    
      <if:IfTrue cond="<%= av_stick_day > 30 && (av_stick_month == 4 || av_stick_month == 6 || av_stick_month == 9 || av_stick_month == 11) %>">
        <jsp:setProperty name="avDetailsBean" property="error"
          value="You have entered an invalid stickered date.<br/>Please try again" />
        <jsp:forward page="avDetailsView.jsp" />
      </if:IfTrue>
      <if:IfTrue cond="<%= (av_stick_date_gc.isLeapYear(av_stick_year) && av_stick_month == 2 && av_stick_day > 29) || (!av_stick_date_gc.isLeapYear(av_stick_year) && av_stick_month == 2 && av_stick_day > 28) %>">
        <jsp:setProperty name="avDetailsBean" property="error"
          value="You have entered an invalid stickered date.<br/>Please try again" />
        <jsp:forward page="avDetailsView.jsp" />
      </if:IfTrue>
      <if:IfTrue cond="<%= av_stick_date.after(todaysDate) %>">
        <jsp:setProperty name="avDetailsBean" property="error"
          value="The stickered date cannot be in the future.<br/>Please try again" />
        <jsp:forward page="avDetailsView.jsp" />
      </if:IfTrue>
    </if:IfTrue>
    <if:IfTrue cond="<%= !isAvStickDateCompleted && !isAvStickDateBlank %>">
      <jsp:setProperty name="avDetailsBean" property="error"
        value="You have not entered a complete stickered date.<br/>Please try again" />
      <jsp:forward page="avDetailsView.jsp" />
    </if:IfTrue>
    
    <%-- STICKERED TIME VALIDATION --%>
    <%-- check that if the hours have been added then the mins should have been as well --%>
    <if:IfTrue cond="<%= !isAvStickTimeCompleted && !isAvStickTimeBlank %>">
      <jsp:setProperty name="avDetailsBean" property="error"
        value="You have not entered a complete stickered time.<br/>Please try again" />
      <jsp:forward page="avDetailsView.jsp" />
    </if:IfTrue>
    <%-- av_stick_time_h field (hrs) validation, check for integer values --%>
    <if:IfTrue cond="<%= avDetailsBean.getAv_stick_time_h() != null && !avDetailsBean.getAv_stick_time_h().equals("") &&
                         !helperBean.isStringInt(avDetailsBean.getAv_stick_time_h()) %>">
      <jsp:setProperty name="avDetailsBean" property="error"
        value="The stickered time (hrs) must be an integer.<br/>Please try again" />
      <jsp:forward page="avDetailsView.jsp" />
    </if:IfTrue>
    <%-- Check that no negative values have been entered as hours --%>
    <if:IfTrue cond="<%= avDetailsBean.getAv_stick_time_h() != null && !avDetailsBean.getAv_stick_time_h().equals("") &&
                         Integer.parseInt(avDetailsBean.getAv_stick_time_h()) < 0 %>">
      <jsp:setProperty name="avDetailsBean" property="error"
        value="The stickered time (hrs) must NOT be less than zero.<br/>Please try again" />
      <jsp:forward page="avDetailsView.jsp" />
    </if:IfTrue>
    <%-- Check that hours positive integer value is valid --%>
    <if:IfTrue cond="<%= avDetailsBean.getAv_stick_time_h() != null && !avDetailsBean.getAv_stick_time_h().equals("") &&
                         Integer.parseInt(avDetailsBean.getAv_stick_time_h()) > 23 %>">
      <jsp:setProperty name="avDetailsBean" property="error"
        value="The stickered time (hrs) must NOT be greater than 23.<br/>Please try again" />
      <jsp:forward page="avDetailsView.jsp" />
    </if:IfTrue>
    <%-- av_stick_time_m field (mins) validation, check for integer values --%>
    <if:IfTrue cond="<%= avDetailsBean.getAv_stick_time_m() != null && !avDetailsBean.getAv_stick_time_m().equals("") &&
                         !helperBean.isStringInt(avDetailsBean.getAv_stick_time_m()) %>">
      <jsp:setProperty name="avDetailsBean" property="error"
        value="The stickered time (mins) must be an integer.<br/>Please try again" />
      <jsp:forward page="avDetailsView.jsp" />
    </if:IfTrue>
    <%-- Check that no negative values have been entered as minutes --%>
    <if:IfTrue cond="<%= avDetailsBean.getAv_stick_time_m() != null && !avDetailsBean.getAv_stick_time_m().equals("") &&
                         Integer.parseInt(avDetailsBean.getAv_stick_time_m()) < 0 %>">
      <jsp:setProperty name="avDetailsBean" property="error"
        value="The stickered time (mins) must NOT be less than zero.<br/>Please try again" />
      <jsp:forward page="avDetailsView.jsp" />
    </if:IfTrue>
    <%-- Check that minutes positive integer value is valid --%>
    <if:IfTrue cond="<%= avDetailsBean.getAv_stick_time_m() != null && !avDetailsBean.getAv_stick_time_m().equals("") &&
    Integer.parseInt(avDetailsBean.getAv_stick_time_m()) >= 60 %>">
      <jsp:setProperty name="avDetailsBean" property="error"
        value="The stickered time (mins) must be less than 60.<br/>Please try again" />
      <jsp:forward page="avDetailsView.jsp" />
    </if:IfTrue>
        
    <%-- STICKERED DATE + TICK BOX VALIDATION --%>
    <if:IfTrue cond='<%= (isAvStickDateCompleted && isAvStickTimeCompleted && !avDetailsBean.getIs_stickered().equals("Y")) %>' >
      <jsp:setProperty name="avDetailsBean" property="error"
        value="The stickered date and time are completed but you have not ticked 'Stickered'.<br/>Please try again" />
      <jsp:forward page="avDetailsView.jsp" />
    </if:IfTrue>

    <%-- STICKERED EXPIRY DATE + TIME VALIDATION --%>
    <if:IfTrue cond='<%= ( (isAvStickDateCompleted && !isAvStickTimeCompleted) || (!isAvStickDateCompleted && isAvStickTimeCompleted) )  %>' >
      <jsp:setProperty name="avDetailsBean" property="error"
        value="Both Stickered Date and Stickered Time must be completed, or both must be blank.<br/>Please try again" />
      <jsp:forward page="avDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= avDetailsBean.getAction().equals("Add Another Status") %>' >
      <%-- Check to see if the new status closes the complaint --%>
      <% boolean closeComp = false; %>
      <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con1">
        <sql:query>
          SELECT closed_yn
            FROM av_status
          WHERE status_ref = '<%= recordBean.getAv_status_ref() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="closed_yn" />
          <if:IfTrue cond='<%= helperBean.isNotValid( pageContext.getAttribute("closed_yn") ) %>'>
            <% pageContext.setAttribute("closed_yn", ""); %>
          </if:IfTrue>
          <if:IfTrue cond='<%= ((String)pageContext.getAttribute("closed_yn")).trim().equals("Y") %>'>
            <% closeComp = true; %>
          </if:IfTrue>
        </sql:resultSet>
      </sql:statement>
      <sql:closeConnection conn="con1"/>
      <if:IfTrue cond='<%= closeComp %>' >
        <jsp:setProperty name="avDetailsBean" property="error"
          value="The current status will close the complaint.<br/>No further statuses can be selected." />
        <jsp:forward page="avDetailsView.jsp" />
      </if:IfTrue>
    </if:IfTrue>

    <%-- Valid entry--%>

    <%-- get rid of newline and carriage return chars from the notes --%>
    <%
      String tempTextIn = avDetailsBean.getText();
      tempTextIn = tempTextIn.replace('\n',' ');
      tempTextIn = tempTextIn.replace('\r',' ');      
      avDetailsBean.setText(tempTextIn);
      recordBean.setAv_notes(tempTextIn);
    %>
  
    <%-- Establish database connection --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
    
      <%-- Get the AV's patrol area --%>
      <sql:query>
        SELECT pa_av_area
          FROM site_pa_av
         WHERE pa_av_site_ref = '<%= recordBean.getSite_ref() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="pa_av_area" />
        <% recordBean.setPa_area((String) pageContext.getAttribute("pa_av_area")); %>
      </sql:resultSet>
      <%-- Get the item description and type from the keys table--%>
      <sql:query>
        SELECT keydesc,
               c_field
          FROM keys
         WHERE keyname = 'AV_ITEM'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="item_desc" />
        <% recordBean.setItem_desc((String) pageContext.getAttribute("item_desc")); %>
        <sql:getColumn position="2" to="item_ref" />
        <% recordBean.setItem_ref((String) pageContext.getAttribute("item_ref")); %>
      </sql:resultSet>
      <%-- Get the building status--%>
      <sql:query>
        select building_stat
        from site_detail
        where site_ref = '<%= recordBean.getSite_ref() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="building_stat" />
        <% recordBean.setBuilding_stat((String) pageContext.getAttribute("building_stat")); %>
      </sql:resultSet>
      <%-- Set the patrol officers name --%>
      <sql:query>
        select patr.po_name
        from patr, patr_area
        where patr_area.area_c = '<%= recordBean.getPa_area() %>'
        and patr_area.pa_site_flag = 'P'
        and patr.po_code = patr_area.po_code
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="po_name" />
        <% recordBean.setPo_name((String) pageContext.getAttribute("po_name")); %>
      </sql:resultSet>
      <%-- Set up AV fault code from keys table --%>
      <sql:query>
        SELECT c_field, 
               keydesc
          FROM keys
         WHERE keyname = 'AV_COMP_CODE'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="av_fault_code" />
        <% recordBean.setFault_code((String) pageContext.getAttribute("av_fault_code")); %>
        <sql:getColumn position="2" to="av_fault_desc" />
        <% recordBean.setFault_desc((String) pageContext.getAttribute("av_fault_desc")); %>
      </sql:resultSet>

      <%-- Get the AV Contract ref from the keys table --%>
      <sql:query>
        SELECT c_field, 
               keydesc
          FROM keys
         WHERE keyname = 'AV_CONTRACT'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="av_contract_ref" />
        <% recordBean.setContract_ref((String) pageContext.getAttribute("av_contract_ref")); %>
      </sql:resultSet>
     
      <%-- Get the AV last sequence number, if it doesn't exist set to 0 --%>
      <sql:query>
        SELECT last_seq 
          FROM comp_av
         WHERE complaint_no = <%= recordBean.getComplaint_no() %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="av_last_seq" />
        <sql:wasNull>
          <% recordBean.setAv_last_seq("0"); %>
        </sql:wasNull>
        <sql:wasNotNull>
          <% recordBean.setAv_last_seq((String) pageContext.getAttribute("av_last_seq")); %>
        </sql:wasNotNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% recordBean.setAv_last_seq("1"); %>
      </sql:wasEmpty>

      <%-- Get the AV doa, toa_h/m and location from comp_av_hist --%>
      <sql:query>
        SELECT doa,
               toa_h,
               toa_m,
               vehicle_position
          FROM comp_av_hist
         WHERE complaint_no = <%= recordBean.getComplaint_no() %>
           AND seq = <%= recordBean.getAv_last_seq() %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getDate position="1" to="doa" format="<%= application.getInitParameter("db_date_fmt") %>" />
        <% recordBean.setAv_doa((String) pageContext.getAttribute("doa")); %>
        <sql:getColumn position="2" to="toa_h" />
        <% recordBean.setAv_toa_h((String) pageContext.getAttribute("toa_h")); %>
        <sql:getColumn position="3" to="toa_m" />
        <% recordBean.setAv_toa_m((String) pageContext.getAttribute("toa_m")); %>
        <sql:getColumn position="4" to="position" />
        <% recordBean.setAv_position((String) pageContext.getAttribute("position")); %>
      </sql:resultSet>
      
    </sql:statement>
    <sql:closeConnection conn="con"/>   
  </if:IfTrue>
  
  <%
    // 23/07/2010  TW  Required for addAvFunc, contract, etc.
    recordBean.setAction_flag(recordBean.getComp_action_flag());
  %>
    
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= avDetailsBean.getAction().equals("Add Another Status") %>' >
    <%-- add AV details to complaint --%>
    <sess:setAttribute name="form">addAVHistFunc</sess:setAttribute>
    <c:import url="addAVHistFunc.jsp" var="webPage" />
    <% helperBean.throwException((String)pageContext.getAttribute("webPage")); %>

    <%-- Display this form again, ready for next status input --%>
    <% recordBean.setAv_status_ref(""); %>
    <% recordBean.setAv_notes(""); %>
    <% avDetailsBean.setText(""); %>

    <sess:setAttribute name="form">avDetails</sess:setAttribute>
    <jsp:forward page="avDetailsView.jsp" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= avDetailsBean.getAction().equals("Finish") %>' >    
    <%-- Valid entry --%>
    <% recordBean.setAv_action_flag("S"); %>
    <%-- add AV details to complaint --%>
    <sess:setAttribute name="form">addAVFunc</sess:setAttribute>
    <c:import url="addAVFunc.jsp" var="webPage" />
    <% helperBean.throwException((String)pageContext.getAttribute("webPage")); %>

    <%-- add complaint text --%>
    <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
    <c:import url="addTextFunc.jsp" var="webPage" />
    <% helperBean.throwException((String)pageContext.getAttribute("webPage")); %>

    <%-- run the veolia link if required --%>
    <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
    <c:import url="veoliaLinkFunc.jsp" var="webPage" />
    <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">avDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">updateStatus</sess:setAttribute>
    <c:redirect url="updateStatusScript.jsp" />
  </if:IfTrue>

  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= avDetailsBean.getAction().equals("W/O") %>' >    
    <%-- Valid entry --%>
    <%-- Set the av action flag to a Works Order --%>
    <% recordBean.setAv_action_flag("W"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">avDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">contract</sess:setAttribute>
    <c:redirect url="contractScript.jsp" />
  </if:IfTrue>

  <%-- Next view 4 --%>
  <if:IfTrue cond='<%= avDetailsBean.getAction().equals("Hist") %>' >
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">avDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">avHist</sess:setAttribute>
    <c:redirect url="avHistScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= avDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">avDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>
  
  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= avDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">avDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>
 
  <%-- Previous view --%>
  <if:IfTrue cond='<%= avDetailsBean.getAction().equals("Back") %>' >
    <% recordBean.setAction_flag(""); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">avDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= avDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${avDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="avDetailsView.jsp" />
