<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.changeItemLookupBean, com.vsb.recordBean" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="changeItemLookupBean" scope="session" class="com.vsb.changeItemLookupBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="changeItemLookup" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="changeItemLookup" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="changeItemLookupBean" property="all" value="clear" />
    <jsp:setProperty name="changeItemLookupBean" property="*" />
    
    <%-- Add the new values to the record as long as a user selected an item --%>
    <if:IfTrue cond='<%= changeItemLookupBean.getView_key() != null && !changeItemLookupBean.getView_key().equals("") %>' >
      <%
        StringTokenizer view_key = new StringTokenizer(changeItemLookupBean.getView_key(), "|");
        String item_ref = view_key.nextToken();
        String feature_ref = view_key.nextToken();
        String contract_ref = view_key.nextToken();

        recordBean.setChanged_item_ref(item_ref.trim());
        recordBean.setChanged_feature_ref(feature_ref.trim());
        recordBean.setChanged_contract_ref(contract_ref.trim());
      %>

      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
      <sql:statement id="stmt" conn="con">
        <sql:query>
          select occur_day, occur_week, occur_month, round_c, pa_area,
            priority_flag, volume
          from si_i
          where site_ref = '<%= recordBean.getSite_ref() %>'
          and item_ref = '<%= recordBean.getChanged_item_ref() %>'
          and feature_ref = '<%= recordBean.getChanged_feature_ref() %>'
          and contract_ref = '<%= recordBean.getChanged_contract_ref() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="occur_day" />
          <% recordBean.setChanged_occur_day((String) pageContext.getAttribute("occur_day")); %>
          <sql:getColumn position="2" to="occur_week" />
          <% recordBean.setChanged_occur_week((String) pageContext.getAttribute("occur_week")); %>
          <sql:getColumn position="3" to="occur_month" />
          <% recordBean.setChanged_occur_month((String) pageContext.getAttribute("occur_month")); %>
          <sql:getColumn position="4" to="round_c" />
          <% recordBean.setChanged_round_c((String) pageContext.getAttribute("round_c")); %>
          <sql:getColumn position="5" to="pa_area" />
          <% recordBean.setChanged_pa_area((String) pageContext.getAttribute("pa_area")); %>
          <sql:getColumn position="6" to="priority_flag" />
          <% recordBean.setChanged_priority((String) pageContext.getAttribute("priority_flag")); %>
          <sql:getColumn position="7" to="total_volume" />
          <% recordBean.setChanged_total_volume((String) pageContext.getAttribute("total_volume")); %>
        </sql:resultSet>

        <sql:query>
          select feature_desc
          from feat
          where feature_ref = '<%= recordBean.getChanged_feature_ref() %>'
         </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="feature_desc" />
          <% recordBean.setChanged_feature_desc((String) pageContext.getAttribute("feature_desc")); %>
        </sql:resultSet>
        
        <sql:query>
          select item_desc, item_type, insp_item_flag
          from item
          where item_ref = '<%= recordBean.getChanged_item_ref() %>'
         </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="item_desc" />
          <% recordBean.setChanged_item_desc((String) pageContext.getAttribute("item_desc")); %>
          <sql:getColumn position="2" to="item_type" />
          <% recordBean.setChanged_item_type((String) pageContext.getAttribute("item_type")); %>
          <sql:getColumn position="3" to="insp_item_flag" />
          <% recordBean.setChanged_insp_item_flag((String) pageContext.getAttribute("insp_item_flag")); %>
        </sql:resultSet>
        
        <sql:query>
          select building_stat
          from site_detail
          where site_ref = '<%= recordBean.getSite_ref() %>'
         </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="building_stat" />
          <% recordBean.setChanged_building_stat((String) pageContext.getAttribute("building_stat")); %>
        </sql:resultSet>
        
        <sql:query>
          select lookup_text
          from allk
          where lookup_code = '<%= recordBean.getChanged_building_stat() %>'
          and lookup_func = 'SITEBG'
         </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="building_stat_desc" />
          <% recordBean.setChanged_building_stat_desc((String) pageContext.getAttribute("building_stat_desc")); %>
        </sql:resultSet>
        
        <sql:query>
          select patr.po_name
          from patr, patr_area
          where patr_area.area_c = '<%= recordBean.getChanged_pa_area() %>'
          and patr_area.pa_site_flag = 'P'
          and patr.po_code = patr_area.po_code
         </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="po_name" />
          <% recordBean.setChanged_po_name((String) pageContext.getAttribute("po_name")); %>
        </sql:resultSet>
      </sql:statement>
      <sql:closeConnection conn="con"/>
    </if:IfTrue>
    
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="changeItemLookupBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="compSampDetails" >
  <jsp:setProperty name="changeItemLookupBean" property="action" value="" />
  <jsp:setProperty name="changeItemLookupBean" property="all" value="clear" />
  <jsp:setProperty name="changeItemLookupBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="changeItemLookup" value="false">
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
<sess:equalsAttribute name="input" match="changeItemLookup" >
  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= changeItemLookupBean.getAction().equals("Fault") %>' >
    <% recordBean.setChanged_date_due(""); %>

    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= changeItemLookupBean.getView_key() == null || changeItemLookupBean.getView_key().equals("") %>' >
      <jsp:setProperty name="changeItemLookupBean" property="error"
        value="Please choose an item." />
      <jsp:forward page="changeItemLookupView.jsp" />
    </if:IfTrue>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">changeItemLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">changeFaultLookup</sess:setAttribute>
    <c:redirect url="changeFaultLookupScript.jsp" />
  </if:IfTrue>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= changeItemLookupBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">changeItemLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= changeItemLookupBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">changeItemLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= changeItemLookupBean.getAction().equals("Back") %>' >
    <% recordBean.setAction_flag(""); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">changeItemLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= changeItemLookupBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${changeItemLookupBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="changeItemLookupView.jsp" />
