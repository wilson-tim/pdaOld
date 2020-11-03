<%@ page errorPage="error.jsp" %>

<!-- Disable the browser back button -->
<script>window.history.go(1);</script>

<html>
<head>
  <title>Daemon Webapp</title>
</head>

<body>
   <b>Daemon webapp</b><br/><br/>
   <b>insp_list daemon:</b><br/>
   <a href="daemon/inspList" >View insp_list daemon status</a><br/><br/>

   <b>mon_list daemon:</b><br/>
   <a href="daemon/monList" >View mon_list daemon status</a><br/><br/>

   <b>con_sum_list daemon:</b><br/>
   <a href="daemon/conSumList" >View con_sum_list daemon status</a><br/><br/>   

   <b>enf_list daemon:</b><br/>
   <a href="daemon/enfList" >View enf_list daemon status</a><br/><br/>   
</body>
</html>
