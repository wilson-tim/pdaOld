<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.townWardenBean, com.vsb.lookupSite1Bean" %>
<%@ page import="com.db.*, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="townWardenBean" scope="session" class="com.vsb.townWardenBean" />
<jsp:useBean id="lookupSite1Bean" scope="session" class="com.vsb.lookupSite1Bean" />
<jsp:useBean id="pageSet" scope="session" class="com.db.PageSet" />

<!-- Disable the browser back button -->
<script>window.history.go(1);</script>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="lookupSite1" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<html>
<head>
  <meta http-equiv="Refresh" content="<app:initParameter name="refreshInterval"/>" >
	<title>lookupSite1</title>
  <style type="text/css">
		@import URL("global.css");
	</style>
</head>

<body>
  <form action="lookupSite1Script.jsp" method="post">
  	<table width="240">
  		<tr height="40">
    		<td bgcolor="#259225" align="center">
  				<h2><font color="white"><b>Site Lookup</b></font>
  			</td>
  		</tr>
  		<tr><td><hr size="2" noshade></td></tr>
  		<tr><td><font color="#ff6565"><b><jsp:getProperty name="lookupSite1Bean" property="error" /></b></font></td></tr>
  		<tr><td><hr size="2" noshade></td></tr>
  	</table>
  	<jsp:include page="include/rowset_nav_buttons.jsp" flush="true" />
		<table width="240">
		  <tr>
  			<td colspan="2">
  			  <font size="-1">sites <%= pageSet.getMinRecordInPage() %> - <%= pageSet.getMaxRecordInPage() %> of <%= pageSet.getRecordCount() %></font>
  		  </td>
    	</tr>
		
    	<%-- Show all the sites matching the search criteria --%>
    	<%-- select site_ref, site_name_1 --%>
      <%-- from site --%>
      <%-- where ... --%>
     
      <% Page thePage = pageSet.getCurrentPage(); %>
      <% while (thePage.next()) { %>
			<tr>
				<td>
				  <if:IfTrue cond='<%= thePage.getField(1).equals(lookupSite1Bean.getSite_ref()) %>' >
            <input type="radio" name="site_ref"  value="<%= thePage.getField(1) %>"  checked="checked">
          </if:IfTrue>
          <if:IfTrue cond='<%= !(thePage.getField(1).equals(lookupSite1Bean.getSite_ref())) %>' >
            <input type="radio" name="site_ref"  value="<%= thePage.getField(1) %>">
          </if:IfTrue>
				</td>
				<td>
				  <%= thePage.getField(2) %>
				</td>
			</tr>
			<tr><td colspan="2"><hr size="1" noshade></td></tr>
			<% } %>
			
			<%-- If there are no sites found --%>
			<if:IfTrue cond='<%= pageSet.getRecordCount() == 0 %>' >
			  <tr>
	   	    <td colspan="2">
	   	      <b>No sites available</b>
	   	    </td>
	   	  </tr>
			</if:IfTrue>
			
   	  <tr>
  			<td colspan="2">
  			  <font size="-1">sites <%= pageSet.getMinRecordInPage() %> - <%= pageSet.getMaxRecordInPage() %> of <%= pageSet.getRecordCount() %></font>
  		  </td>
    	</tr>
	  </table>

    <jsp:include page="include/rowset_nav_buttons.jsp" flush="true" />	  
    <jsp:include page="include/back_submit_buttons.jsp" flush="true" />
    <jsp:include page="include/footer.jsp" flush="true" />
	  <input type="hidden" name="input" value="lookupSite1" >
  </form>
</body>
</html>
