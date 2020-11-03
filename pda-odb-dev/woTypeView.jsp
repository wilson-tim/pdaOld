<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.woTypeBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="woTypeBean" scope="session" class="com.vsb.woTypeBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="woType" value="false">
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
  <title>Type and Contact</title>
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
  <form onSubmit="return singleclick();" action="woTypeScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Type and Contact</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="woTypeBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table width="100%">
      <tr>
        <td>
          <b>Type</b>
        </td>
        <td>
          <select name="wo_type_f">
            <option value="" selected="selected" ></option>
            <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
            <sql:statement id="stmt" conn="con">
              <sql:query>
                <app:equalsInitParameter name="limit_wo_type_by_suffix" match="Y">
                  select wo_type.wo_type_f, wo_type.wo_type_desc
                  from wo_type, wo_s
                  where wo_type.contract_ref = '<%= recordBean.getWo_contract_ref() %>'
                  and wo_s.wo_suffix = '<%= recordBean.getWo_suffix() %>'
                  and wo_type.contract_ref = wo_s.contract_ref
                  and wo_type.wo_type_f = wo_s.wo_type_f
                  order by wo_type.wo_type_desc
                </app:equalsInitParameter>
                <app:equalsInitParameter name="limit_wo_type_by_suffix" match="Y" value="false">
                  select wo_type.wo_type_f, wo_type.wo_type_desc
                  from wo_type
                  where wo_type.contract_ref = '<%= recordBean.getWo_contract_ref() %>'
                  order by wo_type.wo_type_desc
                </app:equalsInitParameter>
              </sql:query>
              <sql:resultSet id="rset">
                <sql:getColumn position="1" to="wo_type_f" />
                <if:IfTrue cond='<%= pageContext.getAttribute("wo_type_f") != null && !(((String) pageContext.getAttribute("wo_type_f")).trim().equals("")) %>' >
                  <if:IfTrue cond='<%= ((String)pageContext.getAttribute("wo_type_f")).trim().equals(woTypeBean.getWo_type_f()) %>' >
                    <option value="<sql:getColumn position="1" />" selected="selected" ><sql:getColumn position="2" /></option>
                  </if:IfTrue>
                  <if:IfTrue cond='<%= !((String)pageContext.getAttribute("wo_type_f")).trim().equals(woTypeBean.getWo_type_f()) %>' >
                    <option value="<sql:getColumn position="1" />"><sql:getColumn position="2" /></option>
                  </if:IfTrue>
                </if:IfTrue>
               </sql:resultSet>
            </sql:statement> 
            <sql:closeConnection conn="con"/>
          </select>
        </td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>

      <%-- Get the contact name and phone number --%>
      <tr>
        <td>
          <b>Contact Name</b>
        </td>
        <td>
          <input type="text" name="del_contact" size="15" maxlength="40"
            value="<jsp:getProperty name="woTypeBean" property="del_contact" />" />
        </td>
      </tr>
      <tr>
        <td>
          <b>Tel. No.</b>
        </td>
        <td>
          <input type="text" name="del_phone" size="15" maxlength="20"
            value="<jsp:getProperty name="woTypeBean" property="del_phone" />" />
        </td>
      </tr>
    </table>

    <jsp:include page="include/back_next_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="woType" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
