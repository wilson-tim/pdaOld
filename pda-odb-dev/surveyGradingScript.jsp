<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.surveyGradingBean" %>
<%@ page import="com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app"  %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="surveyGradingBean" scope="session" class="com.vsb.surveyGradingBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="surveyGrading" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="surveyGrading" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="surveyGradingBean" property="all" value="clear" />
    <jsp:setProperty name="surveyGradingBean" property="*" />

		<%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="bv_litter_grade"      value='<%=surveyGradingBean.getLitter_grade()%>' />
    <jsp:setProperty name="recordBean" property="bv_litter_text"       value='<%=surveyGradingBean.getLitter_text()%>' />
    <jsp:setProperty name="recordBean" property="bv_detritus_grade"    value='<%=surveyGradingBean.getDetritus_grade()%>' />
    <jsp:setProperty name="recordBean" property="bv_detritus_text"     value='<%=surveyGradingBean.getDetritus_text()%>' />
    <jsp:setProperty name="recordBean" property="bv_graffiti_grade"    value='<%=surveyGradingBean.getGraffiti_grade()%>' />
    <jsp:setProperty name="recordBean" property="bv_graffiti_text"     value='<%=surveyGradingBean.getGraffiti_text()%>' />
    <jsp:setProperty name="recordBean" property="bv_fly_posting_grade" value='<%=surveyGradingBean.getFlyposting_grade()%>' />
    <jsp:setProperty name="recordBean" property="bv_fly_posting_text" value='<%=surveyGradingBean.getFlyposting_text()%>' />
    <%-- Save the complaint_no and comp_action_flag for the surveyConfirm form to repopulate the --%>
    <%-- recordBean. This is because if any defaults are created they will overwrite the recordBeans --%>
    <%-- values with there own, and the addSurveyFunc will update the wrong complaint_no. --%> 
    <%-- 11/10/2010  TW  If coming via Inspect route make these assignments in inspListScript.jsp --%>
    <%--                 Otherwise a new enquiry is being created and there is nothing to save --%>
    <if:IfTrue cond='<%= !recordBean.getComingFromInspList().equals("Y") %>'>
      <jsp:setProperty name="recordBean" property="bv_complaint_no_save" value="" />
      <jsp:setProperty name="recordBean" property="bv_comp_action_flag_save" value="" />
    </if:IfTrue>
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="surveyGradingBean" property="error" value="" />

<%-- error message --%>
<% String errorMsg = ""; %>

<%-- error switch --%>
<% boolean isError = false; %>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="surveyLandUse" >
  <jsp:setProperty name="surveyGradingBean" property="action" value="" />
  <jsp:setProperty name="surveyGradingBean" property="all" value="bean" />
  <jsp:setProperty name="surveyGradingBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>
<sess:equalsAttribute name="input" match="surveyExisting" >
  <jsp:setProperty name="surveyGradingBean" property="action" value="" />
  <jsp:setProperty name="surveyGradingBean" property="all" value="bean" />
  <jsp:setProperty name="surveyGradingBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="surveyGrading" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>

    <app:equalsInitParameter name="use_bv199_defaulting" match="Y">    
      <%-- Open connection to the database --%>
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
      <sql:statement id="stmt" conn="con">
        
        <%-- Setup the grades translation hashmap in the bean --%>
        <sql:query>
          SELECT lookup_code, 
                 lookup_text
            FROM allk
           WHERE lookup_func = 'BVGRAD'
           ORDER BY lookup_code
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="lookup_code" />
          <% String lookup_code = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
          <sql:getColumn position="2" to="lookup_text" />
          <% String lookup_text = ((String)pageContext.getAttribute("lookup_text")).trim(); %>
          <% surveyGradingBean.addGrade( lookup_text, lookup_code ); %>
          <% surveyGradingBean.addCode( lookup_text, lookup_code ); %>
        </sql:resultSet>
        
      
        <%-- Get all the required system keys for the BV199 Defaults and set the flags    --%>
        <%-- for each of the items. A flag is set to 'Y' if the grade given to the item   --%>
        <%-- appears in the list of grades that should raise a default. This is done only --%>
        <%-- when we first come from the surveyGrading form.                              --%>
        
        <%-- Get the Litter raise default grades --%>
        <sql:query>
          SELECT c_field FROM keys WHERE keyname = 'BV199_LITTER_DEF'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="litter_list" />
          <sql:wasNotNull>
            <% surveyGradingBean.setLitter_list( ((String)pageContext.getAttribute("litter_list")).trim() ); %>
          </sql:wasNotNull>
          <sql:wasNull>
            <% surveyGradingBean.setLitter_list(""); %>
            <% errorMsg = "Exception: System Key not set - BV199_LITTER_DEF"; %>
            <% isError = true; %>
          </sql:wasNull>
        </sql:resultSet>
        <sql:wasEmpty>
          <% surveyGradingBean.setLitter_list(""); %>
          <% errorMsg = "Exception: System Key not set - BV199_LITTER_DEF"; %>
          <% isError = true; %>
        </sql:wasEmpty>
        <%-- Get the Detritus item --%>
        <sql:query>
          SELECT c_field FROM keys WHERE keyname = 'BV199_DETRIT_DEF'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="detrit_list" />     
          <sql:wasNotNull>
            <% surveyGradingBean.setDetrit_list( ((String)pageContext.getAttribute("detrit_list")).trim() ); %>
          </sql:wasNotNull>
          <sql:wasNull>
            <% surveyGradingBean.setDetrit_list(""); %>
            <% errorMsg = "Exception: System Key not set - BV199_DETRIT_DEF"; %>
            <% isError = true; %>
          </sql:wasNull>
        </sql:resultSet>
        <sql:wasEmpty>
          <% surveyGradingBean.setDetrit_list(""); %>
          <% errorMsg = "Exception: System Key not set - BV199_DETRIT_DEF"; %>
          <% isError = true; %>
        </sql:wasEmpty>
        <%-- Get the Graffiti item --%>
        <sql:query>
          SELECT c_field FROM keys WHERE keyname = 'BV199_GRAFF_DEF'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="grafft_list" />
          <sql:wasNotNull>
            <% surveyGradingBean.setGrafft_list( ((String)pageContext.getAttribute("grafft_list")).trim() ); %>
          </sql:wasNotNull>
          <sql:wasNull>
            <% surveyGradingBean.setGrafft_list(""); %>
            <% errorMsg = "Exception: System Key not set - BV199_GRAFF_DEF"; %>
            <% isError = true; %>
          </sql:wasNull>
        </sql:resultSet>
        <sql:wasEmpty>
          <% surveyGradingBean.setGrafft_list(""); %>
          <% errorMsg = "Exception: System Key not set - BV199_GRAFF_DEF"; %>
          <% isError = true; %>
        </sql:wasEmpty>
        <%-- Get the Fly Posting item --%>
        <sql:query>
          SELECT c_field FROM keys WHERE keyname = 'BV199_FLYPOS_DEF'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="flypos_list" />
          <sql:wasNotNull>
            <% surveyGradingBean.setFlypos_list( ((String)pageContext.getAttribute("flypos_list")).trim() ); %>
          </sql:wasNotNull>
          <sql:wasNull>
            <% surveyGradingBean.setFlypos_list(""); %>
            <% errorMsg = "Exception: System Key not set - BV199_FLYPOS_DEF"; %>
            <% isError = true; %>
          </sql:wasNull>
        </sql:resultSet>
        <sql:wasEmpty>
          <% surveyGradingBean.setFlypos_list(""); %>
          <% errorMsg = "Exception: System Key not set - BV199_FLYPOS_DEF"; %>
          <% isError = true; %>
        </sql:wasEmpty>
        
      <%-- Close connection to the database --%>
      </sql:statement>
      <sql:closeConnection conn="con"/>
    </app:equalsInitParameter>    
    
  </if:IfTrue>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="surveyGrading" >
  <%-- Next view --%>
	<if:IfTrue cond='<%= surveyGradingBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
   	<if:IfTrue cond='<%= surveyGradingBean.getLitter_grade().toUpperCase().equals("GRADE") %>' >
   		<jsp:setProperty name="surveyGradingBean" property="error"
        value="Choose grade for: Litter" />
      <jsp:forward page="surveyGradingView.jsp" />
    </if:IfTrue>
    <if:IfTrue cond='<%= surveyGradingBean.getDetritus_grade().toUpperCase().equals("GRADE") %>' >
   		<jsp:setProperty name="surveyGradingBean" property="error"
        value="Choose grade for: Detritus" />
      <jsp:forward page="surveyGradingView.jsp" />
    </if:IfTrue>
    <if:IfTrue cond='<%= surveyGradingBean.getGraffiti_grade().toUpperCase().equals("GRADE") %>' >
   		<jsp:setProperty name="surveyGradingBean" property="error"
        value="Choose grade for: Graffiti" />
      <jsp:forward page="surveyGradingView.jsp" />
    </if:IfTrue>
    <if:IfTrue cond='<%= surveyGradingBean.getFlyposting_grade().toUpperCase().equals("GRADE") %>' >
   		<jsp:setProperty name="surveyGradingBean" property="error"
        value="Choose grade for: Fly Posting" />
      <jsp:forward page="surveyGradingView.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond='<%= isError %>' >
   		<jsp:setProperty name="surveyGradingBean" property="error"
        value="<%= errorMsg%>" />
      <jsp:forward page="surveyGradingView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= surveyGradingBean.getLitter_text().length() > 256 %>' >
      <%
        int n = surveyGradingBean.getLitter_text().length() - 256;
        String error = "Grading text is limited to 256 characters."+
        "Please delete " + n + " characters from the Litter text.";
      %>
      <jsp:setProperty name="surveyGradingBean" property="error" value='<%= error %>' />
      <jsp:forward page="surveyGradingView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= surveyGradingBean.getDetritus_text().length() > 256 %>' >
      <%
        int n = surveyGradingBean.getDetritus_text().length() - 256;
        String error = "Grading text is limited to 256 characters."+
        "Please delete " + n + " characters from the Detritus text.";
      %>
      <jsp:setProperty name="surveyGradingBean" property="error" value='<%= error %>' />
      <jsp:forward page="surveyGradingView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= surveyGradingBean.getGraffiti_text().length() > 256 %>' >
      <%
        int n = surveyGradingBean.getGraffiti_text().length() - 256;
        String error = "Grading text is limited to 256 characters."+
        "Please delete " + n + " characters from the Graffiti text.";
      %>
      <jsp:setProperty name="surveyGradingBean" property="error" value='<%= error %>' />
      <jsp:forward page="surveyGradingView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= surveyGradingBean.getFlyposting_text().length() > 256 %>' >
      <%
        int n = surveyGradingBean.getFlyposting_text().length() - 256;
        String error = "Grading text is limited to 256 characters."+
        "Please delete " + n + " characters from the Flyposting text.";
      %>
      <jsp:setProperty name="surveyGradingBean" property="error" value='<%= error %>' />
      <jsp:forward page="surveyGradingView.jsp" />
    </if:IfTrue>

    <app:equalsInitParameter name="use_bv199_defaulting" match="Y">    
      <%-- Set the flags for each BV199 items depending on the grade given --%>
      <%-- Flags are not allowed to be changed if they have already been defaulted i.e. set to 'A' --%>
      <%-- BV199 LITTER --%>
      <if:IfTrue cond='<%= surveyGradingBean.isGrade_in_litter_list( recordBean.getBv_litter_grade() ) && 
                           (!surveyGradingBean.isLitter_defaulted()) %>'>
        <% surveyGradingBean.setLitter_flag("Y"); %>
      </if:IfTrue>
      <if:IfTrue cond='<%= !surveyGradingBean.isGrade_in_litter_list( recordBean.getBv_litter_grade() ) && 
                           (!surveyGradingBean.isLitter_defaulted()) %>'>
        <% surveyGradingBean.setLitter_flag("N"); %>
      </if:IfTrue>
      <%-- BV199 DETRITUS --%>
      <if:IfTrue cond='<%= surveyGradingBean.isGrade_in_detrit_list( recordBean.getBv_detritus_grade() ) &&
                           (!surveyGradingBean.isDetrit_defaulted()) %>'>
        <% surveyGradingBean.setDetrit_flag("Y"); %>
      </if:IfTrue>
      <if:IfTrue cond='<%= !surveyGradingBean.isGrade_in_detrit_list( recordBean.getBv_detritus_grade() ) &&
                           (!surveyGradingBean.isDetrit_defaulted()) %>'>
        <% surveyGradingBean.setDetrit_flag("N"); %>
      </if:IfTrue>
      <%-- BV199 GRAFFITI --%>
      <if:IfTrue cond='<%= surveyGradingBean.isGrade_in_grafft_list( recordBean.getBv_graffiti_grade() ) &&
                           (!surveyGradingBean.isGrafft_defaulted()) %>'>
        <% surveyGradingBean.setGrafft_flag("Y"); %>
      </if:IfTrue>
      <if:IfTrue cond='<%= !surveyGradingBean.isGrade_in_grafft_list( recordBean.getBv_graffiti_grade() ) &&
                           (!surveyGradingBean.isGrafft_defaulted()) %>'>
        <% surveyGradingBean.setGrafft_flag("N"); %>
      </if:IfTrue>
      <%-- BV199 FLY POSTING --%>
      <if:IfTrue cond='<%= surveyGradingBean.isGrade_in_flypos_list( recordBean.getBv_fly_posting_grade() ) &&
                           (!surveyGradingBean.isFlypos_defaulted()) %>'>
        <% surveyGradingBean.setFlypos_flag("Y"); %>
      </if:IfTrue>
      <if:IfTrue cond='<%= !surveyGradingBean.isGrade_in_flypos_list( recordBean.getBv_fly_posting_grade() ) &&
                           (!surveyGradingBean.isFlypos_defaulted()) %>'>
        <% surveyGradingBean.setFlypos_flag("N"); %>
      </if:IfTrue>    
    </app:equalsInitParameter>

    <%-- Valid entry --%>
    <%-- If we are raising defaults then we need to go to the surveyAddDefaultForm --%>
    <app:equalsInitParameter name="use_bv199_defaulting" match="Y">
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">surveyGrading</sess:setAttribute>
      <%-- Indicate which form we are going to next--%>
      <sess:setAttribute name="form">surveyAddDefault</sess:setAttribute>
      <c:redirect url="surveyAddDefaultScript.jsp" />
    </app:equalsInitParameter>
    <app:equalsInitParameter name="use_bv199_defaulting" match="Y" value="false">
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">surveyGrading</sess:setAttribute>
      <%-- Indicate which form we are going to next--%>
      <sess:setAttribute name="form">surveyConfirm</sess:setAttribute>
      <c:redirect url="surveyConfirmScript.jsp" />
    </app:equalsInitParameter>

  </if:IfTrue>

  <%-- Menu view --%>
  <if:IfTrue cond='<%= surveyGradingBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyGrading</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view --%>
  <if:IfTrue cond='<%= surveyGradingBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyGrading</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= surveyGradingBean.getAction().equals("Back") %>' >
    <%-- Invalid entry --%>  
    <%-- Do not allow the user to leave if they have already defaulted an item --%>
    <app:equalsInitParameter name="use_bv199_defaulting" match="Y">    
      <if:IfTrue cond='<%= surveyGradingBean.isAnyFlagDefaulted() %>'>
        <% String errorValue="Action Cancelled. You have already " + application.getInitParameter("def_name_past").toLowerCase() + " an item on this survey. Please complete the survey."; %>
        <jsp:setProperty name="surveyGradingBean" property="error"
          value="<%= errorValue %>" />
        <jsp:forward page="surveyGradingView.jsp" />
      </if:IfTrue>
    </app:equalsInitParameter>
    <%-- Valid entry --%>    
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyGrading</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= surveyGradingBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${surveyGradingBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="surveyGradingView.jsp" />
