<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.compHistoryBean, com.vsb.recordBean, com.vsb.helperBean" %>
<%@ page import="javax.sql.*, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="compHistoryBean" scope="session" class="com.vsb.compHistoryBean" />
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
<sess:equalsAttribute name="form" match="compHistory" value="false">
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
  <title>compHistory</title>
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
  <form onSubmit="return singleclick();" action="compHistoryScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Complaint History</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="compHistoryBean" property="error" /></b></font></td></tr>
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
      <tr>
        <td colspan="2"><jsp:getProperty name="recordBean" property="item_desc" /></td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      
      <% int histCount = 0; %>
      
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
        <%-- get the maximum number of records allowed to be shown, default to 5 if --%>
        <%-- COMP_HIST_LIMIT_VAL is null --%>
        <% int maxHistCount = 5; %>
        <sql:query>
          select c_field
          from keys
          where service_c = 'ALL'
          and   keyname = 'PDA_COMP_HIST_VAL'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="max_count" />
          <sql:wasNotNull>
            <% maxHistCount = Integer.parseInt(((String)pageContext.getAttribute("max_count")).trim()); %>
          </sql:wasNotNull>
        </sql:resultSet>

        <sql:query>
          select complaint_no, action_flag, comp_code, date_entered, date_closed, service_c
          from comp
          where site_ref = '<%= recordBean.getSite_ref() %>'
          <%-- 26/05/2010  TW  New condition, is full history being displayed or not? --%>
          <if:IfTrue cond='<%= recordBean.getComp_full_history().equals("N") %>' >
            and   item_ref = '<%= recordBean.getItem_ref() %>'
          </if:IfTrue>
          order by date_entered desc
        </sql:query>
        <sql:resultSet id="rset1" loop="false">
          <%-- manually setup and use the ResultSet from the above sql --%>
          <% java.sql.ResultSet rs = (java.sql.ResultSet)pageContext.getAttribute("rset1"); %>
          <% while(rs.next() && histCount < maxHistCount) { %>
          
          <sql:getColumn position="1" to="complaint_no" />
          <tr>
            <td bgcolor="#259225" align="center">
              <font color="white"><b><sql:getColumn position="1" /></b></font>
            </td>
            <%-- if the complaint is not closed then show it's action --%>
            <sql:getDate position="5" to="date_closed" format="<%= application.getInitParameter("db_date_fmt") %>" />
            <sql:wasNull>
              <td bgcolor="#259225" align="center"><font color="white"><b>Running</b></font></td>
            </sql:wasNull>
            <sql:wasNotNull>
              <td bgcolor="#ff6565" align="center"><font color="white"><b>Closed</b></font></td>
            </sql:wasNotNull>
          </tr>
          
          <tr>
            <sql:getColumn position="2" to="action_flag" />
            <sql:wasNull>
              <td bgcolor="#DDDDDD" align="center">
                <b><sql:getColumn position="6" /></b>
              </td>
              <td align="center">&nbsp;</td>
            </sql:wasNull>
            <sql:getColumn position="2" to="action_flag" />
            <sql:wasNotNull>
              <td bgcolor="#DDDDDD" align="center">
                <b><sql:getColumn position="6" /></b>
              </td>
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("action_flag")).trim().equals("D") %>' >
                <td bgcolor="#DDDDDD" align="center"><b><app:initParameter name="def_name_noun"/></b></td>
              </if:IfTrue>
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("action_flag")).trim().equals("P") %>' >
                <td bgcolor="#DDDDDD" align="center"><b>Pending</b></td>
              </if:IfTrue>
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("action_flag")).trim().equals("I") %>' >
                <td bgcolor="#DDDDDD" align="center"><b>Inspect</b></td>
              </if:IfTrue>
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("action_flag")).trim().equals("W") %>' >
                <td bgcolor="#DDDDDD" align="center"><b>Works Order</b></td>
              </if:IfTrue>
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("action_flag")).trim().equals("H") %>' >
                <td bgcolor="#DDDDDD" align="center"><b>Hold</b></td>
              </if:IfTrue>
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("action_flag")).trim().equals("E") %>' >
                <td bgcolor="#DDDDDD" align="center"><b>Enforcement</b></td>
              </if:IfTrue>
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("action_flag")).trim().equals("N") %>' >
                <td bgcolor="#DDDDDD" align="center"><b>No Further Action</b></td>
              </if:IfTrue>
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("action_flag")).trim().equals("X") %>' >
                <td bgcolor="#DDDDDD" align="center"><b>Void</b></td>
              </if:IfTrue>
            </sql:wasNotNull>
          </tr>
          
          <sql:getColumn position="3" to="comp_code" />
          <tr>
            <td bgcolor="#DDDDDD" colspan="2" align="center">
              <sql:statement id="stmt2" conn="con">
                <sql:query>
                  select lookup_text
                  from allk
                  where lookup_func = 'COMPLA'
                  and   lookup_code = '<%= ((String)pageContext.getAttribute("comp_code")).trim() %>'
                </sql:query>
                <sql:resultSet id="rset2">
                  <b><%= pageContext.getAttribute("comp_code") %> : </b><sql:getColumn position="1" />
                </sql:resultSet>
              </sql:statement>
            </td>
          </tr>
          
          <tr>
            <td colspan="2">
              <sql:statement id="stmt3" conn="con">
                <sql:query>
                  select txt, seq
                  from comp_text
                  where complaint_no = '<%= ((String)pageContext.getAttribute("complaint_no")).trim() %>'
                  order by seq asc
                </sql:query>
                <sql:resultSet id="rset3">
                  <sql:getColumn position="1" to="line" />
                  <%= helperBean.displayString(((String)pageContext.getAttribute("line")).trim()) %>
                </sql:resultSet>
                <sql:wasEmpty>
                  <b>No text available</b>
                </sql:wasEmpty>
              </sql:statement>
            </td>
          </tr>

          <sql:statement id="stmt4" conn="con">
            <sql:query>
              select customer.compl_init, customer.compl_name, customer.compl_surname
              from customer, comp_clink
              where comp_clink.complaint_no = '<%= ((String)pageContext.getAttribute("complaint_no")).trim() %>'
              and   comp_clink.seq_no = (
                select max(seq_no)
                from comp_clink
                where complaint_no = '<%= ((String)pageContext.getAttribute("complaint_no")).trim() %>'
              )
              and customer.customer_no = comp_clink.customer_no
            </sql:query>
            <sql:resultSet id="rset4">
              <tr>
                <td bgcolor="#DDDDDD" colspan="2" align="center">
                  <b><sql:getColumn position="1" /></b><sql:getColumn position="2" /><sql:getColumn position="3" />
                </td>
              </tr>
            </sql:resultSet>
            <sql:wasEmpty>
              <tr>
                <td bgcolor="#DDDDDD" colspan="2" align="center">
                  <b>No name</b>
                </td>
              </tr>
            </sql:wasEmpty>
          </sql:statement>

          <sql:getDate position="4" to="date_entered" format="<%= application.getInitParameter("db_date_fmt") %>" />
          <tr>
            <td bgcolor="#DDDDDD" colspan="2" align="left">
              <b>Entered on </b>
              <%= helperBean.dispDate(((String)pageContext.getAttribute("date_entered")).trim(), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %>
            </td>
          </tr>

          <sql:getDate position="5" to="date_closed" format="<%= application.getInitParameter("db_date_fmt") %>" />
          <sql:wasNotNull>
            <tr>
              <td bgcolor="#DDDDDD" colspan="2" align="left">
                <b>Closed on </b>
                <%= helperBean.dispDate(((String)pageContext.getAttribute("date_closed")).trim(), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %>
              </td>
            </tr>
          </sql:wasNotNull>

          <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
          <% histCount++; %>
          <% } %>
        </sql:resultSet>
        <%-- was empty --%>
        <if:IfTrue cond='<%= histCount == 0 %>' >
          <tr>
             <td colspan="3">
               <b>No history available</b>
             </td>
           </tr>
        </if:IfTrue>
        <%-- was not empty --%>
        <if:IfTrue cond='<%= histCount > 0 %>' >
          <tr>
            <td colspan="3">
              <span class="subscript"><%= histCount %> complaints</span>
            </td>
          </tr>
        </if:IfTrue>
      </sql:statement>
      <sql:closeConnection conn="con"/>
    </table>
    <%-- 26/05/2010  TW  New conditions, is full history being displayed or not? --%>
    <if:IfTrue cond='<%= recordBean.getComp_full_history().equals("N") %>' >
      <%-- Display Full History button --%>
      <jsp:include page="include/back_fullhist_button.jsp" flush="true" />
    </if:IfTrue>
    <if:IfTrue cond='<%= recordBean.getComp_full_history().equals("Y") %>' >
      <%-- Display Item History button --%>
      <jsp:include page="include/back_itemhist_button.jsp" flush="true" />
    </if:IfTrue>
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="compHistory" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
