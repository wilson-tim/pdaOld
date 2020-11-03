<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.changeTraderBean, com.vsb.recordBean, com.vsb.helperBean" %>
<%@ page import="com.db.PagingBean" %>

<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"       prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0"     prefix="sess" %>
<%@ taglib uri="http://java.sun.com/jstl/xml"                      prefix="x" %>
<%@ taglib uri="http://java.sun.com/jstl/core"                     prefix="c"    %>

<jsp:useBean id="changeTraderBean" scope="session" class="com.vsb.changeTraderBean" />
<jsp:useBean id="recordBean"    scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean"    scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="changeTraderPagingBean" scope="session" class="com.db.PagingBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at beginning --%>
<sess:equalsAttribute name="form" match="changeTrader" value="false">
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
  <meta name = "viewport" content = "width = device-width"/>

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
  <title>changeTrader</title>
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
  <form onSubmit="return singleclick();" action="changeTraderScript.jsp" method="post">
    <%-- Title --%>
    <table width="100%">
      <tr>
        <td><h2>Select Trader</h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="changeTraderBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>      
    </table>

    <%-- If not empty --%>
    <if:IfTrue cond='<%= changeTraderPagingBean.getRecordCount() != 0 %>' >
      <jsp:include page="include/rowset_nav_buttons.jsp" flush="true" />
    </if:IfTrue>

    <%-- If not empty --%>
    <table width="100%">
      <%-- Paging position --%>
      <if:IfTrue cond='<%= changeTraderPagingBean.getRecordCount() != 0 %>' >
        <tr>
          <td colspan="4">
            <span class="subscript">records <%= changeTraderPagingBean.getMinRecordInPage() %> - <%= changeTraderPagingBean.getMaxRecordInPage() %> of <%= changeTraderPagingBean.getRecordCount() %></span>
          </td>
        </tr>
      </if:IfTrue>
      <tr><td><hr size="1" noshade="noshade" /></td></tr>
    </table>

    <if:IfTrue cond='<%= changeTraderPagingBean.getRecordCount() != 0 %>' >
      <table width="100%">
        <%-- Trader List start --%>
        <% for (int i = changeTraderPagingBean.getMinRecordInPage(); i <= changeTraderPagingBean.getMaxRecordInPage(); ++i){ %>
          <c:set var="i"><%= i %></c:set>

          <x:set var="traderRecord" select="$tradersList//element[position()=$i]" />

          <%-- trader_ref --%>
          <c:set var="trader_ref" ><x:out select="$traderRecord//trader_ref" /></c:set>
          <% String trader_ref = (String)pageContext.getAttribute("trader_ref"); %>

          <%-- trader_name radio button and banner line --%>
          <%-- Check for current trader --%>
          <% String bgcolour = "orange"; %>
          <if:IfTrue cond='<%= trader_ref.equals(recordBean.getTrader_ref()) %>' >
            <% bgcolour = "#259225"; %>
          </if:IfTrue>
          <tr bgcolor="<%= bgcolour %>">
            <td valign="top" width="10%">
              <if:IfTrue cond='<%= trader_ref.equals(changeTraderBean.getTrader_ref()) %>' >
                <input type="radio" name="trader_ref" id="<%= trader_ref %>"
                  value="<%= trader_ref %>" checked="checked" />
              </if:IfTrue>
              <if:IfTrue cond='<%= ! trader_ref.equals(changeTraderBean.getTrader_ref()) %>' >
                <input type="radio" name="trader_ref" id="<%= trader_ref %>"
                  value="<%= trader_ref %>" />
              </if:IfTrue>
              </font>
            </td>

            <td valign="top" colspan="2">
              <font color="white">
              <label for="<%= trader_ref %>"><b>&nbsp;<x:out select="$traderRecord/trader_name" />&nbsp;</b></label>
              </font>
            </td>

            <c:set var="compliant_yn"><x:out select="$traderRecord/compliant_yn" /></c:set>
            <% String compliant_yn = (String)pageContext.getAttribute("compliant_yn"); %>
            <if:IfTrue cond='<%= compliant_yn.equals("Y") %>' >
              <td valign="top" bgcolor="#259225">
                <font color="white">
                <label for="<%= trader_ref %>"><b>&nbsp;Compliant&nbsp;</b></label>
                </font>
              </td>
            </if:IfTrue>
            <if:IfTrue cond='<%= !compliant_yn.equals("Y") %>' >
              <td valign="top" bgcolor="#ff6565">
                <font color="white">
                <label for="<%= trader_ref %>"><b>&nbsp;Not Compliant&nbsp;</b></label>
                </font>
              </td>
            </if:IfTrue>
          </tr>

          <%-- contact --%>
          <tr bgcolor="#ffffff">
            <td><b>Contact</b></td>
            <td colspan="3"><x:out select="$traderRecord/contact_name" /></td>
          </tr>

          <%-- telephone --%>
          <tr bgcolor="#ecf5ff">
            <td><b>Telephone</b></td>
            <td><x:out select="$traderRecord/contact_tel" /></td>
            <td><b>Mobile</b></td>
            <td><x:out select="$traderRecord/contact_mobile" /></td>
          </tr>

          <%-- site_name_1 --%>
          <% String site_name   = ""; %>
          <% String site_name_1 = ""; %>
          <% String site_name_2 = ""; %>
          <c:set var="site_name_1"><x:out select="$traderRecord/trader_site_name_1" /></c:set>
          <% site_name_1 = (String)pageContext.getAttribute("site_name_1"); %>
          <c:set var="site_name_2"><x:out select="$traderRecord/trader_site_name_2" /></c:set>
          <% site_name_2 = (String)pageContext.getAttribute("site_name_2"); %>
          <%
          site_name = site_name_1;
          if (!site_name_1.equals("") & !site_name_2.equals("")) {
            site_name = site_name + " " + site_name_2;
          }
          %>
          <tr bgcolor="#ffffff">
            <td><label for="<%= trader_ref %>"><b>Address</b></label></td>
            <td colspan="3"><label for="<%= trader_ref %>"><%= site_name %></label></td>
          </tr>

          <%-- Reason for non-compliance --%>
          <if:IfTrue cond='<%= !compliant_yn.equals("Y") %>' >
            <tr bgcolor="#ecf5ff">
              <td><label for="<%= trader_ref %>"><b>Not compliant</b></label></td>
              <td colspan="3"><label for="<%= trader_ref %>"><x:out select="$traderRecord/non_alloc_reason" /></label></td>
            </tr>
          </if:IfTrue>

          <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>
        <% } %>
        <%-- Trader List end --%>
      </table>
    </if:IfTrue>

    <table width="100%">
      <%-- If there are no traders found --%>
      <if:IfTrue cond='<%= changeTraderPagingBean.getRecordCount() == 0 %>' >
        <tr
          <td colspan="4">
            <b>No traders found</b>
          </td>
        </tr>
      </if:IfTrue>

      <%-- If not empty --%>
      <if:IfTrue cond='<%= changeTraderPagingBean.getRecordCount() != 0 %>' >
        <tr>
          <td colspan="4">
            <span class="subscript">records <%= changeTraderPagingBean.getMinRecordInPage() %> - <%= changeTraderPagingBean.getMaxRecordInPage() %> of <%= changeTraderPagingBean.getRecordCount() %></span>
          </td>
        </tr>
      </if:IfTrue>
    </table>

    <%-- If not empty --%>
    <if:IfTrue cond='<%= changeTraderPagingBean.getRecordCount() != 0 %>' >
      <jsp:include page="include/rowset_nav_buttons.jsp" flush="true" />
    </if:IfTrue>

    <jsp:include page="include/back_continue_buttons.jsp" flush="true" />
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="page_number" value="<%= changeTraderPagingBean.getCurrentPageNum() %>" />
    <input type="hidden" name="input" value="changeTrader" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>

</html>
