<%@ page errorPage="error.jsp" %>
<%@ page import="com.db.DbUtils, com.vsb.helperBean, java.text.SimpleDateFormat, java.util.*" %>
<%@ page import="com.vsb.recordBean, com.vsb.compSampDetailsBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req"  %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if"   %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"      prefix="sql"  %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c"    %>

<jsp:useBean id="DbUtils"             scope="session" class="com.db.DbUtils" />
<jsp:useBean id="helperBean"          scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="recordBean"          scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="compSampDetailsBean" scope="session" class="com.vsb.compSampDetailsBean" />
 
<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="updatePositionRemarksFunc" value="false">
  updatePositionRemarksFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="updatePositionRemarksFunc">
  <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con1">

    <%-- Set up the remarks --%>
    <% String remarks_1 = ""; %>
    <% String remarks_2 = ""; %>
    <% String remarks_3 = ""; %>
  
    <%-- The text should be split into 70 char lines, and there should be a --%>
    <%-- single record for each line. --%>
    <% String tempRemarks = ""; %>

    <% tempRemarks = compSampDetailsBean.getRemarks().toUpperCase(); %>

    <%
      tempRemarks = tempRemarks.replace('\n',' ');
      tempRemarks = tempRemarks.replace('\r',' ');
  
      String allText = tempRemarks.trim();
      String line;
      int count = 1;
      int lineIndex;
      boolean flag = true;
      do {
        if (allText.length() <= 70) {
          line = allText;
          flag = false;
        } else {
          lineIndex = allText.lastIndexOf(" ", 70);
          // Space not found so use the whole 70
          if (lineIndex == -1) {
            lineIndex = 70;
          } else {
            lineIndex = lineIndex + 1;
          }
          line = allText.substring(0,lineIndex);
          allText = allText.substring(lineIndex);
        }

        if (count == 1) {
          remarks_1 = DbUtils.cleanString(line);
        } else if (count == 2) {
          remarks_2 = DbUtils.cleanString(line);
        } else if (count == 3) {
          remarks_3 = DbUtils.cleanString(line);
        }

        count = count + 1;
      } while (flag == true);
    %>

    <% String tempPosition = ""; %>
    <% tempPosition = recordBean.getExact_location().toUpperCase(); %>

    <%-- updateing complaint position and remarks --%>
    <sql:query>
      update comp
      set exact_location = '<%= tempPosition %>',
          details_1 = '<%= remarks_1 %>',
          details_2 = '<%= remarks_2 %>',
          details_3 = '<%= remarks_3 %>'
      where complaint_no = <%= recordBean.getComplaint_no() %>
    </sql:query>
    <sql:execute />

  </sql:statement>
  <sql:closeConnection conn="con1"/>
</sess:equalsAttribute>
