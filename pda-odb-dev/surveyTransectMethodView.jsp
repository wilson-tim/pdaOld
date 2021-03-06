<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.surveyTransectMethodBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="surveyTransectMethodBean" scope="session" class="com.vsb.surveyTransectMethodBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="surveyTransectMethod" value="false">
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
  <title>surveyTransectMethod</title>
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
  <form onSubmit="return singleclick();" action="surveyTransectMethodScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Measurement Method</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="surveyTransectMethodBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td>
       	<table align="center" width="100%" cellspacing="0">
					<sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
						<sql:statement id="stmt" conn="con">
							<sql:query>
								select lookup_code, lookup_text
								from allk
								where lookup_func = 'BVMEAS'
                and   status_yn = 'Y'
							</sql:query>

							<% String color="#ffffff"; %>

							<sql:resultSet id="rset">
								<sql:getColumn position="1" to="transectMethod" />
								<%

									if(color=="#ffffff")
									{color = "#ecf5ff";}
									else if (color=="#ecf5ff")
									{color = "#ffffff";}

								%>
                <tr bgcolor="<%= color %>">
									<td valign="top" width="10">
										<if:IfTrue cond='<%= ((String)pageContext.getAttribute("transectMethod")).trim().equals(surveyTransectMethodBean.getTransectMethod()) %>' >
											<input type="radio" id="<sql:getColumn position="1" />" name="transectMethod"  value="<sql:getColumn position="1" />"  checked="checked" />
										</if:IfTrue>
										<if:IfTrue cond='<%= !(((String)pageContext.getAttribute("transectMethod")).trim().equals(surveyTransectMethodBean.getTransectMethod())) %>' >
											<input type="radio" id="<sql:getColumn position="1" />" name="transectMethod"  value="<sql:getColumn position="1" />" />
										</if:IfTrue>
									</td>
									<td valign="top">
										<label for="<sql:getColumn position="1" />"><sql:getColumn position="2" /></label>
									</td>
								</tr>
							</sql:resultSet>
							<sql:wasEmpty>
								<tr>
									<td colspan="3">
										<b>No Measurement Methods Available</b>
									</td>
								</tr>
							</sql:wasEmpty>
						</sql:statement>
					<sql:closeConnection conn="con"/>

				</table>
			</td></tr>
		</table>

    <jsp:include page="include/back_continue_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="surveyTransectMethod" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
