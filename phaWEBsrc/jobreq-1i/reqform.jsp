<%@ page errorPage="error.jsp" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/datetime-1.0" prefix="date" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>

<%-- Create unique ID --%>
<sess:session id="ss"/>
<sess:setAttribute name="uniqueId"><jsp:getProperty name="ss" property="sessionId"/><date:currentTime/></sess:setAttribute>

<%-- Open the database via the jndi connection pool --%>
<sql:connection id="con" jndiName="java:comp/env/jdbc/pharaoh" />

<html>
<head>
  <title>Pharaoh - Request logging</title>
  <jsp:include page="style-include.jsp" flush="true" />
</head>

<body>

  <form action="controller.jsp" method="post">
  
    <table>
    <tr>
      <td align="center" colspan="2"><h1>Request Logging Form</h1></td>
    </tr>
    <tr>
      <td bgcolor="#259225" colspan="2">&nbsp;</td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>
      <td colspan="2">
        <b>
          All
          <req:equalsParameter name="formCorrect" match="false">
            <font color="#ff6565">RED</font>
          </req:equalsParameter>
          fields below must be filled in
        </b>
        <req:equalsParameter name="noAsset" match="true">
          <br>
          <b>The <font color="#ff6565">Asset Id</font> does not exist please use another one</b>
        </req:equalsParameter>
      </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr bgcolor="<req:parameter name="userNameError" />">
      <td><b>Name:</b></td>
      <td>
        <input type="text" name="userName" maxlength="30" size="30" value="<req:parameter name="userName" />">
      </td>
    </tr>
    <tr bgcolor="<req:parameter name="userContactError" />">
      <td><b>Contact No.:</b></td>
      <td>
        <input type="text" name="userContact" maxlength="15" size="15" value="<req:parameter name="userContact" />">
      </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr bgcolor="<req:parameter name="assetIdError" />">
      <td><b>Asset ID:</b></td>
      <td>
        <input type="text" name="assetId" maxlength="6" size="6" value="<req:parameter name="assetId" />">
      </td>
    </tr>
    <tr>
      <td><b>Job Type:</b></td>
      <td>
        <select name="jobType">
          <%-- Get the list of job types --%>
          <sql:statement id="stmt" conn="con">
            <sql:query>
              select job_type_code, descript from jb_type
            </sql:query>
            <sql:resultSet id="rset">
              <%-- Create the option list --%>
              <sql:getColumn position="1" to="jobTypeMatch" />
              <if:IfParameterEquals name="jobType" value='<%=(String)pageContext.getAttribute("jobTypeMatch")%>' >
                <option value="<sql:getColumn position="1" />" selected>
                  <sql:getColumn position="1" /> | <sql:getColumn position="2" />
                </option>
              </if:IfParameterEquals>
              <if:IfParameterNotEquals name="jobType" value='<%=(String)pageContext.getAttribute("jobTypeMatch")%>' >
                <option value="<sql:getColumn position="1" />" >
                  <sql:getColumn position="1" /> | <sql:getColumn position="2" />
                </option>
              </if:IfParameterNotEquals>
            </sql:resultSet>
            <%-- Unlock jb_type as the dbtags lock the records found with a select query --%>
            <sql:query>
              unlock jb_type
            </sql:query>
            <sql:execute />
          </sql:statement>
        </select>
      </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr bgcolor="<req:parameter name="problemDetailsError" />">
      <td><b>Problem<br>Details:</b></td>
      <td>
        <input type="text" name="problemDetails" maxlength="50" size="50" value="<req:parameter name="problemDetails" />">
      </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>
      <td bgcolor="#259225" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2">
        <table>
          <tr>
            <td>
              <a href="reqform.jsp"><img src="pharaoh-arrow-web.gif" alt="back" border="0"></a>
            </td>
            <td>
              <b>New<br>Request</b>
            </td>
            <td>
              &nbsp;&nbsp;&nbsp;<input type="submit" value="Submit">
            </td>
          </tr>
        </table>
      </td>
    </tr>
    <jsp:include page="footer-include.jsp" flush="true" />
    </table>
    
    <input type="hidden" name="reqUniqueId" value="<sess:attribute name="uniqueId" />">
    
  </form>
  
</body>
</html>

<%-- Close the database --%>
<sql:closeConnection conn="con" />