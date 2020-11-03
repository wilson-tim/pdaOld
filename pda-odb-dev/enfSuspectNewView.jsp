<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfSuspectNewBean, com.vsb.recordBean,  java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="enfSuspectNewBean" scope="session" class="com.vsb.enfSuspectNewBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfSuspectNew" value="false">
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
  <title>enfSuspectNew</title>
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
  <form onSubmit="return singleclick();" action="enfSuspectNewScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>New Suspect</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="enfSuspectNewBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <%-- Open a connection to the database to help create the view --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
    <table width="100%" border="0">
      <tr>
        <td><b>Title</b></td>
        <td>
          <input type="text" size="10" name="sus_title" maxlength="10"
            value="<%= enfSuspectNewBean.getSus_title() %>" />
        </td>
      </tr>
      <tr>
        <td><b>Surname</b></td>
        <td>
          <input type="text" size="15" name="sus_surname" maxlength="30"
            value="<%= enfSuspectNewBean.getSus_surname() %>" />
        </td>
      </tr>
      <tr>
        <td><b>First Name</b></td>
        <td>
          <input type="text" size="15" name="sus_fstname" maxlength="15"
            value="<%= enfSuspectNewBean.getSus_fstname() %>" />
        </td>
      </tr>
      <tr>
        <td><b>Mid. Name</b></td>
        <td>
          <input type="text" size="15" name="sus_midname"  maxlength="15"
            value="<%= enfSuspectNewBean.getSus_midname() %>" />
        </td>
      </tr>
      <tr>
        <td><b>Est. Age</b></td>
        <td>
          <input type="text" size="15" name="sus_age"  maxlength="3"
            value="<%= enfSuspectNewBean.getSus_age() %>" />
        </td>
      </tr>
      <tr>
        <td><b>Gender</b></td>
        <td>
          <select name="sus_sex">
            <if:IfTrue cond='<%= enfSuspectNewBean.getSus_sex().equals("") %>'>
              <option value="" selected="selected" ></option>
            </if:IfTrue>
            <if:IfTrue cond='<%= ! enfSuspectNewBean.getSus_sex().equals("") %>'>
              <option value=""></option>
            </if:IfTrue>

            <sql:query>
              SELECT lookup_code
                FROM allk
               WHERE lookup_func = 'GENDER'
              ORDER BY lookup_code
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="gender" />
              <sql:wasNotNull>
                <% String gender = ((String)pageContext.getAttribute("gender")).trim(); %>
                <if:IfTrue cond='<%= gender.equals(enfSuspectNewBean.getSus_sex())%>'>
                  <option value="<%= gender %>" selected="selected"><%= gender %></option>
                </if:IfTrue>
                <if:IfTrue cond='<%= !gender.equals(enfSuspectNewBean.getSus_sex())%>'>
                  <option value="<%= gender %>"><%= gender %></option>
                </if:IfTrue>
              </sql:wasNotNull>
            </sql:resultSet>
          </select>
        </td>
      </tr>
      <tr><td colspan="2">&nbsp;</td></tr>
      <tr>
        <td colspan="2"><b>Date Of Birth:</b></td>
      </tr>
      <%-- Find out the minimum age --%>
      <% String min_age = "0"; %>
      <sql:query>
        select n_field
        from keys
        where service_c = 'ALL'
        and   keyname = 'ENF_SUSPECT_MIN_AGE'
      </sql:query>
      <sql:resultSet id="rset1">
        <sql:getColumn position="1" to="c_field" />
        <sql:wasNotNull>
          <% min_age = ((String) pageContext.getAttribute("c_field")).trim().toLowerCase(); %>
        </sql:wasNotNull>
      </sql:resultSet>
      <tr>
        <td colspan="2">
          <select name="day_ob">
            <option value="">DD</option>
            <%
              for (int i=1;i<32; i++) {
                if (enfSuspectNewBean.getDay_ob() != null && !(enfSuspectNewBean.getDay_ob().equals(""))) {
                  int day = Integer.parseInt((String)enfSuspectNewBean.getDay_ob());
                  if (i == day) {
                    out.println("<option value=\""+  i + "\" selected>" + i + "</option>");
                  } else {
                    out.println("<option value=\""+  i + "\">" + i + "</option>");
                  }
                } else {
                  out.println("<option value=\""+  i + "\">" + i + "</option>");
                }
              }
            %>
          </select>

          <select name="month_ob">
            <option value="">MM</option>
            <%
              for (int i=1;i<13; i++) {
                if (enfSuspectNewBean.getMonth_ob() != null && !(enfSuspectNewBean.getMonth_ob().equals(""))) {
                  int month = Integer.parseInt((String)enfSuspectNewBean.getMonth_ob());
                  if (i == month) {
                    out.println("<option value=\""+  i + "\" selected>" + i + "</option>");
                  } else {
                    out.println("<option value=\""+  i + "\">" + i + "</option>");
                  }
                } else {
                  out.println("<option value=\""+  i + "\">" + i + "</option>");
                }
              }
            %>
          </select>

          <select name="year_ob">
            <option value="">YYYY</option>
            <%
              Calendar cal = new GregorianCalendar();
              int year = cal.get(Calendar.YEAR);
              year = year - Math.round((new Float(min_age)).floatValue());

              for (int i=0;i<100;i++) {
                if (enfSuspectNewBean.getYear_ob() != null && !(enfSuspectNewBean.getYear_ob().equals(""))) {
                  int thisyear = Integer.parseInt((String)enfSuspectNewBean.getYear_ob());
                  if(year ==thisyear) {
                    out.println("<option value=\"" + year + "\" selected>" + year +"</option>");
                    year = year - 1;
                  } else {
                    out.println("<option value=\"" + year + "\">" + year +"</option>");
                    year = year - 1;
                  }
                } else {
                    out.println("<option value=\""+  year + "\">" + year + "</option>");
                    year = year - 1;
                }
              }
            %>
          </select>
        </td>
      </tr>
      <tr><td colspan="2">&nbsp;</td></tr>
      <tr>
        <td><b>Build. No.</b></td>
        <td>
          <input type="text" size="10" name="sus_build_no"  maxlength="10"
            value="<%= enfSuspectNewBean.getSus_build_no() %>" />
        </td>
      </tr>
      <tr>
        <td><b>Build. Name</b></td>
        <td>
          <input type="text" size="15" name="sus_build_name"  maxlength="60"
            value="<%= enfSuspectNewBean.getSus_build_name() %>" />
        </td>
      </tr>
      <tr>
        <td><b>Addr 1</b></td>
        <td>
          <input type="text" size="15" name="sus_addr1"  maxlength="70"
            value="<%= enfSuspectNewBean.getSus_addr1() %>" />
        </td>
      </tr>
      <tr>
        <td><b>Addr 2</b></td>
        <td>
          <input type="text" size="15" name="sus_addr2" maxlength="70"
            value="<%= enfSuspectNewBean.getSus_addr2() %>" />
        </td>
      </tr>
      <tr>
        <td><b>Addr 3</b></td>
        <td>
          <input type="text" size="15" name="sus_addr3" maxlength="50"
            value="<%= enfSuspectNewBean.getSus_addr3() %>" />
        </td>
      </tr>
      <tr>
        <td><b>Postcode</b></td>
        <td>
          <input type="text" size="15" name="sus_postcode" maxlength="8"
            value="<%= enfSuspectNewBean.getSus_postcode() %>" />
        </td>
      </tr>
      <tr><td colspan="2">&nbsp;</td></tr>
      <tr>
        <td><b>Home</b></td>
        <td>
          <input type="text" size="15" name="sus_homeno" maxlength="18"
            value="<%= enfSuspectNewBean.getSus_homeno() %>" />
        </td>
      </tr>
      <tr>
        <td><b>Work</b></td>
        <td>
          <input type="text" size="15" name="sus_workno" maxlength="20"
            value="<%= enfSuspectNewBean.getSus_workno() %>" />
        </td>
      </tr>
      <tr>
        <td><b>Mobile</b></td>
        <td>
          <input type="text" size="15" name="sus_mobno" maxlength="16"
            value="<%= enfSuspectNewBean.getSus_mobno() %>" />
        </td>
      </tr>
      <tr><td colspan="2">&nbsp;</td></tr>
      <tr>
        <td colspan="2">
          <b>Search for a company name:</b>
        </td>
      </tr>
      <tr>
        <td colspan="2">
        <input type="text" size="25" name="sus_company" maxlength="50"
            value="<%= enfSuspectNewBean.getSus_company() %>" />
        </td>
      </tr>
    </table>
    </sql:statement>
    <sql:closeConnection conn="con"/>
    <jsp:include page="include/back_continue_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="enfSuspectNew" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
