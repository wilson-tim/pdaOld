<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfQueryBean" %>
<%@ page import="java.util.GregorianCalendar" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="enfQueryBean" scope="session" class="com.vsb.enfQueryBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfQuery" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>


<%
  // Create calendar to create the year drop down boxes.
  GregorianCalendar gregDate = new GregorianCalendar();
%>

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
  <title>enfQuery</title>
  <style type="text/css">
    @import URL("global.css");
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
  <form onSubmit="return singleclick();" action="enfQueryScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Search Enforcements</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="enfQueryBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade /></td></tr>
    </table>
    <%-- Open a connection to the database to help create the view --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
    <%-- Due Date Table --%>
    <table width="100%">
      <tr bgcolor="#ecf5ff">
        <td width="25%" rowspan="2"><b>Due Date</b></td>
        <td width="25%"><b>Day</b></td>
        <td width="25%"><b>Month</b></td>
        <td width="25%"><b>Year</b></td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td>
          <select name="enf_due_day">
            <option value=""></option>
            <% int enf_due_day = 0; %>
            <if:IfTrue cond='<%= !enfQueryBean.getEnf_due_day().equals("") %>'>
              <% enf_due_day = new Integer(enfQueryBean.getEnf_due_day()).intValue(); %>
            </if:IfTrue>
            <%  for (int i=1; i<32; i++) { %>
              <if:IfTrue cond="<%= i == enf_due_day %>">
                <option value="<%= i %>" selected="selected"><%= i %></option>
              </if:IfTrue>
              <if:IfTrue cond="<%= i != enf_due_day %>">
                <option value="<%= i %>"><%= i %></option>
              </if:IfTrue>
            <%  } %>
          </select>
        </td>
        <td>
          <select name="enf_due_month">
            <option value=""></option>
            <% int enf_due_month = 0; %>
            <if:IfTrue cond='<%= !enfQueryBean.getEnf_due_month().equals("") %>'>
              <% enf_due_month = new Integer(enfQueryBean.getEnf_due_month()).intValue(); %>
            </if:IfTrue>
            <%  for (int i=1; i<13; i++) { %>
              <if:IfTrue cond="<%= i == enf_due_month %>">
                <option value="<%= i %>" selected="selected" ><%= i %></option>
              </if:IfTrue>
              <if:IfTrue cond="<%= i != enf_due_month %>">
                <option value="<%= i %>" ><%= i %></option>
              </if:IfTrue>
            <%  } %>
          </select>
        </td>
        <td>
          <select name="enf_due_year">
            <option value=""></option>
            <% int enf_due_year = 0; %>
            <if:IfTrue cond='<%= !enfQueryBean.getEnf_due_year().equals("") %>'>
              <% enf_due_year = new Integer(enfQueryBean.getEnf_due_year()).intValue(); %>
            </if:IfTrue>
            <%  for (int i=(gregDate.get(gregDate.YEAR)-1), k=i+3; i <= k; i++) { %>
              <if:IfTrue cond="<%= i == enf_due_year %>">
                <option value="<%= i %>" selected="selected" ><%= i %></option>
              </if:IfTrue>
              <if:IfTrue cond="<%= i != enf_due_year %>">
                <option value="<%= i %>" ><%= i %></option>
              </if:IfTrue>
            <%  } %>
          </select>
        </td>
      </tr>
    </table>
    <%-- Action Date Table --%>
    <table width="100%">
      <tr>
        <td width="25%" rowspan="2"><b>Action Date</b></td>
        <td width="25%"><b>Day</b></td>
        <td width="25%"><b>Month</b></td>
        <td width="25%"><b>Year</b></td>
      </tr>
      <tr>
        <td>
          <select name="enf_action_day">
            <option value=""></option>
            <% int enf_action_day = 0; %>
            <if:IfTrue cond='<%= !enfQueryBean.getEnf_action_day().equals("") %>'>
              <% enf_action_day = new Integer(enfQueryBean.getEnf_action_day()).intValue(); %>
            </if:IfTrue>              
            <%  for (int i=1; i<32; i++) { %>
              <if:IfTrue cond="<%= i == enf_action_day %>">
                <option value="<%= i %>" selected="selected"><%= i %></option>
              </if:IfTrue>
              <if:IfTrue cond="<%= i != enf_action_day %>">
                <option value="<%= i %>" ><%= i %></option>
              </if:IfTrue>
            <%  } %>
          </select>
        </td>
        <td>
          <select name="enf_action_month">
            <option value=""></option>
            <% int enf_action_month = 0; %>
            <if:IfTrue cond='<%= !enfQueryBean.getEnf_action_month().equals("") %>'>
              <% enf_action_month = new Integer(enfQueryBean.getEnf_action_month()).intValue(); %>
            </if:IfTrue>
            <%  for (int i=1; i<13; i++) { %>
              <if:IfTrue cond="<%= i == enf_action_month %>">
                <option value="<%= i %>" selected="selected"><%= i %></option>
              </if:IfTrue>
              <if:IfTrue cond="<%= i != enf_action_month %>">
                <option value="<%= i %>"><%= i %></option>
              </if:IfTrue>
            <%  } %>
          </select>
        </td>
        <td>
          <select name="enf_action_year">
            <option value=""></option>
            <% int enf_action_year = 0; %>
            <if:IfTrue cond='<%= !enfQueryBean.getEnf_action_year().equals("") %>'>
              <% enf_action_year = new Integer(enfQueryBean.getEnf_action_year()).intValue(); %>
            </if:IfTrue>              
          <%  for (int i=(gregDate.get(gregDate.YEAR)-1), k=i+3; i <= k; i++) { %>
            <if:IfTrue cond="<%= i == enf_action_year %>">
              <option value="<%= i %>" selected="selected"><%= i %></option>
            </if:IfTrue>
            <if:IfTrue cond="<%= i != enf_action_year %>">
              <option value="<%= i %>"><%= i %></option>
            </if:IfTrue>
          <%  } %>
          </select>
        </td>
      </tr>
    </table>
    <%-- Status --%>
    <table width="100%">
      <tr bgcolor="#ecf5ff">
        <td width="80"><b>Status</b></td>
        <td>
          <select name="enf_status">
            <option value=""></option>
            <sql:query>
              SELECT lookup_code
                FROM allk
               WHERE lookup_func = 'ENFST'
              ORDER BY lookup_code 
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="enf_status" />
              <sql:wasNotNull>
                <% String enf_status = ((String)pageContext.getAttribute("enf_status")).trim(); %>
                <if:IfTrue cond='<%= enf_status.equals(enfQueryBean.getEnf_status())%>'>
                  <option value="<%= enf_status %>" selected="selected"><%= enf_status %></option>
                </if:IfTrue>
                <if:IfTrue cond='<%= !enf_status.equals(enfQueryBean.getEnf_status())%>'>
                  <option value="<%= enf_status %>"><%= enf_status %></option>
                </if:IfTrue>
              </sql:wasNotNull>
            </sql:resultSet>
          </select>
        </td>
      </tr>
    </table>
    <table width="100%">
      <tr>
        <td width="80"><b>Action</b></td>
        <td>
          <select name="enf_action_code">
            <option value=""></option>
            <sql:query>
              SELECT action_code
                FROM enf_act
              ORDER BY action_code
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="enf_action_code" />
              <sql:wasNotNull>
                <% String enf_action_code = ((String)pageContext.getAttribute("enf_action_code")).trim(); %>
                <if:IfTrue cond='<%= enf_action_code.equals(enfQueryBean.getEnf_action_code())%>'>
                  <option value="<%= enf_action_code %>" selected="selected"><%= enf_action_code %></option>
                </if:IfTrue>
                <if:IfTrue cond='<%= !enf_action_code.equals(enfQueryBean.getEnf_action_code())%>'>
                  <option value="<%= enf_action_code %>"><%= enf_action_code %></option>
                </if:IfTrue>
              </sql:wasNotNull>
            </sql:resultSet>
          </select>
        </td>
      </tr>
    </table>
    <table width="100%">
      <tr bgcolor="#ecf5ff">
        <td width="80"><b>Law</b></td>
        <td>
          <select name="enf_law">
            <option value=""></option>
            <sql:query>
              SELECT lookup_code
                FROM allk
               WHERE lookup_func = 'ENFLAW'
              ORDER BY lookup_code 
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="enf_law" />
              <sql:wasNotNull>
                <% String enf_law = ((String)pageContext.getAttribute("enf_law")).trim(); %>
                <if:IfTrue cond='<%= enf_law.equals(enfQueryBean.getEnf_law())%>'>
                  <option value="<%= enf_law %>" selected="selected"><%= enf_law %></option>
                </if:IfTrue>
                <if:IfTrue cond='<%= !enf_law.equals(enfQueryBean.getEnf_law())%>'>
                  <option value="<%= enf_law %>"><%= enf_law %></option>
                </if:IfTrue>                  
              </sql:wasNotNull>
            </sql:resultSet>
          </select>
        </td>
      </tr>
    </table>
    <table width="100%">
      <tr>
        <td width="80"><b>Offence</b></td>
        <td>
          <select name="enf_offence">
            <option value=""></option>
            <sql:query>
              SELECT lookup_code
                FROM allk
               WHERE lookup_func = 'ENFDET'
              ORDER BY lookup_code 
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="enf_offence" />
              <sql:wasNotNull>
                <% String enf_offence = ((String)pageContext.getAttribute("enf_offence")).trim(); %>
                <if:IfTrue cond='<%= enf_offence.equals(enfQueryBean.getEnf_offence())%>'>
                  <option value="<%= enf_offence %>" selected="selected"><%= enf_offence %></option>
                </if:IfTrue>
                <if:IfTrue cond='<%= !enf_offence.equals(enfQueryBean.getEnf_offence())%>'>
                  <option value="<%= enf_offence %>"><%= enf_offence %></option>
                </if:IfTrue>
              </sql:wasNotNull>
            </sql:resultSet>
          </select>
        </td>
      </tr>
    </table>
    <table width="100%">
      <tr bgcolor="#ecf5ff">
        <td width="80"><b>Officer</b></td>
        <td>
          <select name="enf_officer">
            <option value=""></option>
            <sql:query>
              select distinct po_code, full_name
              from pda_user
              where po_code in (
                select lookup_code
                from allk
                where lookup_func = 'ENFOFF'
                and status_yn = 'Y'
              )
              order by full_name
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="officer" />

              <% String fullname = ""; %>
              <sql:getColumn position="2" to="fullname" />
              <sql:wasNotNull>
                <% fullname = ((String)pageContext.getAttribute("fullname")).trim(); %>
              </sql:wasNotNull>

              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("officer")).trim().equals(enfQueryBean.getEnf_officer().trim()) %>' >
                <if:IfTrue cond='<%= ! fullname.equals("") %>' >
                  <option value="<sql:getColumn position="1" />" selected="selected" ><sql:getColumn position="2" /></option>
                </if:IfTrue>
                <if:IfTrue cond='<%= fullname.equals("") %>' >
                  <option value="<sql:getColumn position="1" />" selected="selected" >No Name</option>
                </if:IfTrue>
              </if:IfTrue>
              <if:IfTrue cond='<%= ! ((String)pageContext.getAttribute("officer")).trim().equals(enfQueryBean.getEnf_officer().trim()) %>' >
                <if:IfTrue cond='<%= ! fullname.equals("") %>' >
                  <option value="<sql:getColumn position="1" />"><sql:getColumn position="2" /></option>
                </if:IfTrue>
                <if:IfTrue cond='<%= fullname.equals("") %>' >
                  <option value="<sql:getColumn position="1" />" selected="selected" >No Name</option>
                </if:IfTrue>
              </if:IfTrue>
            </sql:resultSet>
          </select>
        </td>
      </tr>
    </table>
    <table width="100%">
      <tr>
        <td width="80"><b>Site</b></td>
        <td>
         <input type="text" name="enf_site" size="18"
            value="<%= enfQueryBean.getEnf_site() %>" 
        </td>
      </tr>
    </table>
    </sql:statement>
    <sql:closeConnection conn="con"/>
    <jsp:include page="include/back_submit_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="enfQuery" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
    <input type="hidden" name="enf_due_date" value="<%= enfQueryBean.getEnf_due_date() %>" />
    <input type="hidden" name="enf_action_date" value="<%= enfQueryBean.getEnf_action_date() %>" />
  </form>
</body>
</html>
