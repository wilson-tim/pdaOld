<%@ page errorPage="error.jsp" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>

<!-- Disable the browser back button -->
<script>window.history.go(1);</script>

<%-- Indicate which form we are in/just-come-from --%>
<sess:setAttribute name="input">index</sess:setAttribute>

<%-- Indicate which form we are going to next --%>
<sess:setAttribute name="form">reqform</sess:setAttribute>

<%-- The user is sent to the home form --%>
<jsp:forward page="reqformScript.jsp" />

<html>
<head>
  <title>Pharaoh|WEB</title>
</head>

<body>
  
</body>
</html>