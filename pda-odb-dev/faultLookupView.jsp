<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.faultLookupBean, com.vsb.recordBean, com.vsb.locLookupBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>

<jsp:useBean id="faultLookupBean" scope="session" class="com.vsb.faultLookupBean" />
<jsp:useBean id="locLookupBean" scope="session" class="com.vsb.locLookupBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="faultLookup" value="false">
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
  <title>faultLookup</title>
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
  <form onSubmit="return singleclick();" action="faultLookupScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Fault Lookup</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="faultLookupBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>

    <input type="hidden" name="comp_action_error" value="" />
    <%-- If the module is inspector then use this drop down --%>
    <app:equalsInitParameter name="module" match="pda-in" >
    	<app:equalsInitParameter name="use_comp_action_link" match="Y" >
        <table> 
          <if:IfTrue cond='<%= faultLookupBean.getComp_action_error().equals("") %>' >
            <tr>
              <td colspan="2">
              	This dropdown can be used to override the automatic action selection.
              </td>
            </tr>
          </if:IfTrue>
          <%
            String blank = "";
            String hold = "";
            String inspect = "";
            String def_name_noun = "";
            String works_order = "";
            String no_action = "";
            
            if (faultLookupBean.getActionTaken().equals("")) {
              blank = "selected=\"selected\"";
            } else if (faultLookupBean.getActionTaken().equals("Hold")) {
            	hold = "selected=\"selected\"";
            } else if (faultLookupBean.getActionTaken().equals("Inspect")) {
            	inspect = "selected=\"selected\"";
            } else if (faultLookupBean.getActionTaken().equals(application.getInitParameter("def_name_noun"))) {
            	def_name_noun = "selected=\"selected\"";
            } else if (faultLookupBean.getActionTaken().equals("Works Order")) {
            	works_order = "selected=\"selected\"";
            } else if (faultLookupBean.getActionTaken().equals("No Action")) {
            	no_action = "selected=\"selected\"";
            }
          %>
          <tr>
            <td colspan="2">
              <b>Action:</b>
              <select name="actionTaken">
                <option <%= blank %> ></option>
                <option <%= hold %> >Hold</option>
                <option <%= inspect %> >Inspect</option>
                <%-- If the service is dart or graffiti don't allow to default --%>
                <if:IfTrue cond='<%= !recordBean.getService_c().equals(recordBean.getDart_service()) && !recordBean.getService_c().equals(recordBean.getGraffiti_service()) %>' >
                  <option <%= def_name_noun %> ><app:initParameter name="def_name_noun" /></option>
                </if:IfTrue>
                <%-- If the service is dart don't allow to worksorder --%>
                <if:IfTrue cond='<%= !recordBean.getService_c().equals(recordBean.getDart_service()) %>' >
                  <option <%= works_order %> >Works Order</option>
                </if:IfTrue>
                <option></option>
                <option <%= no_action %> >No Action</option>
              </select><br/><br/>
            </td>
          </tr>
        </table>
      </app:equalsInitParameter>
    </app:equalsInitParameter>

    <% String color="#ffffff"; %>
    <table cellpadding="2" cellspacing="0" width="100%">
      <%-- Make sure the default code is also a complaint code --%>
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
        <%-- Setup trade switch --%>
        <% boolean usingCompCodeToTaskLink = false; %>
        <%-- Only get the system key if we are doing a Trade complaint --%>
        <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getTrade_service()) && locLookupBean.getAction().equals("Agreement") %>' >
          <%-- get the system key to see if we are using it --%>
          <sql:query>
            select c_field
            from keys
            where keyname = 'COMP CODE>TASK LINK'
            and   service_c = 'ALL'
          </sql:query>
          <sql:resultSet id="rset">
            <sql:getColumn position="1" to="c_field" />
            <sql:wasNotNull>
              <if:IfTrue cond='<%= ((String) pageContext.getAttribute("c_field")).trim().equals("Y") %>' >
                <% usingCompCodeToTaskLink = true; %>
              </if:IfTrue>
            </sql:wasNotNull>
          </sql:resultSet>
        </if:IfTrue>

<%-- 08/09/2010  TW  If using comp_action_link recordBean Action_flag will have been cleared --%>
<%--                 See faultLookupView.jsp --%>
        <if:IfTrue cond='<%= recordBean.getAction_flag().equals("H") ||
                             recordBean.getAction_flag().equals("I") ||
                             recordBean.getAction_flag().equals("W") ||
                             recordBean.getAction_flag().equals("N") ||
                             recordBean.getAction_flag().equals("") %>' >
          <if:IfTrue cond='<%= usingCompCodeToTaskLink == false %>' >
            <sql:query>
              select distinct pda_lookup.comp_code, pda_lookup.comp_code_desc, pda_lookup.display_order
              from it_c, pda_lookup, allk
              where it_c.item_ref = '<%= recordBean.getItem_ref() %>'
              and   pda_lookup.role_name = '<%= recordBean.getPda_role() %>'
              and   pda_lookup.comp_code = it_c.comp_code
              and   allk.lookup_func = 'COMPLA'
              and   allk.status_yn = 'Y'
              and   allk.lookup_code = pda_lookup.comp_code
              order by pda_lookup.display_order, pda_lookup.comp_code
            </sql:query>
          </if:IfTrue>
          <if:IfTrue cond='<%= usingCompCodeToTaskLink == true %>' >
            <sql:query>
              select distinct pda_lookup.comp_code, pda_lookup.comp_code_desc, pda_lookup.display_order
              from ta_c, pda_lookup, allk
              where ta_c.task_ref = '<%= recordBean.getTat_ref() %>'
              and   pda_lookup.role_name = '<%= recordBean.getPda_role() %>'
              and   pda_lookup.comp_code = ta_c.comp_code
              and   allk.lookup_func = 'COMPLA'
              and   allk.status_yn = 'Y'
              and   allk.lookup_code = pda_lookup.comp_code
              order by pda_lookup.display_order, pda_lookup.comp_code
            </sql:query>
          </if:IfTrue>
        </if:IfTrue>
        <if:IfTrue cond='<%= recordBean.getAction_flag().equals("D") %>' >
          <if:IfTrue cond='<%= usingCompCodeToTaskLink == false %>' >
            <sql:query>
              select distinct pda_lookup.comp_code, pda_lookup.comp_code_desc, pda_lookup.display_order
              from it_c, pda_lookup, allk, defa
              where it_c.item_ref = '<%= recordBean.getItem_ref() %>'
              and   pda_lookup.role_name = '<%= recordBean.getPda_role() %>'
              and   pda_lookup.comp_code = it_c.comp_code
              and   allk.lookup_func = 'DEFRN'
              and   allk.status_yn = 'Y'
              and   allk.lookup_code = pda_lookup.comp_code
              and   defa.item_type = '<%= recordBean.getItem_type() %>'
              and   defa.notice_rep_no = allk.lookup_num
              order by pda_lookup.display_order, pda_lookup.comp_code
            </sql:query>
          </if:IfTrue>
          <if:IfTrue cond='<%= usingCompCodeToTaskLink == true %>' >
            <sql:query>
              select distinct pda_lookup.comp_code, pda_lookup.comp_code_desc, pda_lookup.display_order
              from ta_c, pda_lookup, allk, defa
              where ta_c.task_ref = '<%= recordBean.getTat_ref() %>'
              and   pda_lookup.role_name = '<%= recordBean.getPda_role() %>'
              and   pda_lookup.comp_code = ta_c.comp_code
              and   allk.lookup_func = 'DEFRN'
              and   allk.status_yn = 'Y'
              and   allk.lookup_code = pda_lookup.comp_code
              and   defa.item_type = '<%= recordBean.getItem_type() %>'
              and   defa.notice_rep_no = allk.lookup_num
              order by pda_lookup.display_order, pda_lookup.comp_code
            </sql:query>
          </if:IfTrue>
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
              <sql:getColumn position="1" to="lookup_code" />
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("lookup_code")).trim().equals(faultLookupBean.getLookup_code()) %>' >
                <input type="radio" name="lookup_code" id="<sql:getColumn position="1" />" value="<sql:getColumn position="1" />"  checked="checked" />
              </if:IfTrue>
              <if:IfTrue cond='<%= ! ((String)pageContext.getAttribute("lookup_code")).trim().equals(faultLookupBean.getLookup_code()) %>' >
                <input type="radio" name="lookup_code" id="<sql:getColumn position="1" />"  value="<sql:getColumn position="1" />" />
              </if:IfTrue>
            </td>
            <td valign="top">
              <label for="<sql:getColumn position="1" />"><b><sql:getColumn position="1" /></b></label>
            </td>
            <td valign="top" >
             <label for="<sql:getColumn position="1" />"> <sql:getColumn position="2" /> </label>
            </td>
          </tr>
        </sql:resultSet>
        <sql:wasEmpty>
          <tr>
           <td colspan="3">
             <b>No faults available</b>
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
    <jsp:include page="include/back_continue_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="faultLookup" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
