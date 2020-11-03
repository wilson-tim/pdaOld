<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="surveyConfirmBean" scope="session" class="com.vsb.surveyConfirmBean" />
<jsp:useBean id="surveyGradingBean" scope="session" class="com.vsb.surveyGradingBean" />
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
<sess:equalsAttribute name="form" match="surveyConfirm" value="false">
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
  <title>surveyConfirm</title>
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
  <form onSubmit="return singleclick();" action="surveyConfirmScript.jsp" method="post">
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
    <table width="100%" border="0">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Survey Details</b></font></h2>
        </td>
      </tr>
      <%-- Inform the user that a default has been added --%>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="surveyConfirmBean" property="error" /></b></font></td></tr>
      <tr><td align="center">
        <table width="90%">
          <tr><td align="center"><strong>
            <%= helperBean.displayString(recordBean.getBv_site_name_1()) %>
          </strong></td></tr>
        </table>
      </td></tr>
      <tr><td><hr size="1" noshade="noshade" /></td></tr>

      <tr bgcolor="#eeeeee"><td align="center"><strong>Transect</strong></td></tr>

      <if:IfTrue cond='<%= recordBean.getBv_transect_method().equals("01") %>' >
      <tr bgcolor="#eeeeee">
        <td colspan="2" align="center">
          <b>by Street Furniture</b>
        </td>
      </tr>
      </if:IfTrue>
      <if:IfTrue cond='<%= recordBean.getBv_transect_method().equals("02") %>' >
      <tr bgcolor="#eeeeee">
        <td colspan="2" align="center">
           <b>by House Number</b>
        </td>
      </tr>
      </if:IfTrue>
      <if:IfTrue cond='<%= recordBean.getBv_transect_method().equals("03") %>' >
      <tr bgcolor="#eeeeee">
        <td colspan="2" align="center">
          <b>by Text</b>
        </td>
      </tr>
      </if:IfTrue>
      <tr><td>
        <table align="center" width="90%">
          <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
          <if:IfTrue cond='<%= recordBean.getBv_transect_method().equals("01") %>' >
            <tr>
              <td>
                <b>Start:</b>
              </td>
              <td align="right">
                <%= helperBean.displayString(recordBean.getBv_start_post())%>
              </td>
            </tr>
            <tr>
              <td>
                <b>End:</b>
              </td>
              <td align="right">
                <%= helperBean.displayString(recordBean.getBv_stop_post())%>
              </td>
            </tr>
          </if:IfTrue>
          <if:IfTrue cond='<%= recordBean.getBv_transect_method().equals("02") %>' >
            <tr>
              <td>
                <b>Start:</b>
              </td>
              <td>
                <%= helperBean.displayString(recordBean.getBv_start_house())%>
              </td>
            </tr>
            <tr>
              <td>
                <b>End:</b>
              </td>
              <td>
                <%= helperBean.displayString(recordBean.getBv_stop_house())%>
              </td>
            </tr>
          </if:IfTrue>
          <if:IfTrue cond='<%= recordBean.getBv_transect_method().equals("03") %>' >
            <tr>
              <td colspan="2">
                <%= helperBean.displayString(recordBean.getBv_transect_desc())%>
              </td>
            </tr>
          </if:IfTrue>
          <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
        </table>
      </td></tr>

      <tr bgcolor="#eeeeee"><td align="center"><strong>Land Use</strong></td></tr>
      <sql:query>
        select lookup_text
        from allk
        where lookup_func = 'BVLAND'
        and lookup_code = '<%= recordBean.getBv_land_use() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="bv_land_use" />
      </sql:resultSet>
      <tr bgcolor="#ecf5ff"><td align="center"><strong><%= (String)pageContext.getAttribute("bv_land_use") %></strong></td></tr>
      <if:IfTrue cond='<%= recordBean.getBv_lowdensity_flag().equals("Y") %>'>
        <tr><td align="center"><i>Low Density</i></td></tr>
      </if:IfTrue>
      <if:IfTrue cond='<%= recordBean.getBv_ward_flag().equals("Y") %>'>
        <tr><td align="center"><i>Outside Ward</i></td></tr>
      </if:IfTrue>
      <tr><td>&nbsp;</td></tr>

      <tr bgcolor="#eeeeee"><td align="center"><strong>Transect Grading</strong></td></tr>

        <sql:query>
          select lookup_text
          from allk
          where lookup_func = 'BVGRAD'
          and lookup_code = '<%= recordBean.getBv_litter_grade() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="litter_grade" />
        </sql:resultSet>

        <sql:query>
          select lookup_text
          from allk
          where lookup_func = 'BVGRAD'
          and lookup_code = '<%= recordBean.getBv_detritus_grade() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="detritus_grade" />
        </sql:resultSet>

        <sql:query>
          select lookup_text
          from allk
          where lookup_func = 'BVGRAD'
          and lookup_code = '<%= recordBean.getBv_graffiti_grade() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="graffiti_grade" />
        </sql:resultSet>

        <sql:query>
          select lookup_text
          from allk
          where lookup_func = 'BVGRAD'
          and lookup_code = '<%= recordBean.getBv_fly_posting_grade() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="fly_posting_grade" />
        </sql:resultSet>
      <tr><td>
        <table align="center" width="85%" cellspacing="0" cellpadding="0">
          <tr bgcolor="#ecf5ff">
            <if:IfTrue cond='<%= surveyGradingBean.isLitter_defaulted() %>'>
              <td><strong>Litter (<app:initParameter name="def_name_past" />)</strong></td>
            </if:IfTrue>
            <if:IfTrue cond='<%= !surveyGradingBean.isLitter_defaulted() %>'>
              <td><strong>Litter</strong></td>
            </if:IfTrue>
            <td><strong><%= (String)pageContext.getAttribute("litter_grade") %></strong></td>
          </tr>
          <tr><td colspan="2"><%= helperBean.displayString(recordBean.getBv_litter_text()) %></td></tr>
          <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
          <tr bgcolor="#ecf5ff">
            <if:IfTrue cond='<%= surveyGradingBean.isDetrit_defaulted() %>'>
              <td><strong>Detritus (<app:initParameter name="def_name_past" />)</strong></td>
            </if:IfTrue>
            <if:IfTrue cond='<%= !surveyGradingBean.isDetrit_defaulted() %>'>
              <td><strong>Detritus</strong></td>
            </if:IfTrue>
            <td><strong><%= (String)pageContext.getAttribute("detritus_grade") %></strong></td>
          </tr>
          <tr><td colspan="2"><%= helperBean.displayString(recordBean.getBv_detritus_text()) %></td></tr>
          <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
          <tr bgcolor="#ecf5ff">
            <if:IfTrue cond='<%= surveyGradingBean.isGrafft_defaulted() %>'>
              <td><strong>Graffiti (<app:initParameter name="def_name_past" />)</strong></td>
            </if:IfTrue>
            <if:IfTrue cond='<%= !surveyGradingBean.isGrafft_defaulted() %>'>
              <td><strong>Graffiti</strong></td>
            </if:IfTrue>
            <td><strong><%= (String)pageContext.getAttribute("graffiti_grade") %></strong></td>
          </tr>
          <tr><td colspan="2"><%= helperBean.displayString(recordBean.getBv_graffiti_text()) %></td></tr>
          <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
          <tr bgcolor="#ecf5ff">
            <if:IfTrue cond='<%= surveyGradingBean.isFlypos_defaulted() %>'>
              <td><strong>Fly Posting (<app:initParameter name="def_name_past" />)</strong></td>
            </if:IfTrue>
            <if:IfTrue cond='<%= !surveyGradingBean.isFlypos_defaulted() %>'>
              <td><strong>Fly Posting</strong></td>
            </if:IfTrue>
            <td><strong><%= (String)pageContext.getAttribute("fly_posting_grade") %></strong></td>
          </tr>
          <tr><td colspan="2"><%= helperBean.displayString(recordBean.getBv_fly_posting_text()) %></td></tr>
          <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
        </table>
      </td></tr>
      <tr bgcolor="#eeeeee"><td align="center"><strong>Additional Comments</strong></td></tr>
      <tr><td>
        <table align="center" width="90%">
          <tr><td>
              <textarea cols="18" rows="3" name="survey_text"><%= helperBean.displayString(surveyConfirmBean.getSurvey_text())%></textarea>
          </td></tr>
        </table>
      </td></tr>
    </table>
    <jsp:include page="include/back_submit_buttons.jsp" flush="true" />
    <%-- If we have already defaulted a BV199 item do not allow the user to exit --%>
    <if:IfTrue cond='<%= !surveyGradingBean.isAnyFlagDefaulted() %>'>
      <%@ include file="include/insp_sched_buttons.jsp" %>
    </if:IfTrue>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="surveyConfirm" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />

    </sql:statement>
    <sql:closeConnection conn="con"/>

  </form>
</body>
</html>
