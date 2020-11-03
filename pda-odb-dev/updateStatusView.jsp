<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.locLookupBean, com.vsb.updateStatusBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="locLookupBean" scope="session" class="com.vsb.locLookupBean" />
<jsp:useBean id="updateStatusBean" scope="session" class="com.vsb.updateStatusBean" />
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
<sess:equalsAttribute name="form" match="updateStatus" value="false">
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
  <title>updateStatus</title>
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
  <form onSubmit="return singleclick();" action="updateStatusScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Update Status</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="updateStatusBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table width="100%">
      <tr>
        <td>&nbsp;</td>
        <%-- Do we care about any printing errors? --%>
        <app:equalsInitParameter name="show_printing_errors" match="Y">
          <if:IfTrue cond='<%= recordBean.getPrinting_error().equals("ok") %>' >
             <td><b>The action was carried out successfully. </b></td>
          </if:IfTrue>
          <if:IfTrue cond='<%= ! recordBean.getPrinting_error().equals("ok") %>' >
             <td><b>There was a printing error and the requested report has not been printed, but the database action was carried out successfully.</b></td>
          </if:IfTrue>
        </app:equalsInitParameter>
        <app:equalsInitParameter name="show_printing_errors" match="N">
           <td><b>The action was carried out successfully. </b></td>
        </app:equalsInitParameter>
        <td>&nbsp;</td>
      </tr>
      <%-- If a new complaint has been added then show the complaint no. --%>
      <if:IfTrue cond='<%= recordBean.getComingFromSchedComp().equals("Y") && ! recordBean.getComplaint_no().equals("") %>' >
        <tr>
          <td>&nbsp;</td>
          <td><b>The new request number is: </b><%= recordBean.getComplaint_no() %></td>
          <td>&nbsp;</td>
        </tr>
      </if:IfTrue>
    </table>

    <%-- 03/08/2010  TW  New condition --%>
    <%-- Enforcements - action button to allow input of further action / status --%>
    <if:IfTrue cond='<%= recordBean.getEnf_list_flag().equals("Y") %>' >
      <%-- Populate the required fields for the Enf_list route --%>
      <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con1">
        <%-- From enfList form --%>
        <sql:query>
          SELECT suspect_ref, action_seq
            FROM comp_enf
           WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="suspect_ref" />
          <% recordBean.setEnf_list_suspect_ref((String) pageContext.getAttribute("suspect_ref")); %>
          <sql:wasNull>
            <% recordBean.setEnf_list_suspect_ref(""); %>
          </sql:wasNull>
          <sql:getColumn position="2" to="action_seq" />
          <% recordBean.setEnf_list_action_seq((String) pageContext.getAttribute("action_seq")); %>
          <sql:wasNull>
            <% recordBean.setEnf_list_action_seq(""); %>
          </sql:wasNull>
        </sql:resultSet>
      </sql:statement>
      <sql:closeConnection conn="con1"/>
      <%-- Only show button if there is an action for this enforcement --%>
      <if:IfTrue cond='<%= ! recordBean.getEnf_list_action_seq().equals("") %>' >
        <table width="100%">
          <tr><td>&nbsp;</td></tr>
          <tr>
            <td>
              <b><input type="submit" name="action" value="Add Action/Status"
                style="font-weight:bold; width: 14em; font-size: 85%" /></b>
            </td>
          </tr>
        </table>
      </if:IfTrue>
      <%-- Only show button if there is a suspect for this enforcement --%>
      <if:IfTrue cond='<%= recordBean.getEnf_list_action_seq().equals("") %>' >
        <if:IfTrue cond='<%= ! recordBean.getEnf_list_suspect_ref().equals("") %>' >
          <table width="100%">
            <tr><td>&nbsp;</td></tr>
            <tr>
              <td>
                <b><input type="submit" name="action" value="Add Action/Status"
                  style="font-weight:bold; width: 14em; font-size: 85%" /></b>
              </td>
            </tr>
          </table>
        </if:IfTrue>
      </if:IfTrue>
    </if:IfTrue>

    <%-- Show the normal OK button if not coming from the sched/comp route otherwise show the --%>
    <%-- two buttons to allow a new property complaint or use the same property again for the next --%>
    <%-- complaint. --%>
    <if:IfTrue cond='<%= ! recordBean.getComingFromSchedComp().equals("Y") %>' >
      <jsp:include page="include/ok_button.jsp" flush="true" />
    </if:IfTrue>
    <if:IfTrue cond='<%= recordBean.getComingFromSchedComp().equals("Y") %>' >
      <%-- Only property sites have the option to create a new complaint, --%>
      <%-- Trade sites don't get the option. --%>
      <if:IfTrue cond='<%= locLookupBean.getAction().equals("Agreement") %>' >
        <jsp:include page="include/ok_button.jsp" flush="true" />
      </if:IfTrue>
      <if:IfTrue cond='<%= ! locLookupBean.getAction().equals("Agreement") %>' >
        <jsp:include page="include/menu_complaint_buttons.jsp" flush="true" />
      </if:IfTrue>
    </if:IfTrue>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="updateStatus" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
