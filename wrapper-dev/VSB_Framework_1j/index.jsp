<%@ page errorPage="error.jsp" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<!-- Disable the browser back button -->
<script>window.history.go(1);</script>

<%-- Indicate which form we are in/just-come-from --%>
<sess:setAttribute name="input">index</sess:setAttribute>

<%-- Indicate which form we are going to next --%>
<sess:setAttribute name="form">login</sess:setAttribute>

<%-- The user is sent to the home form --%>
<c:redirect url="loginScript.jsp" />

<html>
<head>
  <title>VSB index</title>
</head>

<body>
  
</body>
</html>