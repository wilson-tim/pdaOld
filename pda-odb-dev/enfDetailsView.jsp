<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfDetailsBean, com.vsb.recordBean, com.vsb.helperBean, com.vsb.systemKeysBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="enfDetailsBean" scope="session" class="com.vsb.enfDetailsBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="systemKeysBean" scope="session" class="com.vsb.systemKeysBean" />
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
<sess:equalsAttribute name="form" match="enfDetails" value="false">
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
  <title>enfDetails</title>
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
  <form onSubmit="return singleclick();" action="enfDetailsScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Enforcement Details</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="enfDetailsBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table width="100%">
      <%-- do all the sql to get the requisite information for the enforcement --%>
      <%
        String action_ref = "";
        String action_desc = "";
        String enf_status = "";
        String enf_status_desc = "";
        String action_date = "";
        String action_time_h = "";
        String action_time_m = "";
        String due_date = "";
        String law_ref = "";
        String law_desc = "";
        String offence_ref = "";
        String offence_desc = "";
        String offence_date = "";
        String offence_time_h = "";
        String offence_time_m = "";
        String inv_officer = "";
        String inv_officer_desc = "";
        String enf_officer = "";
        String enf_officer_desc = "";
        String aut_officer = "";
        String aut_officer_desc = "";
        String car_id = "";
        String fstname = "";
        String midname = "";
        String surname = "";
        String company_ref = "";
        String company_name = "";
        String exact_location = "";
        String position = "";
        String action_txt = "";
        String offence_period_start = "";
        String offence_period_end   = "";
      %>
      <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con1">
        <sql:query>
          SELECT law_ref, offence_ref, offence_date,
                 inv_officer, enf_officer,
                 car_id, offence_time_h, offence_time_m,
                 inv_period_start, inv_period_finish
            FROM comp_enf
           WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="law_ref" />
          <sql:wasNotNull>
            <% law_ref = ((String) pageContext.getAttribute("law_ref")).trim(); %>
          </sql:wasNotNull>

          <sql:getColumn position="2" to="offence_ref" />
          <sql:wasNotNull>
            <% offence_ref = ((String) pageContext.getAttribute("offence_ref")).trim(); %>
          </sql:wasNotNull>

          <sql:getDate position="3" to="offence_date" format="<%= application.getInitParameter("db_date_fmt") %>" />
          <sql:wasNotNull>
            <% offence_date = ((String) pageContext.getAttribute("offence_date")).trim(); %>
          </sql:wasNotNull>

          <sql:getColumn position="4" to="inv_officer" />
          <sql:wasNotNull>
            <% inv_officer = ((String) pageContext.getAttribute("inv_officer")).trim(); %>
          </sql:wasNotNull>

          <sql:getColumn position="5" to="enf_officer" />
          <sql:wasNotNull>
            <% enf_officer = ((String) pageContext.getAttribute("enf_officer")).trim(); %>
          </sql:wasNotNull>

          <sql:getColumn position="6" to="car_id" />
          <sql:wasNotNull>
            <% car_id = ((String) pageContext.getAttribute("car_id")).trim(); %>
          </sql:wasNotNull>

          <sql:getColumn position="7" to="offence_time_h" />
          <sql:wasNotNull>
            <% offence_time_h = ((String) pageContext.getAttribute("offence_time_h")).trim(); %>
          </sql:wasNotNull>

          <sql:getColumn position="8" to="offence_time_m" />
          <sql:wasNotNull>
            <% offence_time_m = ((String) pageContext.getAttribute("offence_time_m")).trim(); %>
          </sql:wasNotNull>

          <sql:getDate position="9" to="offence_period_start" format="<%= application.getInitParameter("db_date_fmt") %>" />
          <sql:wasNotNull>
            <% offence_period_start = ((String) pageContext.getAttribute("offence_period_start")).trim(); %>
          </sql:wasNotNull>

          <sql:getDate position="10" to="offence_period_end" format="<%= application.getInitParameter("db_date_fmt") %>" />
          <sql:wasNotNull>
            <% offence_period_end = ((String) pageContext.getAttribute("offence_period_end")).trim(); %>
          </sql:wasNotNull>
        </sql:resultSet>
  
        <%-- Get the details for the comp_enf fields --%>
        <sql:query>
          SELECT lookup_text
            FROM allk 
           WHERE lookup_func = 'ENFLAW'
             AND lookup_code = '<%= law_ref %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="law_desc" />
          <sql:wasNotNull>
            <% law_desc = ((String) pageContext.getAttribute("law_desc")).trim(); %>
          </sql:wasNotNull>
        </sql:resultSet>
 
        <%-- Find out what version of contender is being run against the database --%>
        <%-- 10/05/2010  TW  Read contender_version from systemKeysBean --%>
        <% String contender_version = systemKeysBean.getContender_version(); %>
        
        <sql:query>
          <if:IfTrue cond='<%= contender_version.equals("v7") || contender_version.equals("") %>' >
            select lookup_text
            from allk 
            where lookup_func = 'ENFDET'
            and   lookup_code = '<%= offence_ref %>'
          </if:IfTrue>
          <if:IfTrue cond='<%= contender_version.equals("v8") %>' >
            select offence_desc
            from enf_offence
            where offence_ref = '<%= offence_ref %>'
          </if:IfTrue>
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="offence_desc" />
          <sql:wasNotNull>
            <% offence_desc = ((String) pageContext.getAttribute("offence_desc")).trim(); %>
          </sql:wasNotNull>
        </sql:resultSet>
  
        <sql:query>
          SELECT lookup_text
            FROM allk 
           WHERE lookup_func = 'ENFOFF'
             AND lookup_code = '<%= inv_officer %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="inv_officer_desc" />
          <sql:wasNotNull>
            <% inv_officer_desc = ((String) pageContext.getAttribute("inv_officer_desc")).trim(); %>
          </sql:wasNotNull>
        </sql:resultSet>
  
        <sql:query>
          SELECT lookup_text
            FROM allk 
           WHERE lookup_func = 'ENFOFF'
             AND lookup_code = '<%= enf_officer %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="enf_officer_desc" />
          <sql:wasNotNull>
            <% enf_officer_desc = ((String) pageContext.getAttribute("enf_officer_desc")).trim(); %>
          </sql:wasNotNull>
        </sql:resultSet>

        <%-- Get the name for the position field, default to 'Exact Location' --%>
        <% position = "Exact Location"; %>
        <sql:query>
          SELECT c_field
            FROM keys
           WHERE service_c = 'ALL'
             AND keyname = 'POSITION_TITLE'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="c_field" />
          <sql:wasNotNull>
            <% position = (String)pageContext.getAttribute("c_field"); %>
          </sql:wasNotNull>
          <sql:wasNull>
            <% position = "Exact Location"; %>
          </sql:wasNull>
        </sql:resultSet>
        <sql:wasEmpty>
          <% position = "Exact Location"; %>
        </sql:wasEmpty>

        <sql:query>
          SELECT exact_location
            FROM comp 
           WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="exact_location" />
          <sql:wasNotNull>
            <% exact_location = ((String) pageContext.getAttribute("exact_location")).trim(); %>
          </sql:wasNotNull>
        </sql:resultSet>

        <%-- only process if there is an action for this enforcement --%>
        <if:IfTrue cond='<%= ! recordBean.getEnf_list_action_seq().equals("") %>' >
          <sql:query>
            SELECT action_ref, enf_status, action_date, due_date, aut_officer,
                   action_time_h, action_time_m
              FROM enf_action 
             WHERE action_seq = '<%= recordBean.getEnf_list_action_seq() %>'
               AND complaint_no = '<%= recordBean.getComplaint_no() %>'
          </sql:query>
          <sql:resultSet id="rset">
            <sql:getColumn position="1" to="action_ref" />
            <sql:wasNotNull>
              <% action_ref = ((String) pageContext.getAttribute("action_ref")).trim(); %>
            </sql:wasNotNull>

            <sql:getColumn position="2" to="enf_status" />
            <sql:wasNotNull>
              <% enf_status = ((String) pageContext.getAttribute("enf_status")).trim(); %>
            </sql:wasNotNull>

            <sql:getDate position="3" to="action_date" format="<%= application.getInitParameter("db_date_fmt") %>" />
            <sql:wasNotNull>
              <% action_date = ((String) pageContext.getAttribute("action_date")).trim(); %>
            </sql:wasNotNull>

            <sql:getDate position="4" to="due_date" format="<%= application.getInitParameter("db_date_fmt") %>" />
            <sql:wasNotNull>
              <% due_date = ((String) pageContext.getAttribute("due_date")).trim(); %>
            </sql:wasNotNull>

            <sql:getColumn position="5" to="aut_officer" />
            <sql:wasNotNull>
              <% aut_officer = ((String) pageContext.getAttribute("aut_officer")).trim(); %>
            </sql:wasNotNull>

            <sql:getColumn position="6" to="action_time_h" />
            <sql:wasNotNull>
              <% action_time_h = ((String) pageContext.getAttribute("action_time_h")).trim(); %>
            </sql:wasNotNull>

            <sql:getColumn position="7" to="action_time_m" />
            <sql:wasNotNull>
              <% action_time_m = ((String) pageContext.getAttribute("action_time_m")).trim(); %>
            </sql:wasNotNull>
          </sql:resultSet>

          <%-- Get the details for the enf_action fields --%>
          <sql:query>
            SELECT description
              FROM enf_act
             WHERE action_code = '<%= action_ref %>'
          </sql:query>
          <sql:resultSet id="rset">
            <sql:getColumn position="1" to="description" />
            <sql:wasNotNull>
              <% action_desc = ((String) pageContext.getAttribute("description")).trim(); %>
            </sql:wasNotNull>
          </sql:resultSet>

          <sql:query>
            SELECT lookup_text
              FROM allk 
             WHERE lookup_func = 'ENFST'
               AND lookup_code = '<%= enf_status %>'
          </sql:query>
          <sql:resultSet id="rset">
            <sql:getColumn position="1" to="enf_status_desc" />
            <sql:wasNotNull>
              <% enf_status_desc = ((String) pageContext.getAttribute("enf_status_desc")).trim(); %>
            </sql:wasNotNull>
          </sql:resultSet>

          <sql:query>
            SELECT lookup_text
              FROM allk 
             WHERE lookup_func = 'ENFOFF'
               AND lookup_code = '<%= aut_officer %>'
          </sql:query>
          <sql:resultSet id="rset">
            <sql:getColumn position="1" to="aut_officer_desc" />
            <sql:wasNotNull>
              <% aut_officer_desc = ((String) pageContext.getAttribute("aut_officer_desc")).trim(); %>
            </sql:wasNotNull>
          </sql:resultSet>

          <%-- Get the text associated with this action --%>
          <sql:query>
            SELECT txt, seq
              FROM enf_act_text
             WHERE action_seq = '<%= recordBean.getEnf_list_action_seq() %>'
               AND complaint_no = '<%= recordBean.getComplaint_no() %>'
            ORDER BY seq
          </sql:query>
          <sql:resultSet id="rset">
            <sql:getColumn position="1" to="action_txt" />
            <sql:wasNotNull>
              <% action_txt += ((String) pageContext.getAttribute("action_txt")).trim() + " "; %>
            </sql:wasNotNull>
          </sql:resultSet>
          
        </if:IfTrue>
         
        <%-- only process if there is a suspect for this enforcement --%>
        <if:IfTrue cond='<%= ! recordBean.getEnf_list_suspect_ref().equals("") %>' >
          <sql:query>
            SELECT fstname, midname, surname, company_ref
              FROM enf_suspect
             WHERE suspect_ref = <%= recordBean.getEnf_list_suspect_ref() %>
          </sql:query>
          <sql:resultSet id="rset">
            <sql:getColumn position="1" to="fstname" />
            <sql:wasNotNull>
              <% fstname = ((String) pageContext.getAttribute("fstname")).trim(); %>
            </sql:wasNotNull>

            <sql:getColumn position="2" to="midname" />
            <sql:wasNotNull>
              <% midname = ((String) pageContext.getAttribute("midname")).trim(); %>
            </sql:wasNotNull>

            <sql:getColumn position="3" to="surname" />
            <sql:wasNotNull>
              <% surname = ((String) pageContext.getAttribute("surname")).trim(); %>
            </sql:wasNotNull>

            <sql:getColumn position="4" to="company_ref" />
            <sql:wasNotNull>
              <% company_ref = ((String) pageContext.getAttribute("company_ref")).trim(); %>
            </sql:wasNotNull>
          </sql:resultSet>

          <%-- only process if there is a company for this suspect --%>
          <if:IfTrue cond='<%= ! company_ref.equals("") %>' >
            <sql:query>
              SELECT company_name
                FROM enf_company 
               WHERE company_ref = <%= company_ref %>
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="company_name" />
              <sql:wasNotNull>
                <% company_name = ((String) pageContext.getAttribute("company_name")).trim(); %>
              </sql:wasNotNull>
            </sql:resultSet>
          </if:IfTrue>
        </if:IfTrue>
      </sql:statement>
      <sql:closeConnection conn="con1"/>

      <tr>
        <td align="center" colspan="2">
          <b><jsp:getProperty name="recordBean" property="site_name_1" /></b>
        </td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Law</b></td>
        <td><%= law_ref %></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td colspan="2"><%= law_desc %></td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Offence</b></td>
        <td><%= offence_ref %></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td colspan="2"><%= offence_desc %></td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#ecf5ff">
        <td colspan="2"><b>Evidence</b></td>
      </tr>
      <tr bgcolor="#ffffff">
        <if:IfTrue cond='<%= recordBean.getEnf_list_evidence().equals("") %>' >
          <td colspan="2">&nbsp;</td>
        </if:IfTrue>
        <if:IfTrue cond='<%= ! recordBean.getEnf_list_evidence().equals("") %>' >
          <td colspan="2"><%= helperBean.endRestrict(recordBean.getEnf_list_evidence(), 200) %></td>
        </if:IfTrue>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#ecf5ff">
        <td colspan="2">
          <b><%= position %></b>
        </td>
      </tr>
      <tr bgcolor="#ffffff">
        <if:IfTrue cond='<%= exact_location.equals("") %>' >
          <td colspan="2">&nbsp;</td>
        </if:IfTrue>
        <if:IfTrue cond='<%= ! exact_location.equals("") %>' >
          <td colspan="2"><%= exact_location %></td>
        </if:IfTrue>
      </tr>
      <tr><td colspan="2">&nbsp;</td></tr>
      <tr>
        <td colspan="2" bgcolor="#ff6600" align="center">
          <h4><b>OFFICER DETAILS</b></h4>
        </td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Inv. Officer</b></td>
        <td><%= inv_officer %></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td colspan="2"><%= inv_officer_desc %></td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Enf. Officer</b></td>
        <td><%= enf_officer %></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td colspan="2"><%= enf_officer_desc %></td>
      </tr>

      <%-- only show if there is an action for this enforcement --%>
      <if:IfTrue cond='<%= ! recordBean.getEnf_list_action_seq().equals("") %>' >
        <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
        <tr bgcolor="#ecf5ff">
          <td><b>Aut. Officer</b></td>
          <td><%= aut_officer %></td>
        </tr>
        <tr bgcolor="#ffffff">
          <td colspan="2"><%= aut_officer_desc %></td>
        </tr>
        <tr><td colspan="2">&nbsp;</td></tr>
        <tr>
          <td colspan="2" bgcolor="#ff6600" align="center">
            <h4><b>ACTION DETAILS</b></h4>
          </td>
        </tr>
        <tr bgcolor="#dddddd">
          <td><b>Action</b></td>
          <td><%= action_ref %></td>
        </tr>
        <tr bgcolor="#ffffff">
          <td colspan="2"><%= action_desc %></td>
        </tr>
        <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
        <if:IfTrue cond='<%= !action_txt.equals("") %>'>
          <tr bgcolor="#dddddd">
            <td colspan="2"><b>Action Text</b></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td colspan="2"><%= action_txt %></td>
          </tr>
          <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
        </if:IfTrue>
        <tr bgcolor="#dddddd">
          <td><b>Status</b></td>
          <td><%= enf_status %></td>
        </tr>
        <tr bgcolor="#ffffff">
          <td colspan="2"><%= enf_status_desc %></td>
        </tr>
      </if:IfTrue>

      <%-- only show if there is a suspect for this enforcement --%>
      <if:IfTrue cond='<%= ! recordBean.getEnf_list_suspect_ref().equals("") %>' >
        <tr><td colspan="2">&nbsp;</td></tr>
        <tr>
          <td colspan="2" bgcolor="#ff6600" align="center">
            <h4><b>SUSPECT DETAILS</b></h4>
          </td>
        </tr>

        <%-- only show if there is a suspect name for this suspect --%>
        <if:IfTrue cond='<%= !fstname.equals("") || !midname.equals("") || !surname.equals("") %>' >
          <tr bgcolor="#dddddd">
            <td><b>Suspect</b></td>
            <td><%= recordBean.getEnf_list_suspect_ref() %></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td colspan="2"><%= fstname %> <%= midname %> <%= surname %></td>
          </tr>
        </if:IfTrue>

        <%-- only show if there is a company for this suspect --%>
        <if:IfTrue cond='<%= ! company_ref.equals("") %>' >
          <tr bgcolor="#dddddd">
            <td><b>Company</b></td>
            <td><%= company_ref %></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td colspan="2"><%= company_name %></td>
          </tr>
        </if:IfTrue>

      </if:IfTrue>

      <tr><td colspan="2">&nbsp;</td></tr>
      <tr>
        <td colspan="2" bgcolor="#ff6600" align="center">
          <h4><b>BASIC DETAILS</b></h4>
        </td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Enquiry Ref.</b></td>
        <td><%= recordBean.getComplaint_no() %></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Car Id.</b></td>
        <td><%= car_id %></td>
      </tr>
      <if:IfTrue cond='<%= ! offence_date.equals("") %>' >
        <tr bgcolor="#ecf5ff">
          <td><b>Offence Date</b></td>
          <td><%= helperBean.dispDate(offence_date, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></td>
        </tr>
        <tr bgcolor="#ffffff">
          <td><b>Offence Time</b></td>
          <if:IfTrue cond='<%= ! offence_time_h.equals("") %>' >
            <td><%= offence_time_h %>:<%= offence_time_m %></td>
          </if:IfTrue>
          <if:IfTrue cond='<%= offence_time_h.equals("") %>' >
            <td>No time set</td>
          </if:IfTrue>
        </tr>
      </if:IfTrue>
      <if:IfTrue cond='<%= ! offence_period_start.equals("") %>' >
        <tr bgcolor="#ecf5ff">
          <td><b>Offence Period</b></td>
            <td>
              <%= helperBean.dispDate(offence_period_start, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %>
              -
              <%= helperBean.dispDate(offence_period_end, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %>
            </td>
        </tr>
      </if:IfTrue>
      
      <%-- only show if there is an action for this enforcement --%>
      <if:IfTrue cond='<%= ! recordBean.getEnf_list_action_seq().equals("") %>' >
        <tr bgcolor="#ecf5ff">
          <td><b>Action Date</b></td>
          <td><%= helperBean.dispDate(action_date, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></td>
        </tr>
        <tr bgcolor="#ffffff">
          <td><b>Action Time</b></td>
          <if:IfTrue cond='<%= ! action_time_h.equals("") %>' >
            <td><%= action_time_h %>:<%= action_time_m %></td>
          </if:IfTrue>
          <if:IfTrue cond='<%= action_time_h.equals("") %>' >
            <td>No time set</td>
          </if:IfTrue>
        </tr>
        <tr bgcolor="#ecf5ff">
          <td><b>Due Date</b></td>
          <td><%= helperBean.dispDate(due_date, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></td>
        </tr>
      </if:IfTrue>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
    </table>
    <table width="100%">
      <tr>
        <td>
          <b>Previous Text</b><br/>
          <textarea rows="4" cols="28" name="textOut" readonly="readonly" ><jsp:getProperty name="enfDetailsBean" property="textOut" /></textarea>
        </td>
      </tr>
      <tr>
        <td>
          <b>Text</b><br/>
          <textarea rows="4" cols="28" name="text" ><jsp:getProperty name="enfDetailsBean" property="text" /></textarea>
        </td>
      </tr>
    </table>
    <table width="100%">
      <tr><td>&nbsp;</td></tr>
      <%-- only show status and action buttons if there is an action for this enforcement --%>
      <if:IfTrue cond='<%= ! recordBean.getEnf_list_action_seq().equals("") %>' >
        <tr>
          <td>
            <b><input type="submit" name="action" value="Add Action"
              style="font-weight:bold; width: 14em; font-size: 85%" /></b>
          </td>
        </tr>
        <tr>
          <td>
            <b><input type="submit" name="action" value="Update Status"
              style="font-weight:bold; width: 14em; font-size: 85%" /></b>
          </td>
        </tr>
      </if:IfTrue>
      <%-- only show action button if there is suspect for this enforcement --%>
      <if:IfTrue cond='<%= recordBean.getEnf_list_action_seq().equals("") %>' >
        <if:IfTrue cond='<%= ! recordBean.getEnf_list_suspect_ref().equals("") %>' >
          <tr>
            <td>
              <b><input type="submit" name="action" value="Add Action"
                style="font-weight:bold; width: 14em; font-size: 85%" /></b>
            </td>
          </tr>
        </if:IfTrue>
      </if:IfTrue>
      <tr>
        <td>
          <b><input type="submit" name="action" value="Update Text"
            style="font-weight:bold; width: 14em; font-size: 85%" /></b>
        </td>
      </tr>
      <tr>
        <td>
          <b><input type="submit" name="action" value="Update Evidence"
            style="font-weight:bold; width: 14em; font-size: 85%" /></b>
        </td>
      </tr>
      <tr>
        <td>
          <b><input type="submit" name="action" value="Add/Update Suspect"
            style="font-weight:bold; width: 14em; font-size: 85%" /></b>
        </td>
      </tr>
      <tr><td>&nbsp;</td></tr>
    </table>

    <%-- 06/07/2010  TW  New conditional Attachments button --%>
    <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con1">
      <sql:query>
        SELECT attach_no
          FROM attachments
         WHERE source_no = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="attach_no" />
      </sql:resultSet>
      <sql:wasEmpty>
        <jsp:include page="include/back_button.jsp" flush="true" />
      </sql:wasEmpty>
      <sql:wasNotEmpty>
        <jsp:include page="include/back_attachments_buttons.jsp" flush="true" />
      </sql:wasNotEmpty>
    </sql:statement>
    <sql:closeConnection conn="con1"/>

    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="enfDetails" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
