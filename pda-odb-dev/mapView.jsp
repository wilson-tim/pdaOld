<%@ page errorPage="error.jsp" %>
<%@ page import="javax.naming.*, com.vsb.mapBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="mapBean" scope="session" class="com.vsb.mapBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="map" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<app:equalsInitParameter name="use_xhtml" match="Y">
  <html xmlns="http://www.w3.org/1999/xhtml">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <html>
</app:equalsInitParameter>
<head>
  <!-- Set iPhone OS Safari attributes -->
  <meta name = "viewport" content = "width = device-width">

  <%-- Stop the browser from caching the page --%>
  <meta http-equiv="Cache-Control" content="no-cache"/>
  <meta http-equiv="Pragma" content="no-cache"/>
  <%-- Stop any proxy servers from caching the page --%>
  <% response.addHeader("Cache-Control", "no-cache"); %>

  <meta http-equiv="Refresh" content="<app:initParameter name="refreshInterval"/>" />
  <app:equalsInitParameter name="use_xhtml" match="Y">
    <meta http-equiv="Content-Type" content="application/xhtml+xml" />
    <% response.setContentType("application/xhtml+xml"); %>
  </app:equalsInitParameter>
  <app:equalsInitParameter name="use_xhtml" match="Y" value="false">
    <meta http-equiv="Content-Type" content="text/html" />
  </app:equalsInitParameter>
  <title>map</title>
  <style type="text/css">
    @import url("global.css");
  </style>
  <!-- Allow user to click on the map image to get new easting and northing -->
  <script type="text/javascript">
    <!-- Begin
    
    var tempX  = 0;         //temporary mouse x coord
    var tempY  = 0;         //temporary mouse y coord
    var imgX   = 0;         //top left corner of image x coord
    var imgY   = 0;         //top left corner of image y coord
    var height = 0;         //height of currently selected image
    var width  = 0;         //width of currently selected image
    var centreX= 0;         //images centre x coord
    var centreY= 0;         //images centre y coord
    var disX   = 0;         //displacement of the mouse in x-axis from the centre of image
    var disY   = 0;         //displacement of the mouse in y-axis from the centre of image
    var IE = document.all?true:false;       //check if this is IE

    //run getMouseXY when the mouse moves
    if (!IE) document.captureEvents(Event.MOUSEMOVE)
      document.onmousemove = getMouseXY;
    
    //run clickHandler when mouse button is pressed
    if (document.layers) {
      document.captureEvents(Event.MOUSEDOWN);
      document.onmousedown = clickHandler;
    }else{
      document.onclick = clickHandler;
    }
    
    /*********************************************************
    * Function getMouse resolves the mouses current position
    * within the browser window for most browsers. These values
    * are stored in tempX and tempY and then displayed in the
    * form.
    */
    function getMouseXY(e) {
      if (IE) { // grab the x-y pos.s if browser is IE
        tempX = event.clientX + document.body.scrollLeft;
        tempY = event.clientY + document.body.scrollTop;
      } else {  // grab the x-y pos.s if browser is NS
        tempX = e.pageX;
        tempY = e.pageY;
      }  

      if (tempX < 0){tempX = 0;}
      if (tempY < 0){tempY = 0;}  
      
      return true;
    }

    /**********************************************************
    * Function clickHandler checks to see if an image has been
    * selected within the browser window. If so it retrieves
    * the images height and width, the images top left corner
    * or position, and then goes on to calculate the images
    * and the mouses displacement from the centre of the image
    */
    function clickHandler (evt) {
      if (document.layers) {
        if (evt.target.constructor == Image) {
          width= evt.target.width;
          height= evt.target.height;
          imgX = evt.target.x;
          imgY = evt.target.y;

          centreX = imgX + (width/2);
          centreY = imgY + (height/2);
          disX    = tempX - centreX;
          disY    = tempY - centreY;
          document.view.XWorldCenter.value = (disX * document.view.zoom.value) 
                                           + (document.view.XWorldCenter.value * 1);
          document.view.YWorldCenter.value = ((disY * document.view.zoom.value) * -1) 
                                           + (document.view.YWorldCenter.value * 1);
          // Submit form
          document.view.submit();
        }        
      } else if (document.all) {
        if (event.srcElement.tagName == 'IMG') {
          width  = event.srcElement.width
          height = event.srcElement.height
          imgX = event.srcElement.offsetLeft;
          imgY = event.srcElement.offsetTop;

          centreX = imgX + (width/2);
          centreY = imgY + (height/2);
          disX    = tempX - centreX;
          disY    = tempY - centreY;
          document.view.XWorldCenter.value = (disX * document.view.zoom.value) 
                                           + (document.view.XWorldCenter.value * 1);
          document.view.YWorldCenter.value = ((disY * document.view.zoom.value) * -1) 
                                           + (document.view.YWorldCenter.value * 1);
          // Submit form
          document.view.submit();
        }        
      } else if (document.getElementById) {
        if (evt.target.tagName == 'IMG') {
          width= evt.target.width;
          height= evt.target.height;                
          imgX = evt.target.offsetLeft;
          imgY = evt.target.offsetTop;
          
          centreX = imgX + (width/2);
          centreY = imgY + (height/2);
          disX    = tempX - centreX;
          disY    = tempY - centreY;
          document.view.XWorldCenter.value = (disX * document.view.zoom.value) 
                                           + (document.view.XWorldCenter.value * 1);
          document.view.YWorldCenter.value = ((disY * document.view.zoom.value) * -1) 
                                           + (document.view.YWorldCenter.value * 1);
          // Submit form
          document.view.submit();
        }        
      }

      return true;
    }
    
    //  End -->
  </script>
  <!-- Make all submit buttons single click only -->
  <script type="text/javascript">
    var allowed = true;
    function singleclick() {
      if (allowed == true ) {
        allowed = false;
        return true;
      } else {
        return false;
      }
    }
  </script>
</head>

<body onLoad="window.history.go(1);" onUnload="">
  <form onSubmit="return singleclick();" action="mapScript.jsp" method="post" name="view">
    <table width="100%">
      <tr height="40">
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Map</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="mapBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>

    <%
      // obtain the initial context, which holds the server/web.xml environment variables.
      Context initCtx = new InitialContext();
      Context envCtx = (Context) initCtx.lookup("java:comp/env");

      // Put all values that are going to be used in the <c:import ...> call, into the pageContext
      // So that the <c:import ...> tag can access them. All others into variables.
      String map_service = (String)envCtx.lookup("map_service");
      String map_type = (String)envCtx.lookup("map_type");
      String xPixels = (String)envCtx.lookup("x_pixels");
      String yPixels = (String)envCtx.lookup("y_pixels");
      String show_map_type = (String)envCtx.lookup("show_map_type");
      String zoom = mapBean.getZoom();
    %>

    <%-- Setup the different zoom rounding for the different map types --%>
    <if:IfTrue cond='<%= map_type.equals("cartology") || map_type.equals("WMS") %>' >
      <% zoom = String.valueOf(helperBean.roundDouble((new Double(zoom)).doubleValue(),1)); %>
    </if:IfTrue>
    <if:IfTrue cond='<%= map_type.equals("googleMaps") || map_type.equals("multimap") %>' >
      <% zoom = String.valueOf(Math.round((new Double(zoom)).doubleValue())); %>
    </if:IfTrue>

    <img width="<%= xPixels %>" height="<%= yPixels %>" alt="No map data available" 
         src='<%= map_service + 
             "?E=" + mapBean.getXWorldCenter() +
             "&N=" + mapBean.getYWorldCenter() +
             "&Z=" + zoom +
             "&X=" + xPixels +
             "&Y=" + yPixels +
             "&M=" + show_map_type %>' />
    <if:IfTrue cond='<%= map_type.equals("multimap") %>' >
      <br/>
      <a href="http://clients.multimap.com/about/legal_and_copyright/">Terms of use</a>
    </if:IfTrue>

    <table width="100%">
      <tr>
        <td>
          <table>
            <tr>
              <td valign="middle">
                <input type="submit" name="action" value="&lt;"
                  style="color: black; font-weight: bold; font-size: 85%" />
              </td>
              <td align="center">
                <input type="submit" name="action" value="Up"
                  style="width: 5em; color: black; font-weight: bold; font-size: 85%" /><br/>
                <input type="submit" name="action" value="Down"
                  style="width: 5em; color: black; font-weight: bold; font-size: 85%" />
              </td>
              <td valign="middle">
                <input type="submit" name="action" value="&gt;"
                  style="color: black; font-weight: bold; font-size: 85%" />
              </td>
            </tr>
            <tr>
              <td>
                <input type="submit" name="action" value="+"
                  style="color: black; font-weight: bold; font-size: 85%" />
              </td>
              <td align="center">
                <b><%= mapBean.getZoom() %></b>
              </td>
              <td>
                <input type="submit" name="action" value="-"
                  style="color: black; font-weight: bold; font-size: 85%" />
              </td>
           </tr>
          </table>
        </td>
      </tr>
      <tr><td><hr size="1" noshade="noshade" /></td></tr>
      <%-- Eastings --%>
      <tr>
        <td><b>Easting:</b></td>
      </tr>
      <tr>
        <td>
          <input type="text" name="XWorldCenter" value="<%= mapBean.getXWorldCenter() %>" />
        </td>
      </tr>
      <%-- Northings --%>
      <tr>
        <td><b>Northing:</b></td>
      </tr>
      <tr>
        <td>
          <input type="text" name="YWorldCenter" value="<%= mapBean.getYWorldCenter() %>" />
        </td>
      </tr>
      <%-- Zoom metre(s)/pixel --%>
      <tr>
        <td><b>Zoom:</b></td>
      </tr>
      <tr>
        <td>
          <input type="text" name="zoom" value="<%= mapBean.getZoom() %>" />
        </td>
      </tr>
    </table>
    <%-- Do not show the submit button if no map is displayed --%>
     <jsp:include page="include/submit_button.jsp" flush="true" />
    <tr><td><hr size="1" noshade="noshade" /></td></tr>
    <jsp:include page="include/back_capture_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="map" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />

    <%-- This must be the last tag before the closing form tag. --%>
    <%-- This is a hidden action, and will be used as the action --%>
    <%-- if no user action is submitted (ie. via a button press). --%>
    <%-- This allows the javaScript submit to work correctly. --%>
    <input type="hidden" name="action" value="JSubmit" />
  </form>
</body>
</html>
