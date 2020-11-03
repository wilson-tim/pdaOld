<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <script type="text/javascript" src="http://localhost:5151/gps"></script>
  <script type="text/javascript">
    function update() {
      document.forms[0].elements["testJS"].value = "JavaScript Works";
      document.forms[0].elements["gpsLat"].value = gpsLat;
      document.forms[0].elements["gpsLng"].value = gpsLng;
    }
  </script>
</head>

<body onUnload="" onLoad="update()">
  <form action="testBrowser.jsp" method="post">
    <b>JPEG Image</b></br>
    <img src="images/test-browser.jpg" /></br>
    </br>
    <b>PNG Image</b></br>
    <img src="images/test-browser.png" /></br>
    </br>
    <b>JavaScript Test</b></br>
    <input type="text" name="testJS" id="testJS" value="JavaScript Failed" /></br>
    </br>
    <b>GPS Values from http://localhost:5151/gps</b></br>
    gpsLat</br>
    <input type="text" name="gpsLat" value="Failed" /></br>
    gpsLng</br>
    <input type="text" name="gpsLng" value="Failed" />
  </form>
</body>
</html>
