<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.custDetailsBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="custDetailsBean" scope="session" class="com.vsb.custDetailsBean" />
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
<sess:equalsAttribute name="form" match="custDetails" value="false">
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
  <title>custDetails</title>
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
  <form onSubmit="return singleclick();" action="custDetailsScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Customer Details</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="custDetailsBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table width="100%">
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
      <sql:statement id="stmt" conn="con">
        <sql:query>
          select customer.compl_init, customer.compl_name, customer.compl_surname,
                 customer.compl_phone, customer.compl_email, customer.int_ext_flag,
                 customer.compl_build_no, customer.compl_build_name,
                 customer.compl_addr2, customer.compl_addr4, customer.compl_postcode
          from customer, comp_clink
          where comp_clink.complaint_no = '<%= recordBean.getComplaint_no() %>'
          and   comp_clink.seq_no = (
            select max(seq_no)
            from comp_clink
            where complaint_no = '<%= recordBean.getComplaint_no() %>'
          )
          and customer.customer_no = comp_clink.customer_no
        </sql:query>
        <sql:resultSet id="rset">
          <tr bgcolor="#ecf5ff">
            <td><b>Title</b></td>
            <td><sql:getColumn position="1" /></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td><b>1st name</b></td>
            <td><sql:getColumn position="2" /></td>
          </tr>
          <tr bgcolor="#ecf5ff">
            <td><b>Surname</b></td>
            <td><sql:getColumn position="3" /></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td><b>Tel. No.</b></td>
            <td><sql:getColumn position="4" /></td>
          </tr>
          <tr bgcolor="#ecf5ff">
            <td><b>Email</b></td>
            <td><sql:getColumn position="5" /></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td><b>Int/Ext</b></td>
            <td><sql:getColumn position="6" /></td>
          </tr>
          <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
          <tr bgcolor="#ecf5ff">
            <td><b>House No.</b></td>
            <td><sql:getColumn position="7" /></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td><b>Building Name</b></td>
            <td><sql:getColumn position="8" /></td>
          </tr>
          <tr bgcolor="#ecf5ff">
            <td><b>Street Name</b></td>
            <td><sql:getColumn position="9" /></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td><b>Town</b></td>
            <td><sql:getColumn position="10" /></td>
          </tr>
          <tr bgcolor="#ecf5ff">
            <td><b>Postcode</b></td>
            <td><sql:getColumn position="11" /></td>
          </tr>
        </sql:resultSet>
        <sql:wasEmpty>
          <tr>
             <td colspan="2">
               <b>No customer details available</b>
             </td>
          </tr>
        </sql:wasEmpty>
      </sql:statement>
      <sql:closeConnection conn="con"/>
    </table>
    <jsp:include page="include/back_button.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="custDetails" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
