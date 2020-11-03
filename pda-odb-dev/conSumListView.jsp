<%@ page errorPage="error.jsp" %>
<%@ page  import="com.vsb.conSumListBean, com.vsb.loginBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>

<jsp:useBean id="conSumListBean" scope="session" class="com.vsb.conSumListBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
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
<sess:equalsAttribute name="form" match="conSumList" value="false">
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
  <title>conSumList</title>
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
  <form onSubmit="return singleclick();" action="conSumListScript.jsp" method="post">  
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Contractor Summary</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr>
        <td>
          <font color="#ff6565"><b><jsp:getProperty name="conSumListBean" property="error" /></b></font>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <%-- Check the setting of the sort order--%>  
    <sess:equalsAttribute name="sort_order" match="defaults" >
      <jsp:include page="include/sort_order_defaults_wo_date.jsp" flush="true" />
    </sess:equalsAttribute>
    <sess:equalsAttribute name="sort_order" match="works orders" >
      <jsp:include page="include/sort_order_wo_defaults_date.jsp" flush="true" />
    </sess:equalsAttribute>
    <sess:equalsAttribute name="sort_order" match="date" >
      <jsp:include page="include/sort_order_date_defaults_wo.jsp" flush="true" />
    </sess:equalsAttribute>
    <%--
      Construct two sql queries to collext data on Defaults and W/O, these
      are joined together using a UNION, which is why gaps ('') may appear.
    --%>  
    <table width="100%">
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt1" conn="con">
        <sql:query>
           SELECT complaint_no,
                  action_flag,
                  site_ref,
                  dest_ref,
                  dest_suffix,
                  item_ref,
                  do_date,
                  start_time_h,
                  start_time_m,
                  wo_stat,
                  def_action,
                  state,
                  contract_ref
             FROM con_sum_list
            WHERE (state = 'A' or state = 'P')
              AND user_name = '<%= loginBean.getUser_name() %>'
              AND contract_ref IN
              (
                SELECT cont_logins.contract_ref
                  FROM cont_logins, patr, pda_user
                 WHERE cont_logins.login_name = patr.po_login
                   AND patr.po_code = pda_user.po_code
                   AND pda_user.user_name = '<%= loginBean.getUser_name() %>'
              )
          <%-- The sort order --%>
          <sess:equalsAttribute name="sort_order" match="defaults" >
             ORDER BY 2 ASC
          </sess:equalsAttribute>
          <sess:equalsAttribute name="sort_order" match="works orders" >
             ORDER BY 2 DESC
          </sess:equalsAttribute>
          <sess:equalsAttribute name="sort_order" match="date" >
             ORDER BY 7
          </sess:equalsAttribute>
        </sql:query>
        <sql:resultSet id="rset1">
        <%-- Table row: Radio button, action_flag D/W, action U/A/N/Z --%>  
          <tr>
            <td width="10">
              <sql:getColumn position="1" to="complaint_no" />
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("complaint_no")).trim().equals(conSumListBean.getComplaint_no()) %>' >
                <input type    ="radio" 
		       name    ="complaint_no" 
		       id      ="<sql:getColumn position="1" />"  
		       value   ="<sql:getColumn position="1" />"  
		       checked ="checked" />
              </if:IfTrue>
              <if:IfTrue cond='<%= !((String)pageContext.getAttribute("complaint_no")).trim().equals(conSumListBean.getComplaint_no()) %>' >
                <input type    ="radio" 
		       name    ="complaint_no" 
		       id      ="<sql:getColumn position="1" />" 
		       value   ="<sql:getColumn position="1" />" />
              </if:IfTrue>
            </td>
            <sql:getColumn position="2" to="action_flag" />
            <sql:wasNull>
              <td align="center">&nbsp;</td>
              <td align="center">&nbsp;</td>
            </sql:wasNull>
            <sql:wasNotNull>
	      <%-- Default --%>
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("action_flag")).trim().equals("D") %>' >
                <td bgcolor="#259225" align="center"><font color="white"><b><app:initParameter name="def_name_noun" /></b></font></td>
                <sql:getColumn position="11" to="action" />
                <sql:wasNull>                 
                  <td bgcolor="#259225" align="center"><font color="white"><b>&nbsp;</b></font></td>
                </sql:wasNull>
                <sql:wasNotNull>
                  <if:IfTrue cond='<%= ((String)pageContext.getAttribute("action")).trim().equals("U") %>' >
                    <td bgcolor="#259225" align="center"><font color="white"><b>Unjustified</b></font></td>
                  </if:IfTrue>
                  <if:IfTrue cond='<%= ((String)pageContext.getAttribute("action")).trim().equals("A") %>' >
                    <td bgcolor="#259225" align="center"><font color="white"><b>Actioned</b></font></td>
                  </if:IfTrue>
                  <if:IfTrue cond='<%= ((String)pageContext.getAttribute("action")).trim().equals("N") %>' >
                    <td bgcolor="#259225" align="center"><font color="white"><b>Not Actioned</b></font></td>
                  </if:IfTrue>
                  <if:IfTrue cond='<%= ((String)pageContext.getAttribute("action")).trim().equals("Z") %>' >
                    <td bgcolor="#259225" align="center"><font color="white"><b>Cleared</b></font></td>
                  </if:IfTrue>
                </sql:wasNotNull>
              </if:IfTrue>
              <%--Works Order--%>
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("action_flag")).trim().equals("W") %>' >
                <td bgcolor="#259225" align="center"><font color="white"><b>W/O</b></font></td>
                <sql:getColumn position="10" to="status" />
                <sql:wasNull>
                  <td bgcolor="#259225" align="center"><font color="white"><b>&nbsp;</b></font></td>
                </sql:wasNull>
                <sql:wasNotNull>
                  <%-- Grab the Works Order Status --%>		
                  <sql:statement id="stmt2" conn="con">
                    <sql:query>
                      SELECT wo_stat_desc
                      FROM wo_stat
                      WHERE wo_h_stat = '<%=((String)pageContext.getAttribute("status")).trim() %>'
                    </sql:query>
                    <sql:resultSet id="wo_status">
                      <sql:getColumn position="1" to="status_desc" />
                      <td bgcolor="#259225" align="center">
                        <font color="white">
                          <b><%= ((String)pageContext.getAttribute("status_desc")).trim() %></b>
                        </font>
                      </td>
                    </sql:resultSet>
                  </sql:statement>
                </sql:wasNotNull>		  
              </if:IfTrue>
            </sql:wasNotNull>
          </tr>

          <%-- Table row: site name --%> 
          <sql:getColumn position="3" to="comp_site_ref" />                 
          <sql:statement id="stmt2" conn="con">
          <sql:query>
            SELECT site_name_1
            FROM site
            WHERE site_ref = '<%=((String)pageContext.getAttribute("comp_site_ref")).trim() %>'
          </sql:query>
          <sql:resultSet id="rs2">
            <tr>
              <td bgcolor="#DDDDDD" colspan="3" align="left">
                <label for='<%= ((String)pageContext.getAttribute("complaint_no")).trim() %>'>
                 <sql:getColumn position="1" />
                </label>
              </td>
            </tr>
          </sql:resultSet>
          </sql:statement>

          <%-- Table row: item_ref and complaint dest_refi (Default) --%>
          <if:IfTrue cond='<%= ((String)pageContext.getAttribute("action_flag")).trim().equals("D") %>' >	  
            <tr>
              <td bgcolor="#DDDDDD" colspan="3" align="center">
                <table width="100%">
                  <tr>
                    <td bgcolor="#DDDDDD" align="left">
                      <label for="<sql:getColumn position="1" />"><b><sql:getColumn position="6" /></b></label>
                    </td>
                    <td align="right">
                      <label for="<sql:getColumn position="1" />"><b><sql:getColumn position="4" /></b></label>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
          </if:IfTrue>
          <%-- Table row: works order suffix and wo_ref (Works Order) --%>
          <if:IfTrue cond='<%= ((String)pageContext.getAttribute("action_flag")).trim().equals("W") %>' >	  
            <tr>
              <td bgcolor="#DDDDDD" colspan="3" align="center">
                <table width="100%">
                  <tr>
                    <td bgcolor="#DDDDDD" align="left">
                      <label for="<sql:getColumn position="1" />"><b><sql:getColumn position="5" /></b></label>
                    </td>
                    <td align="right">
                      <label for="<sql:getColumn position="1" />"><b><sql:getColumn position="4" /></b></label>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
          </if:IfTrue>
            <tr>
          <%-- Table row: Date and Time, will not show if item is PENDING --%>
          <sql:getColumn position="12" to="state" />
          <%-- item has been processed so the date/time will have --%>
          <%-- changed, so flag it as such. --%>
          <if:IfTrue cond='<%= ((String)pageContext.getAttribute("state")).trim().equals("P") %>' >
              <td bgcolor="#ff6565" colspan="3" align="center">
                <label for="<sql:getColumn position="1" />"><font color="white"><b>PROCESSED</b></font></label>
              </td>
          </if:IfTrue>
          <%-- item has not been processed so the date/time will have --%>
          <%-- to be shown. --%>
          <if:IfTrue cond='<%= ((String)pageContext.getAttribute("state")).trim().equals("A") %>' >
              <td bgcolor="#DDDDDD" colspan="3">
                <label for="<sql:getColumn position="1" />">
                <sql:getDate position="7" to="due_date" format="<%= application.getInitParameter("db_date_fmt") %>" />
                <sql:wasNull>
                  <% pageContext.setAttribute("due_date",""); %>
                </sql:wasNull>
                <b>Due</b>&nbsp;
                <%-- Check to see if there is a time value --%>
                <sql:getColumn position="8" to="time_h" />
                <if:IfTrue cond='<%= pageContext.getAttribute("time_h") == null
	                          || ((String)pageContext.getAttribute("time_h")).trim().equals("") %>' >
                  <%-- just use date if no time value --%>
                  <%= helperBean.dispDate(((String)pageContext.getAttribute("due_date")).trim(), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %>
                </if:IfTrue>
                <if:IfTrue cond='<%= pageContext.getAttribute("time_h") != null
	                          && ! ((String)pageContext.getAttribute("time_h")).trim().equals("") %>' >
                  <%= helperBean.dispDate(((String)pageContext.getAttribute("due_date")).trim(), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %>
                  @ 
                  <sql:getColumn position="8" />:<sql:getColumn position="9" />
                </if:IfTrue>
                </label>
              </td>
          </if:IfTrue>
            </tr>
            <%-- Horizontal Rule --%>
            <tr>
              <td colspan="3"><hr size="1" noshade="noshade" /></td>
            </tr>
        </sql:resultSet>
        <sql:wasEmpty>
          <tr>
            <td colspan="3">
               <b>No list available</b>
            </td>
          </tr>
        </sql:wasEmpty>
        <sql:wasNotEmpty>
          <tr>
            <td colspan="3">
              <span class="subscript"><sql:rowCount /> items</span>
            </td>
          </tr>
        </sql:wasNotEmpty>
      </sql:statement>
      <sql:closeConnection conn="con"/>
      </table>
      <sess:equalsAttribute name="sort_order" match="defaults" >
        <jsp:include page="include/sort_order_defaults_wo_date.jsp" flush="true" />
      </sess:equalsAttribute>
      <sess:equalsAttribute name="sort_order" match="works orders" >
        <jsp:include page="include/sort_order_wo_defaults_date.jsp" flush="true" />
      </sess:equalsAttribute>
      <sess:equalsAttribute name="sort_order" match="date" >
        <jsp:include page="include/sort_order_date_defaults_wo.jsp" flush="true" />
      </sess:equalsAttribute>
      <jsp:include page="include/back_details_buttons.jsp" flush="true" />
      <%@ include file="include/insp_sched_buttons.jsp" %>
      <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="conSumList" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>    
