<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/datetime-1.0" prefix="date" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
  <meta http-equiv="Refresh" content="300" >
  <title>inspListReport</title>
  <style type="text/css">
    @import URL("global.css");
  </style>
</head>

<body onUnload="">
  <form action="inspListReport.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Insp List Report</b></font></h2>
        </td>
      </tr>
      <tr><td>&nbsp;</td></tr>
    </table>
    <% String color="#ffffff"; %>
    <% int counter = 0; %>
    <table width="100%">
      <tr>
        <td colspan="2">
          <b>The Top 500 Insp List Report at:</b>
          <date:format pattern="E dd/MM/yyyy h:mm a">
            <date:currentTime />
          </date:format>
          <br>
        </td>
      </tr>
      <tr><td colspan="2">&nbsp;</td></tr>
      <tr>
        <td><b>Complaint_no</b></td>
        <td><b>User_name</b></td>
      </tr>
      <%-- Open the database --%>
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
        <sql:query>
          select complaint_no, user_name
          from insp_list
	  where state = 'A'
          order by complaint_no desc, user_name asc
        </sql:query>
        <sql:resultSet id="rset">
          <%-- Do limit through counting --%>
          <% counter++; %>
          <if:IfTrue cond='<%= counter <= 500 %>'>
            <%
              if(color=="#ffffff") {
                color = "#ecf5ff";
              } else if (color=="#ecf5ff") {
                color = "#ffffff";
              }
            %>
            <tr bgcolor="<%= color %>" >
              <td>
                <sql:getColumn position="1" />
              </td>
              <td>
                <sql:getColumn position="2" />
              </td>
            </tr>
          </if:IfTrue>
        </sql:resultSet>
        <sql:wasEmpty>
          <tr>
           <td colspan="2">
             <b>No records available</b>
           </td>
         </tr>
        </sql:wasEmpty>
        <sql:wasNotEmpty>
          <tr>
            <td colspan="2">
              <span class="subscript">Top 500 of <sql:rowCount /> record(s)</span>
            </td>
          </tr>
        </sql:wasNotEmpty>
      
      <%-- Close the database --%>
      </sql:statement>
      <sql:closeConnection conn="con"/>
      
    </table>
    <jsp:include page="include/refresh_button.jsp" flush="true" />
    <jsp:include page="include/footer.jsp" flush="true" />
  </form>
</body>
</html>
