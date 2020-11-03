<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="com.vsb.propertyDetailsBean, com.vsb.addPrivateContractBean" %>
<%@ page import="com.vsb.recordBean, com.vsb.helperBean, com.utils.date.vsbCalendar" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="propertyDetailsBean" scope="session" class="com.vsb.propertyDetailsBean" />
<jsp:useBean id="addPrivateContractBean" scope="session" class="com.vsb.addPrivateContractBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="addPrivateContract" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="addPrivateContract" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="addPrivateContractBean" property="all" value="clear" />
    <jsp:setProperty name="addPrivateContractBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="addPrivateContractBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="propertyDetails" >
  <jsp:setProperty name="addPrivateContractBean" property="action" value="" />
  <jsp:setProperty name="addPrivateContractBean" property="all" value="clear" />
  <jsp:setProperty name="addPrivateContractBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="addPrivateContract" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Populate the view if a user has picked a private contract from the propertyDetails form --%>
    <if:IfTrue cond='<%= ! propertyDetailsBean.getTrader_ref().equals("") %>' >
      <%-- Get the database format for the date and initialise date variables --%>
      <% String dbDateFormat = application.getInitParameter("db_date_fmt"); %>
      <% String cwtn_start_date = ""; %>
      <% String cwtn_end_date = ""; %>
  
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
        <%-- Initialise the form bean by populating the form bean with the values from the record --%>
        <sql:query>
          select status_ref, business_name, ta_name, 
                 contact_name, contact_title, contact_email, contact_tel, contact_mobile,
                 recvd_by, origin, contract_size, bus_category, 
                 disposal_method, exact_locn, disposer_ref, waste_type, 
                 pa_area, notes, cwtn_start, cwtn_end
          from trading_org
          where trader_ref = <%= propertyDetailsBean.getTrader_ref() %>
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="status_ref" />
          <% addPrivateContractBean.setStatus((String)pageContext.getAttribute("status_ref")); %>
          <sql:wasNull>
            <% addPrivateContractBean.setStatus(""); %>
          </sql:wasNull>
  
          <sql:getColumn position="2" to="business_name" />
          <% addPrivateContractBean.setBusiness_name((String)pageContext.getAttribute("business_name")); %>
          <sql:wasNull>
            <% addPrivateContractBean.setBusiness_name(""); %>
          </sql:wasNull>
  
          <sql:getColumn position="3" to="ta_name" />
          <% addPrivateContractBean.setTa_name((String)pageContext.getAttribute("ta_name")); %>
          <sql:wasNull>
            <% addPrivateContractBean.setTa_name(""); %>
          </sql:wasNull>
  
          <sql:getColumn position="4" to="contact_name" />
          <% addPrivateContractBean.setContact_name((String)pageContext.getAttribute("contact_name")); %>
          <sql:wasNull>
            <% addPrivateContractBean.setContact_name(""); %>
          </sql:wasNull>
  
          <sql:getColumn position="5" to="contact_title" />
          <% addPrivateContractBean.setContact_title((String)pageContext.getAttribute("contact_title")); %>
          <sql:wasNull>
            <% addPrivateContractBean.setContact_title(""); %>
          </sql:wasNull>
  
          <sql:getColumn position="6" to="contact_email" />
          <% addPrivateContractBean.setContact_email((String)pageContext.getAttribute("contact_email")); %>
          <sql:wasNull>
            <% addPrivateContractBean.setContact_email(""); %>
          </sql:wasNull>
  
          <sql:getColumn position="7" to="contact_tel" />
          <% addPrivateContractBean.setContact_tel((String)pageContext.getAttribute("contact_tel")); %>
          <sql:wasNull>
            <% addPrivateContractBean.setContact_tel(""); %>
          </sql:wasNull>
  
          <sql:getColumn position="8" to="contact_mobile" />
          <% addPrivateContractBean.setContact_mobile((String)pageContext.getAttribute("contact_mobile")); %>
          <sql:wasNull>
            <% addPrivateContractBean.setContact_mobile(""); %>
          </sql:wasNull>
  
          <sql:getColumn position="9" to="recvd_by" />
          <% addPrivateContractBean.setRecvd_by((String)pageContext.getAttribute("recvd_by")); %>
          <sql:wasNull>
            <% addPrivateContractBean.setRecvd_by(""); %>
          </sql:wasNull>
  
          <sql:getColumn position="10" to="origin" />
          <% addPrivateContractBean.setOrigin((String)pageContext.getAttribute("origin")); %>
          <sql:wasNull>
            <% addPrivateContractBean.setOrigin(""); %>
          </sql:wasNull>
  
          <sql:getColumn position="11" to="contract_size" />
          <% addPrivateContractBean.setContract_size((String)pageContext.getAttribute("contract_size")); %>
          <sql:wasNull>
            <% addPrivateContractBean.setContract_size(""); %>
          </sql:wasNull>
  
          <sql:getColumn position="12" to="bus_category" />
          <% addPrivateContractBean.setBusiness_cat((String)pageContext.getAttribute("bus_category")); %>
          <sql:wasNull>
            <% addPrivateContractBean.setBusiness_cat(""); %>
          </sql:wasNull>
  
          <sql:getColumn position="13" to="disposal_method" />
          <% addPrivateContractBean.setDisposal_method((String)pageContext.getAttribute("disposal_method")); %>
          <sql:wasNull>
            <% addPrivateContractBean.setDisposal_method(""); %>
          </sql:wasNull>
  
          <sql:getColumn position="14" to="exact_locn" />
          <% addPrivateContractBean.setExact_location((String)pageContext.getAttribute("exact_locn")); %>
          <sql:wasNull>
            <% addPrivateContractBean.setExact_location(""); %>
          </sql:wasNull>
  
          <sql:getColumn position="15" to="disposer_ref" />
          <% addPrivateContractBean.setDisposer_ref((String)pageContext.getAttribute("disposer_ref")); %>
          <sql:wasNull>
            <% addPrivateContractBean.setDisposer_ref(""); %>
          </sql:wasNull>
  
          <sql:getColumn position="16" to="waste_type" />
          <% addPrivateContractBean.setWaste_type((String)pageContext.getAttribute("waste_type")); %>
          <sql:wasNull>
            <% addPrivateContractBean.setWaste_type(""); %>
          </sql:wasNull>
  
          <sql:getColumn position="17" to="pa_area" />
          <% addPrivateContractBean.setPa_area((String)pageContext.getAttribute("pa_area")); %>
          <sql:wasNull>
            <% addPrivateContractBean.setPa_area(""); %>
          </sql:wasNull>
  
          <sql:getColumn position="18" to="notes" />
          <% addPrivateContractBean.setNotes((String)pageContext.getAttribute("notes")); %>
          <sql:wasNull>
            <% addPrivateContractBean.setNotes(""); %>
          </sql:wasNull>

          <sql:getDate position="19" to="cwtn_start" format="<%= application.getInitParameter("db_date_fmt") %>" />
          <sql:wasNotNull>
            <% cwtn_start_date = ((String)pageContext.getAttribute("cwtn_start")).trim(); %>
          </sql:wasNotNull>
          <sql:wasNull>
            <% cwtn_start_date = ""; %>
          </sql:wasNull>

          <sql:getDate position="20" to="cwtn_end" format="<%= application.getInitParameter("db_date_fmt") %>" />
          <sql:wasNotNull>
            <% cwtn_end_date = ((String)pageContext.getAttribute("cwtn_end")).trim(); %>
          </sql:wasNotNull>
          <sql:wasNull>
            <% cwtn_end_date = ""; %>
          </sql:wasNull>
        </sql:resultSet>
        <sql:wasEmpty>
          <% addPrivateContractBean.setStatus(""); %>
          <% addPrivateContractBean.setBusiness_name(""); %>
          <% addPrivateContractBean.setTa_name(""); %>
          <% addPrivateContractBean.setContact_name(""); %>
          <% addPrivateContractBean.setContact_title(""); %>
          <% addPrivateContractBean.setContact_email(""); %>
          <% addPrivateContractBean.setContact_tel(""); %>
          <% addPrivateContractBean.setContact_mobile(""); %>
          <% addPrivateContractBean.setRecvd_by(""); %>
          <% addPrivateContractBean.setOrigin(""); %>
          <% addPrivateContractBean.setContract_size(""); %>
          <% addPrivateContractBean.setBusiness_cat(""); %>
          <% addPrivateContractBean.setDisposal_method(""); %>
          <% addPrivateContractBean.setExact_location(""); %>
          <% addPrivateContractBean.setDisposer_ref(""); %>
          <% addPrivateContractBean.setWaste_type(""); %>
          <% addPrivateContractBean.setPa_area(""); %>
          <% addPrivateContractBean.setNotes(""); %>
        </sql:wasEmpty>
        
        <%-- Initialise the day/month/year fields in the bean for the CWTN start date if not blank --%>
        <if:IfTrue cond='<%= ! cwtn_start_date.equals("") %>'>
          <% vsbCalendar cwtnStartCalendar = new vsbCalendar( cwtn_start_date, dbDateFormat ); %>
          <% addPrivateContractBean.setCwtn_start_day( cwtnStartCalendar.getDay() ); %>
          <% addPrivateContractBean.setCwtn_start_month( cwtnStartCalendar.getMonth() ); %>
          <% addPrivateContractBean.setCwtn_start_year( cwtnStartCalendar.getYear() ); %>
        </if:IfTrue>
  
        <%-- Initialise the day/month/year fields in the bean for the CWTN end date if not blank --%>
        <if:IfTrue cond='<%= ! cwtn_end_date.equals("") %>'>
          <% vsbCalendar cwtnEndCalendar = new vsbCalendar( cwtn_end_date, dbDateFormat ); %>
          <% addPrivateContractBean.setCwtn_end_day( cwtnEndCalendar.getDay() ); %>
          <% addPrivateContractBean.setCwtn_end_month( cwtnEndCalendar.getMonth() ); %>
          <% addPrivateContractBean.setCwtn_end_year( cwtnEndCalendar.getYear() ); %>
        </if:IfTrue>
      </sql:statement>
      <sql:closeConnection conn="con"/>
    </if:IfTrue>

  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="addPrivateContract" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= addPrivateContractBean.getAction().equals("Finish") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=addPrivateContractBean.getStatus() == null || addPrivateContractBean.getStatus().equals("") %>' >
      <jsp:setProperty name="addPrivateContractBean" property="error" 
        value="Please choose a status." />
      <jsp:forward page="addPrivateContractView.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond='<%=addPrivateContractBean.getBusiness_name() == null || addPrivateContractBean.getBusiness_name().equals("") %>' >
      <jsp:setProperty name="addPrivateContractBean" property="error" 
        value="Please enter a business name." />
      <jsp:forward page="addPrivateContractView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%=addPrivateContractBean.getOrigin() == null || addPrivateContractBean.getOrigin().equals("") %>' >
      <jsp:setProperty name="addPrivateContractBean" property="error" 
        value="Please choose an officer ref." />
      <jsp:forward page="addPrivateContractView.jsp" />
    </if:IfTrue>

    <%-- Get the CWTN start day, month and year --%>
    <% String cwtnStartDay   = addPrivateContractBean.getCwtn_start_day(); %>
    <% String cwtnStartMonth   = addPrivateContractBean.getCwtn_start_month(); %>
    <% String cwtnStartYear   = addPrivateContractBean.getCwtn_start_year(); %>
    <%-- If an incomplete indemnity date has been entered flag an error --%>
    <if:IfTrue cond='<%= !(cwtnStartDay.equals("")&&cwtnStartMonth.equals("")&&cwtnStartYear.equals(""))
                      && !(!cwtnStartDay.equals("")&&!cwtnStartMonth.equals("")&&!cwtnStartYear.equals("")) %>'>
      <jsp:setProperty name="addPrivateContractBean" property="error" 
        value="Incomplete CWTN start date has been entered. Please try again." />
      <jsp:forward page="addPrivateContractView.jsp" />
    </if:IfTrue>
    
    <%-- Get the CWTN end day, month and year --%>
    <% String cwtnEndDay   = addPrivateContractBean.getCwtn_end_day(); %>
    <% String cwtnEndMonth   = addPrivateContractBean.getCwtn_end_month(); %>
    <% String cwtnEndYear   = addPrivateContractBean.getCwtn_end_year(); %>
    <%-- If an incomplete indemnity date has been entered flag an error --%>
    <if:IfTrue cond='<%= !(cwtnEndDay.equals("")&&cwtnEndMonth.equals("")&&cwtnEndYear.equals(""))
                      && !(!cwtnEndDay.equals("")&&!cwtnEndMonth.equals("")&&!cwtnEndYear.equals("")) %>'>
      <jsp:setProperty name="addPrivateContractBean" property="error" 
        value="Incomplete CWTN end date has been entered. Please try again." />
      <jsp:forward page="addPrivateContractView.jsp" />
    </if:IfTrue>
   
    <%-- We know the dates either have valid data or they are all blank --%>
    <% boolean isCwtnStartDateBlank = false; %>
    <%-- Check if the CWTN start date entered is blank --%>
    <if:IfTrue cond='<%= cwtnStartDay.equals("") %>'>
      <% isCwtnStartDateBlank = true; %>
    </if:IfTrue>

    <% boolean isCwtnEndDateBlank = false; %>
    <%-- Check if the CWTN end date entered is blank --%>
    <if:IfTrue cond='<%= cwtnEndDay.equals("") %>'>
      <% isCwtnEndDateBlank = true; %>
    </if:IfTrue>

    <% GregorianCalendar calendar = new GregorianCalendar(); %>

    <%----------- CHECKING THE CWTN START DATE VARIABLES IF DATE IS NOT BLANK---------------%>
    <if:IfTrue cond='<%= !isCwtnStartDateBlank %>'>
      <% // Convert string dates to integers
        int iDay   = new Integer( cwtnStartDay ).intValue();
        int iMonth = new Integer( cwtnStartMonth ).intValue();
        int iYear  = new Integer( cwtnStartYear ).intValue();
      %> 
      
      <if:IfTrue cond='<%= iDay > 30 && (iMonth == 4 || iMonth == 6 
                        || iMonth == 9 || iMonth == 11) %>' >
        <jsp:setProperty name="addPrivateContractBean" property="error"
          value="You have entered an invalid CWTN start date.<br/>Please try again" />
        <jsp:forward page="addPrivateContractView.jsp" />
      </if:IfTrue>
      
      <if:IfTrue cond='<%= (calendar.isLeapYear(iYear) && iMonth == 2 && iDay > 29) ||
                           (!calendar.isLeapYear(iYear) && iMonth == 2 && iDay > 28) %>' >
        <jsp:setProperty name="addPrivateContractBean" property="error"
          value="You have entered an invalid CWTN start date.<br/>Please try again" />
        <jsp:forward page="addPrivateContractView.jsp" />
      </if:IfTrue>
    </if:IfTrue>

    <%----------- CHECKING THE CWTN END DATE VARIABLES IF DATE IS NOT BLANK---------------%>
    <if:IfTrue cond='<%= !isCwtnEndDateBlank %>' >
      <% // Convert string dates to integers
        int iDay   = new Integer( cwtnEndDay ).intValue();
        int iMonth = new Integer( cwtnEndMonth ).intValue();
        int iYear  = new Integer( cwtnEndYear ).intValue();
      %> 
      
      <if:IfTrue cond='<%= iDay > 30 && (iMonth == 4 || iMonth == 6 
                        || iMonth == 9 || iMonth == 11) %>' >
        <jsp:setProperty name="addPrivateContractBean" property="error"
          value="You have entered an invalid CWTN end date.<br/>Please try again" />
        <jsp:forward page="addPrivateContractView.jsp" />
      </if:IfTrue>
      
      <if:IfTrue cond='<%= (calendar.isLeapYear(iYear) && iMonth == 2 && iDay > 29) ||
                           (!calendar.isLeapYear(iYear) && iMonth == 2 && iDay > 28) %>' >
        <jsp:setProperty name="addPrivateContractBean" property="error"
          value="You have entered an invalid CWTN end date.<br/>Please try again" />
        <jsp:forward page="addPrivateContractView.jsp" />
      </if:IfTrue>
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- add a private contract --%>
    <sess:setAttribute name="form">addUpdatePrivateContractFunc</sess:setAttribute>
    <c:import url="addUpdatePrivateContractFunc.jsp" var="webPage" />
    <% helperBean.throwException("addUpdatePrivateContractFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addPrivateContract</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">updateStatus</sess:setAttribute>
    <c:redirect url="updateStatusScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= addPrivateContractBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addPrivateContract</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= addPrivateContractBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addPrivateContract</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= addPrivateContractBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addPrivateContract</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= addPrivateContractBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${addPrivateContractBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="addPrivateContractView.jsp" />
