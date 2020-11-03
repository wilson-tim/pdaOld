The idea is that the DbSQL class is instantiated via a JSP taglib and stored
in the session:

<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.DbSQL" %>

<jsp:useBean id="DbSQL" scope="session" class="com.vsb.DbSQL" />

The DbSQL object can then be used to for creating paged lookups into an SQL
query. This is because the DbSQL holds the ResultSet, returned from an SQL
query, in the session. This means that the ResultSet can be accessed between
pages. The DbSQL session object should be disconnected and removed from the
session when the user has finished with the query.

If the DbSQL object is not removed, or the user quits the application, then the
connection will stay active untill the session holding it times out. The
connection will then be cleaned up.

If possible, when the user logs back into the application they should be
reunited with the session they were using before they quit the application.

Example of using the DbSQL object for paging through a ResultSet. The first
time the page is looked at, a ResultSet is created. When the page is refreshed
or looked at again the same ResultSet as before is used but pointed to the
next record:

<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.DbSQL" %>

<%!-- used for checking the existence of the DbSQL object --%>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>

<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>

<%!-- Only create the DbSQL object if it doesn't already exist --%>
<sess:existsAttribute name="DbSQL" value="false">
  <%!-- Create a session instance of the DbSQL object --%>
  <jsp:useBean id="DbSQL" scope="session" class="com.vsb.DbSQL" />

  <%!-- Connect to the database using the context and datasource --%>
  <% DbSQL.connect("java:comp/env", "jdbc/pharaoh"); %>
  
  <%!-- Run a query --%>
  <% DbSQL.query("select * from ph_hist;"); %>
</sess:existsAttribute>

<%!-- The ResultSet has now been created, so this can now be interrorgated --%>
<% boolean temp = false; %>
<%!-- Get the next record --%>
<% temp = DbSQL.rs.next(); %>
<if:IfTrue cond='<%= temp %>' >
  <%!-- View the record --%>
  <%= DbSQL.rs.getString(1) %><br>
  <%= DbSQL.rs.getString(2) %><br>
  <%!-- etc... --%>
  <%!-- When this page is called again the ResultSet will be positioned --%>
  <%!-- ready for the next record --%>
</if:IfTrue>

<%!-- Remeber to remove the DbSQL object from the session after finished --%>
<%!-- using it, i.e. when come to the end of the ResultSet. --%>
<%!-- Alternativelty do this when the user moves to the next form in the forms script --%>
<if:IfTrue cond='<%= !temp %>' >
  <% DbSQL.rs.close(); %>
  <% DbSQL.disconnect(); %>
  <sess:removeAttribute name="DbSQL" />
</if:IfTrue>
