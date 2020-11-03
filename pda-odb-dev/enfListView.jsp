<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfListBean, com.vsb.helperBean" %>
<%@ page import="com.db.*, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="enfListBean" scope="session" class="com.vsb.enfListBean" />
<jsp:useBean id="enfListPageSet" scope="session" class="com.db.PageSet" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfList" value="false">
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

  <meta http-equiv="Refresh" content="<app:initParameter name="listRefreshInterval"/>" />
  <app:equalsInitParameter name="use_xhtml" match="Y">
    <meta http-equiv="Content-Type" content="application/xhtml+xml" />
    <% response.setContentType("application/xhtml+xml"); %>
  </app:equalsInitParameter>
  <app:equalsInitParameter name="use_xhtml" match="Y" value="false">
    <meta http-equiv="Content-Type" content="text/html" />
  </app:equalsInitParameter>
  <title>enfList</title>
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
  <form onSubmit="return singleclick();" action="enfListScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Enforcement List</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="enfListBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td>&nbsp;</td></tr>      
    </table>
    <jsp:include page="include/rowset_nav_buttons.jsp" flush="true" />
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
    <table width="100%">
      <tr>
        <td colspan="3">
          <span class="subscript">sites <%= enfListPageSet.getMinRecordInPage() %> - <%= enfListPageSet.getMaxRecordInPage() %> of <%= enfListPageSet.getRecordCount() %></span>
        </td>
      </tr>

      <% Page thePage = enfListPageSet.getCurrentPage(); %>
      <% while (thePage.next()) { %>
        <%-- Set the complaint number for ease of use --%>
        <% String complaint_no = thePage.getField(1).trim(); %>
        <%-- set the other values we will use --%>
        <% String enf_officer = thePage.getField(2).trim(); %>
        <% String site_name_1 = thePage.getField(3).trim(); %>
        <% String action_ref  = thePage.getField(4).trim(); %>
        <% String enf_status  = thePage.getField(5).trim(); %>
        <% String do_date     = ""; %>
        <if:IfTrue cond='<%= thePage.getField(6) != null %>' >
          <% do_date = thePage.getField(6).trim(); %>
        </if:IfTrue>
        <% String state  = ""; %>
        <if:IfTrue cond='<%= thePage.getField(7) != null %>' >
          <% state  = thePage.getField(7).trim(); %>
        </if:IfTrue>
        <% String action_seq = ""; %>
        <if:IfTrue cond='<%= thePage.getField(8) != null %>' >
          <% action_seq  = thePage.getField(8).trim(); %>
        </if:IfTrue>
        <tr>
          <%-- Draw radio buttons on the form and check if any items have been selected--%>
          <td width="10">
            <if:IfTrue cond='<%= complaint_no.equals(enfListBean.getComplaint_no()) %>' >
              <input type="radio" 
                     name="complaint_no" 
                     id="<%= complaint_no %>"
                     value="<%= complaint_no %>"  
                     checked="checked" />
            </if:IfTrue>
            <if:IfTrue cond='<%= !complaint_no.equals(enfListBean.getComplaint_no()) %>' >
              <input type="radio" 
                     name="complaint_no" 
                     id="<%= complaint_no %>" 
                     value="<%= complaint_no %>" />
            </if:IfTrue>
          </td>
          <td align="center" bgcolor="#259225">
            <label for="<%= complaint_no %>">
              <font color="white"><b>Ref.</b>&nbsp;<%= complaint_no %></font>
            </label>
          </td>
          <td align="center" bgcolor="#259225">
            <label for="<%= complaint_no %>">
              <font color="white"><b>Enf.</b>&nbsp;<%= enf_officer %></font>
            </label>
          </td>
        </tr>
        <tr>
          <td colspan="3">
            <label for="<%= complaint_no %>"><%= site_name_1 %></label>
          </td>
        </tr>

        <%-- enforcement has been processed so do not show additional datai, and flag it as processed --%>
        <if:IfTrue cond='<%= state.equals("P") %>' >
          <tr>
            <td bgcolor="#ff6565" colspan="3" align="center">
              <label for="<%= complaint_no %>"><font color="white"><b>PROCESSED</b></font></label>
            </td>
          </tr>
        </if:IfTrue>
        <%-- enforcement has not been processed so show additional data --%>
        <if:IfTrue cond='<%= state.equals("A") %>' >
          <%-- Only show the Action details if they exist --%>
          <if:IfTrue cond='<%= ! action_ref.equals("") %>' >
            <tr>
              <td colspan="3" align="center" bgcolor="#dddddd">
                <table width="100%">
                  <tr>
                    <td align="left">
                      <label for="<%= complaint_no %>"><b>Action</b></label>
                    </td>
                    <td align="right">
                      <label for="<%= complaint_no %>"><%= action_ref %></label>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
              <if:IfTrue cond='<%= !action_seq.equals("") %>'>
                <sql:query>
                  SELECT txt
                    FROM enf_act_text
                   WHERE complaint_no = <%= complaint_no %>
                     AND action_seq = <%= action_seq %>
                     AND seq = 1
                </sql:query>
                <sql:resultSet id="rset">
                  <sql:getColumn position="1" to="txt" />
                  <sql:wasNotNull>
                    <% String txt = ((String)pageContext.getAttribute("txt")).trim(); %>
                    <tr>
                      <td colspan="3" align="center" bgcolor="#ffffff">
                        <table width="100%">
                          <tr>
                            <td align="left">
                              <label for="<%= complaint_no %>">
                                <%= helperBean.restrict(txt, 40) %>
                              </label>
                            </td>
                          </tr>
                        </table>
                      </td>
                    </tr>
                  </sql:wasNotNull>
                </sql:resultSet>
              </if:IfTrue>
            <tr>
              <td colspan="3" align="center" bgcolor="#dddddd">
                <table width="100%">
                  <tr>
                    <td align="left">
                      <label for="<%= complaint_no %>"><b>Status</b></label>
                    </td>
                    <td align="right">
                      <label for="<%= complaint_no %>"><%= enf_status %></label>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
          </if:IfTrue>
  
          <tr>
            <td colspan="3" bgcolor="#dddddd">
              <label for="<%= complaint_no %>">
                <if:IfTrue cond='<%= action_ref.equals("") %>' >
                  <b>Entered</b>&nbsp;
                </if:IfTrue>
                <if:IfTrue cond='<%= ! action_ref.equals("") %>' >
                  <b>Due</b>&nbsp;
                </if:IfTrue>
                <if:IfTrue cond='<%= do_date.equals("") %>' >
                  No Date
                </if:IfTrue>
                <if:IfTrue cond='<%= ! do_date.equals("") %>' >
                  <%= helperBean.dispDate( do_date, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %>
                </if:IfTrue>
              </label>
            </td>
          </tr>
        </if:IfTrue>
        <tr><td colspan="3"><hr noshade="noshade" size="1"></td></tr>
      <% } %>

      <%-- If there are no sites found --%>
      <if:IfTrue cond='<%= enfListPageSet.getRecordCount() == 0 %>' >
        <tr>
           <td colspan="3">
             <b>No enforcements available</b>
           </td>
         </tr>
       </if:IfTrue>
       <tr><td>&nbsp;</td></tr>
       <tr>
        <td colspan="3">
          <span class="subscript">sites <%= enfListPageSet.getMinRecordInPage() %> - <%= enfListPageSet.getMaxRecordInPage() %> of <%= enfListPageSet.getRecordCount() %></span>
        </td>
      </tr>
    </table>
    </sql:statement>
    <sql:closeConnection conn="con"/>
    <jsp:include page="include/rowset_nav_buttons.jsp" flush="true" />
    <jsp:include page="include/back_details_buttons.jsp" flush="true" />    
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="enfList" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
