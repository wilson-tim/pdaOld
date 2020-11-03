<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.marketsListBean, com.vsb.recordBean, com.vsb.helperBean" %>
<%@ page import="com.db.PagingBean" %>

<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"       prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0"     prefix="sess" %>
<%@ taglib uri="http://java.sun.com/jstl/xml"                      prefix="x" %>
<%@ taglib uri="http://java.sun.com/jstl/core"                     prefix="c"    %>

<jsp:useBean id="marketsListBean" scope="session" class="com.vsb.marketsListBean" />
<jsp:useBean id="recordBean"    scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean"    scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="marketsListPagingBean" scope="session" class="com.db.PagingBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at beginning --%>
<sess:equalsAttribute name="form" match="marketsList" value="false">
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
  <title>marketsList</title>
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
  <form onSubmit="return singleclick();" action="marketsListScript.jsp" method="post">
    <%-- Title --%>
    <table width="100%">
      <tr>
        <td>
          <h2>Markets</h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="marketsListBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>      
    </table>

    <%-- If not empty --%>
    <if:IfTrue cond='<%= marketsListPagingBean.getRecordCount() != 0 %>' >
      <jsp:include page="include/rowset_nav_buttons.jsp" flush="true" />
    </if:IfTrue>

    <%-- If not empty --%>
    <table width="100%">
      <%-- Paging position --%>
      <if:IfTrue cond='<%= marketsListPagingBean.getRecordCount() != 0 %>' >
        <tr>
          <td colspan="2">
            <span class="subscript">records <%= marketsListPagingBean.getMinRecordInPage() %> - <%= marketsListPagingBean.getMaxRecordInPage() %> of <%= marketsListPagingBean.getRecordCount() %></span>
          </td>
        </tr>
        <tr><td><hr size="1" noshade="noshade" /></td></tr>
      </if:IfTrue>
    </table>

    <if:IfTrue cond='<%= marketsListPagingBean.getRecordCount() != 0 %>' >
      <table width="100%">
        <%-- Markets List start --%>
        <% for (int i = marketsListPagingBean.getMinRecordInPage(); i <= marketsListPagingBean.getMaxRecordInPage(); ++i){ %>
          <c:set var="i"><%= i %></c:set>

          <%-- market_ref --%>
          <c:set var="market_ref" ><x:out select="$marketsList//element[position()=$i]/market_ref" /></c:set>
          <% String market_ref = (String)pageContext.getAttribute("market_ref"); %>

          <%-- market_desc radio button and banner line --%>
          <tr bgcolor="orange">
            <td valign="top" width="10%">
              <if:IfTrue cond='<%= market_ref.equals(marketsListBean.getMarket_ref()) %>' >
                <input type="radio" name="market_ref" id="<%= market_ref %>"
                  value="<%= market_ref %>" checked="checked" />
              </if:IfTrue>
              <if:IfTrue cond='<%= ! market_ref.equals(marketsListBean.getMarket_ref()) %>' >
                <input type="radio" name="market_ref" id="<%= market_ref %>"
                  value="<%= market_ref %>" />
              </if:IfTrue>
            </td>
            <td valign="top">
              <label for="<%= market_ref %>"><b>&nbsp;<x:out select="$marketsList//element[position()=$i]/market_desc" />&nbsp;</b></label>
            </td>
          </tr>

          <%-- site_name_1 --%>
          <% String site_name = ""; %>
          <% String site_name_1 = ""; %>
          <% String site_name_2 = ""; %>
          <c:set var="site_name_1"><x:out select="$marketsList//element[position()=$i]/site_name_1" /></c:set>
          <% site_name_1 = (String)pageContext.getAttribute("site_name_1"); %>
          <c:set var="site_name_2"><x:out select="$marketsList//element[position()=$i]/site_name_2" /></c:set>
          <% site_name_2 = (String)pageContext.getAttribute("site_name_2"); %>
          <%
          site_name = site_name_1;
          if (!site_name_1.equals("") & !site_name_2.equals("")) {
            site_name = site_name + " " + site_name_2;
          }
          %>
          <tr bgcolor="#ffffff">
            <td colspan="2"><label for="<%= market_ref %>"><%= site_name %></label></td>
          </tr>

          <%-- market_theme_desc --%>
          <tr bgcolor="#ecf5ff">
            <td><label for="<%= market_ref %>"><b>Market Theme</b></label></td>
            <td><label for="<%= market_ref %>"><x:out select="$marketsList//element[position()=$i]/market_theme_desc" /></label></td>
          </tr>

          <%-- market_type_desc --%>
          <tr bgcolor="#ffffff">
            <td><label for="<%= market_ref %>"><b>Market Type</b></label></td>
            <td><label for="<%= market_ref %>"><x:out select="$marketsList//element[position()=$i]/market_type_desc" /></label></td>
          </tr>

          <%-- next_due_date --%>
          <tr bgcolor="#ecf5ff">
            <c:set var="next_due_date" ><x:out select="$marketsList//element[position()=$i]/next_due_date" /></c:set>
            <% String next_due_date = (String)pageContext.getAttribute("next_due_date");  %>
            <td><label for="<%= market_ref %>"><b>Inspection Due Date</b></label></td>
           <if:IfTrue cond='<%= !next_due_date.equals("") %>' >
              <td><label for="<%= market_ref %>"><%= helperBean.dispDate( next_due_date, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></label></td>
           </if:IfTrue>
           <if:IfTrue cond='<%= next_due_date.equals("") %>' >
              <td><label for="<%= market_ref %>"></td>
           </if:IfTrue>
          </tr>

          <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
        <% } %>
        <%-- Markets List end --%>
      </table>
    </if:IfTrue>

    <table width="100%">
      <%-- If there are no markets found --%>
      <if:IfTrue cond='<%= marketsListPagingBean.getRecordCount() == 0 %>' >
        <tr
          <td colspan="2">
            <b>No markets found</b>
          </td>
        </tr>
      </if:IfTrue>

      <%-- If not empty --%>
      <if:IfTrue cond='<%= marketsListPagingBean.getRecordCount() != 0 %>' >
        <tr>
          <td colspan="2">
            <span class="subscript">records <%= marketsListPagingBean.getMinRecordInPage() %> - <%= marketsListPagingBean.getMaxRecordInPage() %> of <%= marketsListPagingBean.getRecordCount() %></span>
          </td>
        </tr>
      </if:IfTrue>
    </table>

    <%-- If not empty --%>
    <if:IfTrue cond='<%= marketsListPagingBean.getRecordCount() != 0 %>' >
      <jsp:include page="include/rowset_nav_buttons.jsp" flush="true" />
    </if:IfTrue>

    <jsp:include page="include/back_enforce_details_buttons.jsp" flush="true" />
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="page_number" value="<%= marketsListPagingBean.getCurrentPageNum() %>" />
    <input type="hidden" name="input" value="marketsList" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>

</html>
