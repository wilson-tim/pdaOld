<%@ page import="java.util.*" %>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jstl/fmt" prefix="fmt" %>
<%--
<%@ taglib uri="http://www.servletsuite.com/servlets/barcodetag" prefix="b" %>
--%>

<jsp:useBean id="now" class="java.util.Date" />

<fmt:setTimeZone var="timeZone" value="Europe/London" />

<head>
  <title>islington_fpn_print</title>
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
        <c:out value="${param.fpn_ref}" />&nbsp;
      </td>
    </tr>
    <tr>
      <td>
        <c:out value="${param.cn_number}" />&nbsp;
      </td>
    </tr>
    <tr>
      <td>
        <c:out value="${param.aut_officer}" />&nbsp;
      </td>
    </tr>
    <tr>
      <td>
        <c:out value="${param.title}" />&nbsp;
      </td>
    </tr>
    <tr>
      <td>
        <c:out value="${param.surname}" />&nbsp;
      </td>
    </tr>
    <tr>
      <td>
        <c:out value="${param.fstname}" />
        <c:if test="${not empty param.midname}">
          , <c:out value="${param.midname}" />
        </c:if>
        &nbsp;
      </td>
    </tr>
    <tr>
      <td>
        <c:out value="${param.dob}" />&nbsp;
      </td>
    </tr>
    <tr>
      <td>
        <c:out value="${param.company_name}" />&nbsp;
      </td>
    </tr>
    <tr>
      <td>
        <c:out value="${param.build_name}" />&nbsp;
      </td>
    </tr>
    <tr>
      <td>
        <c:if test="${not empty param.build_no}">
          <c:out value="${param.build_no}" />&nbsp;
        </c:if>
        <c:if test="${not empty param.addr1}">
          <c:out value="${param.addr1}" />
        </c:if>
        &nbsp;
      </td>
    </tr>
    <tr>
      <td>
        <c:out value="${param.postcode}" />&nbsp;
      </td>
    </tr>
    <tr>
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
        <c:out value="${param.offence_date}" />&nbsp;
      </td>
    </tr>
    <tr>
      <td>
        <c:out value="${param.exact_location}" />&nbsp;
      </td>
    </tr>
    <tr>
      <td>
        <div style="font-size: 85%"><c:out value="${param.offence_desc}" /></div>&nbsp;
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td class="page_gap">&nbsp;<td>
    </tr>
    <tr>
      <td align="center">
        <img src="fpn_print_pages/images/islington-logo.gif" alt="Islington" />
      </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>
      <td align="center">
        <b><c:out value="${param.fpn_ref}" /> - <c:out value="${param.cn_number}" /></b>&nbsp;
      </td>
    </tr>
    <tr>
      <td align="center">
        <b><u>Remittance Slip</u></b>
      </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>
      <td align="center">
        Please submit/send this slip</br>
        with your payment.
      </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>
      <td>
        <b>Date of Issue: </b><fmt:formatDate type="date" pattern="${initParam.view_date_fmt}" 
          value="${now}" timeZone="${timeZone}" />
      </td>
    </tr>
    <tr>
      <td>
        <c:out value="${param.title} " />
        <c:out value="${param.fstname}" />
        <c:if test="${not empty param.midname}">
          , <c:out value="${param.midname}" />
        </c:if>
        <c:out value=" ${param.surname}" />
        &nbsp;
      </td>
    </tr>
    <tr>
      <td>
        <c:out value="${param.company_name}" />&nbsp;
      </td>
    </tr>
    <tr>
      <td>
        <c:out value="${param.exact_location}" />&nbsp;
      </td>
    </tr>
    <tr>
      <td>
        <b>Full Charge: </b><c:out value="${param.full_charge}" />
      </td>
    </tr>
    <tr>
      <td>
        <b>Discount Charge: </b><c:out value="${param.discount_charge}" />
      </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <%--
    <tr>
      <td align="center">
        <b:Code39><c:out value="${param.fpn_ref}" /></b:Code39>
      </td>
    </tr>
    --%>
  </table>
</body>
</html>
