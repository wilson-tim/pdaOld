<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="com.vsb.avAddDetailsBean, com.vsb.recordBean, com.vsb.helperBean" %>
<%@ page import="java.util.GregorianCalendar" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>

<jsp:useBean id="avAddDetailsBean" scope="session" class="com.vsb.avAddDetailsBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="avAddDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="avAddDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="avAddDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="avAddDetailsBean" property="*" />
    
    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="av_car_id"       param="car_id" />
    <jsp:setProperty name="recordBean" property="av_colour_ref"   param="colour_ref" />
    <jsp:setProperty name="recordBean" property="av_model_ref"    param="model_ref" />
    <jsp:setProperty name="recordBean" property="av_is_stickered" param="is_stickered" />
    <jsp:setProperty name="recordBean" property="av_is_taxed"     param="is_taxed" />
    <jsp:setProperty name="recordBean" property="av_vin"          param="vin" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="avAddDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form --%>
<sess:equalsAttribute name="input" match="avMake" >
  <jsp:setProperty name="avAddDetailsBean" property="action" value="" />
  <jsp:setProperty name="avAddDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="avAddDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="avAddDetails" >
  <%
    // Check if any fields are blank
    boolean isAvStickDateCompleted = false;
    if( (!avAddDetailsBean.getAv_stick_day().equals(""))   &&
        (!avAddDetailsBean.getAv_stick_month().equals("")) && 
        (!avAddDetailsBean.getAv_stick_year().equals("")) ) {
      isAvStickDateCompleted = true;
    }
    boolean isAvStickTimeCompleted = false;
    if( (!avAddDetailsBean.getAv_stick_time_h().equals(""))   &&
        (!avAddDetailsBean.getAv_stick_time_m().equals("")) ) {
      isAvStickTimeCompleted = true;
    }
    boolean isAvTaxDateCompleted = false;
    if( (!avAddDetailsBean.getAv_tax_day().equals(""))   &&
        (!avAddDetailsBean.getAv_tax_month().equals("")) && 
        (!avAddDetailsBean.getAv_tax_year().equals("")) ) {
      isAvTaxDateCompleted = true;
    }
    // Check if all the fields are blank
    boolean isAvStickDateBlank = false;
    if( (avAddDetailsBean.getAv_stick_day().equals(""))   && 
        (avAddDetailsBean.getAv_stick_month().equals("")) && 
        (avAddDetailsBean.getAv_stick_year().equals("")) ) {
      isAvStickDateBlank = true;
    }
    boolean isAvStickTimeBlank = false;
    if( (avAddDetailsBean.getAv_stick_time_h().equals(""))   && 
        (avAddDetailsBean.getAv_stick_time_m().equals("")) ) {
      isAvStickTimeBlank = true;
    }
    boolean isAvTaxDateBlank = false;
    if( (avAddDetailsBean.getAv_tax_day().equals(""))   && 
        (avAddDetailsBean.getAv_tax_month().equals("")) && 
        (avAddDetailsBean.getAv_tax_year().equals("")) ) {
      isAvTaxDateBlank = true;
    }
  
    // Set the time zone
    TimeZone dtz = TimeZone.getTimeZone("Europe/London");
    TimeZone.setDefault(dtz);    

    int av_stick_day   = 0;
    int av_stick_month = 0;
    int av_stick_year  = 0;
    int av_tax_day     = 0;
    int av_tax_month   = 0;
    int av_tax_year    = 0;
    String av_stick_date_string = "";
    GregorianCalendar av_stick_date_gc = new GregorianCalendar();
    String av_tax_date_string = "";
    GregorianCalendar av_tax_date_gc = new GregorianCalendar();

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
      av_stick_day   = Integer.parseInt(avAddDetailsBean.getAv_stick_day());
      av_stick_month = Integer.parseInt(avAddDetailsBean.getAv_stick_month());
      av_stick_year  = Integer.parseInt(avAddDetailsBean.getAv_stick_year());

      // Create string representation of forms stickered date (yyyy-MM-dd)
      String string_stick_date = avAddDetailsBean.getAv_stick_year()  + "-" +
                                 avAddDetailsBean.getAv_stick_month() + "-" +
                                 avAddDetailsBean.getAv_stick_day();
      // Create stickered date from string 
      av_stick_date = formatStDate.parse(string_stick_date);
      av_stick_date_string = formatDbDate.format(av_stick_date);
    }

    // Check to see if the av_tax_date is complete before attempting to convert to gregorian date
    if( isAvTaxDateCompleted ) {
      // Get the forms integer date representation of day, month and year
      // These will be used to check if the user entry is valid, below.
      av_tax_day     = Integer.parseInt(avAddDetailsBean.getAv_tax_day());
      av_tax_month   = Integer.parseInt(avAddDetailsBean.getAv_tax_month());
      av_tax_year    = Integer.parseInt(avAddDetailsBean.getAv_tax_year());

      // Create string representation of forms tax expiry date (yyyy-MM-dd)
      String string_tax_date = avAddDetailsBean.getAv_tax_year()  + "-" +
                               avAddDetailsBean.getAv_tax_month() + "-" +
                               avAddDetailsBean.getAv_tax_day();
      // Create tax expiry date from string 
      Date av_tax_date = formatStDate.parse(string_tax_date);
      av_tax_date_string = formatDbDate.format(av_tax_date);
    }
  %>
   
  <%-- Invalid entry --%>
  <if:IfTrue cond='<%= avAddDetailsBean.getAction().equals("Status") || avAddDetailsBean.getAction().equals("Continue") %>' >
    <%-- User entered both plates and no plates--%>
    <if:IfTrue cond='<%= avAddDetailsBean.getNo_id().equals("NO PLATES") && 
                        (!avAddDetailsBean.getCar_id().trim().equals("") &&
                         !avAddDetailsBean.getCar_id().trim().equals("NO PLATES") )  %>'>
      <jsp:setProperty name="avAddDetailsBean" property="error"
        value="Cannot enter Car ID and tick 'No Car ID'.<br/>Please try again" />
      <jsp:forward page="avAddDetailsView.jsp" />
    </if:IfTrue>

    <%-- User entered neither car_id or "no plates"--%>
    <if:IfTrue cond='<%= avAddDetailsBean.getCar_id().trim().equals("") && avAddDetailsBean.getNo_id().equals("")  %>' >
      <jsp:setProperty name="avAddDetailsBean" property="error"
        value="Please enter a Car ID or tick 'No Car ID'.<br/>Please try again" />
      <jsp:forward page="avAddDetailsView.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond='<%= avAddDetailsBean.getModel_ref() == null || avAddDetailsBean.getModel_ref().trim().equals("") %>' >
      <jsp:setProperty name="avAddDetailsBean" property="error" 
        value="Please choose a model.<br/>Please try again" />
      <jsp:forward page="avAddDetailsView.jsp" />
    </if:IfTrue>
  
    <if:IfTrue cond='<%= avAddDetailsBean.getColour_ref() == null || avAddDetailsBean.getColour_ref().trim().equals("") %>' >
      <jsp:setProperty name="avAddDetailsBean" property="error"
        value="Please choose a colour.<br/>Please try again" />
      <jsp:forward page="avAddDetailsView.jsp" />
    </if:IfTrue>

    <%-- Check if the car_id is already being used in an open complaint as long as it is not "NO PLATES" --%> 
    <%-- Establish database connection --%>

    <if:IfTrue cond='<%= ! recordBean.getAv_car_id().equals("NO PLATES") && ! recordBean.getAv_car_id().equals("NOPLATES") %>'>
      <% boolean carIdExists = false; %>
      <% String running_complaint_no = ""; %>
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
        <sql:query>
          SELECT comp.complaint_no 
          FROM comp, comp_av
          WHERE comp.date_closed is null
          AND   comp_av.complaint_no = comp.complaint_no
          AND   comp_av.car_id = '<%= recordBean.getAv_car_id().toUpperCase() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="complaint_no" />
          <sql:wasNotNull>
            <% running_complaint_no = ((String) pageContext.getAttribute("complaint_no")).trim(); %>
          </sql:wasNotNull>
        </sql:resultSet>
        <sql:wasEmpty>
          <% carIdExists = false; %>
        </sql:wasEmpty>
        <sql:wasNotEmpty>
          <% carIdExists = true; %>
        </sql:wasNotEmpty>
      </sql:statement>
      <sql:closeConnection conn="con"/> 
      <if:IfTrue cond='<%= carIdExists == true %>' >
        <% 
          String carIdError = "The Car ID is already in use by another running complaint: " +
            running_complaint_no + "<br/>Please try again";
        %>
        <jsp:setProperty name="avAddDetailsBean" property="error"
          value="<%= carIdError %>" />
        <jsp:forward page="avAddDetailsView.jsp" />
      </if:IfTrue>
    </if:IfTrue>

    <%-- STICKERED DATE VALIDATION --%>    
    <if:IfTrue cond="<%= isAvStickDateCompleted %>">    
      <if:IfTrue cond="<%= av_stick_day > 30 && (av_stick_month == 4 || av_stick_month == 6 || av_stick_month == 9 || av_stick_month == 11) %>">
        <jsp:setProperty name="avAddDetailsBean" property="error"
          value="You have entered an invalid stickered date.<br/>Please try again" />
        <jsp:forward page="avAddDetailsView.jsp" />
      </if:IfTrue>
      <if:IfTrue cond="<%= (av_stick_date_gc.isLeapYear(av_stick_year) && av_stick_month == 2 && av_stick_day > 29) || (!av_stick_date_gc.isLeapYear(av_stick_year) && av_stick_month == 2 && av_stick_day > 28) %>">
        <jsp:setProperty name="avAddDetailsBean" property="error"
          value="You have entered an invalid stickered date.<br/>Please try again" />
        <jsp:forward page="avAddDetailsView.jsp" />
      </if:IfTrue>
      <if:IfTrue cond="<%= av_stick_date.after(todaysDate) %>">
        <jsp:setProperty name="avAddDetailsBean" property="error"
          value="The stickered date cannot be in the future.<br/>Please try again" />
        <jsp:forward page="avAddDetailsView.jsp" />
      </if:IfTrue>
    </if:IfTrue>
    <if:IfTrue cond="<%= !isAvStickDateCompleted && !isAvStickDateBlank %>">
      <jsp:setProperty name="avAddDetailsBean" property="error"
        value="You have not entered a complete stickered date.<br/>Please try again" />
      <jsp:forward page="avAddDetailsView.jsp" />
    </if:IfTrue>
    
    <%-- STICKERED TIME VALIDATION --%>
    <%-- check that if the hours have been added then the mins should have been as well --%>
    <if:IfTrue cond="<%= !isAvStickTimeCompleted && !isAvStickTimeBlank %>">
      <jsp:setProperty name="avAddDetailsBean" property="error"
        value="You have not entered a complete stickered time.<br/>Please try again" />
      <jsp:forward page="avAddDetailsView.jsp" />
    </if:IfTrue>
    <%-- av_stick_time_h field (hrs) validation, check for integer values --%>
    <if:IfTrue cond="<%= avAddDetailsBean.getAv_stick_time_h() != null && !avAddDetailsBean.getAv_stick_time_h().equals("") &&
                         !helperBean.isStringInt(avAddDetailsBean.getAv_stick_time_h()) %>">
      <jsp:setProperty name="avAddDetailsBean" property="error"
        value="The stickered time (hrs) must be an integer.<br/>Please try again" />
      <jsp:forward page="avAddDetailsView.jsp" />
    </if:IfTrue>
    <%-- Check that no negative values have been entered as hours --%>
    <if:IfTrue cond="<%= avAddDetailsBean.getAv_stick_time_h() != null && !avAddDetailsBean.getAv_stick_time_h().equals("") &&
                         Integer.parseInt(avAddDetailsBean.getAv_stick_time_h()) < 0 %>">
      <jsp:setProperty name="avAddDetailsBean" property="error"
        value="The stickered time (hrs) must NOT be less than zero.<br/>Please try again" />
      <jsp:forward page="avAddDetailsView.jsp" />
    </if:IfTrue>
    <%-- Check that hours positive integer value is valid --%>
    <if:IfTrue cond="<%= avAddDetailsBean.getAv_stick_time_h() != null && !avAddDetailsBean.getAv_stick_time_h().equals("") &&
                         Integer.parseInt(avAddDetailsBean.getAv_stick_time_h()) > 23 %>">
      <jsp:setProperty name="avAddDetailsBean" property="error"
        value="The stickered time (hrs) must NOT be greater than 23.<br/>Please try again" />
      <jsp:forward page="avAddDetailsView.jsp" />
    </if:IfTrue>
    <%-- av_stick_time_m field (mins) validation, check for integer values --%>
    <if:IfTrue cond="<%= avAddDetailsBean.getAv_stick_time_m() != null && !avAddDetailsBean.getAv_stick_time_m().equals("") &&
                         !helperBean.isStringInt(avAddDetailsBean.getAv_stick_time_m()) %>">
      <jsp:setProperty name="avAddDetailsBean" property="error"
        value="The stickered time (mins) must be an integer.<br/>Please try again" />
      <jsp:forward page="avAddDetailsView.jsp" />
    </if:IfTrue>
    <%-- Check that no negative values have been entered as minutes --%>
    <if:IfTrue cond="<%= avAddDetailsBean.getAv_stick_time_m() != null && !avAddDetailsBean.getAv_stick_time_m().equals("") &&
                         Integer.parseInt(avAddDetailsBean.getAv_stick_time_m()) < 0 %>">
      <jsp:setProperty name="avAddDetailsBean" property="error"
        value="The stickered time (mins) must NOT be less than zero.<br/>Please try again" />
      <jsp:forward page="avAddDetailsView.jsp" />
    </if:IfTrue>
    <%-- Check that minutes positive integer value is valid --%>
    <if:IfTrue cond="<%= avAddDetailsBean.getAv_stick_time_m() != null && !avAddDetailsBean.getAv_stick_time_m().equals("") &&
    Integer.parseInt(avAddDetailsBean.getAv_stick_time_m()) >= 60 %>">
      <jsp:setProperty name="avAddDetailsBean" property="error"
        value="The stickered time (mins) must be less than 60.<br/>Please try again" />
      <jsp:forward page="avAddDetailsView.jsp" />
    </if:IfTrue>
        
    <%-- TAX EXPIRY DATE VALIDATION --%>    
    <if:IfTrue cond="<%= isAvTaxDateCompleted %>">    
      <if:IfTrue cond="<%= av_tax_day > 30 && (av_tax_month == 4 || av_tax_month == 6 || av_tax_month == 9 || av_tax_month == 11) %>">
        <jsp:setProperty name="avAddDetailsBean" property="error"
          value="You have entered an invalid tax expiry date.<br/>Please try again" />
        <jsp:forward page="avAddDetailsView.jsp" />
      </if:IfTrue>
      <if:IfTrue cond="<%= (av_tax_date_gc.isLeapYear(av_tax_year) && av_tax_month == 2 && av_tax_day > 29) || (!av_tax_date_gc.isLeapYear(av_tax_year) && av_tax_month == 2 && av_tax_day > 28) %>">
        <jsp:setProperty name="avAddDetailsBean" property="error"
          value="You have entered an invalid tax date.<br/>Please try again" />
        <jsp:forward page="avAddDetailsView.jsp" />
      </if:IfTrue>
    </if:IfTrue>
    <if:IfTrue cond="<%= !isAvTaxDateCompleted && !isAvTaxDateBlank %>">
      <jsp:setProperty name="avAddDetailsBean" property="error"
        value="You have not entered a complete tax expiry date.<br/>Please try again" />
      <jsp:forward page="avAddDetailsView.jsp" />
    </if:IfTrue>
    
    <%-- STICKERED OR TAX EXPIRY DATE + TICK BOX VALIDATION --%>
    <if:IfTrue cond='<%= (isAvStickDateCompleted && isAvStickTimeCompleted && !avAddDetailsBean.getIs_stickered().equals("Y")) %>' >
      <jsp:setProperty name="avAddDetailsBean" property="error"
        value="The stickered date and time are completed but you have not ticked 'Stickered'.<br/>Please try again" />
      <jsp:forward page="avAddDetailsView.jsp" />
    </if:IfTrue>
    <if:IfTrue cond='<%= (avAddDetailsBean.getIs_taxed().equals("Y") && (!isAvTaxDateCompleted || isAvTaxDateBlank)) %>' >
      <jsp:setProperty name="avAddDetailsBean" property="error"
        value="You have ticked 'Tax Displayed' but not completed the Tax Expiry Date.<br/>Please try again" />
      <jsp:forward page="avAddDetailsView.jsp" />
    </if:IfTrue>
    <if:IfTrue cond='<%= (!avAddDetailsBean.getIs_taxed().equals("Y") && isAvTaxDateCompleted) %>' >
      <jsp:setProperty name="avAddDetailsBean" property="error"
        value="The tax expiry date is completed but you have not ticked 'Tax Displayed'.<br/>Please try again" />
      <jsp:forward page="avAddDetailsView.jsp" />
    </if:IfTrue>

    <%-- STICKERED EXPIRY DATE + TIME VALIDATION --%>
    <if:IfTrue cond='<%= ( (isAvStickDateCompleted && !isAvStickTimeCompleted) || (!isAvStickDateCompleted && isAvStickTimeCompleted) )  %>' >
      <jsp:setProperty name="avAddDetailsBean" property="error"
        value="Both Stickered Date and Stickered Time must be completed, or both must be blank.<br/>Please try again" />
      <jsp:forward page="avAddDetailsView.jsp" />
    </if:IfTrue>

    <%-- Make sure the user has selected an action to be performed --%>
    <if:IfTrue cond='<%= avAddDetailsBean.getActionTaken() == null || avAddDetailsBean.getActionTaken().equals("") %>' >
      <jsp:setProperty name="avAddDetailsBean" property="error"
        value="Please select an action to perform." />
      <jsp:forward page="avAddDetailsView.jsp" />
    </if:IfTrue>
   
    <%-- Valid entry--%>
    <%-- 08/07/2010  TW  Action selection now possible --%>
    <% recordBean.setAction_flag("H"); %>

    <if:IfTrue cond='<%= avAddDetailsBean.getActionTaken().equals("Hold") %>' >
      <% recordBean.setAction_flag("H"); %>
    </if:IfTrue>

    <if:IfTrue cond='<%= avAddDetailsBean.getActionTaken().equals("Inspect") %>' >
      <% recordBean.setAction_flag("I"); %>
    </if:IfTrue>

    <if:IfTrue cond='<%= avAddDetailsBean.getActionTaken().equals(application.getInitParameter("def_name_noun")) %>' >
      <% recordBean.setAction_flag("D"); %>
    </if:IfTrue>

    <if:IfTrue cond='<%= avAddDetailsBean.getActionTaken().equals("Works Order") %>' >
      <% recordBean.setAction_flag("W"); %>
    </if:IfTrue>

    <if:IfTrue cond='<%= avAddDetailsBean.getActionTaken().equals("No Action") %>' >
      <% recordBean.setAction_flag("N"); %>
    </if:IfTrue>

    <%-- Change the car_id if the 'no car id' is ticked --%>

    <if:IfTrue cond='<%= avAddDetailsBean.getNo_id().equals("NO PLATES") %>'>
      <% recordBean.setAv_car_id("NO PLATES"); %>
    </if:IfTrue>

    <%-- Establish database connection --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <%-- Get the AV's patrol area --%>
      <sql:query>
        SELECT pa_area
          FROM site_pa
         WHERE site_ref = '<%= recordBean.getSite_ref() %>'
         AND   pa_func = 'AV'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="pa_area" />
        <% recordBean.setPa_area((String) pageContext.getAttribute("pa_area")); %>
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
          
    </sql:statement>
    <sql:closeConnection conn="con"/>   

    <%-- get rid of all spaces in the car_id --%>
    <% recordBean.setAv_car_id(helperBean.removeSpaces(recordBean.getAv_car_id())); %>

    <%-- Set the date values in the avAddDetailsBean --%>
    <% avAddDetailsBean.setAv_stick_date(av_stick_date_string);       %>    
    <% avAddDetailsBean.setAv_tax_date(av_tax_date_string);       %>    

    <if:IfTrue cond='<%= avAddDetailsBean.getActionTaken().equals("Inspect") %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">avAddDetails</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">inspDate</sess:setAttribute>
      <c:redirect url="inspDateScript.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= !avAddDetailsBean.getActionTaken().equals("Inspect") %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">avAddDetails</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">avStatus</sess:setAttribute>
      <c:redirect url="avStatusScript.jsp" />
    </if:IfTrue>
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= avAddDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">avAddDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>
  
  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= avAddDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">avAddDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>
 
  <%-- Previous view --%>
  <if:IfTrue cond='<%= avAddDetailsBean.getAction().equals("Back") %>' >
    <% recordBean.setAction_flag(""); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">avAddDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= avAddDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${avAddDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="avAddDetailsView.jsp" />
