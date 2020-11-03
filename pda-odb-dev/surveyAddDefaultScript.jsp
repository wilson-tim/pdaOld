<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.surveyAddDefaultBean, com.vsb.recordBean, com.vsb.surveyGradingBean" %>
<%@ page import="com.vsb.textBean, com.vsb.addCustDetailsBean" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"      prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c" %>

<jsp:useBean id="surveyAddDefaultBean" scope="session" class="com.vsb.surveyAddDefaultBean" />
<jsp:useBean id="surveyGradingBean"    scope="session" class="com.vsb.surveyGradingBean" />
<jsp:useBean id="recordBean"           scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="textBean"             scope="session" class="com.vsb.textBean" />
<jsp:useBean id="addCustDetailsBean"   scope="session" class="com.vsb.addCustDetailsBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="surveyAddDefault" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- clear errors --%>
<jsp:setProperty name="surveyAddDefaultBean" property="error" value="" />

<%-- Open connection to the database --%>
<sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
<sql:statement id="stmt" conn="con">

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="surveyAddDefault" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="surveyAddDefaultBean" property="all" value="clear" />
    <jsp:setProperty name="surveyAddDefaultBean" property="*" />
    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="fault_code" value='<%= surveyAddDefaultBean.getLookup_code() %>' />

    <sql:query>
      select lookup_text, lookup_num
      from allk
      where lookup_func = 'DEFRN'
      and   lookup_code = '<%= recordBean.getFault_code() %>'
    </sql:query>
    <sql:resultSet id="rset">
       <sql:getColumn position="1" to="lookup_text" />
       <% recordBean.setFault_desc((String) pageContext.getAttribute("lookup_text")); %>
       <sql:getColumn position="2" to="lookup_num" />
       <% recordBean.setNotice_no((String) pageContext.getAttribute("lookup_num")); %>
    </sql:resultSet>
   
  </if:IfParameterEquals>
</req:existsParameter>    

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="defaultAdditional" >
  <jsp:setProperty name="surveyAddDefaultBean" property="action" value="" />
  <jsp:setProperty name="surveyAddDefaultBean" property="all"    value="bean" />
  <jsp:setProperty name="surveyAddDefaultBean" property="savedPreviousForm"
    value='surveyGrading' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="surveyGrading" >
  <jsp:setProperty name="surveyAddDefaultBean" property="action" value="" />
  <jsp:setProperty name="surveyAddDefaultBean" property="all"    value="bean" />
  <jsp:setProperty name="surveyAddDefaultBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="surveyAddDefault" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
    <%-- get the graffiti service name --%>
    <sql:query>
      select c_field
      from keys
      where service_c = 'ALL'
      and   keyname = 'ERT_SERVICE'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="c_field" />
      <sql:wasNotNull>
        <% recordBean.setGraffiti_service((String) pageContext.getAttribute("c_field")); %>
      </sql:wasNotNull>
    </sql:resultSet>

    <%-- The module is inspectors --%>
    <app:equalsInitParameter name="module" match="pda-in" >
      <sql:query>
        select c_field
        from keys
        where service_c = 'ALL'
        and   keyname = 'PDA_INSPECTOR_ROLE'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="pda_role" />
        <% recordBean.setPda_role((String) pageContext.getAttribute("pda_role")); %>
      </sql:resultSet>
    </app:equalsInitParameter>

    <%-- The module is town warden --%>
    <app:equalsInitParameter name="module" match="pda-tw" >
      <sql:query>
        select c_field
        from keys
        where service_c = 'ALL'
        and   keyname = 'PDA_WARDEN_ROLE'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="pda_role" />
        <% recordBean.setPda_role((String) pageContext.getAttribute("pda_role")); %>
      </sql:resultSet>
    </app:equalsInitParameter>
    
    <%-- Copy the BV199 site varaibles to the record bean site variables --%>
	  <% recordBean.setSite_ref( recordBean.getBv_site_ref() );              %>
    <% recordBean.setSite_name_1( recordBean.getBv_site_name_1() );        %>
    <% recordBean.setLocation_c( recordBean.getBv_location_c() );          %>
    <% recordBean.setPostcode( recordBean.getBv_postcode() );              %>
    <% recordBean.setBuild_no( recordBean.getBv_build_no() );              %>
    <% recordBean.setBuild_sub_no( recordBean.getBv_build_sub_no() );      %>
    <% recordBean.setBuild_name( recordBean.getBv_build_name() );          %>
    <% recordBean.setBuild_sub_name( recordBean.getBv_build_sub_name() );  %>
    <% recordBean.setArea_ward_desc( recordBean.getBv_area_ward_desc() );  %>
    <% recordBean.setLocation_name( recordBean.getBv_location_name() );    %>
    
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If we are not getting input from the form we run this section to setup the recordBean --%>
<sess:equalsAttribute name="input" match="surveyAddDefault" value="false">
  <%-- We now need to check if any of the items have their flags set to 'Y'. If an items --%>
  <%-- flag is set to 'Y' then we need to setup the record bean with all the information --%>
  <%-- that is needed in order to raise a default. --%>

  <%-- Check if there are any flags set to 'Y' --%>
  <if:IfTrue cond='<%= surveyGradingBean.isAnyFlagSet() %>'>

    <%-- Get the last items name whose flag is set to 'Y' --%>
    <% surveyAddDefaultBean.setBv_name( surveyGradingBean.getLastSetItem() ); %>

    <%-- Get the service for this bv_item --%>
    <% String bv_service = ""; %>
    <sql:query>
      SELECT c_field FROM keys WHERE keyname = 'BV199_<%= surveyAddDefaultBean.getBv_name() %>_SERVICE'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="bv_service" />
      <% bv_service = ((String)pageContext.getAttribute("bv_service")).trim(); %>
      <% recordBean.setService_c( bv_service ); %>
    </sql:resultSet>

    <%-- Get the item for this bv_item --%>
    <% String bv_item = ""; %>
    <sql:query>
      SELECT c_field FROM keys WHERE keyname = '<%= "BV199_"+surveyAddDefaultBean.getBv_name()+"_TYPE" %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="bv_item" />
      <% bv_item = ((String)pageContext.getAttribute("bv_item")).trim(); %>
    </sql:resultSet>

    <%-- Get all the variables needed to create a default from the si_i table --%>
    <sql:query>
      SELECT distinct item_ref, 
                      feature_ref, 
                      contract_ref,
                      occur_day,
                      occur_week,
                      occur_month,
                      round_c,
                      pa_area,
                      priority_flag,
                      volume,
                      date_due
        FROM si_i
       WHERE site_ref = '<%= recordBean.getSite_ref() %>'
         AND item_ref IN (
           SELECT item_ref
             FROM item
            WHERE bv199_type = '<%= bv_item %>'
         )
    </sql:query>
    <%-- Set the record bean with these variables --%>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="item_ref" />
      <% recordBean.setItem_ref((String) pageContext.getAttribute("item_ref")); %>
      <sql:getColumn position="2" to="feature_ref" />
      <% recordBean.setFeature_ref((String) pageContext.getAttribute("feature_ref")); %>
      <sql:getColumn position="3" to="contract_ref" />
      <% recordBean.setContract_ref((String) pageContext.getAttribute("contract_ref")); %>
      <sql:getColumn position="4" to="occur_day" />
      <% recordBean.setOccur_day((String) pageContext.getAttribute("occur_day")); %>
      <sql:getColumn position="5" to="occur_week" />
      <% recordBean.setOccur_week((String) pageContext.getAttribute("occur_week")); %>
      <sql:getColumn position="6" to="occur_month" />
      <% recordBean.setOccur_month((String) pageContext.getAttribute("occur_month")); %>
      <sql:getColumn position="7" to="round_c" />
      <% recordBean.setRound_c((String) pageContext.getAttribute("round_c")); %>
      <sql:getColumn position="8" to="pa_area" />
      <% recordBean.setPa_area((String) pageContext.getAttribute("pa_area")); %>
      <sql:getColumn position="9" to="priority_flag" />
      <% recordBean.setPriority((String) pageContext.getAttribute("priority_flag")); %>
      <sql:getColumn position="10" to="total_volume" />
      <% recordBean.setTotal_volume((String) pageContext.getAttribute("total_volume")); %>
      <sql:getDate position="11" to="date_due" format="<%= application.getInitParameter("db_date_fmt") %>" />
      <sql:wasNotNull>
        <% recordBean.setDate_due((String) pageContext.getAttribute("date_due")); %>
      </sql:wasNotNull>
      <sql:wasNull>
        <% recordBean.setDate_due(""); %>
      </sql:wasNull>
    </sql:resultSet>
    <sql:wasEmpty>
      <% recordBean.setItem_ref(""); %>
      <% recordBean.setFeature_ref(""); %>
      <% recordBean.setContract_ref(""); %>
      <% recordBean.setOccur_day(""); %>
      <% recordBean.setOccur_week(""); %>
      <% recordBean.setOccur_month(""); %>
      <% recordBean.setRound_c(""); %>
      <% recordBean.setPa_area(""); %>
      <% recordBean.setPriority(""); %>
      <% recordBean.setTotal_volume(""); %>
      <% recordBean.setDate_due(""); %>
    </sql:wasEmpty>

    <%-- Set the defaults text from the grading beans text value --%>
    <if:IfTrue cond='<%= surveyAddDefaultBean.getBv_name().equals("LITTER") %>'>
      <% textBean.setText( surveyGradingBean.getLitter_text() ); %>
    </if:IfTrue>
    <if:IfTrue cond='<%= surveyAddDefaultBean.getBv_name().equals("DETRIT") %>'>
      <% textBean.setText( surveyGradingBean.getDetritus_text() ); %>
    </if:IfTrue>
    <if:IfTrue cond='<%= surveyAddDefaultBean.getBv_name().equals("GRAFF") %>'>
      <% textBean.setText( surveyGradingBean.getGraffiti_text() ); %>
    </if:IfTrue>
    <if:IfTrue cond='<%= surveyAddDefaultBean.getBv_name().equals("FLYPOS") %>'>
      <% textBean.setText( surveyGradingBean.getFlyposting_text() ); %>
    </if:IfTrue>
    <%-- indicate the route which will be taken to get to defaultAdditional --%>
    <% recordBean.setDefault_route("surveyAddDefault"); %>
    
    <sql:query>
      select feature_desc
      from feat
      where feature_ref = '<%= recordBean.getFeature_ref() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="feature_desc" />
      <% recordBean.setFeature_desc((String) pageContext.getAttribute("feature_desc")); %>
    </sql:resultSet>
    <sql:wasEmpty>
      <% recordBean.setFeature_desc(""); %>
    </sql:wasEmpty>

    <sql:query>
      select item_desc, item_type
      from item
      where item_ref = '<%= recordBean.getItem_ref() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="item_desc" />
      <% recordBean.setItem_desc((String) pageContext.getAttribute("item_desc")); %>
      <sql:getColumn position="2" to="item_type" />
      <% recordBean.setItem_type((String) pageContext.getAttribute("item_type")); %>
    </sql:resultSet>
    <sql:wasEmpty>
      <% recordBean.setItem_desc(""); %>
      <% recordBean.setItem_type(""); %>
    </sql:wasEmpty>

    <sql:query>
      select building_stat
      from site_detail
      where site_ref = '<%= recordBean.getSite_ref() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="building_stat" />
      <% recordBean.setBuilding_stat((String) pageContext.getAttribute("building_stat")); %>
    </sql:resultSet>

    <sql:query>
      select lookup_text
      from allk
      where lookup_code = '<%= recordBean.getBuilding_stat() %>'
      and lookup_func = 'SITEBG'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="building_stat_desc" />
      <% recordBean.setBuilding_stat_desc((String) pageContext.getAttribute("building_stat_desc")); %>
    </sql:resultSet>

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
  
  </if:IfTrue>
</sess:equalsAttribute>


<%-- Close connection to the database --%>
</sql:statement>
<sql:closeConnection conn="con"/>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- If we are not adding defaults we can skip this form and goto the surveyConfirm form --%>
<if:IfTrue cond='<%= !surveyGradingBean.isAnyFlagSet() %>'>
  <%-- Valid entry --%>
  <%-- Indicate which form we are in/just-come-from --%>
  <sess:setAttribute name="input">surveyAddDefault</sess:setAttribute>  
  <%-- Indicate which form we are coming from when we forward to another form --%>
  <%-- This is the form before this one as we are skipping this form --%>
  <sess:setAttribute name="previousForm">surveyAddDefault</sess:setAttribute>
  <%-- Indicate which form we are going to next--%>
  <sess:setAttribute name="form">surveyConfirm</sess:setAttribute>
  <c:redirect url="surveyConfirmScript.jsp" />
</if:IfTrue>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="surveyAddDefault" >

  <%-- Next view 1--%>
  <if:IfTrue cond='<%= surveyAddDefaultBean.getAction().equals(application.getInitParameter("def_name_verb")) %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=surveyAddDefaultBean.getLookup_code() == null ||
                        surveyAddDefaultBean.getLookup_code().equals("") %>' >
      <jsp:setProperty name="surveyAddDefaultBean" property="error"
        value="Please choose a fault code." />
      <jsp:forward page="surveyAddDefaultView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- indicate that we are going to be adding a default --%>
    <% recordBean.setAction_flag("D"); %>
    <%-- add a bv199 default --%> 
    <% recordBean.setBv_default_flag("Y"); %>
    <%-- 06/10/2010  TW  Checked by addComplaintFunc.jsp before creating CUSTOMER records --%>
    <% addCustDetailsBean.setConfirm("No"); %>
    <%-- Create the message to say that this item has been defaulted when we get back --%>
    <% recordBean.setBv_message("Created " + surveyAddDefaultBean.getBv_name() + " " + application.getInitParameter("def_name_noun").toLowerCase() + "."); %>
    <%-- If this is a graffiti default, we need to take the user to the graffiti details form --%>
    <if:IfTrue cond='<%= recordBean.getService_c().equals( recordBean.getGraffiti_service() ) %>'>
      <%-- Set the graffiti flag to 'Y' --%>
      <% recordBean.setDart_graff_flag("Y"); %>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">surveyAddDefault</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">graffDetails</sess:setAttribute>
      <c:redirect url="graffDetailsScript.jsp" />
    </if:IfTrue>
    <%-- Set the graffiti flag to 'N' --%>
    <% recordBean.setDart_graff_flag("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyAddDefault</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">streetLength</sess:setAttribute>
    <c:redirect url="streetLengthScript.jsp" />
  </if:IfTrue>
  
  <%-- Menu view 1--%>
  <if:IfTrue cond='<%= surveyAddDefaultBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyAddDefault</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2--%>
  <if:IfTrue cond='<%= surveyAddDefaultBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyAddDefault</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>  
  <if:IfTrue cond='<%= surveyAddDefaultBean.getAction().equals("Back") %>' >
    <%-- Set the graffiti flag to 'N' --%>
    <% recordBean.setDart_graff_flag("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyAddDefault</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= surveyAddDefaultBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${surveyAddDefaultBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="surveyAddDefaultView.jsp" />
