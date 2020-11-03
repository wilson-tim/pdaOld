<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.itemLookupBean, com.vsb.recordBean, com.vsb.helperBean" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="itemLookupBean" scope="session" class="com.vsb.itemLookupBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="itemLookup" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="itemLookup" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="itemLookupBean" property="all" value="clear" />
    <jsp:setProperty name="itemLookupBean" property="*" />
    
    <%-- Add the new values to the record as long as a user selected an item --%>
    <if:IfTrue cond='<%= itemLookupBean.getView_key() != null && !itemLookupBean.getView_key().equals("") %>' >
      <%
        StringTokenizer view_key = new StringTokenizer(itemLookupBean.getView_key(), "|");
        String item_ref = view_key.nextToken();
        String feature_ref = view_key.nextToken();
        String contract_ref = view_key.nextToken();

        recordBean.setItem_ref(item_ref.trim());
        recordBean.setFeature_ref(feature_ref.trim());
        recordBean.setContract_ref(contract_ref.trim());
      %>
   
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
      <sql:statement id="stmt" conn="con">
        <sql:query>
          select occur_day, occur_week, occur_month, round_c, pa_area,
            priority_flag, volume, date_due
          from si_i
          where site_ref = '<%= recordBean.getSite_ref() %>'
          and item_ref = '<%= recordBean.getItem_ref() %>'
          and feature_ref = '<%= recordBean.getFeature_ref() %>'
          and contract_ref = '<%= recordBean.getContract_ref() %>'
         </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="occur_day" />
          <% recordBean.setOccur_day((String) pageContext.getAttribute("occur_day")); %>
          <sql:getColumn position="2" to="occur_week" />
          <% recordBean.setOccur_week((String) pageContext.getAttribute("occur_week")); %>
          <sql:getColumn position="3" to="occur_month" />
          <% recordBean.setOccur_month((String) pageContext.getAttribute("occur_month")); %>
          <sql:getColumn position="4" to="round_c" />
          <% recordBean.setRound_c((String) pageContext.getAttribute("round_c")); %>
          <sql:getColumn position="5" to="pa_area" />
          <% recordBean.setPa_area((String) pageContext.getAttribute("pa_area")); %>
          <sql:getColumn position="6" to="priority_flag" />
          <% recordBean.setPriority((String) pageContext.getAttribute("priority_flag")); %>
          <sql:getColumn position="7" to="total_volume" />
          <% recordBean.setTotal_volume((String) pageContext.getAttribute("total_volume")); %>
          <sql:getDate position="8" to="date_due" format="<%= application.getInitParameter("db_date_fmt") %>" />
          <sql:wasNotNull>
            <% recordBean.setDate_due((String) pageContext.getAttribute("date_due")); %>
          </sql:wasNotNull>
          <sql:wasNull>
            <% recordBean.setDate_due(""); %>
          </sql:wasNull>
        </sql:resultSet>

        <sql:query>
          select feature_desc
          from feat
          where feature_ref = '<%= recordBean.getFeature_ref() %>'
         </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="feature_desc" />
          <% recordBean.setFeature_desc((String) pageContext.getAttribute("feature_desc")); %>
        </sql:resultSet>
        
        <sql:query>
          select item_desc, item_type, insp_item_flag
          from item
          where item_ref = '<%= recordBean.getItem_ref() %>'
         </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="item_desc" />
          <% recordBean.setItem_desc((String) pageContext.getAttribute("item_desc")); %>
          <sql:getColumn position="2" to="item_type" />
          <% recordBean.setItem_type((String) pageContext.getAttribute("item_type")); %>
          <sql:getColumn position="3" to="insp_item_flag" />
          <% recordBean.setInsp_item_flag((String) pageContext.getAttribute("insp_item_flag")); %>
        </sql:resultSet>
        
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
      </sql:statement>
      <sql:closeConnection conn="con"/>
    </if:IfTrue>
    
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="itemLookupBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="service" >
  <jsp:setProperty name="itemLookupBean" property="action" value="" />
  <jsp:setProperty name="itemLookupBean" property="all" value="clear" />
  <jsp:setProperty name="itemLookupBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="updateStatus" >
  <jsp:setProperty name="itemLookupBean" property="action" value="" />
  <jsp:setProperty name="itemLookupBean" property="all" value="clear" />
  <jsp:setProperty name="itemLookupBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="treesList" >
  <jsp:setProperty name="itemLookupBean" property="action" value="" />
  <jsp:setProperty name="itemLookupBean" property="all" value="clear" />
  <jsp:setProperty name="itemLookupBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="treeDetails" >
  <jsp:setProperty name="itemLookupBean" property="action" value="" />
  <jsp:setProperty name="itemLookupBean" property="all" value="clear" />
  <jsp:setProperty name="itemLookupBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="treeAdd" >
  <jsp:setProperty name="itemLookupBean" property="action" value="" />
  <jsp:setProperty name="itemLookupBean" property="all" value="clear" />
  <jsp:setProperty name="itemLookupBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="itemLookup" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
      <sql:query>
        select feature_ref, contract_ref
        from si_i_param
        where service_c = '<%= recordBean.getService_c() %>'
       </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="feature_ref" />
        <% recordBean.setSi_i_param_feature((String) pageContext.getAttribute("feature_ref")); %>
        <sql:wasNull>
          <% recordBean.setSi_i_param_feature(""); %>
        </sql:wasNull>
        <sql:getColumn position="2" to="contract_ref" />
        <% recordBean.setSi_i_param_contract((String) pageContext.getAttribute("contract_ref")); %>
        <sql:wasNull>
          <% recordBean.setSi_i_param_contract(""); %>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% recordBean.setSi_i_param_feature(""); %>
        <% recordBean.setSi_i_param_contract(""); %>
      </sql:wasEmpty>
    </sql:statement>
    <sql:closeConnection conn="con"/>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="itemLookup" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= itemLookupBean.getAction().equals("History") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= itemLookupBean.getView_key() == null || itemLookupBean.getView_key().equals("") %>' >
      <jsp:setProperty name="itemLookupBean" property="error"
        value="Please choose an item." />
      <jsp:forward page="itemLookupView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- 26/05/2010  TW  Initialise comp_full_history flag --%>
    <% recordBean.setComp_full_history("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">itemLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">compHistory</sess:setAttribute>
    <c:redirect url="compHistoryScript.jsp" />
  </if:IfTrue>
  
  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= itemLookupBean.getAction().equals("Detail") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= itemLookupBean.getView_key() == null || itemLookupBean.getView_key().equals("") %>' >
      <jsp:setProperty name="itemLookupBean" property="error"
        value="Please choose an item." />
      <jsp:forward page="itemLookupView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">itemLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">itemDetail</sess:setAttribute>
    <c:redirect url="itemDetailScript.jsp" />
  </if:IfTrue>
  
  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= itemLookupBean.getAction().equals("Add") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= itemLookupBean.getView_key() == null || itemLookupBean.getView_key().equals("") %>' >
      <jsp:setProperty name="itemLookupBean" property="error"
        value="Please choose an item." />
      <jsp:forward page="itemLookupView.jsp" />
    </if:IfTrue>

    <%-- make sure the user has selected an action to be performed --%>
    <if:IfTrue cond='<%= itemLookupBean.getActionTaken() == null || itemLookupBean.getActionTaken().equals("") %>' >
      <jsp:setProperty name="itemLookupBean" property="error"
        value="Please select an action to perform." />
      <jsp:forward page="itemLookupView.jsp" />
    </if:IfTrue>
   
    <%-- Valid entry --%>
    <if:IfTrue cond='<%= itemLookupBean.getActionTaken().equals("Hold") %>' >
      <% recordBean.setAction_flag("H"); %>
    </if:IfTrue>

    <if:IfTrue cond='<%= itemLookupBean.getActionTaken().equals("Inspect") %>' >
      <% recordBean.setAction_flag("I"); %>
    </if:IfTrue>

    <if:IfTrue cond='<%= itemLookupBean.getActionTaken().equals(application.getInitParameter("def_name_noun")) %>' >
      <% recordBean.setAction_flag("D"); %>
    </if:IfTrue>

    <if:IfTrue cond='<%= itemLookupBean.getActionTaken().equals("Works Order") %>' >
      <% recordBean.setAction_flag("W"); %>
    </if:IfTrue>

    <if:IfTrue cond='<%= itemLookupBean.getActionTaken().equals("No Action") %>' >
      <% recordBean.setAction_flag("N"); %>
    </if:IfTrue>

    <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getGraffiti_service()) %>' >
      <%-- 14/07/2010  TW  Initialise last action flag (used by addGraffDetails) --%>
      <% recordBean.setLast_action_flag( recordBean.getAction_flag() ); %>
    </if:IfTrue>
 
    <if:IfTrue cond='<%= itemLookupBean.getActionTaken().equals("Inspect") %>' >
      <%-- 19/05/2010  TW  Display inspDate form --%>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">itemLookup</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">inspDate</sess:setAttribute>
      <c:redirect url="inspDateScript.jsp" />
    </if:IfTrue>

    <%-- 24/05/2010  TW  New condition for Trees service and NFA --%>
    <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getTrees_service()) && recordBean.getAction_flag().equals("N") %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">itemLookup</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">faultLookup</sess:setAttribute>
      <c:redirect url="faultLookupScript.jsp" />
    </if:IfTrue>

    <%-- Use the customer details section --%>
    <if:IfTrue cond='<%= ((String)application.getInitParameter("use_cust_dets")).trim().equals("Y") && !recordBean.getService_c().equals(recordBean.getTrees_service()) %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">itemLookup</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">addCustDetails</sess:setAttribute>
      <c:redirect url="addCustDetailsScript.jsp" />
    </if:IfTrue>

    <%-- Don't use the customer details section --%>
    <if:IfTrue cond='<%= ((String)application.getInitParameter("use_cust_dets")).trim().equals("N") || recordBean.getService_c().equals(recordBean.getTrees_service()) %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">itemLookup</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">faultLookup</sess:setAttribute>
      <c:redirect url="faultLookupScript.jsp" />
    </if:IfTrue>
    
  </if:IfTrue>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= itemLookupBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">itemLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= itemLookupBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">itemLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= itemLookupBean.getAction().equals("Back") %>' >
    <% recordBean.setAction_flag(""); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">itemLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= itemLookupBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${itemLookupBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="itemLookupView.jsp" />
