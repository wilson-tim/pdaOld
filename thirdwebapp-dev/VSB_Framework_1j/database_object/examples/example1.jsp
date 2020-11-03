
<%@ page import="com.db.DbSQL, com.db.RowSet, javax.sql.*, java.util.*" %>

<%-- used for checking the existence of the DbSQL object --%>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>

<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>

<jsp:useBean id="Records" scope="session" class="com.db.RowSet" />

<%-- Create a session instance of the Records object --%>
<%-- and populate it from the database if it currently holds no records --%>
<if:IfTrue cond='<%= Records.getRecordCount() == 0 %>' >
  <%-- Connect to the database using the context and datasource --%>
  <% DbSQL dbCon = new DbSQL(); %>
  <% dbCon.connect("java:comp/env", "jdbc/pda"); %>
  
  <%-- Run a query --%>
  <% java.sql.ResultSet rs = dbCon.query("select * from comp_import"); %>
  <%-- populate the RowSet from the ResultSet --%>
  <% Records.setRowSet(rs); %>
  
  <%-- close the ResultSet and disconnect from the database --%>
  
  <%-- Run a query --%>
  <% rs = dbCon.query("select * from comp_import where import_key = 1"); %>
  <%-- populate the RowSet from the ResultSet --%>
  <% Records.addToRowSet(rs); %>
  
  <%-- close the ResultSet and disconnect from the database --%>
  <% rs.close(); %>
  <% dbCon.disconnect(); %>
</if:IfTrue>

<b>Record No. <%= Records.getCurrentRecord() %> of <%= Records.getRecordCount() %></b><br>
<b>As Record : </b><%= Records.getRecord() %><br>
<br>
<b>As Fields : </b>
<% 
  for (int fld = 1; fld <= Records.getFieldCount(); fld++) {
%>
    <%= Records.getField(fld) %> |
<%
  }
%>

<if:IfTrue cond='<%= Records.getCurrentRecord() == Records.getRecordCount() %>' >
  <% Records.clear(); %>
</if:IfTrue>

<if:IfTrue cond='<%= Records.getRecordCount() != 0 %>' >
  <% Records.next(); %>
</if:IfTrue>

