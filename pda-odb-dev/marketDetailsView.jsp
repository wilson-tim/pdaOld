<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.marketDetailsBean, com.vsb.recordBean, com.vsb.helperBean" %>
<%@ page import="com.db.PagingBean" %>

<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"       prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0"     prefix="sess" %>
<%@ taglib uri="http://java.sun.com/jstl/xml"                      prefix="x" %>
<%@ taglib uri="http://java.sun.com/jstl/core"                     prefix="c"    %>

<jsp:useBean id="marketDetailsBean" scope="session" class="com.vsb.marketDetailsBean" />
<jsp:useBean id="recordBean"    scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean"    scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="marketDetailsPagingBean" scope="session" class="com.db.PagingBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at beginning --%>
<sess:equalsAttribute name="form" match="marketDetails" value="false">
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
  <title>marketDetails</title>
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
  <form onSubmit="return singleclick();" action="marketDetailsScript.jsp" method="post">
    <%-- Title --%>
    <table width="100%">
      <tr>
        <td>
          <c:set var="market_desc"><x:out select="$marketRecord//element/market_desc" /></c:set>
          <% String market_desc = (String)pageContext.getAttribute("market_desc"); %>
          <h2><%= market_desc %></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="marketDetailsBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>      
    </table>

    <% String site_name   = ""; %>
    <% String site_name_1 = ""; %>
    <% String site_name_2 = ""; %>

    <table width="100%">
      <%-- site_name --%>
      <tr>
        <c:set var="site_name_1"><x:out select="$marketRecord//element/site_name_1" /></c:set>
        <% site_name_1 = (String)pageContext.getAttribute("site_name_1"); %>
        <c:set var="site_name_2"><x:out select="$marketRecord//element/site_name_2" /></c:set>
        <% site_name_2 = (String)pageContext.getAttribute("site_name_2"); %>
        <%
        site_name = site_name_1;
        if (!site_name_1.equals("") & !site_name_2.equals("")) {
          site_name = site_name + " " + site_name_2;
        }
        %>
        <td align="center"><b><%= site_name %></b></td>
      </tr>
      <%-- next_due_date --%>
      <tr>
        <c:set var="next_due_date"><x:out select="$marketRecord//element/next_due_date" /></c:set>
        <% String next_due_date = (String)pageContext.getAttribute("next_due_date");  %>
       <if:IfTrue cond='<%= !next_due_date.equals("") %>' >
          <td align="center"><b>Inspection Due Date <%= helperBean.dispDate( next_due_date, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></b></td>
       </if:IfTrue>
      </tr>
    </table>

    <%-- If not empty --%>
    <if:IfTrue cond='<%= marketDetailsPagingBean.getRecordCount() != 0 %>' >
      <sess:equalsAttribute name="sort_order" match="pitch" >
        <jsp:include page="include/sort_order_pitch_buttons.jsp" flush="true" />
      </sess:equalsAttribute>
      <sess:equalsAttribute name="sort_order" match="confirmed" >
        <jsp:include page="include/sort_order_confirmed_buttons.jsp" flush="true" />
      </sess:equalsAttribute>
      <jsp:include page="include/rowset_nav_buttons.jsp" flush="true" />
    </if:IfTrue>

    <%-- If not empty --%>
    <table width="100%">
      <%-- Paging position --%>
      <if:IfTrue cond='<%= marketDetailsPagingBean.getRecordCount() != 0 %>' >
        <tr>
          <td colspan="3">
            <span class="subscript">records <%= marketDetailsPagingBean.getMinRecordInPage() %> - <%= marketDetailsPagingBean.getMaxRecordInPage() %> of <%= marketDetailsPagingBean.getRecordCount() %></span>
          </td>
        </tr>
      </if:IfTrue>
      <tr><td><hr size="1" noshade="noshade" /></td></tr>
    </table>

    <if:IfTrue cond='<%= marketDetailsPagingBean.getRecordCount() != 0 %>' >
      <table width="100%">
        <%-- Pitches List start --%>
        <% for (int i = marketDetailsPagingBean.getMinRecordInPage(); i <= marketDetailsPagingBean.getMaxRecordInPage(); ++i){ %>
          <c:set var="i"><%= i %></c:set>

          <x:set var="pitchRecord" select="$pitchesList//element[position()=$i]" />

          <%-- pitch_no --%>
          <c:set var="pitch_no" ><x:out select="$pitchRecord//pitch_no" /></c:set>
          <% String pitch_no = (String)pageContext.getAttribute("pitch_no"); %>

          <%-- pitch_name radio button and banner line --%>
          <tr bgcolor="orange">
            <td valign="top" width="10%">
              <if:IfTrue cond='<%= pitch_no.equals(marketDetailsBean.getPitch_no()) %>' >
                <input type="radio" name="pitch_no" id="<%= pitch_no %>"
                  value="<%= pitch_no %>" checked="checked" />
              </if:IfTrue>
              <if:IfTrue cond='<%= ! pitch_no.equals(marketDetailsBean.getPitch_no()) %>' >
                <input type="radio" name="pitch_no" id="<%= pitch_no %>"
                  value="<%= pitch_no %>" />
              </if:IfTrue>
            </td>

            <td valign="top">
              <label for="<%= pitch_no %>"><b>&nbsp;<x:out select="$pitchRecord/pitch_name" />&nbsp;</b></label>
            </td>

            <c:set var="confirmed_yn"><x:out select="$pitchRecord/confirmed_yn" /></c:set>
            <% String confirmed_yn = (String)pageContext.getAttribute("confirmed_yn"); %>
            <if:IfTrue cond='<%= confirmed_yn.equals("Y") %>' >
              <td valign="top" bgcolor="#259225">
                <font color="white">
                <label for="<%= pitch_no %>"><b>&nbsp;Confirmed&nbsp;</b></label>
                </font>
              </td>
            </if:IfTrue>
            <if:IfTrue cond='<%= confirmed_yn.equals("N") %>' >
              <td valign="top" bgcolor="#ff6565">
                <font color="white">
                <label for="<%= pitch_no %>"><b>&nbsp;Not Confirmed&nbsp;</b></label>
                </font>
              </td>
            </if:IfTrue>
          </tr>

          <%-- site_name_1 --%>
          <% site_name = ""; %>
          <c:set var="site_name_1"><x:out select="$pitchRecord/site_name_1" /></c:set>
          <% site_name_1 = (String)pageContext.getAttribute("site_name_1"); %>
          <c:set var="site_name_2"><x:out select="$pitchRecord/site_name_2" /></c:set>
          <% site_name_2 = (String)pageContext.getAttribute("site_name_2"); %>
          <%
          site_name = site_name_1;
          if (!site_name_1.equals("") & !site_name_2.equals("")) {
            site_name = site_name + " " + site_name_2;
          }
          %>
          <tr bgcolor="#ffffff">
            <td colspan="2"><label for="<%= pitch_no %>"><%= site_name %></label></td>
          </tr>

          <%-- trader_name --%>
          <tr bgcolor="#ecf5ff">
            <td><label for="<%= pitch_no %>"><b>Trader</b></label></td>
            <td colspan="2"><label for="<%= pitch_no %>"><x:out select="$pitchRecord/trader_name" /></label></td>
          </tr>

          <%-- license_type --%>
          <tr bgcolor="#ffffff">
            <td><label for="<%= pitch_no %>"><b>Licence</b></label></td>
            <td colspan="2"><label for="<%= pitch_no %>"><x:out select="$pitchRecord/license_type" /></label></td>
          </tr>

          <tr><td colspan="3"><hr size="1" noshade="noshade" /></td></tr>
        <% } %>
        <%-- Pitches List end --%>
      </table>
    </if:IfTrue>

    <table width="100%">
      <%-- If there are no pitches found --%>
      <if:IfTrue cond='<%= marketDetailsPagingBean.getRecordCount() == 0 %>' >
        <tr
          <td colspan="3">
            <b>No pitches found</b>
          </td>
        </tr>
      </if:IfTrue>

      <%-- If not empty --%>
      <if:IfTrue cond='<%= marketDetailsPagingBean.getRecordCount() != 0 %>' >
        <tr>
          <td colspan="3">
            <span class="subscript">records <%= marketDetailsPagingBean.getMinRecordInPage() %> - <%= marketDetailsPagingBean.getMaxRecordInPage() %> of <%= marketDetailsPagingBean.getRecordCount() %></span>
          </td>
        </tr>
      </if:IfTrue>
    </table>

    <%-- If not empty --%>
    <if:IfTrue cond='<%= marketDetailsPagingBean.getRecordCount() != 0 %>' >
      <sess:equalsAttribute name="sort_order" match="pitch" >
        <jsp:include page="include/sort_order_pitch_buttons.jsp" flush="true" />
      </sess:equalsAttribute>
      <sess:equalsAttribute name="sort_order" match="confirmed" >
        <jsp:include page="include/sort_order_confirmed_buttons.jsp" flush="true" />
      </sess:equalsAttribute>
      <jsp:include page="include/rowset_nav_buttons.jsp" flush="true" />
    </if:IfTrue>

    <jsp:include page="include/back_enforce_details_buttons.jsp" flush="true" />
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="page_number" value="<%= marketDetailsPagingBean.getCurrentPageNum() %>" />
    <input type="hidden" name="input" value="marketDetails" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>

</html>
