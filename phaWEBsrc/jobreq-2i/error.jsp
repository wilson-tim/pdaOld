<%@ page isErrorPage="true" %>

<!-- Disable the browser back button -->
<script>window.history.go(1);</script>

<html>

<head>
  <title>Pharaoh|WEB - Error report</title>
  <STYLE>
    <!--
      H1{font-family : sans-serif; color : white;background-color : #259225;}
      BODY{font-family : sans-serif; color : black;background-color : white;}
      B{color : white; background-color : #259225;}
      HR{color : #259225;}
    -->
  </STYLE>
</head>

<body>
  <h1>Pharaoh|WEB - Error</h1>
  <HR size="1" noshade>
  <br>
  <b>Error</b>
  <br>
  <br>
  <%= exception.toString() %>
  <br>
  <br>
  <HR size="1" noshade>
</body>
</html>