<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.defaultDetailsBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="defaultDetailsBean" scope="session" class="com.vsb.defaultDetailsBean" />
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
<sess:equalsAttribute name="form" match="defaultDetails" value="false">
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
  <title>defaultDetails</title>
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
  <form onSubmit="return singleclick();" action="defaultDetailsScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b><app:initParameter name="def_name_noun" /> Details</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="defaultDetailsBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table width="100%">
      <tr>
        <td align="center" colspan="2"><b><jsp:getProperty name="recordBean" property="site_name_1" /></b></td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Item</b></td>
        <td><jsp:getProperty name="recordBean" property="item_ref" /></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td colspan="2"><jsp:getProperty name="recordBean" property="item_desc" /></td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Enquiry Ref.</b></td>
        <td><%= recordBean.getComplaint_no() %></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td colspan="2"><jsp:getProperty name="recordBean" property="comp_desc" /></td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#ecf5ff">
        <td colspan="2">
          <b>Source</b>
        </td>
      </tr>
      <tr bgcolor="#ffffff">
        <td colspan="2"><jsp:getProperty name="recordBean" property="source_desc" /></td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Rectify Date</b></td>
        <td><%= helperBean.dispDate(recordBean.getRectify_date(), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Rectify Time</b></td>
        <td><%= recordBean.getRectify_time_h() %>:<%= recordBean.getRectify_time_m() %></td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Contractor Action</b></td>
        <if:IfTrue cond='<%= recordBean.getDef_action().equals("A") %>' >
          <td>Actioned</td>
        </if:IfTrue>
        <if:IfTrue cond='<%= recordBean.getDef_action().equals("U") %>' >
          <td>Unjustified</td>
        </if:IfTrue>
        <if:IfTrue cond='<%= ! recordBean.getDef_action().equals("A") && ! recordBean.getDef_action().equals("U") %>' >
          <td>&nbsp;</td>
        </if:IfTrue>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Actioned Date</b></td>
        <td><%= helperBean.dispDate(recordBean.getActioned_date(), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Actioned Time</b></td>
        <if:IfTrue cond='<%= ! recordBean.getActioned_time_h().equals("") %>' >
          <td><%= recordBean.getActioned_time_h() %>:<%= recordBean.getActioned_time_m() %></td>
        </if:IfTrue>
        <if:IfTrue cond='<%= recordBean.getActioned_time_h().equals("") %>' >
          <td>&nbsp;</td>
        </if:IfTrue>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Item Volume</b></td>
        <td><%= recordBean.getTotal_volume() %></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Transaction Date</b></td>
        <td><%= helperBean.dispDate(recordBean.getTrans_date(), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Transaction Time</b></td>
        <td><%= recordBean.getTrans_time_h() %>:<%= recordBean.getTrans_time_m() %></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Transaction Flag</b></td>
        <if:IfTrue cond='<%= recordBean.getDef_action_flag().equals("D") %>' >
          <td><app:initParameter name="def_name_past" /></td>
        </if:IfTrue>
        <if:IfTrue cond='<%= recordBean.getDef_action_flag().equals("R") %>' >
          <td>Re-<app:initParameter name="def_name_past" /></td>
        </if:IfTrue>
        <if:IfTrue cond='<%= recordBean.getDef_action_flag().equals("C") %>' >
          <td>Cleared</td>
        </if:IfTrue>
        <if:IfTrue cond='<%= recordBean.getDef_action_flag().equals("Z") %>' >
          <td>Credited</td>
        </if:IfTrue>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Transaction Volume</b></td>
        <td><%= recordBean.getVolume() %></td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr>
        <td bgcolor="#ecf5ff" colspan="2">
          <%-- Get the name for the position field, default to 'Exact Location' --%>
          <% String position = "Exact Location"; %>
          <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
          <sql:statement id="stmt" conn="con">
            <sql:query>
              select c_field
              from keys
              where service_c = 'ALL'
              and   keyname = 'POSITION_TITLE'
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="c_field" />
              <sql:wasNotNull>
                <% position = (String)pageContext.getAttribute("c_field"); %>
              </sql:wasNotNull>
              <sql:wasNull>
                <% position = "Exact Location"; %>
              </sql:wasNull>
            </sql:resultSet>
            <sql:wasEmpty>
              <% position = "Exact Location"; %>
            </sql:wasEmpty>
          </sql:statement>
          <sql:closeConnection conn="con"/>

          <b><%= position %></b>
        </td>
      </tr>
      <tr>
        <if:IfTrue cond='<%= recordBean.getExact_location().equals("") %>' >
          <td colspan="2">&nbsp;</td>
        </if:IfTrue>
        <if:IfTrue cond='<%= ! recordBean.getExact_location().equals("") %>' >
          <td colspan="2"><%= recordBean.getExact_location() %></td>
        </if:IfTrue>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr>
         <td colspan="2">
          <b>Previous Text</b><br/>
          <textarea rows="4" cols="28" name="textOut" readonly="readonly" ><jsp:getProperty name="defaultDetailsBean" property="textOut" /></textarea>
        </td>
      </tr>
       <tr>
         <td colspan="2">
           <if:IfTrue cond='<%= recordBean.getCredit_def_id().equals("Y") %>' >
             <b>Text/Credit Reason</b><br/>
           </if:IfTrue>
          <if:IfTrue cond='<%= ! recordBean.getCredit_def_id().equals("Y") %>' >
             <b>Text</b><br/>
           </if:IfTrue>
          <textarea rows="4" cols="28" name="text" ><jsp:getProperty name="defaultDetailsBean" property="text" /></textarea>
        </td>
      </tr>
      <tr><td>&nbsp;</td></tr>
      <tr>
        <td colspan="2">     
          <b>Action:</b>
          <select name="actionTaken">
            <option selected="selected" ></option>
            <option>Update-Text</option>
            <option>Clear</option>
            <option>Re-<app:initParameter name="def_name_verb" /></option>
            <app:equalsInitParameter name="use_credit" match="Y" >
              <option>Credit</option>
              <option>Credit-All</option>
            </app:equalsInitParameter>
          </select><br/><br/>
        </td>
      </tr>
    </table>
    <%-- Use Map Module --%>
    <%-- Check if we should display the trade details button --%>
    <%-- NOTE: If we end up adding more options here for different services, we should make the trade --%>
    <%-- button a generic services button, and poissibly have a switch to catch each different service. --%>
    <app:equalsInitParameter name="use_map" match="Y" >
      <%-- TRADE Service --%>
      <if:IfTrue cond='<%= recordBean.getService_c().equals( recordBean.getTrade_service() ) %>'>
        <jsp:include page="include/map_trade_cust_buttons.jsp" flush="true" />
        <jsp:include page="include/back_finish_buttons.jsp" flush="true" />
      </if:IfTrue>
      <%-- TREES Service --%>
      <if:IfTrue cond='<%= recordBean.getService_c().equals( recordBean.getTrees_service() ) %>'>
        <jsp:include page="include/map_tree_cust_buttons.jsp" flush="true" />
        <jsp:include page="include/back_finish_buttons.jsp" flush="true" />
      </if:IfTrue>
      <%-- No Special Service--%>
      <if:IfTrue cond='<%= (!(recordBean.getService_c().equals( recordBean.getTrade_service()) )) &&
                           (!(recordBean.getService_c().equals( recordBean.getTrees_service()) )) %>'>
        <jsp:include page="include/map_cust_buttons.jsp" flush="true" />
        <jsp:include page="include/back_finish_buttons.jsp" flush="true" />
      </if:IfTrue>
    </app:equalsInitParameter>
    <%-- Do not show map module button --%>
    <%-- Check if we should display the trade details button --%>        
    <app:equalsInitParameter name="use_map" match="N" >
      <%-- TRADE Service --%>
      <if:IfTrue cond='<%= recordBean.getService_c().equals( recordBean.getTrade_service() ) %>'>
        <jsp:include page="include/cust_trade_buttons.jsp" flush="true" />
        <jsp:include page="include/back_finish_buttons.jsp" flush="true" />      
      </if:IfTrue>
      <%-- TREES Service --%>
      <if:IfTrue cond='<%= recordBean.getService_c().equals( recordBean.getTrees_service() ) %>'>
        <jsp:include page="include/cust_tree_buttons.jsp" flush="true" />
        <jsp:include page="include/back_finish_buttons.jsp" flush="true" />      
      </if:IfTrue>
      <%-- No Special Service--%>
      <if:IfTrue cond='<%= (!(recordBean.getService_c().equals( recordBean.getTrade_service()) )) &&
                           (!(recordBean.getService_c().equals( recordBean.getTrees_service()) )) %>'>
        <jsp:include page="include/back_cust_finish_buttons.jsp" flush="true" />
      </if:IfTrue>
    </app:equalsInitParameter>
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="defaultDetails" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
