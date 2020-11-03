<%@ page import="java.util.*" %>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jstl/fmt" prefix="fmt" %>

<jsp:useBean id="now" class="java.util.Date" />

<fmt:setTimeZone var="timeZone" value="Europe/London" />

<head>
  <title>fpn_print</title>
  <style type="text/css">
    @import URL("../global.css");
  </style>
  <!-- Disable the browser back button -->
  <script type="text/javascript">window.history.go(1);</script>
</head>

<body onUnload="">
  <table>
    <tr>
      <td>
        <b>Fpn</b>
      </td>
      <td>
        <c:out value="${param.fpn_ref}" />
      </td>
    </tr>
    <tr>
      <td>
        <b>Date of Issue</b>
      </td>
      <td>
        <fmt:formatDate type="date" pattern="${initParam.view_date_fmt}" 
          value="${now}" timeZone="${timeZone}" />
      </td>
    </tr>
    <tr>
      <td>
        <b>Complaint No.</b>
      </td>
      <td>
        <c:out value="${param.complaint_no}" />
      </td>
    </tr>
    <tr>
      <td>
        <b>Exact Location</b>
      </td>
      <td>
        <c:out value="${param.exact_location}" />
      </td>
    </tr>
    <tr>
      <td>
        <b>Offence Ref.</b>
      </td>
      <td>
        <c:out value="${param.offence_ref}" />
      </td>
    </tr>
    <tr>
      <td>
        <b>Offence Desc.</b>
      </td>
      <td>
        <c:out value="${param.offence_desc}" />
      </td>
    </tr>
    <tr>
      <td>
        <b>Offence Date</b>
      </td>
      <td>
        <c:out value="${param.offence_date}" />
      </td>
    </tr>
    <tr>
      <td>
        <b>Offence Time</b>
      </td>
      <td>
        <c:if test="${param.offence_time == ':'}">
          &nbsp;
        </c:if>
        <c:if test="${param.offence_time != ':'}">
          <c:out value="${param.offence_time}" />
        </c:if>
      </td>
    </tr>
    <tr>
      <td>
        <b>Authorizing Officer</b>
      </td>
      <td>
        <c:out value="${param.aut_officer}" />
      </td>
    </tr>
    <tr>
      <td>
        <b>Title</b>
      </td>
      <td>
        <c:out value="${param.title}" />
      </td>
    </tr>
    <tr>
      <td>
        <b>Surname</b>
      </td>
      <td>
        <c:out value="${param.surname}" />
      </td>
    </tr>
    <tr>
      <td>
        <b>Firstname</b>
      </td>
      <td>
        <c:out value="${param.fstname}" />
      </td>
    </tr>
    <tr>
      <td>
        <b>Midname</b>
      </td>
      <td>
        <c:out value="${param.midname}" />
      </td>
    </tr>
    <tr>
      <td>
        <b>Date of Birth</b>
      </td>
      <td>
        <c:out value="${param.dob}" />
      </td>
    </tr>
    <tr>
      <td>
        <b>Building No.</b>
      </td>
      <td>
        <c:out value="${param.build_no}" />
      </td>
    </tr>
    <tr>
      <td>
        <b>Building Name</b>
      </td>
      <td>
        <c:out value="${param.build_name}" />
      </td>
    </tr>
    <tr>
      <td>
        <b>Address Line 1</b>
      </td>
      <td>
        <c:out value="${param.addr1}" />
      </td>
    </tr>
    <tr>
      <td>
        <b>Address Line 2</b>
      </td>
      <td>
        <c:out value="${param.addr2}" />
      </td>
    </tr>
    <tr>
      <td>
        <b>Address Line 3</b>
      </td>
      <td>
        <c:out value="${param.addr3}" />
      </td>
    </tr>
    <tr>
      <td>
        <b>Postcode</b>
      </td>
      <td>
        <c:out value="${param.postcode}" />
      </td>
    </tr>
    <tr>
      <td>
        <b>Company Name</b>
      </td>
      <td>
        <c:out value="${param.company_name}" />
      </td>
    </tr>
  </table>
</body>
</html>
