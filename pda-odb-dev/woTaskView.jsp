<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.woTaskBean, com.vsb.recordBean, com.vsb.defectDetailsBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>

<jsp:useBean id="woTaskBean" scope="session" class="com.vsb.woTaskBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="defectDetailsBean" scope="session" class="com.vsb.defectDetailsBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="woTask" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<app:equalsInitParameter name="use_xhtml" match="Y">
  <html xmlns="http://www.w3.org/1999/xhtml">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <html>
</app:equalsInitParameter>
<head>
  <!-- Set iPhone OS Safari attributes -->
  <meta name = "viewport" content = "width = device-width">

  <%-- Stop the browser from caching the page --%>
  <meta http-equiv="Cache-Control" content="no-cache"/>
  <meta http-equiv="Pragma" content="no-cache"/>
  <%-- Stop any proxy servers from caching the page --%>
  <% response.addHeader("Cache-Control", "no-cache"); %>

  <meta http-equiv="Refresh" content="<app:initParameter name="refreshInterval"/>" />
  <app:equalsInitParameter name="use_xhtml" match="Y">
    <meta http-equiv="Content-Type" content="application/xhtml+xml" />
    <% response.setContentType("application/xhtml+xml"); %>
  </app:equalsInitParameter>
  <app:equalsInitParameter name="use_xhtml" match="Y" value="false">
    <meta http-equiv="Content-Type" content="text/html" />
  </app:equalsInitParameter>
  <title>woTask</title>
  <style type="text/css">
    @import url("global.css");
  </style>
  <!-- Disable the browser back button -->
  <script type="text/javascript">window.history.go(1);</script>
  <!-- Make all submit buttons single click only -->
  <script type="text/javascript">
    var allowed = true;
    function singleclick() {
      if (allowed == true ) {
        allowed = false;
        return true;
      } else {
        return false;
      }
    }
  </script>
</head>

<body onUnload="">
  <form onSubmit="return singleclick();" action="woTaskScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Task Lookup</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="woTaskBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <% String color="#ffffff"; %>
    <table cellpadding="2" cellspacing="0" width="100%">
      <%-- Make sure the task relates to group if link required --%>
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
        <%-- Set up the defect tasks list. --%>
        <% String defect_tasks = ""; %>

        <%-- If this is a defect works order --%>
        <if:IfTrue cond='<%= !recordBean.getDefect_flag().equals("") && !recordBean.getDefect_flag().equals("N") %>'>
          <sql:query>
            select c_field from keys
            where keyname = 'LINK_TASK_TO_WO_TYPE'
            and service_c = 'ALL'
          </sql:query>
          <sql:resultSet id="rset_flag">
            <sql:getColumn position="1" to="link_task_to_wo_flag" />
          </sql:resultSet>
          <if:IfTrue cond='<%= ((String)pageContext.getAttribute("link_task_to_wo_flag")).trim().equals("Y") %>' >
            <% String wo_type_group = ""; %>
            <sql:query>
              select wo_type_group from wo_type
              where wo_type_f = '<%= recordBean.getWo_type_f() %>'
              and contract_ref = '<%= recordBean.getWo_contract_ref() %>'
            </sql:query>
            <sql:resultSet id="rset_group">
              <sql:getColumn position="1" to="wo_type_group" />
              <sql:wasNotNull>
                <% wo_type_group = ((String)pageContext.getAttribute("wo_type_group")).trim(); %>
              </sql:wasNotNull>
            </sql:resultSet>
            <%
              boolean wo_group_flag;
              if (wo_type_group == null || wo_type_group == "") {
                wo_group_flag = false;
              } else {
                wo_group_flag = true;
              }
            %>
            <if:IfTrue cond='<%= wo_group_flag %>' >
              <sql:query>
                select distinct ta_r.task_ref, task.task_desc
                from task, ta_r
                where task.task_ref = ta_r.task_ref
                and ta_r.rate_band_code = 'SELL'
                and ta_r.cont_cycle_no = '<%= recordBean.getCont_cycle_no() %>'
                and (task.wo_type_group = '<%= wo_type_group %>'
                  or (task.wo_type_group = '' and ta_r.contract_ref = '<%= recordBean.getWo_contract_ref() %>')
                  or (task.wo_type_group is null and ta_r.contract_ref = '<%= recordBean.getWo_contract_ref() %>')
                )
                AND task.task_ref IN (
                    SELECT task_ref 
                      FROM measurement_task
                     WHERE measurement_task.task_ref  = task.task_ref
                       AND measurement_task.priority  = '<%= recordBean.getDefect_priority() %>'
                )
                order by ta_r.task_ref
              </sql:query>
            </if:IfTrue>
            <if:IfTrue cond='<%= ! wo_group_flag %>' >
              <sql:query>
                select distinct ta_r.task_ref, task.task_desc
                from task, ta_r
                where task.task_ref = ta_r.task_ref
                and ta_r.rate_band_code = 'SELL'
                and ta_r.cont_cycle_no = '<%= recordBean.getCont_cycle_no() %>'
                and ta_r.contract_ref = '<%= recordBean.getWo_contract_ref() %>'
                AND task.task_ref IN (
                    SELECT task_ref 
                      FROM measurement_task
                     WHERE measurement_task.task_ref  = task.task_ref
                       AND measurement_task.priority  = '<%= recordBean.getDefect_priority() %>'
                )
                order by ta_r.task_ref
              </sql:query>
            </if:IfTrue>
          </if:IfTrue>
          <if:IfTrue cond='<%= ! ((String)pageContext.getAttribute("link_task_to_wo_flag")).trim().equals("Y") %>' >
            <sql:query>
              select distinct ta_r.task_ref, task.task_desc
              from task, ta_r
              where task.task_ref = ta_r.task_ref
              and ta_r.rate_band_code = 'SELL'
              and ta_r.cont_cycle_no = '<%= recordBean.getCont_cycle_no() %>'
              and ta_r.contract_ref = '<%= recordBean.getWo_contract_ref() %>'
              AND task.task_ref IN (
                  SELECT task_ref 
                    FROM measurement_task
                   WHERE measurement_task.task_ref  = task.task_ref
                     AND measurement_task.priority  = '<%= recordBean.getDefect_priority() %>'
              )
              order by ta_r.task_ref
            </sql:query>
          </if:IfTrue>
          <sql:resultSet id="rset">
            <%
              if(color=="#ffffff") {
                color = "#ecf5ff";
              } else if (color=="#ecf5ff") {
                color = "#ffffff";
              }
            %>
            <tr bgcolor="<%= color %>" >
              <td valign="top" width="10">
                <sql:getColumn position="1" to="woi_task_ref" />
                <% String woi_task_ref = ((String)pageContext.getAttribute("woi_task_ref")).trim(); %>
                <%
                  // Add a comma if there is already a task stored
                  if(! defect_tasks.equals("")) {
                    defect_tasks = defect_tasks + ", ";
                  }
                  // Store the task 
                  defect_tasks = defect_tasks + "'" + woi_task_ref + "'";
                %>
                  <input type="checkbox" 
                         name="woi_task_refs" 
                         id="<%= woi_task_ref %>" 
                         value="<%= woi_task_ref %>"
                         <if:IfTrue cond='<%= woTaskBean.contains( woi_task_ref ) %>' >
                           checked="checked" 
                         </if:IfTrue>
                  />
              </td>
              <td valign="top">
                <label for="<%= woi_task_ref %>"><b><%= woi_task_ref %></b></label>
              </td>
            </tr>
            <tr bgcolor="<%= color %>" >
              <td>&nbsp;</td>
              <td>
               <label for="<%= woi_task_ref %>"> <sql:getColumn position="2" /> </label>
              </td>
            </tr>
          </sql:resultSet>
          <sql:wasEmpty>
            <tr>
              <td colspan="3">
                <b>No Area or Linear tasks available for this priority</b>
              </td>
            </tr>
          </sql:wasEmpty>
          <sql:wasNotEmpty>
            <tr>
              <td colspan="3">
                <span class="subscript"><sql:rowCount /> codes</span>
              </td>
            </tr>
          </sql:wasNotEmpty>
          <tr><td colspan="3"><hr size="1" noshade="noshade" /></td></tr>
        </if:IfTrue>

        <%-- For all works order --%>
        <sql:query>
          select c_field from keys
          where keyname = 'LINK_TASK_TO_WO_TYPE'
          and service_c = 'ALL'
        </sql:query>
        <sql:resultSet id="rset_flag">
          <sql:getColumn position="1" to="link_task_to_wo_flag" />
        </sql:resultSet>
        <if:IfTrue cond='<%= ((String)pageContext.getAttribute("link_task_to_wo_flag")).trim().equals("Y") %>' >
          <% String wo_type_group = ""; %>
          <sql:query>
            select wo_type_group from wo_type
            where wo_type_f = '<%= recordBean.getWo_type_f() %>'
            and contract_ref = '<%= recordBean.getWo_contract_ref() %>'
          </sql:query>
          <sql:resultSet id="rset_group">
            <sql:getColumn position="1" to="wo_type_group" />
            <sql:wasNotNull>
              <% wo_type_group = ((String)pageContext.getAttribute("wo_type_group")).trim(); %>
            </sql:wasNotNull>
          </sql:resultSet>
          <%
            boolean wo_group_flag;
            if (wo_type_group == null || wo_type_group == "") {
              wo_group_flag = false;
            } else {
              wo_group_flag = true;
            }
          %>
          <if:IfTrue cond='<%= wo_group_flag %>' >
            <sql:query>
              select distinct ta_r.task_ref, task.task_desc
              from task, ta_r
              where task.task_ref = ta_r.task_ref
              and ta_r.rate_band_code = 'SELL'
              and ta_r.cont_cycle_no = '<%= recordBean.getCont_cycle_no() %>'
              and (task.wo_type_group = '<%= wo_type_group %>'
                or (task.wo_type_group = '' and ta_r.contract_ref = '<%= recordBean.getWo_contract_ref() %>')
                or (task.wo_type_group is null and ta_r.contract_ref = '<%= recordBean.getWo_contract_ref() %>')
              )
              AND task.task_ref NOT IN (
                  SELECT task_ref 
                    FROM measurement_task
                   WHERE measurement_task.task_ref  = task.task_ref
              )
              <if:IfTrue cond='<%= ! defect_tasks.equals("") %>' >
                AND task.task_ref NOT IN (<%= defect_tasks %>)
              </if:IfTrue>
              order by ta_r.task_ref
            </sql:query>
          </if:IfTrue>
          <if:IfTrue cond='<%= ! wo_group_flag %>' >
            <sql:query>
              select distinct ta_r.task_ref, task.task_desc
              from task, ta_r
              where task.task_ref = ta_r.task_ref
              and ta_r.rate_band_code = 'SELL'
              and ta_r.cont_cycle_no = '<%= recordBean.getCont_cycle_no() %>'
              and ta_r.contract_ref = '<%= recordBean.getWo_contract_ref() %>'
              AND task.task_ref NOT IN (
                  SELECT task_ref 
                    FROM measurement_task
                   WHERE measurement_task.task_ref  = task.task_ref
              )
              <if:IfTrue cond='<%= ! defect_tasks.equals("") %>' >
                AND task.task_ref NOT IN (<%= defect_tasks %>)
              </if:IfTrue>
              order by ta_r.task_ref
            </sql:query>
          </if:IfTrue>
        </if:IfTrue>
        <if:IfTrue cond='<%= ! ((String)pageContext.getAttribute("link_task_to_wo_flag")).trim().equals("Y") %>' >
          <sql:query>
            select distinct ta_r.task_ref, task.task_desc
            from task, ta_r
            where task.task_ref = ta_r.task_ref
            and ta_r.rate_band_code = 'SELL'
            and ta_r.cont_cycle_no = '<%= recordBean.getCont_cycle_no() %>'
            and ta_r.contract_ref = '<%= recordBean.getWo_contract_ref() %>'
            AND task.task_ref NOT IN (
                SELECT task_ref 
                  FROM measurement_task
                 WHERE measurement_task.task_ref  = task.task_ref
            )
            <if:IfTrue cond='<%= ! defect_tasks.equals("") %>' >
              AND task.task_ref NOT IN (<%= defect_tasks %>)
            </if:IfTrue>
            order by ta_r.task_ref
          </sql:query>
        </if:IfTrue>
        <sql:resultSet id="rset">
          <%
            if(color=="#ffffff") {
              color = "#ecf5ff";
            } else if (color=="#ecf5ff") {
              color = "#ffffff";
            }
          %>
          <tr bgcolor="<%= color %>" >
            <td valign="top" width="10">
              <sql:getColumn position="1" to="woi_task_ref" />
              <% String woi_task_ref = ((String)pageContext.getAttribute("woi_task_ref")).trim(); %>
                <input type="checkbox" 
                       name="woi_task_refs" 
                       id="<%= woi_task_ref %>" 
                       value="<%= woi_task_ref %>"
                       <if:IfTrue cond='<%= woTaskBean.contains( woi_task_ref ) %>' >
                         checked="checked" 
                       </if:IfTrue>
                />
            </td>
            <td valign="top">
              <label for="<%= woi_task_ref %>"><b><%= woi_task_ref %></b></label>
            </td>
          </tr>
          <tr bgcolor="<%= color %>" >
            <td>&nbsp;</td>
            <td>
             <label for="<%= woi_task_ref %>"> <sql:getColumn position="2" /> </label>
            </td>
          </tr>
        </sql:resultSet>
        <sql:wasEmpty>
          <tr>
            <td colspan="3">
              <b>No tasks available</b>
            </td>
          </tr>
        </sql:wasEmpty>
        <sql:wasNotEmpty>
          <tr>
            <td colspan="3">
              <span class="subscript"><sql:rowCount /> codes</span>
            </td>
          </tr>
        </sql:wasNotEmpty>
      </sql:statement>
      <sql:closeConnection conn="con"/>
    </table>
    <jsp:include page="include/back_next_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="woTask" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
