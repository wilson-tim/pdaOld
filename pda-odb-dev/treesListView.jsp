<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.treesListBean, com.vsb.recordBean, com.vsb.helperBean" %>
<%@ page import="com.db.*, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"          prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"       prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0"     prefix="sess" %>

<jsp:useBean id="treesListBean" scope="session" class="com.vsb.treesListBean" />
<jsp:useBean id="recordBean"    scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean"    scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="treesListPageSet" scope="session" class="com.db.PageSet" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="treesList" value="false">
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
  <title>treesList</title>
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
  <form onSubmit="return singleclick();" action="treesListScript.jsp" method="post">
    <%-- Title --%>
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Trees</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="treesListBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>      
    </table>

    <%-- If not empty --%>
    <if:IfTrue cond='<%= treesListPageSet.getRecordCount() != 0 %>' >
      <jsp:include page="include/rowset_nav_buttons.jsp" flush="true" />
    </if:IfTrue>

    <table width="100%">
      <%-- Site Name --%>
      <tr>
        <td align="center"><b><%= recordBean.getSite_name_1() %></b></td>
      </tr>
      <%-- Paging position --%>
      <if:IfTrue cond='<%= treesListPageSet.getRecordCount() != 0 %>' >
        <tr>
          <td colspan="3">
            <span class="subscript">records <%= treesListPageSet.getMinRecordInPage() %> - <%= treesListPageSet.getMaxRecordInPage() %> of <%= treesListPageSet.getRecordCount() %></span>
          </td>
        </tr>
      </if:IfTrue>
      <tr><td><hr size="1" noshade="noshade" /></td></tr>
    </table>

    <table width="100%">
      <%-- Trees List start --%>
      <% Page thePage = treesListPageSet.getCurrentPage(); %>
      <% while (thePage.next()) { %>
        <% String tree_ref     = ""; %>
        <% String tree_desc    = ""; %>
        <% String tr_no        = ""; %>
        <% String position     = ""; %>
        <% String position_ref = ""; %>
        <% String species_ref  = ""; %>
        <% String species_desc = ""; %>
        <% String updated      = ""; %>
        <if:IfTrue cond='<%= thePage.getField(1) != null %>' >
          <% tree_ref = thePage.getField(1).trim(); %>
        </if:IfTrue>
        <if:IfTrue cond='<%= thePage.getField(2) != null %>' >
          <% tree_desc = thePage.getField(2).trim(); %>
        </if:IfTrue>
        <if:IfTrue cond='<%= thePage.getField(3) != null %>' >
          <% tr_no = thePage.getField(3).trim(); %>
        </if:IfTrue>
        <if:IfTrue cond='<%= thePage.getField(4) != null %>' >
          <% position = thePage.getField(4).trim(); %>
        </if:IfTrue>
        <if:IfTrue cond='<%= thePage.getField(5) != null %>' >
          <% position_ref = thePage.getField(5).trim(); %>
        </if:IfTrue>
        <if:IfTrue cond='<%= thePage.getField(6) != null %>' >
          <% species_ref = thePage.getField(6).trim(); %>
        </if:IfTrue>
        <if:IfTrue cond='<%= thePage.getField(7) != null %>' >
          <% species_desc = thePage.getField(7).trim(); %>
        </if:IfTrue>
        <if:IfTrue cond='<%= thePage.getField(8) != null %>' >
          <% updated = thePage.getField(8).trim(); %>
        </if:IfTrue>
        <%-- Create the row entries in the table for each tree --%>
        <tr bgcolor="orange">
          <td valign="top" width="10">
            <if:IfTrue cond='<%= tree_ref.equals(treesListBean.getTree_ref()) %>' >
              <input type="radio" name="tree_ref" id="<%= tree_ref %>"
                value="<%= tree_ref %>" checked="checked" />
            </if:IfTrue>
            <if:IfTrue cond='<%= ! tree_ref.equals(treesListBean.getTree_ref()) %>' >
              <input type="radio" name="tree_ref" id="<%= tree_ref %>"
                value="<%= tree_ref %>" /> 
            </if:IfTrue>
          </td>                  
          <td valign="top">                   
            <label for="<%= tree_ref %>"><b>Ref:&nbsp;<%= tree_ref %>&nbsp;</b></label>
          </td>
          <td valign="top">
            <label for="<%= tree_ref %>"><b>Seq:&nbsp;<%= tr_no %></b></label>
          </td>
        </tr>
        <tr bgcolor="#ffffff">
          <td colspan="2"><label for="<%= tree_ref %>"><b>Desc</b></label></td>
          <td><label for="<%= tree_ref %>"><%= tree_desc %></label></td>
        </tr>
        <tr bgcolor="#ecf5ff">
          <td colspan="2"><label for="<%= tree_ref %>"><b>Position</b></label></td>
          <td><label for="<%= tree_ref %>"><%= position %></label></td>
        </tr>
        <tr bgcolor="#ffffff">
          <td colspan="2"><label for="<%= tree_ref %>"><b>Last Updated</b></label></td>
          <td><label for="<%= tree_ref %>"><%= helperBean.dispDate( updated, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></label></td>
        </tr>
        <tr bgcolor="#ecf5ff">
          <td colspan="2"><label for="<%= tree_ref %>"><b>Species</b></label></td>
          <td><label for="<%= tree_ref %>"><%= species_desc %></label></td>
        </tr>
        <tr><td colspan="3"><hr size="1" noshade="noshade" /></td></tr>
      <% } %>
      <%-- Trees List end --%>
    </table>

    <table width="100%">
    
      <%-- If there are no trees found --%>
      <if:IfTrue cond='<%= treesListPageSet.getRecordCount() == 0 %>' >
        <tr>
          <td colspan="3">
            <b>No trees found on this site</b>
          </td>
        </tr>
      </if:IfTrue>

      <%-- If not empty --%>
      <if:IfTrue cond='<%= treesListPageSet.getRecordCount() != 0 %>' >
        <tr>
          <td colspan="3">
            <span class="subscript">records <%= treesListPageSet.getMinRecordInPage() %> - <%= treesListPageSet.getMaxRecordInPage() %> of <%= treesListPageSet.getRecordCount() %></span>
          </td>
        </tr>
      </if:IfTrue>

    </table>

    <%-- If not empty --%>
    <if:IfTrue cond='<%= treesListPageSet.getRecordCount() != 0 %>' >
      <jsp:include page="include/rowset_nav_buttons.jsp" flush="true" />
    </if:IfTrue>
    <jsp:include page="include/back_details_add_item_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="page_number" value="<%= treesListPageSet.getCurrentPageNum() %>" />
    <input type="hidden" name="input" value="treesList" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>

</html>
