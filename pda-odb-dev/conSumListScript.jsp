<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.conSumListBean, com.vsb.recordBean, com.vsb.loginBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="conSumListBean" scope="session" class="com.vsb.conSumListBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="conSumList" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="conSumList" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="conSumListBean" property="all" value="clear" />
    <jsp:setProperty name="conSumListBean" property="*" />

    <%-- Clear the previous record --%>
    <jsp:setProperty name="recordBean" property="all" value="clear" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="complaint_no" param="complaint_no" />
    <jsp:setProperty name="recordBean" property="clearedDefault" value="N" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="conSumListBean" property="error" value="" />

<%-- clear form fields if coming from previous form via a menu jump --%>
<%-- and update savedPreviousForm as if we had just come from the mainMenu form. --%>
<%-- Also reset the menuJump session object. --%>
<sess:equalsAttribute name="menuJump" match="yes">
  <jsp:setProperty name="conSumListBean" property="action" value="" />
  <jsp:setProperty name="conSumListBean" property="all" value="clear" />
  <jsp:setProperty name="conSumListBean" property="savedPreviousForm" value="mainMenu" />
  <sess:setAttribute name="menuJump">no</sess:setAttribute>
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="mainMenu" >
  <jsp:setProperty name="conSumListBean" property="action" value="" />
  <jsp:setProperty name="conSumListBean" property="all" value="clear" />
  <jsp:setProperty name="conSumListBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Populate the sort_order for use in the VIEW, but only the first time through the SCRIPT --%>
<sess:equalsAttribute name="input" match="conSumList" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <sess:setAttribute name="sort_order">date</sess:setAttribute>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="conSumList" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= conSumListBean.getAction().equals("Details") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=conSumListBean.getComplaint_no() == null || conSumListBean.getComplaint_no().equals("") %>' >
      <jsp:setProperty name="conSumListBean" property="error"
        value="Please choose an item." />
      <jsp:forward page="conSumListView.jsp" />
    </if:IfTrue>

    <% pageContext.setAttribute("comp_exists", "false"); %>
    <sql:connection id="conn" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="conn">
      <%-- check to see if the selected complaint still exists and --%>
      <%-- is still open. --%>
      <sql:query>
        select complaint_no
        from comp
        where complaint_no = '<%= recordBean.getComplaint_no() %>'
        and   date_closed is null
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

      <%-- check to see if the selected Workd Order still exists --%>
      <sql:query>
        SELECT action_flag,
               dest_ref,
               dest_suffix
          FROM comp
         WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
           AND date_closed IS NULL
      </sql:query>
      <sql:resultSet id="rset">
        <%-- If the complaint is a works order, check the completion date is still null --%>
        <sql:getColumn position="1" to="wo_action_flag" />
        <if:IfTrue cond='<% ((String)pageContext.getAttribute("wo_action_flag")).trim().equals("W"); %>'>
          <sql:getColumn position="2" to="wo_dest_ref" />
          <sql:getColumn position="3" to="wo_dest_suffix" />
          <sql:statement id="stmt2" conn="conn">
            <sql:query>
              SELECT wo_ref
                FROM wo_cont_h
               WHERE wo_ref = '<% ((String)pageContext.getAttribute("wo_dest_ref")).trim(); %>'
                 AND wo_suffix = '<% ((String)pageContext.getAttribute("wo_dest_suffix")).trim(); %>'
                 AND completion_date IS NULL
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
          </sql:statement>
        </if:IfTrue>
      </sql:resultSet>
      
      <%-- get the state of the currently selected item --%>
      <sql:query>
        select state
        from con_sum_list
        where complaint_no = '<%= recordBean.getComplaint_no() %>'
        and   (
                user_name in (
                  select user_name
                  from pda_cover_list
                  where covered_by = '<%= loginBean.getUser_name() %>'
                )
              )
        and   (state = 'A' or state = 'P')
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="state" />
        <sql:wasNull>
          <% pageContext.setAttribute("state", ""); %>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% pageContext.setAttribute("state", ""); %>
      </sql:wasEmpty>

      <if:IfTrue cond='<%=((String) pageContext.getAttribute("comp_exists")).trim().equals("false") %>' >
        <%-- delete any occurance of the complaint from the inspection --%>
        <%-- list table, as it is no longer exists, or is closed. --%>
        <sql:query>
          delete from insp_list
          where complaint_no = '<%= recordBean.getComplaint_no() %>'
        </sql:query>
        <sql:execute/>
      </if:IfTrue>
    </sql:statement>
    <sql:closeConnection conn="conn"/>

    <if:IfTrue cond='<%=((String) pageContext.getAttribute("comp_exists")).trim().equals("false") %>' >
      <jsp:setProperty name="conSumListBean" property="error"
        value="This item no longer exists, or is closed. Please choose another item." />
      <jsp:forward page="conSumListView.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond='<%=((String) pageContext.getAttribute("state")).trim().equals("P") %>' >
      <jsp:setProperty name="conSumListBean" property="error"
        value="This item has already been processed. Please choose another item." />
      <jsp:forward page="conSumListView.jsp" />
    </if:IfTrue>

    <%-- valid entry --%>
    <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con1">
      <%-- get the action_flag of the currently selected item --%>
      <sql:query>
        SELECT action_flag,
               recvd_by,
               exact_location,
               site_ref,
               service_c
          FROM comp
         WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="comp_action_flag" />
        <% recordBean.setComp_action_flag((String) pageContext.getAttribute("comp_action_flag")); %>
        <sql:getColumn position="2" to="comp_recvd_by" />
        <% recordBean.setSource_code((String) pageContext.getAttribute("comp_recvd_by")); %>
        <sql:getColumn position="3" to="comp_exact_location" />
        <% recordBean.setExact_location((String) pageContext.getAttribute("comp_exact_location")); %>                
        <sql:getColumn position="4" to="comp_site_ref" />
        <% recordBean.setSite_ref((String) pageContext.getAttribute("comp_site_ref")); %>
        <sql:getColumn position="5" to="service_c" />
        <% recordBean.setService_c((String) pageContext.getAttribute("service_c")); %>                        	
      </sql:resultSet>

      <%-- different things need to be got depending on the comp_action_flag --%>
      <%-- for a comp_action_flag of "W" or "D" nothing else needs to be got --%>
      <%-- complaint Works Order "W" --%>
      <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("W") %>' >
        <%-- retrieve the dest_ref and dest_suffix --%>
	<sql:query>
	  SELECT dest_ref,
	         dest_suffix
            FROM comp
	   WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
	</sql:query>
	<sql:resultSet id='rset1'>
	  <sql:getColumn position="1" to="dest_ref" />
            <sql:wasNull>
              <% pageContext.setAttribute("dest_ref", ""); %>
            </sql:wasNull>
          <% recordBean.setWo_ref((String) pageContext.getAttribute("dest_ref")); %>	    
	  <sql:getColumn position="2" to="wo_suffix" />
            <sql:wasNull>
              <% pageContext.setAttribute("wo_suffix", ""); %>
            </sql:wasNull>
          <% recordBean.setWo_suffix((String) pageContext.getAttribute("wo_suffix")); %>
	</sql:resultSet>

        <sql:query>
          SELECT service_c,
                 date_raised,
                 time_raised_h,
                 time_raised_m,
                 wo_h_stat,
                 wo_date_due,
	         contract_ref	 
          FROM wo_h
          WHERE wo_ref  = '<%= recordBean.getWo_ref() %>'
	  AND wo_suffix = '<%= recordBean.getWo_suffix() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="service_c" />
          <sql:wasNull>
            <% pageContext.setAttribute("service_c", ""); %>
          </sql:wasNull>
          <% recordBean.setComp_desc((String) pageContext.getAttribute("service_c")); %>
          <sql:getDate position="2" to="date_raised" format="<%= application.getInitParameter("db_date_fmt") %>" />
          <sql:wasNull>
            <% pageContext.setAttribute("date_raised", ""); %>
          </sql:wasNull>
          <% recordBean.setStart_date((String) pageContext.getAttribute("date_raised")); %>
          <sql:getColumn position="3" to="time_raised_h" />
          <sql:wasNull>
            <% pageContext.setAttribute("time_raised_h", ""); %>
          </sql:wasNull>
          <% recordBean.setStart_time_h((String) pageContext.getAttribute("time_raised_h")); %>
          <sql:getColumn position="4" to="time_raised_m" />
          <sql:wasNull>
            <% pageContext.setAttribute("time_raised_m", ""); %>
          </sql:wasNull>
          <% recordBean.setStart_time_m((String) pageContext.getAttribute("time_raised_m")); %>
          <sql:getColumn position="5" to="wo_h_stat" />
          <sql:wasNull>
            <% pageContext.setAttribute("wo_h_stat", ""); %>
          </sql:wasNull>	  
          <% recordBean.setWo_h_stat((String) pageContext.getAttribute("wo_h_stat")); %>
          <sql:getDate position="6" to="wo_date_due" format="<%= application.getInitParameter("db_date_fmt") %>" />
          <sql:wasNull>
            <% pageContext.setAttribute("wo_date_due", ""); %>
          </sql:wasNull>
          <% recordBean.setWo_date_due((String) pageContext.getAttribute("wo_date_due")); %>
          <sql:getColumn position="7" to="wo_contract_ref" />
          <sql:wasNull>
            <% pageContext.setAttribute("wo_contract_ref", ""); %>
          </sql:wasNull>
          <% recordBean.setWo_contract_ref((String) pageContext.getAttribute("wo_contract_ref")); %>	  
        </sql:resultSet>

        <sql:query>
          SELECT compl_by,
                 cont_canc,
                 cont_rem1,
                 cont_rem2,
                 completion_date,
                 completion_time_h,
                 completion_time_m	 
          FROM wo_cont_h
          WHERE wo_ref  = '<%= recordBean.getWo_ref() %>'
	  AND wo_suffix = '<%= recordBean.getWo_suffix() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="compl_by" />
          <sql:wasNull>
            <% pageContext.setAttribute("compl_by", ""); %>
          </sql:wasNull>
          <% recordBean.setCompl_by((String) pageContext.getAttribute("compl_by")); %>
          <sql:getColumn position="2" to="cont_canc" />
          <sql:wasNull>
            <% pageContext.setAttribute("cont_canc", ""); %>
          </sql:wasNull>
          <% recordBean.setCont_canc((String) pageContext.getAttribute("cont_canc")); %>
          <sql:getColumn position="3" to="cont_rem1" />
          <sql:wasNull>
            <% pageContext.setAttribute("cont_rem1", ""); %>
          </sql:wasNull>
          <% recordBean.setCont_rem1((String) pageContext.getAttribute("cont_rem1")); %>
          <sql:getColumn position="4" to="cont_rem2" />
          <sql:wasNull>
            <% pageContext.setAttribute("cont_rem2", ""); %>
          </sql:wasNull>
          <% recordBean.setCont_rem2((String) pageContext.getAttribute("cont_rem2")); %>
          <sql:getDate position="5" to="completion_date" format="<%= application.getInitParameter("db_date_fmt") %>" />
          <sql:wasNull>
            <% pageContext.setAttribute("completion_date", ""); %>
          </sql:wasNull>	  
          <% recordBean.setCompletion_date((String) pageContext.getAttribute("completion_date")); %>
          <sql:getColumn position="6" to="completion_time_h" />
          <sql:wasNull>
            <% pageContext.setAttribute("completion_time_h", ""); %>
          </sql:wasNull>
          <% recordBean.setCompletion_time_h((String) pageContext.getAttribute("completion_time_h")); %>
          <sql:getColumn position="7" to="completion_time_m" />
          <sql:wasNull>
            <% pageContext.setAttribute("completion_time_m", ""); %>
          </sql:wasNull>
          <% recordBean.setCompletion_time_m((String) pageContext.getAttribute("completion_time_m")); %>	  
        </sql:resultSet>

        <sql:query>
          SELECT site_name_1, ward_code
          FROM site
          WHERE site_ref = '<%= recordBean.getSite_ref() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="site_name_1" />
          <% recordBean.setSite_name_1((String) pageContext.getAttribute("site_name_1")); %>
          <sql:getColumn position="2" to="ward_code" />
          <% recordBean.setWard_code((String) pageContext.getAttribute("ward_code")); %>
        </sql:resultSet>

        <sql:query>
          SELECT wo_stat_desc
          FROM wo_stat
          WHERE wo_h_stat  = '<%= recordBean.getWo_h_stat() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="wo_stat_desc" />
          <% recordBean.setWo_stat_desc((String) pageContext.getAttribute("wo_stat_desc")); %>
        </sql:resultSet>	
	
      </if:IfTrue>

      
      <%-- complaint default "D" --%>
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

        <sql:query>
          SELECT default_reason
          FROM defh
          WHERE default_no = '<%= recordBean.getDefault_no() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="default_reason" />
          <sql:wasNull>
            <% pageContext.setAttribute("default_reason", ""); %>
          </sql:wasNull>
          <% recordBean.setComp_code((String) pageContext.getAttribute("default_reason")); %>
        </sql:resultSet>

        <sql:query>
          SELECT item_ref,
                 feature_ref,	  
                 volume
          FROM defi
          WHERE default_no = '<%= recordBean.getDefault_no() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="item_ref" />
          <% recordBean.setItem_ref((String) pageContext.getAttribute("item_ref")); %>
          <sql:getColumn position="2" to="feature_ref" />
          <% recordBean.setFeature_ref((String) pageContext.getAttribute("feature_ref")); %>	  
          <sql:getColumn position="3" to="volume" />
          <% recordBean.setVolume((String) pageContext.getAttribute("volume")); %>
        </sql:resultSet>
        
        <sql:query>
          SELECT rectify_date, 
                 rectify_time_h, 
                 rectify_time_m
          FROM defi_rect
          WHERE default_no = '<%= recordBean.getDefault_no() %>'
          AND   seq_no = (
                  SELECT MAX(seq_no)
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

        <sql:query>
          SELECT action_flag, 
                 trans_date, 
                 time_h, 
                 time_m
          FROM deft
          WHERE default_no = '<%= recordBean.getDefault_no() %>'
          AND   seq_no = (
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

        <sql:query>
          SELECT item_desc, 
                 item_type
          FROM item
          WHERE item_ref = '<%= recordBean.getItem_ref() %>'
         </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="item_desc" />
          <% recordBean.setItem_desc((String) pageContext.getAttribute("item_desc")); %>
          <sql:getColumn position="2" to="item_type" />
          <% recordBean.setItem_type((String) pageContext.getAttribute("item_type")); %>
        </sql:resultSet>
        
        <sql:query>
          SELECT site_name_1, ward_code
          FROM site
          WHERE site_ref = '<%= recordBean.getSite_ref() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="site_name_1" />
          <% recordBean.setSite_name_1((String) pageContext.getAttribute("site_name_1")); %>
          <sql:getColumn position="2" to="ward_code" />
          <% recordBean.setWard_code((String) pageContext.getAttribute("ward_code")); %>
        </sql:resultSet>
        
        <sql:query>
          SELECT lookup_text
          FROM allk
          WHERE lookup_func = 'DEFRN'
          AND lookup_code = '<%= recordBean.getComp_code() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="lookup_text" />
          <sql:wasNull>
            <% pageContext.setAttribute("lookup_text", ""); %>
          </sql:wasNull>          
          <% recordBean.setComp_desc((String) pageContext.getAttribute("lookup_text")); %>        
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

        <sql:query>
          SELECT start_date,
                 start_time_h,
                 start_time_m
            FROM defh
           WHERE cust_def_no = <%= recordBean.getDefault_no() %>
        </sql:query>
        <sql:resultSet id="res1">
          <sql:getDate position="1" to="start_date" format="<%= application.getInitParameter("db_date_fmt") %>" />
          <% recordBean.setStart_date((String) pageContext.getAttribute("start_date")); %>
          <sql:getColumn position="2" to="start_time_h" />
          <% recordBean.setStart_time_h((String) pageContext.getAttribute("start_time_h")); %>
          <sql:getColumn position="3" to="start_time_m" />
          <% recordBean.setStart_time_m((String) pageContext.getAttribute("start_time_m")); %>	
        </sql:resultSet>   	
	
      </if:IfTrue>
    </sql:statement>
    <sql:closeConnection conn="con1"/>

    <%-- Go to a different screen depending on the complaint action --%>
    <%-- complaint default --%>
    <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("D") %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">conSumList</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">conSumDefaultDetails</sess:setAttribute>
      <c:redirect url="conSumDefaultDetailsScript.jsp" />
    </if:IfTrue>
    <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("W") %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">conSumList</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">conSumWODetails</sess:setAttribute>
      <c:redirect url="conSumWODetailsScript.jsp" />
    </if:IfTrue>
    
  </if:IfTrue>
  
  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= conSumListBean.getAction().equals(application.getInitParameter("def_name_short")) %>' >
    <sess:setAttribute name="sort_order">defaults</sess:setAttribute>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="conSumListView.jsp" />
  </if:IfTrue>

  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= conSumListBean.getAction().equals("W/O") %>' >
    <sess:setAttribute name="sort_order">works orders</sess:setAttribute>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="conSumListView.jsp" />
  </if:IfTrue>

  <%-- Next view 4 --%>
  <if:IfTrue cond='<%= conSumListBean.getAction().equals("Date") %>' >
    <sess:setAttribute name="sort_order">date</sess:setAttribute>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="conSumListView.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= conSumListBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">conSumList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= conSumListBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">conSumList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>
  
  <%-- Previous view --%>
  <if:IfTrue cond='<%= conSumListBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">conSumList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= conSumListBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${conSumListBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="conSumListView.jsp" />
