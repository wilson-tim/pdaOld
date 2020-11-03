<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.taskAgreementBean, com.vsb.recordBean, com.vsb.loginBean, com.vsb.helperBean" %>
<%@ page import="java.text.SimpleDateFormat, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="taskAgreementBean" scope="session" class="com.vsb.taskAgreementBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="taskAgreement" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="taskAgreement" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="taskAgreementBean" property="all" value="clear" />
    <jsp:setProperty name="taskAgreementBean" property="*" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="ta_no" param="taskAgreement_no" />
    <%-- Tokenize the view_key as long as a user selected an item --%>
    <if:IfTrue cond='<%= taskAgreementBean.getView_key() != null && !taskAgreementBean.getView_key().equals("") %>' >
      <%
        StringTokenizer view_key = new StringTokenizer(taskAgreementBean.getView_key(), "|");
        String tat_no = view_key.nextToken();
        String lift_sno = view_key.nextToken();

        recordBean.setTat_no(tat_no.trim());
        recordBean.setTat_lift_sno(lift_sno.trim());
      %>
    </if:IfTrue>        

  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="taskAgreementBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="agreement" >
  <jsp:setProperty name="taskAgreementBean" property="action" value="" />
  <jsp:setProperty name="taskAgreementBean" property="all" value="clear" />
  <jsp:setProperty name="taskAgreementBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="taskAgreement" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= taskAgreementBean.getAction().equals(application.getInitParameter("def_name_verb")) %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= taskAgreementBean.getView_key() == null ||
                         taskAgreementBean.getView_key().equals("") %>' >
      <jsp:setProperty name="taskAgreementBean" property="error"
        value="Please choose an item." />
      <jsp:forward page="taskAgreementView.jsp" />
    </if:IfTrue>

    <%-- valid entry--%>
    <%-- Get the agreements name and number --%>
    <sql:connection id="conn1" jndiName="java:comp/env/jdbc/pda"/>
    <sql:statement id="stmt1" conn="conn1">
    
      <sql:query>
        SELECT coll_day,
               before_after,
               time_hr,
               time_min,
               round_ref,
               to_time_h,
               to_time_m
          FROM lifts
         WHERE lift_sno = <%= recordBean.getTat_lift_sno() %>
           AND agree_task_no = <%= recordBean.getTat_no() %>
      </sql:query>
      <sql:resultSet id="rset8">
        <sql:getColumn position="1" to="coll_day" />
        <% recordBean.setTat_coll_day((String) pageContext.getAttribute("coll_day")); %>
        <sql:getColumn position="2" to="before_after" />
        <% recordBean.setTat_before_after((String) pageContext.getAttribute("before_after")); %>
        <sql:getColumn position="3" to="time_hr" />
        <% recordBean.setTat_time_hr((String) pageContext.getAttribute("time_hr")); %>
        <sql:getColumn position="4" to="time_min" />
        <% recordBean.setTat_time_min((String) pageContext.getAttribute("time_min")); %>
        <sql:getColumn position="5" to="round_ref" />
        <% recordBean.setTat_round_ref((String) pageContext.getAttribute("round_ref")); %>
        <% recordBean.setTat_coll_day_no( helperBean.getDayNo((String) pageContext.getAttribute("coll_day")) ); %>
        <sql:getColumn position="6" to="to_time_h" />
        <% recordBean.setTat_to_time_h((String) pageContext.getAttribute("to_time_h")); %>
        <sql:getColumn position="7" to="to_time_m" />
        <% recordBean.setTat_to_time_m((String) pageContext.getAttribute("to_time_m")); %>
      </sql:resultSet>

      <sql:query>
        SELECT task_ref,
               exact_locn
          FROM agree_task
         WHERE agree_task_no = <%= recordBean.getTat_no() %>
      </sql:query>
      <sql:resultSet id="rset1">
        <sql:getColumn position="1" to="task_ref" />
        <% recordBean.setTat_ref((String) pageContext.getAttribute("task_ref")); %>
        <sql:getColumn position="2" to="exact_locn" />
        <% recordBean.setTat_exact_locn((String) pageContext.getAttribute("exact_locn")); %>
      </sql:resultSet>

      <app:equalsInitParameter name="module" match="pda-in" >
        <sql:query>
          select c_field
          from keys
          where service_c = 'ALL'
          and   keyname = 'PDA_INSPECTOR_ROLE'
        </sql:query>
        <sql:resultSet id="rset2">
          <sql:getColumn position="1" to="pda_role" />
          <% recordBean.setPda_role((String) pageContext.getAttribute("pda_role")); %>
        </sql:resultSet>
      </app:equalsInitParameter>

      <app:equalsInitParameter name="module" match="pda-tw" >
        <sql:query>
          select c_field
          from keys
          where service_c = 'ALL'
          and   keyname = 'PDA_WARDEN_ROLE'
        </sql:query>
        <sql:resultSet id="rset3">
          <sql:getColumn position="1" to="pda_role" />
          <% recordBean.setPda_role((String) pageContext.getAttribute("pda_role")); %>
        </sql:resultSet>
      </app:equalsInitParameter>
    
      <sql:query>
        select c_field
        from keys
        where keyname = 'AV_SERVICE'
        and   service_c = 'ALL'
      </sql:query>
      <sql:resultSet id="rset4">
        <sql:getColumn position="1" to="av_service" />
        <% recordBean.setAv_service((String) pageContext.getAttribute("av_service")); %>
      </sql:resultSet>

      <sql:query>
        select c_field
        from keys
        where keyname = 'TRADE_ITEM'
        and   service_c = 'ALL'
      </sql:query>
      <sql:resultSet id="rset6">
        <sql:getColumn position="1" to="trade_item" />
        <% recordBean.setItem_ref((String) pageContext.getAttribute("trade_item")); %>
      </sql:resultSet>

      <sql:query>
        select item_desc, item_type, contract_ref, priority_f
        from item
        where item_ref = '<%= recordBean.getItem_ref() %>'
      </sql:query>
      <sql:resultSet id="rset7">
        <sql:getColumn position="1" to="item_desc" />
        <% recordBean.setItem_desc((String) pageContext.getAttribute("item_desc")); %>
        <sql:getColumn position="2" to="item_type" />
        <% recordBean.setItem_type((String) pageContext.getAttribute("item_type")); %>
        <sql:getColumn position="3" to="contract_ref" />
        <% recordBean.setContract_ref((String) pageContext.getAttribute("contract_ref")); %>
        <sql:getColumn position="4" to="priority_flag" />
        <% recordBean.setPriority((String) pageContext.getAttribute("priority_flag")); %>          
      </sql:resultSet>

      <sql:query>
        select building_stat
        from site_detail
        where site_ref = '<%= recordBean.getSite_ref() %>'
       </sql:query>
      <sql:resultSet id="rset8">
        <sql:getColumn position="1" to="building_stat" />
        <% recordBean.setBuilding_stat((String) pageContext.getAttribute("building_stat")); %>
      </sql:resultSet>

      <sql:query>
        select lookup_text
        from allk
        where lookup_code = '<%= recordBean.getBuilding_stat() %>'
        and lookup_func = 'SITEBG'
      </sql:query>
      <sql:resultSet id="rset10">
        <sql:getColumn position="1" to="building_stat_desc" />
        <% recordBean.setBuilding_stat_desc((String) pageContext.getAttribute("building_stat_desc")); %>
      </sql:resultSet>

      <sql:query>
        select pa_area
          from trade_site
         where site_no = '<%= recordBean.getTrade_site_no() %>'
      </sql:query>
      <sql:resultSet id="rset12">
        <sql:getColumn position="1" to="pa_area" />
        <% recordBean.setPa_area((String) pageContext.getAttribute("pa_area")); %>
        <sql:wasNull>
          <% recordBean.setPa_area(""); %>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% recordBean.setPa_area(""); %>          
      </sql:wasEmpty>
      
      <sql:query>
        select patr.po_name
        from patr, patr_area
        where patr_area.area_c = '<%= recordBean.getPa_area() %>'
        and patr_area.pa_site_flag = 'P'
        and patr.po_code = patr_area.po_code
      </sql:query>
      <sql:resultSet id="rset11">
        <sql:getColumn position="1" to="po_name" />
        <% recordBean.setPo_name((String) pageContext.getAttribute("po_name")); %>
      </sql:resultSet>

      <%-- for trade the feature_ref is a copy of the item_ref ! --%>
      <% recordBean.setFeature_ref(recordBean.getItem_ref()); %>

      <sql:query>
        select feature_desc
        from feat
        where feature_ref = '<%= recordBean.getFeature_ref() %>'
      </sql:query>
      <sql:resultSet id="rset13">
        <sql:getColumn position="1" to="feature_desc" />
        <% recordBean.setFeature_desc((String) pageContext.getAttribute("feature_desc")); %>
        <sql:wasNull>
          <% recordBean.setFeature_desc(""); %>
        </sql:wasNull>          
      </sql:resultSet>
      <sql:wasEmpty>
        <% recordBean.setFeature_desc(""); %>          
      </sql:wasEmpty>

      <sql:query>
        select n_field
        from keys
        where keyname = 'DEFAULT_VOLUME'
        and service_c = 'ALL'
      </sql:query>
      <sql:resultSet id="rset13">
        <sql:getColumn position="1" to="volume" />
        <% recordBean.setVolume((String) pageContext.getAttribute("volume")); %>
        <% recordBean.setTotal_volume((String) pageContext.getAttribute("volume")); %>        
        <sql:wasNull>
          <% recordBean.setVolume("1"); %>
          <% recordBean.setTotal_volume("1"); %>                    
        </sql:wasNull>          
      </sql:resultSet>
      <sql:wasEmpty>
        <% recordBean.setVolume("1"); %>
        <% recordBean.setTotal_volume("1"); %>        
      </sql:wasEmpty>      
      
    </sql:statement>
    <sql:closeConnection conn="conn1"/>

    <%-- set up the date_due as today, as the TRADE complaint will not have a si_i record --%>
    <%
      // Set the default time zone to where we are, as the time zone
      // returned from sco is GMT+00:00 which is fine but doesn't mentioned
      // BST. So the default timezone has to be set to "Europe/London".
      // Any objects which use the timezone (like SimpleDateFormat) will then
      // be using the correct timezone.
      TimeZone dtz = TimeZone.getTimeZone("Europe/London");
      TimeZone.setDefault(dtz);
    
      String date;
      SimpleDateFormat formatDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
    
      Date currentDate = new java.util.Date();
      date = formatDate.format(currentDate);
  
      recordBean.setDate_due(date);
    %>

    <%-- indicate to the faultLookup form that we are doing a default --%>
    <% recordBean.setAction_flag("D"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">taskAgreement</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">faultLookup</sess:setAttribute>
    <c:redirect url="faultLookupScript.jsp" />    
  
  </if:IfTrue>


  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= taskAgreementBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">taskAgreement</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= taskAgreementBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">taskAgreement</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>
  
  <%-- Previous view --%>
  <if:IfTrue cond='<%= taskAgreementBean.getAction().equals("Back") %>' >
    <% recordBean.setAction_flag(""); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">taskAgreement</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= taskAgreementBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${taskAgreementBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="taskAgreementView.jsp" />
