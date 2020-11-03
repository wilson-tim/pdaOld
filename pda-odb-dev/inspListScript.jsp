<%@ page errorPage="error.jsp" %>
<%@ page import ="com.vsb.inspListBean, com.vsb.inspQueryBean" %>
<%@ page import ="com.vsb.recordBean, com.vsb.loginBean, com.vsb.systemKeysBean" %>
<%@ page import ="com.db.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"      prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c" %>

<jsp:useBean id="recordBean"      scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="systemKeysBean"  scope="session" class="com.vsb.systemKeysBean" />
<jsp:useBean id="inspListBean"    scope="session" class="com.vsb.inspListBean" />
<jsp:useBean id="inspQueryBean"   scope="session" class="com.vsb.inspQueryBean" />
<jsp:useBean id="loginBean"       scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="inspListPageSet" scope="session" class="com.db.PageSet" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="inspList" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="inspList" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="inspListBean" property="all" value="clear" />
    <jsp:setProperty name="inspListBean" property="*" />

    <%-- Clear the previous record --%>
    <jsp:setProperty name="recordBean" property="all" value="clear" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="complaint_no" param="complaint_no" />
    <jsp:setProperty name="recordBean" property="clearedDefault" value="N" />
    <jsp:setProperty name="recordBean" property="comingFromInspList" value="Y" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="inspListBean" property="error" value="" />

<%-- clear form fields if coming from previous form via a menu jump --%>
<%-- and update savedPreviousForm as if we had just come from the mainMenu form. --%>
<%-- Also reset the menuJump session object. --%>
<sess:equalsAttribute name="menuJump" match="yes">
  <jsp:setProperty name="inspListBean" property="action" value="" />
  <jsp:setProperty name="inspListBean" property="all"    value="clear" />
  <jsp:setProperty name="inspListBean" property="savedPreviousForm" value="mainMenu" />
  <sess:setAttribute name="menuJump">no</sess:setAttribute>
  <sess:setAttribute name="sort_order">date</sess:setAttribute>
  <jsp:setProperty   name="inspListBean" property="page_number" value="1" />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="mainMenu" >
  <jsp:setProperty name="inspListBean" property="action" value="" />
  <jsp:setProperty name="inspListBean" property="all"    value="clear" />
  <jsp:setProperty name="inspListBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>
<sess:equalsAttribute name="input" match="inspQuery" >
  <jsp:setProperty name="inspListBean" property="action" value="" />
  <jsp:setProperty name="inspListBean" property="all"    value="clear" />
  <jsp:setProperty name="inspListBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
<sql:statement id="stmt" conn="con">
  <%-- Get the sample source --%>
  <sql:query>
    select c_field
    from keys
    where service_c = 'ALL'
    and   keyname = 'SAMPLE_SOURCE'
  </sql:query>
  <sql:resultSet id="rset">
     <sql:getColumn position="1" to="sample_source" />
     <% recordBean.setSample_source((String) pageContext.getAttribute("sample_source")); %>
  </sql:resultSet>

  <sql:query>
    select c_field
    from keys
    where service_c = 'ALL'
    and   keyname = 'ADHOC_SAMPLE_SOURCE'
  </sql:query>
  <sql:resultSet id="rset">
     <sql:getColumn position="1" to="adhoc_sample_source" />
     <% recordBean.setAdhoc_sample_source((String) pageContext.getAttribute("adhoc_sample_source")); %>
  </sql:resultSet>

  <%-- Get Item_ref --%>
  <sql:query>
    select c_field
    from keys
    where keyname = 'BV199_ITEM'
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="bv_item_ref" />
    <% recordBean.setBv_item_ref((String)pageContext.getAttribute("bv_item_ref")); %>
  </sql:resultSet>

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
  
  <%-- get the dart service name --%>
  <sql:query>
    select c_field
    from keys
    where service_c = 'ALL'
    and   keyname = 'DART_SERVICE'
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="c_field" />
    <sql:wasNotNull>
      <% recordBean.setDart_service((String) pageContext.getAttribute("c_field")); %>
    </sql:wasNotNull>
  </sql:resultSet>

  <%-- get the AV service name --%>
  <sql:query>
    select c_field
    from keys
    where service_c = 'ALL'
    and   keyname = 'AV_SERVICE'
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="c_field" />
    <sql:wasNotNull>
      <% recordBean.setAv_service((String) pageContext.getAttribute("c_field")); %>
    </sql:wasNotNull>
  </sql:resultSet>
  
  <%-- get the TRADE service name --%>
  <sql:query>
    select c_field
    from keys
    where service_c = 'ALL'
    and   keyname = 'TRADE_SERVICE'
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="c_field" />
    <sql:wasNotNull>
      <% recordBean.setTrade_service((String) pageContext.getAttribute("c_field")); %>
    </sql:wasNotNull>
  </sql:resultSet>

  <%-- get the TREES service name --%>
  <sql:query>
    select c_field
    from keys
    where service_c = 'ALL'
    and   keyname = 'TREES_SERVICE'
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="c_field" />
    <sql:wasNotNull>
      <% recordBean.setTrees_service((String) pageContext.getAttribute("c_field")); %>
    </sql:wasNotNull>
  </sql:resultSet>

  <%-- get the TREES service item --%>
  <sql:query>
    select c_field
    from keys
    where service_c = 'ALL'
    and   keyname = 'TREES_ITEM'
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="c_field" />
    <sql:wasNotNull>
      <% recordBean.setTrees_item((String) pageContext.getAttribute("c_field")); %>
    </sql:wasNotNull>
  </sql:resultSet>

  <%-- get the Highways service name --%>
  <sql:query>
    select c_field
    from keys
    where service_c = 'ALL'
    and   keyname = 'HWAY_SERVICE'
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="c_field" />
    <sql:wasNotNull>
      <% recordBean.setHway_service((String) pageContext.getAttribute("c_field")); %>
    </sql:wasNotNull>
  </sql:resultSet>

  <%-- Find out what version of contender is being run against the database --%>
  <%-- 10/05/2010  TW  Read contender_version from systemKeysBean --%>
  <% recordBean.setContender_version( systemKeysBean.getContender_version() ); %>

  <%-- pda_limit_list now done in the daemon --%>

</sql:statement>
<sql:closeConnection conn="con"/>

<%-- Populate the sort_order for use in the VIEW, but only the first time through the SCRIPT, --%>
<%-- set the page number to 1 the first time we are viewing the form --%>
<sess:equalsAttribute name="input" match="inspList" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals("mainMenu") %>' >
    <sess:setAttribute name="sort_order">date</sess:setAttribute>
    <jsp:setProperty   name="inspListBean" property="page_number" value="1" />
  </if:IfTrue>
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals("inspQuery") %>' >
    <sess:setAttribute name="sort_order">date</sess:setAttribute>
    <jsp:setProperty   name="inspListBean" property="page_number" value="1" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- We need to check if the ordering of the list has been changed. If  --%>
<%-- it has we need to re-create the list and show page 1 again. We use --%>
<%-- the order_changed flag to test if the order has been changed below --%>
<% boolean ordering_changed = false; %>
     
<if:IfTrue cond='<%= inspListBean.getAction().equals("Post") %>' >
  <sess:setAttribute name="sort_order">postcode</sess:setAttribute>
  <% ordering_changed = true; %>
</if:IfTrue>
<if:IfTrue cond='<%= inspListBean.getAction().equals("Ward") %>' >
  <sess:setAttribute name="sort_order">ward</sess:setAttribute>
  <% ordering_changed = true; %>
</if:IfTrue>
<if:IfTrue cond='<%= inspListBean.getAction().equals("Area") %>' >
  <sess:setAttribute name="sort_order">area</sess:setAttribute>
  <% ordering_changed = true; %>
</if:IfTrue>
<if:IfTrue cond='<%= inspListBean.getAction().equals("Date") %>' >
  <sess:setAttribute name="sort_order">date</sess:setAttribute>
  <% ordering_changed = true; %>
</if:IfTrue>

<%-- Declare the query string variable --%>
<% String queryString = ""; %>
                   
<%-- set the number of records per page ( Application variable in web.xml ) --%>
<% int recordsOnPage = new Integer(application.getInitParameter("records_on_insp_list")).intValue(); %>
<% inspListPageSet.setRecordsOnPage( recordsOnPage ); %>

<%-- Declare the result set variable --%>
<% java.sql.ResultSet rs = null; %>

<%-- Connect to the database using the context and datasource --%>
<% DbSQL connection = new DbSQL(); %>
<% connection.connect("java:comp/env", "jdbc/pda"); %>

<%-- Create the query string for the inspection list --%>
<%
   // Add the defaults query
   queryString = "SELECT action_flag, " +
                        "action, " +
                        "complaint_no, " +
                        "item_ref, " +
                        "site_ref, " +
                        "postcode, " +
                        "site_name_1, " +
                        "ward_code, " +
                        "do_date, " +
                        "end_time_h, " +
                        "end_time_m, " +
                        "start_time_h, " +
                        "start_time_m, " +
                        "state, " +
                        "service_c, " +
                        "contract_ref, " +
                        "feature_ref, " +
                        "pa_area " +
                  "FROM insp_list " +
                  "WHERE (state = 'A' OR state = 'P') " +
                    "AND action_flag = 'D' " +
                    "AND user_name IN (" +
                        "SELECT user_name " +
                          "FROM pda_cover_list " +
                         "WHERE covered_by = '"+ loginBean.getUser_name() + "' " +
                    ") " +
                    "AND" +
                    "( " +
                      "( recvd_by <> '"+ recordBean.getSample_source() + "' " +
                        "AND recvd_by <> '"+ recordBean.getAdhoc_sample_source() + "' " +
                      ") " +
                      "OR " +
                      "( recvd_by = '" + recordBean.getSample_source() + "' " +
                        "OR recvd_by = '" + recordBean.getAdhoc_sample_source() + "' )" +
                    ") ";
%>

<%-- Check if the user has added query restrictions from the inspection query page --%>
<app:equalsInitParameter name="use_insp_manual_query" match="Y">
  <if:IfTrue cond='<%= !inspQueryBean.getInsp_site().equals("") %>'>
    <% queryString += "AND site_name_1 like '%" + inspQueryBean.getInsp_site().toUpperCase() + "%' "; %>
  </if:IfTrue>
  <if:IfTrue cond='<%= inspQueryBean.getIs_due_date_completed() %>'>
    <% queryString += "AND do_date = '" + inspQueryBean.getInsp_due_date() + "' "; %>
  </if:IfTrue>
  <if:IfTrue cond='<%= !inspQueryBean.getInsp_service().equals("") %>'>
    <% queryString += "AND service_c = '" + inspQueryBean.getInsp_service() + "' "; %>
  </if:IfTrue>
  <if:IfTrue cond='<%= !inspQueryBean.getComplaint_no().equals("") %>'>
    <% queryString += "AND complaint_no like '%" + inspQueryBean.getComplaint_no() + "%' "; %>
  </if:IfTrue>
</app:equalsInitParameter>    
    
<%                    
   // Add the complaints query
   queryString += "UNION " +
                 "SELECT action_flag, " +
                        "action, " +
                        "complaint_no, " +
                        "item_ref, " +
                        "site_ref, " +
                        "postcode, " +
                        "site_name_1, " +
                        "ward_code, " +
                        "do_date, " +
                        "end_time_h, " +
                        "end_time_m, " +
                        "start_time_h, " +
                        "start_time_m, " +
                        "state, " +
                        "service_c, " +
                        "contract_ref, " +
                        "feature_ref, " +
                        "pa_area " +
                  "FROM insp_list " +
                  "WHERE (state = 'A' OR state = 'P') " +
                    "AND action_flag = 'I' " +
                    "AND user_name IN (" +
                        "SELECT user_name " +
                          "FROM pda_cover_list " +
                         "WHERE covered_by = '" + loginBean.getUser_name() + "' " +
                    ") ";
%>

<%-- Check if the user has added query restrictions from the inspection query page --%>
<app:equalsInitParameter name="use_insp_manual_query" match="Y">
  <if:IfTrue cond='<%= !inspQueryBean.getInsp_site().equals("") %>'>
    <% queryString += "AND site_name_1 like '%" + inspQueryBean.getInsp_site().toUpperCase() + "%' "; %>
  </if:IfTrue>
  <if:IfTrue cond='<%= inspQueryBean.getIs_due_date_completed() %>'>
    <% queryString += "AND do_date = '" + inspQueryBean.getInsp_due_date() + "' "; %>
  </if:IfTrue>
  <if:IfTrue cond='<%= !inspQueryBean.getInsp_service().equals("") %>'>
    <% queryString += "AND service_c = '" + inspQueryBean.getInsp_service() + "' "; %>
  </if:IfTrue>
  <if:IfTrue cond='<%= !inspQueryBean.getComplaint_no().equals("") %>'>
    <% queryString += "AND complaint_no like '%" + inspQueryBean.getComplaint_no() + "%' "; %>
  </if:IfTrue>
</app:equalsInitParameter>    
    
<%
   // Add the Samples query
   queryString += "UNION " +
                "SELECT action_flag, " +
                        "action, " +
                        "complaint_no, " +
                        "item_ref, " +
                        "site_ref, " +
                        "postcode, " +
                        "site_name_1, " +
                        "ward_code, " +
                        "do_date, " +
                        "end_time_h, " +
                        "end_time_m, " +
                        "start_time_h, " +
                        "start_time_m, " +
                        "state, " +
                        "service_c, " +
                        "contract_ref, " +
                        "feature_ref, " +
                        "pa_area " +
                 "FROM insp_list " +
                 "WHERE (state = 'A' OR state = 'P') " +
                   "AND action_flag = 'P' " +
                   "AND user_name in ( " +
                       "SELECT user_name " +
                         "FROM pda_cover_list " +
                        "WHERE covered_by = '" + loginBean.getUser_name() + "' " +
                   ") " +
                   "AND ( recvd_by = '" + recordBean.getSample_source() + "' " +
                         "OR recvd_by = '" + recordBean.getAdhoc_sample_source() + "' " +
                    ") ";
%>
                 
<%-- Check if the user has added query restrictions from the inspection query page --%>
<app:equalsInitParameter name="use_insp_manual_query" match="Y">
  <if:IfTrue cond='<%= !inspQueryBean.getInsp_site().equals("") %>'>
    <% queryString += "AND site_name_1 like '%" + inspQueryBean.getInsp_site().toUpperCase() + "%' "; %>
  </if:IfTrue>
  <if:IfTrue cond='<%= inspQueryBean.getIs_due_date_completed() %>'>
    <% queryString += "AND do_date = '" + inspQueryBean.getInsp_due_date() + "' "; %>
  </if:IfTrue>
  <if:IfTrue cond='<%= !inspQueryBean.getInsp_service().equals("") %>'>
    <% queryString += "AND service_c = '" + inspQueryBean.getInsp_service() + "' "; %>
  </if:IfTrue>
  <if:IfTrue cond='<%= !inspQueryBean.getComplaint_no().equals("") %>'>
    <% queryString += "AND complaint_no like '%" + inspQueryBean.getComplaint_no() + "%' "; %>
  </if:IfTrue>
</app:equalsInitParameter>    
    
<%                   
   // Check which order we are sorting the data
   if( ((String)session.getAttribute("sort_order")).equals("postcode") ) {
     queryString += "ORDER BY 14, 6, 7";
   } else if( ((String)session.getAttribute("sort_order")).equals("ward") ) {
     queryString += "ORDER BY 14, 8, 7";
   } else if( ((String)session.getAttribute("sort_order")).equals("area") ) {
     queryString += "ORDER BY 14, 17, 7";
   } else if( ((String)session.getAttribute("sort_order")).equals("date") ) {
     queryString += "ORDER BY 14, 9, 10, 11, 7";
   }
%>

<%-- Run the query --%>
<% rs = connection.query(queryString); %>

<%-- populate the PageSet from the ResultSet --%>
<% inspListPageSet.setPageSet(rs, application.getInitParameter("db_date_fmt")); %>

<%-- set the current page number the user is on, unless the ordering --%>
<%-- has been changed, in which case we set it to page 1 --%>
<% 
   if(ordering_changed) {
     inspListPageSet.setCurrentPageNum( 1 );
   } else {
     inspListPageSet.setCurrentPageNum( new Integer(inspListBean.getPage_number()).intValue() );
   }
%>

<%-- close the ResultSet and disconnect from the database --%>
<% rs.close(); %>
<% connection.disconnect(); %>
    
<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="inspList" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= inspListBean.getAction().equals("Details") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=inspListBean.getComplaint_no() == null ||
                        inspListBean.getComplaint_no().equals("") %>' >
      <jsp:setProperty name="inspListBean" property="error"
        value="Please choose an item." />
      <jsp:forward page="inspListView.jsp" />
    </if:IfTrue>

    <% pageContext.setAttribute("comp_exists", "false"); %>
    <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con1">
      <%-- check to see if the selected complaint still exists and --%>
      <%-- is still open. --%>
      <sql:query>
        SELECT complaint_no
          FROM comp
         WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
           AND date_closed is null
      </sql:query>
      <sql:resultSet id="rset">
        <%-- do nothing --%>
      </sql:resultSet>
      <sql:wasNotEmpty>
        <%-- The complaint exists and is still open --%>
        <% pageContext.setAttribute("comp_exists", "true"); %>
      </sql:wasNotEmpty>
      <sql:wasEmpty>
        <%-- The complaint does not exist or is closed --%>
        <% pageContext.setAttribute("comp_exists", "false"); %>
      </sql:wasEmpty>

      <if:IfTrue cond='<%=((String) pageContext.getAttribute("comp_exists")).trim().equals("false") %>' >
        <%-- delete any occurance of the complaint from the inspection --%>
        <%-- list table, as it is no longer exists, or is closed. --%>
        <sql:query>
          DELETE FROM insp_list
          WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
        </sql:query>
        <sql:execute/>
      </if:IfTrue>

      <%-- get the state of the currently selected item --%>
      <sql:query>
        SELECT state
          FROM insp_list
         WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
           AND (
                 user_name IN (
                       SELECT user_name
                         FROM pda_cover_list
                        WHERE covered_by = '<%= loginBean.getUser_name() %>'
                 )
               )
           AND (state = 'A' or state = 'P')
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="state" />
      </sql:resultSet>
    </sql:statement>
    <sql:closeConnection conn="con1"/>

    <if:IfTrue cond='<%=((String) pageContext.getAttribute("comp_exists")).trim().equals("false") %>' >
      <jsp:setProperty name="inspListBean" property="error"
        value="This item no longer exists, or is closed. Please choose another item." />
      <jsp:forward page="inspListView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%=((String) pageContext.getAttribute("state")).trim().equals("P") %>' >
      <jsp:setProperty name="inspListBean" property="error"
        value="This item has already been processed. Please choose another item." />
      <jsp:forward page="inspListView.jsp" />
    </if:IfTrue>

    <%-- Transect Count --%>
    <% String tran_count = ""; %>
    <%-- Valid entry --%>
    <sql:connection id="con2" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con2">
      <%-- Get the pda_role, assume the module is inspectors --%>
      <sql:query>
        SELECT c_field
          FROM keys
         WHERE service_c = 'ALL'
           AND keyname = 'PDA_INSPECTOR_ROLE'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="pda_role" />
        <% recordBean.setPda_role((String) pageContext.getAttribute("pda_role")); %>
      </sql:resultSet>

      <sql:query>
        SELECT site_ref,
               item_ref, 
               comp_code, 
               feature_ref, 
               contract_ref,
               action_flag,
               dest_ref,
               exact_location,
               occur_day,
               service_c,
               date_entered,
               ent_time_h,
               ent_time_m,
               recvd_by,
               easting,
               northing
          FROM comp
         WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="site_ref" />
        <% recordBean.setSite_ref((String) pageContext.getAttribute("site_ref")); %>
        <sql:getColumn position="2" to="item_ref" />
        <% recordBean.setItem_ref((String) pageContext.getAttribute("item_ref")); %>
        <sql:getColumn position="3" to="comp_code" />
        <% recordBean.setComp_code((String) pageContext.getAttribute("comp_code")); %>
        <sql:getColumn position="4" to="feature_ref" />
        <% recordBean.setFeature_ref((String) pageContext.getAttribute("feature_ref")); %>
        <sql:getColumn position="5" to="contract_ref" />
        <% recordBean.setContract_ref((String) pageContext.getAttribute("contract_ref")); %>
        <sql:getColumn position="6" to="comp_action_flag" />
        <% recordBean.setComp_action_flag((String) pageContext.getAttribute("comp_action_flag")); %>

        <%-- dest_ref now only got when the selected item is a default (action_flag = "D") --%>

        <sql:getColumn position="8" to="exact_location" />
        <sql:wasNull>
          <% pageContext.setAttribute("exact_location", ""); %>
        </sql:wasNull>
        <% recordBean.setExact_location((String) pageContext.getAttribute("exact_location")); %>

        <sql:getColumn position="9" to="occur_day" />
        <sql:wasNull>
          <% pageContext.setAttribute("occur_day", ""); %>
        </sql:wasNull>
        <% recordBean.setOccur_day((String) pageContext.getAttribute("occur_day")); %>

        <sql:getColumn position="10" to="service_c" />
        <% recordBean.setService_c((String) pageContext.getAttribute("service_c")); %>

        <sql:getDate position="11" to="date_entered" format="<%= application.getInitParameter("db_date_fmt") %>" />
        <% recordBean.setComp_date((String) pageContext.getAttribute("date_entered")); %>

        <sql:getColumn position="12" to="ent_time_h" />
        <% recordBean.setComp_time_h((String) pageContext.getAttribute("ent_time_h")); %>

        <sql:getColumn position="13" to="ent_time_m" />
        <% recordBean.setComp_time_m((String) pageContext.getAttribute("ent_time_m")); %>

        <sql:getColumn position="14" to="recvd_by" />
        <% recordBean.setSource_code((String) pageContext.getAttribute("recvd_by")); %>

        <%-- Get the complaints Eastings and Northings for the Cartology Map view --%>
        <sql:getColumn position="15" to="easting" />
        <% recordBean.setMap_easting((String) pageContext.getAttribute("easting")); %>

        <sql:getColumn position="16" to="northing" />
        <% recordBean.setMap_northing((String) pageContext.getAttribute("northing")); %>
      </sql:resultSet>

      <%-- Get the description of the source --%>
       <sql:query>
         SELECT allk.lookup_text
           FROM allk
          WHERE lookup_func = 'CTSRC'
            AND allk.lookup_code = '<%= recordBean.getSource_code() %>'
       </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="lookup_text" />
        <% recordBean.setSource_desc((String) pageContext.getAttribute("lookup_text")); %>
      </sql:resultSet>

      <%-- Get the complaint code --%>
      <sql:query>
         SELECT allk.lookup_text
           FROM allk
          WHERE lookup_func = 'COMPLA'
            AND allk.lookup_code = '<%= recordBean.getComp_code() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="lookup_text" />
        <% recordBean.setComp_desc((String) pageContext.getAttribute("lookup_text")); %>
      </sql:resultSet>

      <%-- Query the site table --%>
      <sql:query>
        SELECT site_name_1, ward_code, location_c, area_c, ward_code,
               postcode, build_no, build_sub_no, build_no_disp, 
               build_sub_no_disp, build_name, build_sub_name
          FROM site
         WHERE site_ref = '<%= recordBean.getSite_ref() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="site_name_1" />
        <% recordBean.setSite_name_1((String) pageContext.getAttribute("site_name_1")); %>
        <sql:getColumn position="2" to="ward_code" />
        <% recordBean.setWard_code((String) pageContext.getAttribute("ward_code")); %>
        <sql:getColumn position="3" to="location_c" />
        <% recordBean.setLocation_c((String) pageContext.getAttribute("location_c")); %>
        <sql:getColumn position="4" to="area_c" />
        <sql:wasNull>
          <% pageContext.setAttribute("area_c", ""); %>
        </sql:wasNull>
        <sql:getColumn position="5" to="ward_code" />
        <sql:wasNull>
          <% pageContext.setAttribute("ward_code", ""); %>
        </sql:wasNull>
        <sql:getColumn position="6" to="postcode" />
        <% recordBean.setPostcode((String) pageContext.getAttribute("postcode")); %>
        <sql:getColumn position="7" to="build_no" />
        <% recordBean.setBuild_no((String) pageContext.getAttribute("build_no")); %>
        <sql:getColumn position="8" to="build_sub_no" />
        <% recordBean.setBuild_sub_no((String) pageContext.getAttribute("build_sub_no")); %>
        <sql:getColumn position="9" to="build_no_disp" />
        <sql:wasNull>
          <% pageContext.setAttribute("build_no_disp", ""); %>
        </sql:wasNull>
        <sql:getColumn position="10" to="build_sub_no_disp" />
        <sql:wasNull>
          <% pageContext.setAttribute("build_sub_no_disp", ""); %>
        </sql:wasNull>
        <sql:getColumn position="11" to="build_name" />
        <% recordBean.setBuild_name((String) pageContext.getAttribute("build_name")); %>
        <if:IfTrue cond='<%= recordBean.getBuild_name() == null || recordBean.getBuild_name().equals("") %>' >
          <% recordBean.setBuild_name(""); %>
        </if:IfTrue>
        <sql:getColumn position="12" to="build_sub_name" />
        <% recordBean.setBuild_sub_name((String) pageContext.getAttribute("build_sub_name")); %>
        <if:IfTrue cond='<%= recordBean.getBuild_sub_name() == null || recordBean.getBuild_sub_name().equals("") %>' >
          <% recordBean.setBuild_sub_name(""); %>
        </if:IfTrue>
      </sql:resultSet>

      <%-- Get the location name and code and store it in the record bean --%>
      <sql:query>
        select location_name
        from locn
        where location_c = '<%= recordBean.getLocation_c() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="location_name" />
        <% recordBean.setLocation_name((String) pageContext.getAttribute("location_name")); %>
      </sql:resultSet>

      <%-- setup the area or ward of the address field --%>
      <%-- a "Y" means to use the area and a "N" means to use ward --%>
      <sql:query>
        select c_field
        from keys
        where keyname = 'DISP_WARD_OR_AREA'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="c_field" />
      </sql:resultSet>

      <if:IfTrue cond='<%= ((String) pageContext.getAttribute("c_field")).trim().equals("Y") && 
                           (!((String) pageContext.getAttribute("area_c")).trim().equals("")) %>' >
        <sql:query>
          select area_name
          from area
          where area_c = '<%= ((String)pageContext.getAttribute("area_c")).trim() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="area_name" />
          <% recordBean.setArea_ward_desc((String) pageContext.getAttribute("area_name")); %>
        </sql:resultSet>
      </if:IfTrue>

      <if:IfTrue cond='<%= ((String) pageContext.getAttribute("c_field")).trim().equals("N") &&
                           (!((String) pageContext.getAttribute("ward_code")).trim().equals("")) %>' >
        <sql:query>
          select ward_name
          from ward
          where ward_code = '<%= ((String)pageContext.getAttribute("ward_code")).trim() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="ward_code" />
          <% recordBean.setArea_ward_desc((String) pageContext.getAttribute("ward_code")); %>
        </sql:resultSet>
      </if:IfTrue>

      <%-- Query the si_i table --%>
      <sql:query>
        SELECT priority_flag, 
               volume,
               date_due,
               pa_area
          FROM si_i
         WHERE site_ref     = '<%= recordBean.getSite_ref() %>'
           AND item_ref     = '<%= recordBean.getItem_ref() %>'
           AND feature_ref  = '<%= recordBean.getFeature_ref() %>'
           AND contract_ref = '<%= recordBean.getContract_ref() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="priority_flag" />
        <% recordBean.setPriority((String) pageContext.getAttribute("priority_flag")); %>
        <sql:wasNull>
          <% recordBean.setPriority(""); %>
        </sql:wasNull>
        <sql:getColumn position="2" to="total_volume" />
        <% recordBean.setTotal_volume((String) pageContext.getAttribute("total_volume")); %>
        <sql:wasNull>
          <% recordBean.setTotal_volume(""); %>
        </sql:wasNull>        
        <sql:getDate position="3" to="date_due" format="<%= application.getInitParameter("db_date_fmt") %>" />
        <% recordBean.setDate_due((String) pageContext.getAttribute("date_due")); %>
        <sql:wasNull>
          <% recordBean.setDate_due(""); %>
        </sql:wasNull>        
        <sql:getColumn position="4" to="pa_area" />
        <% recordBean.setPa_area((String) pageContext.getAttribute("pa_area")); %>
        <sql:wasNull>
          <% recordBean.setPa_area(""); %>
        </sql:wasNull>
      </sql:resultSet>

      <%-- Query the item table --%>
      <sql:query>
        SELECT item_desc, item_type
          FROM item
         WHERE item_ref = '<%= recordBean.getItem_ref() %>'
       </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="item_desc" />
        <% recordBean.setItem_desc((String) pageContext.getAttribute("item_desc")); %>
        <sql:getColumn position="2" to="item_type" />
        <% recordBean.setItem_type((String) pageContext.getAttribute("item_type")); %>
      </sql:resultSet>

      <%-- The AV service has no site items, so the si_i table cannot be used to obtain --%>
      <%-- the pa_area, the site_pa table has to be used instead. The pa_func is hardcoded --%>
      <%-- in contender as 'AV' for the abandoned vehicle service. --%>
      <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getAv_service()) %>' >
        <sql:query>
          SELECT pa_area
            FROM site_pa
           WHERE site_ref = '<%= recordBean.getSite_ref() %>'
             AND pa_func = 'AV'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="pa_area" />
          <% recordBean.setPa_area((String) pageContext.getAttribute("pa_area")); %>
          <sql:wasNull>
            <% recordBean.setPa_area(""); %>
          </sql:wasNull>
        </sql:resultSet>
      </if:IfTrue>

      <%-- The TRADE service has no site items, so the si_i table cannot be used to obtain --%>
      <%-- the pa_area, the trade_site table has to be used instead. --%>
      <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getTrade_service()) %>' > 
        <% String agree_no = ""; %>
        <sql:query>
          SELECT agreement_no
            FROM comp_trade
           WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="agree_no" />
          <sql:wasNotNull>
            <% agree_no = ((String)pageContext.getAttribute("agree_no")).trim(); %>
          </sql:wasNotNull>
        </sql:resultSet>
        
        <% String site_no = ""; %>
        <sql:query>
          SELECT site_ref
            FROM agreement 
           WHERE agreement_no = <%= agree_no %>
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="site_no" />
          <sql:wasNotNull>
            <% site_no = ((String)pageContext.getAttribute("site_no")).trim(); %>
          </sql:wasNotNull>
        </sql:resultSet>
        
        <sql:query>
          SELECT DISTINCT agree_task_no 
            FROM comp_tr
           WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="tat_no" />
          <sql:wasNull>
            <% pageContext.setAttribute("tat_no", ""); %>
          </sql:wasNull>
          <% recordBean.setTat_no( ((String)pageContext.getAttribute("tat_no")).trim() ); %>
        </sql:resultSet>
        
        <sql:query>
          SELECT pa_area,
                 ta_name                 
            FROM trade_site
           WHERE site_no = <%= site_no %>
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="pa_area" />
          <% recordBean.setPa_area((String) pageContext.getAttribute("pa_area")); %>
          <sql:wasNull>
            <% recordBean.setPa_area(""); %>
          </sql:wasNull>
          <sql:getColumn position="2" to="ta_name" />
          <% recordBean.setTa_name((String) pageContext.getAttribute("ta_name")); %>
          <sql:wasNull>
            <% recordBean.setTa_name(""); %>
          </sql:wasNull>
        </sql:resultSet>
      </if:IfTrue>

      <%-- The TREES Service needs to collect the trees reference number from the comp_tree table--%>
      <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getTrees_service()) %>' >
        <sql:query>
          SELECT tree_ref
            FROM comp_tree
           WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="tree_ref" />
          <sql:wasNull>
            <% pageContext.setAttribute("tree_ref", ""); %>
          </sql:wasNull>
          <% recordBean.setTree_ref( ((String)pageContext.getAttribute("tree_ref")).trim() ); %>
        </sql:resultSet>
      </if:IfTrue>
      
      <%-- different things need to be got depending on the comp_action_flag --%>
      <%-- for a comp_action_flag of "I" or "P" nothing else needs to be got --%>
      <%-- complaint default --%>
      <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("D") %>' >
        
        <%-- retrieve the dest_ref --%>
        <sql:query>
          SELECT dest_ref
            FROM comp
           WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="dest_ref" />
          <sql:wasNull>
            <% pageContext.setAttribute("dest_ref", ""); %>
          </sql:wasNull>
          <% recordBean.setDefault_no((String) pageContext.getAttribute("dest_ref")); %>
        </sql:resultSet>
         
        <%-- retrieve the date/time in the defi_rect --%>
        <sql:query>
          SELECT rectify_date, 
                 rectify_time_h, 
                 rectify_time_m
            FROM defi_rect
           WHERE default_no = '<%= recordBean.getDefault_no() %>'
             AND seq_no = (
                 SELECT max(seq_no)
                   FROM defi_rect
                  WHERE default_no = '<%= recordBean.getDefault_no() %>'
             )
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getDate position="1" to="rectify_date" format="<%= application.getInitParameter("db_date_fmt") %>" />
          <% recordBean.setRectify_date((String) pageContext.getAttribute("rectify_date")); %>
          <sql:getColumn position="2" to="rectify_time_h" />
          <% recordBean.setRectify_time_h((String) pageContext.getAttribute("rectify_time_h")); %>
          <sql:getColumn position="3" to="rectify_time_m" />
          <% recordBean.setRectify_time_m((String) pageContext.getAttribute("rectify_time_m")); %>
        </sql:resultSet>

        <%-- retrieve the date/time actioned from the def_cont_i --%>
        <sql:query>
          SELECT action,
                 date_actioned,
                 time_actioned_h,
                 time_actioned_m
            FROM def_cont_i
           WHERE cust_def_no = '<%= recordBean.getDefault_no() %>'
         </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="action" />
          <sql:wasNull>
            <% pageContext.setAttribute("action", ""); %>
          </sql:wasNull>
          <% recordBean.setDef_action((String) pageContext.getAttribute("action")); %>
          <sql:getDate position="2" to="date_actioned" format="<%= application.getInitParameter("db_date_fmt") %>" />
          <% recordBean.setActioned_date((String) pageContext.getAttribute("date_actioned")); %>
          <sql:getColumn position="3" to="time_actioned_h" />
          <% recordBean.setActioned_time_h((String) pageContext.getAttribute("time_actioned_h")); %>
          <sql:getColumn position="4" to="time_actioned_m" />
          <% recordBean.setActioned_time_m((String) pageContext.getAttribute("time_actioned_m")); %>
        </sql:resultSet>

        <%-- retrieve the date/time and transaction flag from the deft --%>
        <sql:query>
          SELECT action_flag, 
                 trans_date,
                 time_h,
                 time_m
            FROM deft
           WHERE default_no = '<%= recordBean.getDefault_no() %>'
             AND seq_no = (
                 SELECT MAX(seq_no)
                   FROM deft
                  WHERE default_no = '<%= recordBean.getDefault_no() %>'
             )
         </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="action_flag" />
          <sql:wasNull>
            <% pageContext.setAttribute("action_flag", ""); %>
          </sql:wasNull>
          <% recordBean.setDef_action_flag((String) pageContext.getAttribute("action_flag")); %>
          <sql:getDate position="2" to="trans_date" format="<%= application.getInitParameter("db_date_fmt") %>" />
          <% recordBean.setTrans_date((String) pageContext.getAttribute("trans_date")); %>
          <sql:getColumn position="3" to="time_h" />
          <% recordBean.setTrans_time_h((String) pageContext.getAttribute("time_h")); %>
          <sql:getColumn position="4" to="time_m" />
          <% recordBean.setTrans_time_m((String) pageContext.getAttribute("time_m")); %>
        </sql:resultSet>

        <%-- retrieve the volume from the defi table --%>
        <sql:query>
          SELECT volume
            FROM defi
           WHERE default_no = '<%= recordBean.getDefault_no() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="volume" />
          <% recordBean.setVolume((String) pageContext.getAttribute("volume")); %>
        </sql:resultSet>
      </if:IfTrue>

      <%-- BV199 to be inspected --%>
      <if:IfTrue cond='<%= recordBean.getItem_ref().equals(recordBean.getBv_item_ref()) %>' >

        <% recordBean.setBv_site_ref(recordBean.getSite_ref()); %>

        <%-- get the site name and details --%>
        <sql:query>
          SELECT site_name_1,
                 location_c,
                 postcode,
                 build_no,
                 build_sub_no,
                 build_no_disp,
                 build_sub_no_disp,
                 build_name,
                 build_sub_name,
                 area_c, ward_code
            FROM site
           WHERE site_ref = '<%= recordBean.getBv_site_ref() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="bv_site_name_1" />
          <% recordBean.setBv_site_name_1((String) pageContext.getAttribute("bv_site_name_1")); %>
          <sql:getColumn position="2" to="bv_location_c" />
          <% recordBean.setBv_location_c((String) pageContext.getAttribute("bv_location_c")); %>
          <sql:getColumn position="3" to="bv_postcode" />
          <% recordBean.setBv_postcode((String) pageContext.getAttribute("bv_postcode")); %>
          <sql:getColumn position="4" to="bv_build_no" />
          <% recordBean.setBv_build_no((String) pageContext.getAttribute("bv_build_no")); %>
          <sql:getColumn position="5" to="bv_build_sub_no" />
          <% recordBean.setBv_build_sub_no((String) pageContext.getAttribute("bv_build_sub_no")); %>
          <sql:getColumn position="6" to="bv_build_no_disp" />
          <sql:wasNull>
            <% pageContext.setAttribute("bv_build_no_disp", ""); %>
          </sql:wasNull>
          <sql:getColumn position="7" to="bv_build_sub_no_disp" />
          <sql:wasNull>
            <% pageContext.setAttribute("bv_build_sub_no_disp", ""); %>
          </sql:wasNull>
          <sql:getColumn position="8" to="bv_build_name" />
          <% recordBean.setBv_build_name((String) pageContext.getAttribute("bv_build_name")); %>
          <if:IfTrue cond='<%= recordBean.getBv_build_name() == null || recordBean.getBv_build_name().equals("") %>' >
            <% recordBean.setBv_build_name(""); %>
          </if:IfTrue>
          <sql:getColumn position="9" to="bv_build_sub_name" />
          <% recordBean.setBv_build_sub_name((String) pageContext.getAttribute("bv_build_sub_name")); %>
          <if:IfTrue cond='<%= recordBean.getBv_build_name() == null || recordBean.getBv_build_name().equals("") %>' >
            <% recordBean.setBv_build_sub_name(""); %>
          </if:IfTrue>
          <sql:getColumn position="10" to="bv_area_c" />
          <sql:wasNull>
            <% pageContext.setAttribute("bv_area_c", ""); %>
          </sql:wasNull>
          <sql:getColumn position="11" to="bv_ward_code" />
          <sql:wasNull>
            <% pageContext.setAttribute("bv_ward_code", ""); %>
          </sql:wasNull>
        </sql:resultSet>

        <%-- Are the recordBean.build_no and recordBean.build_sub_no, the display --%>
        <%-- version or the normal version. --%>
        <sql:query>
          SELECT c_field
            FROM keys
           WHERE service_c = 'ALL'
             AND keyname = 'COMP_BUILD_NO_DISP'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="bv_comp_build_no_disp" />
          <sql:wasNull>
            <% pageContext.setAttribute("bv_comp_build_no_disp", "N"); %>
          </sql:wasNull>
        </sql:resultSet>
        <sql:wasEmpty>
          <% pageContext.setAttribute("bv_comp_build_no_disp", "N"); %>
        </sql:wasEmpty>
        <if:IfTrue cond='<%= ((String) pageContext.getAttribute("bv_comp_build_no_disp")).trim().equals("Y") %>' >
          <% recordBean.setBv_build_no((String) pageContext.getAttribute("bv_build_no_disp")); %>
          <% recordBean.setBv_build_sub_no((String) pageContext.getAttribute("bv_build_sub_no_disp")); %>
        </if:IfTrue>

        <%-- setup the area or ward of the address field --%>
        <%-- a "Y" means to use the area and a "N" means to use ward --%>
        <sql:query>
          SELECT c_field
            FROM keys
           WHERE keyname = 'DISP_WARD_OR_AREA'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="bv_c_field" />
        </sql:resultSet>

        <%-- Use the area name --%>
        <if:IfTrue cond='<%= ((String) pageContext.getAttribute("bv_c_field")).trim().equals("Y") %>' >
          <sql:query>
            SELECT area_name
              FROM area
             WHERE area_c = '<%= ((String)pageContext.getAttribute("bv_area_c")).trim() %>'
          </sql:query>
          <sql:resultSet id="rset">
            <sql:getColumn position="1" to="bv_area_name" />
            <% recordBean.setBv_area_ward_desc((String) pageContext.getAttribute("bv_area_name")); %>
          </sql:resultSet>
        </if:IfTrue>

        <%-- Use the ward name --%>
        <if:IfTrue cond='<%= ((String) pageContext.getAttribute("bv_c_field")).trim().equals("N") %>' >
          <sql:query>
            SELECT ward_name
              FROM ward
             WHERE ward_code = '<%= ((String)pageContext.getAttribute("bv_ward_code")).trim() %>'
          </sql:query>
          <sql:resultSet id="rset">
            <sql:getColumn position="1" to="bv_ward_name" />
            <% recordBean.setBv_area_ward_desc((String) pageContext.getAttribute("bv_ward_name")); %>
          </sql:resultSet>
        </if:IfTrue>

        <%-- Get the location name and code and store it in the record bean --%>
        <sql:query>
          SELECT location_name
            FROM locn
           WHERE location_c = '<%= recordBean.getBv_location_c() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="bv_location_name" />
          <% recordBean.setBv_location_name((String) pageContext.getAttribute("bv_location_name")); %>
        </sql:resultSet>

        <%-- Count the number of transect references for this site --%>
        <sql:query>
          SELECT count(transect_ref)
            FROM bv_transect
           WHERE site_ref = '<%= recordBean.getBv_site_ref() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="tran_count" />
          <% tran_count = ((String)pageContext.getAttribute("tran_count")).trim(); %>
        </sql:resultSet>
      </if:IfTrue>

      <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getTrade_service()) %>' >
        <%-- get the Priority, Total_volume, Date_due again --%>
        <%-- if this is a TRADE service default, as a TRADE site does not have a site item.  --%>
        <% recordBean.setTotal_volume(""); %>
        <% recordBean.setDate_due(""); %>
        <sql:query>
          SELECT priority_f 
            FROM item
           WHERE item_ref     = '<%= recordBean.getItem_ref() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="priority_flag" />
          <% recordBean.setPriority((String) pageContext.getAttribute("priority_flag")); %>
          <sql:wasNull>
            <% recordBean.setPriority(""); %>
          </sql:wasNull>
        </sql:resultSet>
      </if:IfTrue>
     </sql:statement>
    <sql:closeConnection conn="con2"/>

    <%-- Go to a different screen depending on the complaint action --%>
    <%-- complaint default --%>
    <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("D") %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">inspList</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">defaultDetails</sess:setAttribute>
      <c:redirect url="defaultDetailsScript.jsp" />
    </if:IfTrue>

    <%-- BV199 to be inspected --%>
    <if:IfTrue cond='<%= recordBean.getItem_ref().equals(recordBean.getBv_item_ref()) %>' >

      <%-- 11/10/2010  TW  See also surveyGradingScript.jsp --%>
      <% recordBean.setBv_complaint_no_save( recordBean.getComplaint_no() ); %>
      <% recordBean.setBv_comp_action_flag_save( recordBean.getComp_action_flag() ); %>

      <if:IfTrue cond='<%= ! tran_count.equals("0") %>'>
        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">inspList</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">surveyExisting</sess:setAttribute>
        <c:redirect url="surveyExistingScript.jsp" />
      </if:IfTrue>

      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">inspList</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">surveyTransectMethod</sess:setAttribute>
      <c:redirect url="surveyTransectMethodScript.jsp" />
    </if:IfTrue>

    <%-- complaint sample or to be inspected --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">inspList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">compSampDetails</sess:setAttribute>
    <c:redirect url="compSampDetailsScript.jsp" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= inspListBean.getAction().equals("|<<") %>' >
    <% inspListPageSet.first(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="inspListView.jsp" />
  </if:IfTrue>

  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= inspListBean.getAction().equals(">>|") %>' >
    <% inspListPageSet.last(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="inspListView.jsp" />
  </if:IfTrue>

  <%-- Next view 4 --%>
  <if:IfTrue cond='<%= inspListBean.getAction().equals(" < ") %>' >
    <% inspListPageSet.previous(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="inspListView.jsp" />
  </if:IfTrue>

  <%-- Next view 5 --%>
  <if:IfTrue cond='<%= inspListBean.getAction().equals(" > ") %>' >
    <% inspListPageSet.next(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="inspListView.jsp" />
  </if:IfTrue>
  
  <%-- Next view 6 --%>
  <if:IfTrue cond='<%= inspListBean.getAction().equals("Post") %>' >
    <sess:setAttribute name="sort_order">postcode</sess:setAttribute>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="inspListView.jsp" />
  </if:IfTrue>

  <%-- Next view 7 --%>
  <if:IfTrue cond='<%= inspListBean.getAction().equals("Ward") %>' >
    <sess:setAttribute name="sort_order">ward</sess:setAttribute>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="inspListView.jsp" />
  </if:IfTrue>

  <%-- Next view 8 --%>
  <if:IfTrue cond='<%= inspListBean.getAction().equals("Area") %>' >
    <sess:setAttribute name="sort_order">area</sess:setAttribute>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="inspListView.jsp" />
  </if:IfTrue>

  <%-- Next view 9 --%>
  <if:IfTrue cond='<%= inspListBean.getAction().equals("Date") %>' >
    <sess:setAttribute name="sort_order">date</sess:setAttribute>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="inspListView.jsp" />
  </if:IfTrue>

  <%-- Menu view --%>
  <if:IfTrue cond='<%= inspListBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">inspList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= inspListBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">inspList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= inspListBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${inspListBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="inspListView.jsp" />
