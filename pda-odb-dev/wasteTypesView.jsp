<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.wasteTypesBean, com.vsb.helperBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="wasteTypesBean" scope="session" class="com.vsb.wasteTypesBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="wasteTypes" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

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
  <title>wasteTypes</title>
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
  <form onSubmit="return singleclick();" action="wasteTypesScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Additional Waste Types</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="wasteTypesBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <% String color="#ffffff"; %>
    <table cellpadding="2" cellspacing="0" width="100%">
      <%-- Get the waste types --%>
      <% String[] waste_types = wasteTypesBean.getWaste_types(); %>
      <% String[] waste_qtys = wasteTypesBean.getWaste_qtys(); %>
      <% int i = 0; %>
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
      <sql:statement id="stmt" conn="con">
        <sql:query>
          select lookup_code, lookup_text
          from allk
          where lookup_func = 'FCWSTE'
          and   lookup_code <> '<%= recordBean.getDom_waste_type() %>'
          and   status_yn = 'Y'
          order by lookup_code
         </sql:query>
        <sql:resultSet id="rset">
          <% 
            if(color=="#ffffff") {
              color = "#ecf5ff";
            } else if (color=="#ecf5ff") {
              color = "#ffffff";
            }
          %>
          <sql:getColumn position="2" to="lookup_text" />
          <tr bgcolor="<%= color %>" >
            <td width="10">
              <sql:getColumn position="1" to="lookup_code" />
              <if:IfTrue cond='<%= waste_types != null %>' >
                <if:IfTrue cond='<%= pageContext.getAttribute("lookup_code").equals(waste_types[i]) %>' >
                  <input type="checkbox" name="waste_types"  value="<sql:getColumn position="1" />"  checked="checked" />
                </if:IfTrue>
                <if:IfTrue cond='<%= !pageContext.getAttribute("lookup_code").equals(waste_types[i]) %>' >
                  <input type="checkbox" name="waste_types"  value="<sql:getColumn position="1" />" />
                </if:IfTrue>
              </if:IfTrue>
              <if:IfTrue cond='<%= waste_types == null %>' >
                <input type="checkbox" name="waste_types"  value="<sql:getColumn position="1" />" />
              </if:IfTrue>
              <input type="hidden" name="waste_type_list" value="<sql:getColumn position="1" />" /> 
            </td>
            <td>
              <b><sql:getColumn position="1" /></b>
            </td>
            <td>
              <b>Qty&nbsp;</b>
              <if:IfTrue cond='<%= waste_qtys != null %>' >
                <input type="text" name="waste_qtys" size="4" 
                  value="<%= waste_qtys[i] %>" />
              </if:IfTrue>
              <if:IfTrue cond='<%= waste_qtys == null %>' >
                <input type="text" name="waste_qtys" size="4" value="0" />
              </if:IfTrue>
            </td>
          </tr>
          <tr bgcolor="<%= color %>" >
            <td>&nbsp;</td>
            <td colspan="2">
              <%= helperBean.restrict(((String)pageContext.getAttribute("lookup_text")).trim(),25) %>
            </td>
          </tr>
          <% i = i + 1; %>
        </sql:resultSet>
        <sql:wasEmpty>
          <tr>
           <td colspan="3">
             <b>No codes available</b>
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
    <%-- If the action is works order, don't allow the enforcement to be picked --%>
    <%-- and make sure the user cannot skip the works order section --%>
    <if:IfTrue cond='<%= recordBean.getAction_flag().equals("W") %>' >
      <jsp:include page="include/back_wo_buttons.jsp" flush="true" />
    </if:IfTrue>
    <if:IfTrue cond='<%= ! recordBean.getAction_flag().equals("W") %>' >
      <jsp:include page="include/back_enforce_addtext_buttons.jsp" flush="true" />
    </if:IfTrue>
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="wasteTypes" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
