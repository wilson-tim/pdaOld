<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.vsb.changeFaultLookupBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>

<jsp:useBean id="changeFaultLookupBean" scope="session" class="com.vsb.changeFaultLookupBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="changeFaultLookup" value="false">
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
  <title>changeFaultLookup</title>
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
  <form onSubmit="return singleclick();" action="changeFaultLookupScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Change Fault</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="changeFaultLookupBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>

    <% String color="#ffffff"; %>
    <table cellpadding="2" cellspacing="0" width="100%">
      <%-- Make sure the code is a complaint code --%>
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
        <% String defect_fault_codes_string = ""; %>
        <% boolean isDefectFaultCode = false; %>
        <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getHway_service()) %>' >
          <%-- Get the fault codes that are allowed to have defects applied to them --%>
          <sql:query>
            SELECT c_field
              FROM keys
             WHERE keyname = 'MS_FAULT_CODES'
          </sql:query>
          <sql:resultSet id="rset">
            <sql:getColumn position="1" to="c_field" />
            <sql:wasNotNull>
              <% defect_fault_codes_string = ((String)pageContext.getAttribute("c_field")).trim(); %>
            </sql:wasNotNull>
          </sql:resultSet>
          <%-- Create an arraylist of individual fault codes from the comma separated list --%>
          <% ArrayList defect_fault_codes = helperBean.splitCommaList( defect_fault_codes_string ); %>
          <%-- Check if the fault code which the complaint is at the moment is a valid defect code --%>
          <if:IfTrue cond='<%= defect_fault_codes.contains( recordBean.getComp_code() ) %>'>
            <%-- Set the valid fault code field to  as the current fault code is in the list --%>
            <% isDefectFaultCode = true; %>
          </if:IfTrue>
        </if:IfTrue>

        <%-- Only allow complaints that are already defects to select defect fault codes --%>
        <sql:query>
          select distinct pda_lookup.comp_code, pda_lookup.comp_code_desc, pda_lookup.display_order
          from it_c, pda_lookup, allk
          where it_c.item_ref = '<%= recordBean.getChanged_item_ref() %>'
          and   pda_lookup.role_name = '<%= recordBean.getPda_role() %>'
          and   pda_lookup.comp_code = it_c.comp_code
          and   allk.lookup_func = 'COMPLA'
          and   allk.status_yn = 'Y'
          and   allk.lookup_code = pda_lookup.comp_code
          <if:IfTrue cond='<%= ! defect_fault_codes_string.equals("") && isDefectFaultCode == false %>' >
            and allk.lookup_code NOT IN (<%= helperBean.quoteCommaList(defect_fault_codes_string) %>)
          </if:IfTrue>
          order by pda_lookup.display_order, pda_lookup.comp_code
        </sql:query>
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
              <%-- 19/05/2010  TW  If nothing selected yet then highlight the current fault code selection --%>
              <if:IfTrue cond='<%= changeFaultLookupBean.getLookup_code().equals("") %>' >
                <if:IfTrue cond='<%= ((String)pageContext.getAttribute("lookup_code")).trim().equals(recordBean.getComp_code()) %>' >
                  <input type="radio" name="lookup_code" id="<sql:getColumn position="1" />" value="<sql:getColumn position="1" />"  checked="checked" />
                </if:IfTrue>
                <if:IfTrue cond='<%= ! ((String)pageContext.getAttribute("lookup_code")).trim().equals(recordBean.getComp_code()) %>' >
                  <input type="radio" name="lookup_code" id="<sql:getColumn position="1" />"  value="<sql:getColumn position="1" />" />
                </if:IfTrue>
              </if:IfTrue>
              <%-- 19/05/2010  TW  If something has been selected then highlight the new selection --%>
              <if:IfTrue cond='<%= ! changeFaultLookupBean.getLookup_code().equals("") %>' >
                <if:IfTrue cond='<%= ((String)pageContext.getAttribute("lookup_code")).trim().equals(changeFaultLookupBean.getLookup_code()) %>' >
                  <input type="radio" name="lookup_code" id="<sql:getColumn position="1" />" value="<sql:getColumn position="1" />"  checked="checked" />
                </if:IfTrue>
                <if:IfTrue cond='<%= ! ((String)pageContext.getAttribute("lookup_code")).trim().equals(changeFaultLookupBean.getLookup_code()) %>' >
                  <input type="radio" name="lookup_code" id="<sql:getColumn position="1" />"  value="<sql:getColumn position="1" />" />
                </if:IfTrue>
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

    <%-- 11/05/2010  TW  New conditional button text--%>
    <% int complaint_no = Integer.parseInt(recordBean.getComplaint_no()); %>
    <% boolean isInDiry = false; %>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <sql:query>
        select date_due
        from diry
        where source_flag = 'C'
        and   source_ref = '<%= complaint_no %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getDate position="1" to="date_due" format="<%= application.getInitParameter("db_date_fmt") %>" />
        <sql:wasNotNull>
          <% isInDiry = true; %>
        </sql:wasNotNull>
      </sql:resultSet>

      <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("I") && isInDiry == true %>' >
        <jsp:include page="include/back_inspdate_buttons.jsp" flush="true" />
      </if:IfTrue>
      <if:IfTrue cond='<%= ! ( recordBean.getComp_action_flag().equals("I") && isInDiry == true ) %>' >
        <jsp:include page="include/back_finish_buttons.jsp" flush="true" />
      </if:IfTrue>
    </sql:statement>
    <sql:closeConnection conn="con"/>
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="changeFaultLookup" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
