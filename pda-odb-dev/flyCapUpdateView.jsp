<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.flyCapUpdateBean, com.vsb.helperBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="flyCapUpdateBean" scope="session" class="com.vsb.flyCapUpdateBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />
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
<sess:equalsAttribute name="form" match="flyCapUpdate" value="false">
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
  <title>flyCapUpdate</title>
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
  <form onSubmit="return singleclick();" action="flyCapUpdateScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Fly Capture Details</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="flyCapUpdateBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table width="100%">
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
      <sql:statement id="stmt" conn="con">
      <tr><td><b>Land Type</b></td></tr>
      <tr>
        <td>
          <select name="land_type" size="4">
            <option value="" selected="selected" ></option>
            <sql:query>
              select lookup_code, lookup_text
              from allk
              where lookup_func = 'FCLAND'
              and   status_yn = 'Y'
              order by lookup_text
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="lookup_code" />
              <sql:getColumn position="2" to="lookup_text" />
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("lookup_code")).trim().equals(flyCapUpdateBean.getLand_type()) %>' >
                <option value="<sql:getColumn position="1" />" selected="selected" >
                  <%= helperBean.restrict(((String)pageContext.getAttribute("lookup_text")).trim(),25) %>
                </option>
              </if:IfTrue>
              <if:IfTrue cond='<%= ! ((String)pageContext.getAttribute("lookup_code")).trim().equals(flyCapUpdateBean.getLand_type()) %>' >
                <option value="<sql:getColumn position="1" />">
                  <%= helperBean.restrict(((String)pageContext.getAttribute("lookup_text")).trim(),25) %>
                </option>
              </if:IfTrue>
            </sql:resultSet>
          </select>
        </td>
      </tr>
      <tr><td><hr size="1" noshade="noshade" /></td></tr>
      <tr><td><b>Load Size</b></td></tr>
      <tr><td>&nbsp;</td></tr>
      <tr><td>Description|Cost|Qty</td></tr>
      <tr>
        <td>
          <select name="load_size" size="4">
            <option value="" selected="selected" ></option>
            <sql:query>
              select load_ref, load_desc, unit_cost, default_qty, sequence
              from fly_loads
              order by sequence
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="load_ref" />
              <sql:getColumn position="2" to="load_desc" />
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("load_ref")).trim().equals(flyCapUpdateBean.getLoad_size()) %>' >
                <option value="<sql:getColumn position="1" />" selected="selected" >
                  <%= helperBean.restrict(((String)pageContext.getAttribute("load_desc")).trim(),18) %>|<sql:getColumn position="3" />|<sql:getColumn position="4" />
                </option>
              </if:IfTrue>
              <if:IfTrue cond='<%= ! ((String)pageContext.getAttribute("load_ref")).trim().equals(flyCapUpdateBean.getLoad_size()) %>' >
                <option value="<sql:getColumn position="1" />">
                  <%= helperBean.restrict(((String)pageContext.getAttribute("load_desc")).trim(),18) %>|<sql:getColumn position="3" />|<sql:getColumn position="4" />
                </option>
              </if:IfTrue>
            </sql:resultSet>
          </select>
        </td>
      </tr>
      <tr>
        <td>
          <b>Quantity</b>&nbsp;
          <if:IfTrue cond='<%= flyCapUpdateBean.getLoad_qty().equals("") %>' >
            <input type="text" name="load_qty" size="4" value="" />
          </if:IfTrue>
          <if:IfTrue cond='<%= ! flyCapUpdateBean.getLoad_qty().equals("") %>' >
            <input type="text" name="load_qty" size="4"
              value="<jsp:getProperty name="flyCapUpdateBean" property="load_qty" />" />
          </if:IfTrue>
        </td>
      </tr>
      <tr><td><hr size="1" noshade="noshade" /></td></tr>
      <tr><td><b>Dominant Waste Type</b></td></tr>
      <tr>
        <td>
          <select name="dom_waste_type" size="4">
            <option value="" selected="selected" ></option>
            <sql:query>
              select lookup_code, lookup_text
              from allk
              where lookup_func = 'FCWSTE'
              and   status_yn = 'Y'
              order by lookup_text
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="lookup_code" />
              <sql:getColumn position="2" to="lookup_text" />
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("lookup_code")).trim().equals(flyCapUpdateBean.getDom_waste_type()) %>' >
                <option value="<sql:getColumn position="1" />" selected="selected" >
                  <%= helperBean.restrict(((String)pageContext.getAttribute("lookup_text")).trim(),25) %>
                </option>
              </if:IfTrue>
              <if:IfTrue cond='<%= !((String)pageContext.getAttribute("lookup_code")).trim().equals(flyCapUpdateBean.getDom_waste_type()) %>' >
                <option value="<sql:getColumn position="1" />">
                  <%= helperBean.restrict(((String)pageContext.getAttribute("lookup_text")).trim(),25) %>
                </option>
              </if:IfTrue>
            </sql:resultSet>
          </select>
        </td>
      </tr>
      <tr>
        <td>
          <b>Quantity</b>&nbsp;
          <if:IfTrue cond='<%= flyCapUpdateBean.getDom_waste_qty().equals("") %>' >
            <input type="text" name="dom_waste_qty" size="4" value="" />
          </if:IfTrue>
          <if:IfTrue cond='<%= ! flyCapUpdateBean.getDom_waste_qty().equals("") %>' >
            <input type="text" name="dom_waste_qty" size="4"
              value="<jsp:getProperty name="flyCapUpdateBean" property="dom_waste_qty" />" />
          </if:IfTrue>
        </td>
      </tr>
      </sql:statement>
      <sql:closeConnection conn="con"/>
    </table>
    <jsp:include page="include/back_wo_default_finish_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="flyCapUpdate" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
