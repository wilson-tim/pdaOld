<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.surveyExistingBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="surveyExistingBean" scope="session" class="com.vsb.surveyExistingBean" />
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
<sess:equalsAttribute name="form" match="surveyExisting" value="false">
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
  <title>surveyExisting</title>
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
  <form onSubmit="return singleclick();" action="surveyExistingScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Existing Transects For:</b></font></h2>
        </td>
      </tr>
      <tr>
        <td bgcolor="#ffffff" align="center">
          <strong><font><%= recordBean.getBv_site_name_1() %></font></strong>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="surveyExistingBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td>
        <table cellspacing="0" cellpadding="0" align="center" width="100%">
          <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
            <sql:statement id="stmt" conn="con">
              <sql:query>
                select
                  bv_transect.transect_ref,
                  allk.lookup_text,
                  measure_method,
                  start_ref,
                  end_ref,
                  description,
                  transect_date
                from
                  bv_transect,
                  allk
                where
                  allk.lookup_code = bv_transect.land_use
                and
                  allk.lookup_func = 'BVLAND'
                and
                  bv_transect.site_ref =  '<%= recordBean.getBv_site_ref() %>'
              </sql:query>

              <%
                String color="#ffffff";
                String measure="";
              %>

              <sql:resultSet id="rset">
                <sql:getColumn position="1" to="transect" />
                <sql:getColumn position="2" to="landuse" />
                <sql:getColumn position="3" to="measure" />
                <sql:getColumn position="4" to="start" />
                <sql:getColumn position="5" to="end" />
                <sql:getColumn position="6" to="desc" />
                <sql:getDate position="7" to="date" format="<%= application.getInitParameter("db_date_fmt") %>" />

                <%

                  if(color=="#ffffff")
                  {color = "#ecf5ff";}
                  else if (color=="#ecf5ff")
                  {color = "#ffffff";}

                %>

                <tr bgcolor="<%= color %>" >
                  <td valign="top" width="10">
                    <if:IfTrue cond='<%= ((String)pageContext.getAttribute("transect")).trim().equals(surveyExistingBean.getTransect()) %>' >
                      <input type="radio" id="<sql:getColumn position="1" />" name="transect"  value="<sql:getColumn position="1" />"  checked="checked" />
                    </if:IfTrue>
                    <if:IfTrue cond='<%= !(((String)pageContext.getAttribute("transect")).trim().equals(surveyExistingBean.getTransect())) %>' >
                      <input type="radio" id="<sql:getColumn position="1" />" name="transect"  value="<sql:getColumn position="1" />" />
                    </if:IfTrue>
                  </td>
                  <td valign="top">
                    <strong><label for="<sql:getColumn position="1" />">
                      <%= helperBean.dispDate((String)pageContext.getAttribute("date"), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %>
                    </label></strong>
                  </td>
                </tr>
                <tr bgcolor="<%= color %>" >
                  <td></td>
                  <td valign="top">
                    <strong><label for="<sql:getColumn position="1" />">
                      <sql:getColumn position="2" />
                    </label></strong>
                  </td>
                </tr>
                <tr bgcolor="<%= color %>" >
                  <td></td>
                  <td valign="top">
                    <label for="<sql:getColumn position="1" />">
                      <%
                        measure = (String)pageContext.getAttribute("measure");
                        measure = measure.trim();
                      %>
                      <if:IfTrue cond='<%= measure.equals("01") %>' >
                        Street Lighting: <%= helperBean.displayString((String)pageContext.getAttribute("start")) %> - <%= helperBean.displayString((String)pageContext.getAttribute("end")) %>
                      </if:IfTrue>
                      <if:IfTrue cond='<%=  measure.equals("02")  %>' >
                        House Numbers: <%= helperBean.displayString((String)pageContext.getAttribute("start")) %>- <%= helperBean.displayString((String)pageContext.getAttribute("end")) %>
                      </if:IfTrue>
                      <if:IfTrue cond='<%=  measure.equals("03")  %>' >
                        Description:
                      </if:IfTrue>
                    </label>
                  </td>
                </tr>
                <tr>
                  <td></td>
                  <td bgcolor="<%= color %>" valign="top">
                    <label for="<sql:getColumn position="1" />">
                      <%= helperBean.displayString((String)pageContext.getAttribute("desc")) %>
                    </label>
                  </td>
                </tr>
              </sql:resultSet>
              <sql:wasEmpty>
                <tr>
                  <td colspan="3">
                    <b>No Previous Transects Available</b>
                  </td>
                </tr>
              </sql:wasEmpty>
            </sql:statement>
          <sql:closeConnection conn="con"/>
        </table>
      </td></tr>
    </table>

    <jsp:include page="include/back_new_continue_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %> 
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="surveyExisting" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
